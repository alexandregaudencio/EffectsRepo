Shader "Custom/FlatColorfullMetaballs2D"
{
    Properties
    {
        _MainTex ("Camera Texture", 2D) = "white" {}

        // ===== CAUSTIC =====
        _CausticColor ("Caustic Color", Color) = (0.3,0.3,0.3,1)
        _CausticOpacity ("Caustic Opacity", Range(0,1)) = 0.3
        _CausticThreshold ("Caustic Threshold", Range(0,1)) = 0.7
        _CausticPulseSpeed ("Caustic Pulse Speed", Range(0,5)) = 0.5
        _CausticPulseAmount ("Caustic Pulse Amount", Range(0,1)) = 0.5
        _CausticScale ("Caustic Scale", Range(0.1,100)) = 30
        _FusionBoost ("Fusion Boost", Range(0,3)) = 1.5
        _EdgeWidth ("Edge Width", Range(0.01,0.3)) = 0.01
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
        }

 Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        Cull Off
        ZTest LEqual
        Cull Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            // ===== METABALLS (INALTERADOS) =====
            int _MetaballCount;
            float3 _MetaballData[256];
            float4 _MetaballColorData[256]; 

            float _OutlineSize;
            float4 _InnerColor;
            float4 _OutlineColor;
            float _CameraSize;
            float _Alpha = 0.6;

            // ===== CAUSTIC =====
            float4 _CausticColor;
            float _CausticOpacity;
            float _CausticThreshold;
            float _CausticPulseSpeed;
            float _CausticPulseAmount;
            float _CausticScale;
            float _FusionBoost;
            float _EdgeWidth;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = v.uv;
                return o;
            }

            // ===== STABLE NOISE (SCREEN-NORMALIZED) =====
            float hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            float noise2D(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash21(i);
                float b = hash21(i + float2(1, 0));
                float c = hash21(i + float2(0, 1));
                float d = hash21(i + float2(1, 1));

                float2 u = f * f * (3 - 2 * f);
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            // ===== CAUSTIC (RESOLUTION & CAMERA INDEPENDENT) =====
            float CausticNoiseStable(float2 uv, float t)
            {
                // uv já está normalizado (0–1), não depende de câmera
                float2 p = uv * _CausticScale;

                float base = noise2D(p);
                float pulse = noise2D(p * 0.5 + t * _CausticPulseSpeed);

                float threshold =
                    _CausticThreshold +
                    (pulse - 0.5) * _CausticPulseAmount;

                return step(threshold, base);
            }

            float4 frag (Varyings i) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                // ===== METABALL FIELD =====
                float field = 0.0;
                float dist = 1.0;
                float4 colorAccum = float4(0,0,0,0);
                float colorWeight = 0.0;

                float2 screenUV = i.uv * _ScreenParams.xy;

                // for (int m = 0; m < _MetaballCount; ++m)
                // {
                //     float2 metaballPos = _MetaballData[m].xy;
                //     float d = distance(metaballPos, screenUV);
                //     float r = _MetaballData[m].z * _ScreenParams.y / _CameraSize;

                //     float influence = saturate(1.0 - d / r);
                //     field += influence;

                //     dist *= saturate(d / r);
                // }

                float maxInfluence = 0.0;
float3 dominantColor = _InnerColor.rgb;


                // for (int m = 0; m < _MetaballCount; ++m)
                // {
                //     float2 metaballPos = _MetaballData[m].xy;
                //     float d = distance(metaballPos, screenUV);
                //     float r = _MetaballData[m].z * _ScreenParams.y / _CameraSize;

                //     float influence = saturate(1.0 - d / r);

                //     field += influence;
                //     dist *= saturate(d / r);

                //     // ===== COLOR ACCUMULATION =====
                //     float4 c = _MetaballColorData[m];
                //     colorAccum += c * influence;
                //     colorWeight += influence;
                // }
                for (int m = 0; m < _MetaballCount; ++m)
                {
                    float2 metaballPos = _MetaballData[m].xy;
                    float d = distance(metaballPos, screenUV);
                    float r = _MetaballData[m].z * _ScreenParams.y / _CameraSize;

                    float influence = saturate(1.0 - d / r);

                    field += influence;
                    dist *= saturate(d / r);

                     if (influence > maxInfluence)
                    {
                        maxInfluence = influence;
                        dominantColor = _MetaballColorData[m].rgb;
                    }
                }



                float threshold = 0.5;
                float outlineThreshold = threshold * (1.0 - _OutlineSize);

                float4 metaballColor = (colorWeight > 0.0)
                    ? colorAccum / colorWeight
                    : _InnerColor; // fallback

                // float4 metaballCol =
                //     (dist > threshold) ? tex :
                //     ((dist > outlineThreshold) ? _OutlineColor : _InnerColor) * _Alpha;
                // float4 metaballCol =
                //     (dist > threshold) ? tex :
                //     ((dist > outlineThreshold) ? _OutlineColor : metaballColor) * _Alpha;
                float4 metaballCol =
                    (dist > threshold) ? tex :
                    ((dist > outlineThreshold) ? _OutlineColor : float4(dominantColor, 1.0)) * _Alpha;


                // ===== EDGE MASK (SÓ BORDA INTERNA) =====
                float inside = step(dist, threshold);
                float edge = smoothstep(threshold, threshold - _EdgeWidth, dist);
                edge *= inside;

                // ===== FUSION RESPONSE =====
                float fusion = saturate(field - 1.0);
                fusion = pow(fusion, 1.4) * _FusionBoost;

                // ===== CAUSTIC =====
                float caustic = CausticNoiseStable(i.uv, _Time.y);
                float causticMask = caustic * edge * fusion;

                float3 causticCol =
                    lerp(metaballCol.rgb, _CausticColor.rgb, causticMask);

                metaballCol.rgb =
                    lerp(metaballCol.rgb, causticCol, _CausticOpacity);

                return metaballCol;
            }
            ENDHLSL
        }
    }
}
