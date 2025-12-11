Shader "Fullscreen/HeatWave"
{
    Properties
    {
        _Progress("Progress", Range(0,1)) = 1
        _Frequency("Wave Frequency", Range(1,50)) = 15
        _Amplitude("Wave Amplitude", Range(0,0.05)) = 0.008
        _NoiseStrength("Noise Strength", Range(0,0.05)) = 0.02
        _NoiseScale("Noise Scale", Range(1,500)) = 24
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Overlay" }
        ZWrite Off
        ZTest Always
        Cull Off
        Blend One Zero

        Pass
        {
            Name "HeatWaveNoisePass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            //----------------------------------------------------------------------
            // Fullscreen (SV_VertexID)
            //----------------------------------------------------------------------
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings Vert(uint vertexID : SV_VertexID)
            {
                Varyings o;
                o.positionCS = GetFullScreenTriangleVertexPosition(vertexID);
                o.uv = GetFullScreenTriangleTexCoord(vertexID);
                return o;
            }

            //----------------------------------------------------------------------
            // Camera
            //----------------------------------------------------------------------
            TEXTURE2D(_BlitTexture);
            SAMPLER(sampler_BlitTexture);

            float _Progress;
            float _Frequency;
            float _Amplitude;

            float _NoiseStrength;
            float _NoiseScale;

            //----------------------------------------------------------------------
            // Value Noise – rápido e custa pouco
            //----------------------------------------------------------------------
            float hash(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)),
                           dot(p, float2(269.5, 183.3)));
                return frac(sin(p.x + p.y) * 43758.5453123);
            }

            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash(i);
                float b = hash(i + float2(1,0));
                float c = hash(i + float2(0,1));
                float d = hash(i + float2(1,1));

                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(a, b, u.x) +
                       (c - a) * u.y * (1.0 - u.x) +
                       (d - b) * u.x * u.y;
            }

            //----------------------------------------------------------------------
            // Fragment Shader
            //----------------------------------------------------------------------
            float4 Frag(Varyings i) : SV_Target
            {
                float t = _Time.y;

                //------------------------------------------------------------------
                // Heat wave base sinusoidal
                //------------------------------------------------------------------
                float heat =
                    sin(i.uv.y * _Frequency + t * (1  * 3))
                    * _Amplitude * (1  * 3);

                //------------------------------------------------------------------
                // Noise-based distortion (wobbling heat)
                //------------------------------------------------------------------
                float2 nUV = i.uv * _NoiseScale + t * 0.5;
                float n = noise(nUV);

                float noiseDist = (n - 0.5) * _NoiseStrength * (1  * 5);

                //------------------------------------------------------------------
                // Combine distortions
                //------------------------------------------------------------------
                float distortion = (heat + noiseDist) *_Progress;

                float2 uvDistorted = i.uv;
                uvDistorted.x += distortion;

                float4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, uvDistorted);

                return col;
            }

            ENDHLSL
        }
    }

    FallBack Off
}
