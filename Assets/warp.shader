Shader "Custom/warp"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        // Diffuse Warping 기법을 구현하기 위한 커스텀라이팅 함수 warp 를 선언함.
        #pragma surface surf warp noambient // 환경광 제거

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }

        // Diffuse Warping 기법을 구현하기 위한 커스텀라이팅 함수
        float4 Lightingwarp(SurfaceOutput s, float3 lightDir, float atten) {
            float ndotl = dot(s.Normal, lightDir); // surf 함수에서 넘겨받은 노멀벡터와 조명벡터를 내적함.
            return ndotl;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
