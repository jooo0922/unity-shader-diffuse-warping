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

        // Diffuse Warping ����� �����ϱ� ���� Ŀ���Ҷ����� �Լ� warp �� ������.
        #pragma surface surf warp noambient // ȯ�汤 ����

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

        // Diffuse Warping ����� �����ϱ� ���� Ŀ���Ҷ����� �Լ�
        float4 Lightingwarp(SurfaceOutput s, float3 lightDir, float atten) {
            float ndotl = dot(s.Normal, lightDir); // surf �Լ����� �Ѱܹ��� ��ֺ��Ϳ� �����͸� ������.
            return ndotl;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
