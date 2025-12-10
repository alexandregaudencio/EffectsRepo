Shader "Transitions/Ripple"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}

        _Progress("Progress", Range(0.0, 1.0)) = 0.0
        _Amplitude("Amplitude", Float) = 100.0
        _Speed("Speed", Float) = 50.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Overlay" }

        ZWrite Off
        ZTest Always
        Cull Off
        Blend One Zero

        Pass
        {
            Name "RipplePass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // ----------------------------------------------------------------------
            // Fullscreen pass using SV_VertexID
            // ----------------------------------------------------------------------
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings Vert(uint vertexID : SV_VertexID)
            {
                Varyings o;

                // Fullscreen triangle
                o.positionCS = GetFullScreenTriangleVertexPosition(vertexID);
                o.uv = GetFullScreenTriangleTexCoord(vertexID);

                return o;
            }

            // ----------------------------------------------------------------------
            // Uniforms
            // ----------------------------------------------------------------------
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float _Progress;
            float _Amplitude;
            float _Speed;

            // ----------------------------------------------------------------------
            // Fragment
            // ----------------------------------------------------------------------
            half4 Frag(Varyings i) : SV_Target
            {
                float2 dir = i.uv - float2(0.5, 0.5);
                float dist = length(dir);

                float wave =
                    sin(_Time.x * _Speed * dist * _Amplitude - _Progress * _Speed);

                float2 offset = dir * (wave + 0.5) / 30.0;

                float2 uvDistorted = i.uv + offset;

                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvDistorted);

                float fade = smoothstep(0.5, 1.0, _Progress);

                return lerp(color, half4(0,0,0,0), fade);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
