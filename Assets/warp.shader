Shader "Custom/warp"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("NormalMap", 2D) = "bump" {} // 노말맵을 받는 인터페이스 추가
        _RampTex ("RampTex", 2D) = "white" {} // ramp 맵을 받는 인터페이스 추가
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        // Diffuse Warping 기법을 구현하기 위한 커스텀라이팅 함수 warp 를 선언함.
        #pragma surface surf warp noambient // 환경광 제거

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _RampTex; // Diffuse Warping (Ramp Texture 라고도 부름)을 구현하기 위해 필요한 텍스쳐를 인터페이스에서 받아서 담을 변수

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;

            // UnpackNormal() 함수는 변환된 노말맵 텍스쳐 형식인 DXTnm 에서 샘플링해온 텍셀값 float4를 인자로 받아 float3 를 리턴해줌. -> 노말맵에서 추출한 노멀벡터 적용
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Alpha = c.a;
        }

        // Diffuse Warping 기법을 구현하기 위한 커스텀라이팅 함수
        float4 Lightingwarp(SurfaceOutput s, float3 lightDir, float atten) {
            float ndotl = dot(s.Normal, lightDir); // surf 함수에서 넘겨받은 노멀벡터와 조명벡터를 내적함.

            // 이번에는 ramp 텍스쳐 샘플링을 커스텀라이팅 함수에서 해줌.
            // 테스트삼아 (0.1, 0.1) 이라는 uv로 샘플링해봄 -> ramp 텍스쳐의 가장 어두운 단색으로 찍힘 
            // ((0, 0)으로 안해주는 이유는, 그런 극단적인 구석 부분의 uv는 0.999... 부분의 색깔이 묻어나올수도 있어서라고 함.) -> 이걸 방지하려면 텍스쳐 wrap mode 를 clamp 로 설정하면 된다고 함. p.419 참고
            // float4 ramp = tex2D(_RampTex, float2(0.7, 0.7)); 

            /*
                이처럼, 색상 띠 모양의 ramp 텍스쳐로부터 텍셀값을 샘플링해올 수 있다면,
                -1 ~ 1 사이의 내적값을 샘플링해올 때 사용할 uv좌표값으로 활용할 수 있지 않을까?

                내적값이 -1 ~ 1 사이의 범위이니까
                Half-Lambert 공식을 사용해서 0 ~ 1 사이의 값으로 맵핑시켜서 적용하는 것이지!

                왜냐하면, ramp 텍스쳐의 uv좌표도 결국에는 0 ~ 1 사이일테니까!

                이러한 아이디어에서 출발해서, uv좌표의 x컴포넌트는 맵핑된 0 ~ 1 사이의 내적값으로 주고,
                y컴포넌트는 0.5로 고정시켜서, ramp 텍스쳐의 가운데를 가로지르는 가로선 쪽에 분포된
                텍셀들만 샘플링해올 수 있도록 함.

                이렇게 함으로써, 
                내적값이 0에 가까운 부분(조명량이 많지 않은 어두운 부분)은 ramp 텍스쳐의 어두운 색깔을 샘플링해오고,
                내적값이 1에 가까운 부분(조명량을 많이 받는 밝은 부분)은 ramp 텍스쳐의 밝은 색깔을 샘플링해오겠지!

                이런 식으로, 노말벡터와 조명벡터의 내적값을 
                띠 모양의 텍스쳐로부터 샘플링해오는 uv좌표값으로 활용하는 기법을
                Diffuse Warping 이라고 함!
            */
            ndotl = ndotl * 0.5 + 0.5;
            float4 ramp = tex2D(_RampTex, float2(ndotl, 0.5));

            float4 final; // 최종 색상값을 담을 변수
            final.rgb = s.Albedo.rgb * ramp.rgb; // surf 에서 적용한 Albedo 맵의 색상과 ramp 맵에서 샘플링한 텍셀값을 곱해서 적용
            final.a = s.Alpha;

            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
