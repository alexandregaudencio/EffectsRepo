Shader "Transitions/WindDissolveFullscreen"
{
    Properties
    {
        _Progress("Progress", Range(0.0, 1.0)) = 0.0
        _Size("Size", Range(0.1, 0.6)) = 0.3
        _WindVerticalSegments("Wind Height", Range(1.0, 1000.0)) = 100.0
        _Color("Color", Color) = (0,0,0,1)
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" }

        Pass
        {
            Name "WindDissolveFS"
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex FullscreenVert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // textura vinda do Blit
            TEXTURE2D(_BlitTexture);
            SAMPLER(sampler_BlitTexture);

            float _Progress;
            float _Size;
            float _WindVerticalSegments;
            float4 _Color;

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct VaryingsFS
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
            };

            VaryingsFS FullscreenVert(uint vertexID : SV_VertexID)
            {
                VaryingsFS o;

                float2 uv = float2((vertexID << 1) & 2, vertexID & 2);
                o.positionHCS = float4(uv * 2.0 - 1.0, 0, 1);
                o.uv = uv;

                return o;
            }

            float rand(float2 co)
            {
                float x = sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453;
                return frac(x);
            }

            float4 Frag(VaryingsFS i) : SV_Target
            {
                float2 uv = i.uv;

                float r = rand(floor(float2(0.0, uv.y * _WindVerticalSegments)));

                float m = smoothstep(
                    0.0,
                    -_Size,
                    uv.x * (1.0 - _Size) + _Size * r - ((_Progress )* (1.0 + _Size))
                );

                // float4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, uv);

                return  float4(0,0,0,0), m * _Color;
            }
            ENDHLSL
        }
    }
}
