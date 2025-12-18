Shader "Custom/ColorfullMetaballs2D"
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
        _OutlineSize ("Outline Size", Range(0,0.5)) = 0.05
        _Alpha ("Alpha", Range(0,1)) = 0.6
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZWrite Off
        ZTest Always
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

            // ===== METABALL DATA =====
            int _MetaballCount;
            float3 _MetaballData[256];        // x,y,radius
            float4 _MetaballColorData[256];   // rgba

            float4 _OutlineColor;
            float _CameraSize;
            float _Alpha;

            // ===== CAUSTIC =====
            float4 _CausticColor;
            float _CausticOpacity;
            float _CausticThreshold;
            float _CausticPulseSpeed;
            float _CausticPulseAmount;
            float _CausticScale;
            float _FusionBoost;
            float _EdgeWidth;
            float _OutlineSize;

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

            // ===== NOISE =====
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

            float CausticNoiseStable(float2 uv, float t)
            {
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

                float infl = 0.0;
                float4 col = float4(0,0,0,0);
                float dist = 1.0;

                float2 screenPos = i.uv * _ScreenParams.xy;

                // ===== METABALL FIELD (PORTADO DO SHADER FUNCIONAL) =====
                for (int m = 0; m < _MetaballCount; ++m)
                {
                    float2 pos = _MetaballData[m].xy;
                    float2 delta = screenPos - pos;

                    float r = _MetaballData[m].z * _ScreenParams.y / _CameraSize;

                    float d2 = max(dot(delta, delta), 0.0001);
                    float currInfl = (r * r) / d2;

                    infl += currInfl;
                    col += _MetaballColorData[m] * currInfl;

                    float d = sqrt(d2);
                    dist *= saturate(d / r);
                }

                if (infl > 0.0)
                    col /= infl;

                col.a = 1.0;

                float threshold = 0.5;
                float outlineThreshold = threshold * (1.0 - _OutlineSize);

                float4 metaballCol =
                    (dist > threshold) ? tex :
                    ((dist > outlineThreshold) ? _OutlineColor : col) * _Alpha;

                // ===== EDGE MASK =====
                float inside = step(dist, threshold);
                float edge = smoothstep(threshold, threshold - _EdgeWidth, dist);
                edge *= inside;

                // ===== FUSION =====
                float fusion = saturate(infl - 1.0);
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
