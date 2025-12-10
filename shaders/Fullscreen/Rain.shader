Shader "Fullscreen/Rain"
{
    Properties
    {
        _Intensity ("Rain Intensity", Range(0, 1)) = 1
        _Distortion ("Distortion", Range(0, 1)) = 0.2
        _Speed ("Speed", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        ZWrite Off Cull Off ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D_X(_CameraOpaqueTexture); SAMPLER(sampler_CameraOpaqueTexture);

            float _Intensity;
            float _Distortion;
            float _Speed;

            struct Attributes {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings Vert (Attributes input)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                o.uv = input.uv;
                return o;
            }

            // Noise simples
            float hash(float2 p)
            {
                return frac(sin(dot(p, float2(23.1407, 2.6651))) * 43758.5453);
            }

            float rainNoise(float2 uv)
            {
                float drops = hash(uv * 120.0 + _Time.y * _Speed);
                return smoothstep(0.8, 1.0, drops); 
            }

            half4 Frag (Varyings i) : SV_Target
            {
                float2 uv = i.uv;

                float n = rainNoise(uv);

                float2 distortion = float2(0, -n * _Distortion);
                float2 duv = uv + distortion;

                float4 col = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, duv);

                // chuva branca leve
                col.rgb += n * _Intensity * 0.4;

                return col;
            }

            ENDHLSL
        }
    }
}
