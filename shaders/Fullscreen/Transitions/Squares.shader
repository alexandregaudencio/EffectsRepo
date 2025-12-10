Shader "Transitions/Squares"
{
    Properties
    {
        _Color ("Fade to Color", Color) = (0,0,0,1)
        _Progress ("Progress", Range(0, 1)) = 0.0
        _Size ("Size", Vector) = (64.0, 45.0, 0, 0)
        _Smoothness ("Smoothness", Float) = 0.5
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
            Name "SquaresPass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Fullscreen triangle data
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

            // Camera texture (URP automatic Blit input)
            TEXTURE2D(_BlitTexture);
            SAMPLER(sampler_BlitTexture);

            float4 _Color;
            float _Progress;
            float2 _Size;
            float _Smoothness;

            float rand(float2 co)
            {
                float x = sin(dot(co, float2(12.9898, 78.233))) * 43758.5453;
                return frac(x);
            }

            half4 Frag(Varyings i) : SV_Target
            {
                float2 cell = floor(_Size * i.uv);
                float r = rand(cell);

                float m = smoothstep(
                    0.0,
                    -_Smoothness,
                    r - (_Progress * (1.0 + _Smoothness))
                );

                half4 cam = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, i.uv);

                return lerp(cam, _Color, m);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
