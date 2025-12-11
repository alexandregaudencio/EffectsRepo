Shader "Universal Render Pipeline/TerrainToon"
{
    Properties
    {
        // Textures controlled by terrain layers
        [HideInInspector] _Control("Control (RGBA)", 2D) = "red" {}
        [HideInInspector] _Splat0("Layer 0 (R)", 2D) = "grey" {}
        [HideInInspector] _Splat1("Layer 1 (G)", 2D) = "grey" {}
        [HideInInspector] _Splat2("Layer 2 (B)", 2D) = "grey" {}
        [HideInInspector] _Splat3("Layer 3 (A)", 2D) = "grey" {}
        
        [HideInInspector] _Splat0_ST("Layer 0 Scale", Vector) = (1,1,0,0)
        [HideInInspector] _Splat1_ST("Layer 1 Scale", Vector) = (1,1,0,0)
        [HideInInspector] _Splat2_ST("Layer 2 Scale", Vector) = (1,1,0,0)
        [HideInInspector] _Splat3_ST("Layer 3 Scale", Vector) = (1,1,0,0)
        
        // Cell shading properties
        [HDR] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _CellThreshold("Cell Threshold", Range(0, 1)) = 0.5
        // _CellSmoothness("Cell Smoothness", Range(0, 0.5)) = 0.05
        _ShadowColor("Shadow Color", Color) = (0.5, 0.5, 0.5, 1)
    }

    SubShader
    {
        Tags { "Queue" = "Geometry-100" "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "TerrainCompatible"="True" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
             #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            // #pragma multi_compile _ _SHADOWS_SOFT
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS

            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            TEXTURE2D(_Control);
            TEXTURE2D(_Splat0); TEXTURE2D(_Splat1); 
            TEXTURE2D(_Splat2); TEXTURE2D(_Splat3);
            SAMPLER(sampler_Control);
            SAMPLER(sampler_Splat0); SAMPLER(sampler_Splat1);
            SAMPLER(sampler_Splat2); SAMPLER(sampler_Splat3);

            // Texture Scale and offset based on terrain dimension
            float4 _Splat0_ST;
            float4 _Splat1_ST;
            float4 _Splat2_ST;
            float4 _Splat3_ST;

            float4 _BaseColor;
            float _CellThreshold;
            // float _CellSmoothness;
            float4 _ShadowColor;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float2 uvControl : TEXCOORD0;
                float2 uvSplat0 : TEXCOORD2;
                float2 uvSplat1 : TEXCOORD3;
                float2 uvSplat2 : TEXCOORD4;
                float2 uvSplat3 : TEXCOORD5;
                float3 positionWS : TEXCOORD6;
                half fogFactor : TEXCOORD7;  

            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);

                output.uvControl = input.texcoord;
                
                //  UV coord scaled and repeating
                output.uvSplat0 = input.texcoord * _Splat0_ST.xy;
                output.uvSplat1 = input.texcoord * _Splat1_ST.xy;
                output.uvSplat2 = input.texcoord * _Splat2_ST.xy;
                output.uvSplat3 = input.texcoord * _Splat3_ST.xy;
                
                output.fogFactor = ComputeFogFactor(output.positionCS.z);
                return output;
            }

            half4 frag(Varyings input) : SV_TARGET
            {
                half4 control = SAMPLE_TEXTURE2D(_Control, sampler_Control, input.uvControl);
                
                //Show layers with respective UV coord
                half4 layer0 = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, input.uvSplat0);
                half4 layer1 = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat1, input.uvSplat1);
                half4 layer2 = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat2, input.uvSplat2);
                half4 layer3 = SAMPLE_TEXTURE2D(_Splat3, sampler_Splat3, input.uvSplat3);
                
                // Combine layers based on controlMap
                half4 terrainColor = layer0 * control.r;
                terrainColor += layer1 * control.g;
                terrainColor += layer2 * control.b;
                terrainColor += layer3 * control.a;

                // Lighting
                 float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);

                float3 normalWS = normalize(input.normalWS);
                Light mainLight = GetMainLight(shadowCoord);
                float NdotL = dot(normalWS, mainLight.direction);
                 float3 lightColor = normalize( mainLight.color)*2;
                // float3 lightColor = max(mainLight.color, float3(2,2,2));
                //Aplly cel shading
                float cel = floor(NdotL*16  )/ 16 ;
                cel = smoothstep(_CellThreshold, 
                               _CellThreshold, 
                               cel);

                
                // Combine color, light and texture

                float3 lighting =  lerp(_ShadowColor.rgb,  lightColor, cel* mainLight.shadowAttenuation);
                half4 color = half4(terrainColor.rgb * lighting, terrainColor.a)*_BaseColor;
                
                // Invert coments above to disable fog
                // color.rgb += SampleSH(normalWS) * terrainColor.rgb;
                color.rgb = MixFog(color.rgb, input.fogFactor);

                return color;
            }
            ENDHLSL
        }

         // UsePass "Universal Render Pipeline/Terrain/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Terrain/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Terrain/Lit/DepthNormals"
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}