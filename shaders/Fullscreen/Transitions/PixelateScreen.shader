Shader "Transitions/PixelateScreen"
{
    Properties
    {
        _WidthAspectMultiplier("Width Aspect Multiplier", Range(0.01,3)) = 1
        _Progress("Progress", Range(0,1)) = 0.0
        _ProgressColor("Progress Color", Color) = (0,0,0,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Name "PixelateCameraPass"
            ZWrite Off
            ZTest Always
            Cull Off

            HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // FULLSCREEN TRIANGLE
            Varyings Vert(uint id : SV_VertexID)
            {
                Varyings o;
                o.positionCS = GetFullScreenTriangleVertexPosition(id);
                o.uv = GetFullScreenTriangleTexCoord(id);
                return o;
            }

            // The camera texture injected by Blit()
            TEXTURE2D(_BlitTexture);
            SAMPLER(sampler_BlitTexture);

            float _WidthAspectMultiplier;
            float _Progress;
            float4 _ProgressColor;

            static const float MIN_CELL_SIZE = 0.001;
            static const float MAX_CELL_SIZE = 0.08;

            float4 Frag(Varyings i) : SV_Target
            {
                // pixel interpolation logic
                float cellSize = lerp(MIN_CELL_SIZE, MAX_CELL_SIZE, _Progress);
                float2 cellVec = float2(cellSize * _WidthAspectMultiplier, cellSize);

                float2 steppedUV = round(i.uv / cellVec) * cellVec;

                // read the CAMERA IMAGE, not _MainTex
                float4 pixelColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, steppedUV);

                float4 finalColor = lerp(pixelColor, _ProgressColor, _Progress);
                return finalColor;
            }
            ENDHLSL

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }

    FallBack Off
}
