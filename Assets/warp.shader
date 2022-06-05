Shader "Custom/warp"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("NormalMap", 2D) = "bump" {} // �븻���� �޴� �������̽� �߰�
        _RampTex ("RampTex", 2D) = "white" {} // ramp ���� �޴� �������̽� �߰�
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        // Diffuse Warping ����� �����ϱ� ���� Ŀ���Ҷ����� �Լ� warp �� ������.
        #pragma surface surf warp noambient // ȯ�汤 ����

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _RampTex; // Diffuse Warping (Ramp Texture ��� �θ�)�� �����ϱ� ���� �ʿ��� �ؽ��ĸ� �������̽����� �޾Ƽ� ���� ����

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;

            // UnpackNormal() �Լ��� ��ȯ�� �븻�� �ؽ��� ������ DXTnm ���� ���ø��ؿ� �ؼ��� float4�� ���ڷ� �޾� float3 �� ��������. -> �븻�ʿ��� ������ ��ֺ��� ����
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Alpha = c.a;
        }

        // Diffuse Warping ����� �����ϱ� ���� Ŀ���Ҷ����� �Լ�
        float4 Lightingwarp(SurfaceOutput s, float3 lightDir, float atten) {
            float ndotl = dot(s.Normal, lightDir); // surf �Լ����� �Ѱܹ��� ��ֺ��Ϳ� �����͸� ������.

            // �̹����� ramp �ؽ��� ���ø��� Ŀ���Ҷ����� �Լ����� ����.
            // �׽�Ʈ��� (0.1, 0.1) �̶�� uv�� ���ø��غ� -> ramp �ؽ����� ���� ��ο� �ܻ����� ���� 
            // ((0, 0)���� �����ִ� ������, �׷� �ش����� ���� �κ��� uv�� 0.999... �κ��� ������ ����ü��� �־��� ��.) -> �̰� �����Ϸ��� �ؽ��� wrap mode �� clamp �� �����ϸ� �ȴٰ� ��. p.419 ����
            // float4 ramp = tex2D(_RampTex, float2(0.7, 0.7)); 

            /*
                ��ó��, ���� �� ����� ramp �ؽ��ķκ��� �ؼ����� ���ø��ؿ� �� �ִٸ�,
                -1 ~ 1 ������ �������� ���ø��ؿ� �� ����� uv��ǥ������ Ȱ���� �� ���� ������?

                �������� -1 ~ 1 ������ �����̴ϱ�
                Half-Lambert ������ ����ؼ� 0 ~ 1 ������ ������ ���ν��Ѽ� �����ϴ� ������!

                �ֳ��ϸ�, ramp �ؽ����� uv��ǥ�� �ᱹ���� 0 ~ 1 �������״ϱ�!

                �̷��� ���̵��� ����ؼ�, uv��ǥ�� x������Ʈ�� ���ε� 0 ~ 1 ������ ���������� �ְ�,
                y������Ʈ�� 0.5�� �������Ѽ�, ramp �ؽ����� ����� ���������� ���μ� �ʿ� ������
                �ؼ��鸸 ���ø��ؿ� �� �ֵ��� ��.

                �̷��� �����ν�, 
                �������� 0�� ����� �κ�(������ ���� ���� ��ο� �κ�)�� ramp �ؽ����� ��ο� ������ ���ø��ؿ���,
                �������� 1�� ����� �κ�(������ ���� �޴� ���� �κ�)�� ramp �ؽ����� ���� ������ ���ø��ؿ�����!

                �̷� ������, �븻���Ϳ� �������� �������� 
                �� ����� �ؽ��ķκ��� ���ø��ؿ��� uv��ǥ������ Ȱ���ϴ� �����
                Diffuse Warping �̶�� ��!
            */
            ndotl = ndotl * 0.5 + 0.5;
            float4 ramp = tex2D(_RampTex, float2(ndotl, 0.5));

            float4 final; // ���� ������ ���� ����
            final.rgb = s.Albedo.rgb * ramp.rgb; // surf ���� ������ Albedo ���� ����� ramp �ʿ��� ���ø��� �ؼ����� ���ؼ� ����
            final.a = s.Alpha;

            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
