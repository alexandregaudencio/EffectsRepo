Shader "Custom/URPPortalObjectStencil"
{
    Properties
    {
        _Intensity("Intensity", Range(0,10)) = 5.0

        [Header(Movement)]
        _SpeedX("Speed X", Range(-5,5)) = 1.0
        _SpeedY("Speed Y", Range(-5,5)) = 1.0
        _RadialScale("Radial Scale", Range(0,10)) = 1.0
        _LengthScale("Length Scale", Range(0,10)) = 1.0
        _MovingTex("MovingTex", 2D) = "white" {}
        _Multiply("Multiply Moving", Range(0,10)) = 1.0

        [Header(Shape)]
        _ShapeTex("Shape Texture", 2D) = "white" {}
        _ShapeTexIntensity("Shape tex intensity", Range(0,6)) = 0.5

        [Header(Gradient Coloring)]
        _Gradient("Gradient Texture", 2D) = "white" {}
        _Stretch("Gradient Stretch", Range(-2,10)) = 1.0
        _Offset("Gradient Offset", Range(-2,10)) = 1.0

        [Header(Cutoff)]    
        _Cutoff("Outside Cutoff", Range(0,1)) = 1.0
        _Smoothness("Outside Smoothness", Range(0,1)) = 1.0

        _AlphaClip("Alpha Clip Threshold", Range(0,1)) = 0.1
        _Tint("Tint", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="UniversalPipeline" }
        LOD 200

        Pass
        {
            Name "PortalEffectStencil"
            Cull Back

            // ====== STENCIL CONFIG ======
            Stencil
            {
                Ref 1              // valor que será escrito no stencil buffer
                Comp always        // sempre passa o teste
                Pass replace       // substitui o valor do stencil pelo Ref
            }
            // ============================

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float _Cutoff, _Smoothness, _AlphaClip;
            sampler2D _MovingTex;
            float _SpeedX, _SpeedY;
            sampler2D _ShapeTex;
            float _ShapeTexIntensity;
            sampler2D _Gradient;
            float _Stretch, _Multiply;
            float _Intensity, _Offset;
            float _RadialScale, _LengthScale;
            float4 _Tint;

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

            float2 Unity_PolarCoordinates(float2 UV, float2 Center, float RadialScale, float LengthScale)
            {
                float2 delta = UV - Center;
                float radius = length(delta) * 2.0 * RadialScale;
                float angle = atan2(delta.y, delta.x) * 1.0 / 6.28318 * LengthScale;
                return float2(radius, angle);
            }

            float GetFinalDistortion(float2 uv, float shapeTex)
            {
                float2 polarUV = Unity_PolarCoordinates(uv, float2(0.5, 0.5), _RadialScale, _LengthScale);
                float2 movingUV = float2(polarUV.x + (_Time.x * _SpeedX), polarUV.y + (_Time.x * _SpeedY));
                float final = tex2D(_MovingTex, movingUV).r;
                shapeTex *= _ShapeTexIntensity;
                final *= shapeTex;
                return final;
            }

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                float shapeTex = tex2D(_ShapeTex, IN.uv).r;
                float vortexEffect = GetFinalDistortion(IN.uv, shapeTex);

                clip(vortexEffect - _AlphaClip);

                float4 gradientmap = tex2D(_Gradient, (vortexEffect * _Stretch) + _Offset) * _Intensity;
                gradientmap *= vortexEffect;
                gradientmap *= _Tint;
                gradientmap.rgb *= _Tint.rgb;
                gradientmap *= _Tint.a;
                gradientmap *= shapeTex;
                gradientmap *= smoothstep(_Cutoff - _Smoothness, _Cutoff, vortexEffect * _Multiply);
                gradientmap = saturate(gradientmap * 10) * _Intensity;

                return gradientmap;
            }
            ENDHLSL
        }
    }
}
