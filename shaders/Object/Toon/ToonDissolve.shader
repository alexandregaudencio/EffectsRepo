Shader "Shader Graphs/Toon/ToonDissolve"
{
    Properties
    {
        [NoScaleOffset]_BaseMap("BaseMap", 2D) = "white" {}
        _Dissolve("Dissolve", Range(0, 1)) = 0
        _NoiseScale("NoiseScale", Float) = 50
        [HDR]_EdgeColor("EdgeColor", Color) = (0.04705882, 0, 0.7058824, 0)
        _EdgeWidth("EdgeWidth", Range(0, 1)) = 0.09
        _OverwriteColor("OverwriteColor", Color) = (1, 0, 0, 0)
        _OverwriteColorAlpha("OverwriteColorAlpha", Range(0, 1)) = 0
        _RAmpOffsetPoint("RAmpOffsetPoint", Range(0, 1)) = 0.8
        _Ambient("Ambient", Range(0, 1)) = 0
        _RimSize("RimSize", Range(0, 1)) = 0
        _RimIntensity("RimIntensity", Range(0, 1)) = 0
        [HDR]_ShadowColor("ShadowColor", Color) = (1, 1, 1, 0)
        [HideInInspector]_WorkflowMode("_WorkflowMode", Float) = 0
        [HideInInspector]_CastShadows("_CastShadows", Float) = 1
        [HideInInspector]_ReceiveShadows("_ReceiveShadows", Float) = 1
        [HideInInspector]_Surface("_Surface", Float) = 0
        [HideInInspector]_Blend("_Blend", Float) = 0
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 1
        [HideInInspector]_BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 1
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 2
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {

            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Stencil
            {
                Ref 1
                Comp NotEqual
                Pass Keep
            }
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        AlphaToMask [_AlphaToMask]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include_with_pragmas "Assets/Plugins/EffectRepo/shaders/Common/ToonRampUnity6.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Blend_Overwrite_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D.tex, _Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D.samplerstate, _Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_R_4_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.r;
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_G_5_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.g;
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_B_6_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.b;
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_A_7_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.a;
            float4 Color_87f86878bf314e9e9ed41887868da672 = IsGammaSpace() ? LinearToSRGB(float4(0.1960784, 0.1960784, 0.1960784, 0)) : float4(0.1960784, 0.1960784, 0.1960784, 0);
            float Slider_121699f240344ce2a10387df59f6e66c = 0.6;
            float _Property_32a4dd9be1c942ebb2ab3ddfddbb48dc_Out_0_Float = _RAmpOffsetPoint;
            float _Property_a79242f4339742ceb7c4bbafe9324f78_Out_0_Float = _Ambient;
            float3 _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_ToonRampOutput_0_Vector3;
            float3 _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_Direction_7_Vector3;
            ToonShading_float(IN.WorldSpaceNormal, float(0), (float4(IN.ObjectSpacePosition, 1.0)), IN.WorldSpacePosition, (Color_87f86878bf314e9e9ed41887868da672.xyz), Slider_121699f240344ce2a10387df59f6e66c, _Property_32a4dd9be1c942ebb2ab3ddfddbb48dc_Out_0_Float, _Property_a79242f4339742ceb7c4bbafe9324f78_Out_0_Float, _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_ToonRampOutput_0_Vector3, _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_Direction_7_Vector3);
            float _DotProduct_b5d340636ac8400eb5879fdd30c76674_Out_2_Float;
            Unity_DotProduct_float3(IN.WorldSpaceNormal, _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_Direction_7_Vector3, _DotProduct_b5d340636ac8400eb5879fdd30c76674_Out_2_Float);
            float _Property_8888cdef954c4205b6144f43e2e217c6_Out_0_Float = _RimSize;
            float _Multiply_3bb2b92e05d542939b266f95ea0aa34e_Out_2_Float;
            Unity_Multiply_float_float(_Property_8888cdef954c4205b6144f43e2e217c6_Out_0_Float, 0.5, _Multiply_3bb2b92e05d542939b266f95ea0aa34e_Out_2_Float);
            float _OneMinus_b2975e7755ae45acba4ef3e3f6e5236e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_3bb2b92e05d542939b266f95ea0aa34e_Out_2_Float, _OneMinus_b2975e7755ae45acba4ef3e3f6e5236e_Out_1_Float);
            float _FresnelEffect_ec495c4e8b3c432497f9505eba799e46_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _OneMinus_b2975e7755ae45acba4ef3e3f6e5236e_Out_1_Float, _FresnelEffect_ec495c4e8b3c432497f9505eba799e46_Out_3_Float);
            float _Multiply_9d4660333ef845d2a1eb31519f32ff0c_Out_2_Float;
            Unity_Multiply_float_float(_DotProduct_b5d340636ac8400eb5879fdd30c76674_Out_2_Float, _FresnelEffect_ec495c4e8b3c432497f9505eba799e46_Out_3_Float, _Multiply_9d4660333ef845d2a1eb31519f32ff0c_Out_2_Float);
            float _Step_c7988b52063a4aedae06f47ffeda7362_Out_2_Float;
            Unity_Step_float(float(0.5), _Multiply_9d4660333ef845d2a1eb31519f32ff0c_Out_2_Float, _Step_c7988b52063a4aedae06f47ffeda7362_Out_2_Float);
            float4 _Multiply_fd4cab45e1604062a0948beb66857d1e_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4, (_Step_c7988b52063a4aedae06f47ffeda7362_Out_2_Float.xxxx), _Multiply_fd4cab45e1604062a0948beb66857d1e_Out_2_Vector4);
            float _Property_4aad68154aec4582a2d8da1a453f190e_Out_0_Float = _RimIntensity;
            float4 _Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_fd4cab45e1604062a0948beb66857d1e_Out_2_Vector4, (_Property_4aad68154aec4582a2d8da1a453f190e_Out_0_Float.xxxx), _Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4);
            float4 _OneMinus_7c4352dbf0cc4efaa847c540980e9542_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4, _OneMinus_7c4352dbf0cc4efaa847c540980e9542_Out_1_Vector4);
            float4 _Multiply_070b16bc404b4ab48c47aa6f5d989460_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4, _OneMinus_7c4352dbf0cc4efaa847c540980e9542_Out_1_Vector4, _Multiply_070b16bc404b4ab48c47aa6f5d989460_Out_2_Vector4);
            float4 _Add_c9c55b708ca94d85a19982c2f726973e_Out_2_Vector4;
            Unity_Add_float4(_Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4, _Multiply_070b16bc404b4ab48c47aa6f5d989460_Out_2_Vector4, _Add_c9c55b708ca94d85a19982c2f726973e_Out_2_Vector4);
            float3 _Saturate_df2534feaf3245dea248b32ace2c1b8e_Out_1_Vector3;
            Unity_Saturate_float3(_ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_ToonRampOutput_0_Vector3, _Saturate_df2534feaf3245dea248b32ace2c1b8e_Out_1_Vector3);
            float3 _Multiply_d2bfc40be0634fa49e7a06c4f07b25a3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Add_c9c55b708ca94d85a19982c2f726973e_Out_2_Vector4.xyz), _Saturate_df2534feaf3245dea248b32ace2c1b8e_Out_1_Vector3, _Multiply_d2bfc40be0634fa49e7a06c4f07b25a3_Out_2_Vector3);
            float4 _Property_f80cc75153b04608af89292a52e623be_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_ShadowColor) : _ShadowColor;
            float3 _Multiply_01744097e4e149138c97aeaf646e3aa6_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d2bfc40be0634fa49e7a06c4f07b25a3_Out_2_Vector3, (_Property_f80cc75153b04608af89292a52e623be_Out_0_Vector4.xyz), _Multiply_01744097e4e149138c97aeaf646e3aa6_Out_2_Vector3);
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            float3 _Add_e8a94e9754d3928bb12e625e8288b6d7_Out_2_Vector3;
            Unity_Add_float3(_Multiply_01744097e4e149138c97aeaf646e3aa6_Out_2_Vector3, (_DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4.xyz), _Add_e8a94e9754d3928bb12e625e8288b6d7_Out_2_Vector3);
            float4 _Property_253da7cd929740fc979c1d0f60ca890e_Out_0_Vector4 = _OverwriteColor;
            float _Property_54b082c94cae44c39629f2acedcc74e6_Out_0_Float = _OverwriteColorAlpha;
            float3 _Blend_6fdfba80f3104b8e900e04b46ad389eb_Out_2_Vector3;
            Unity_Blend_Overwrite_float3(_Add_e8a94e9754d3928bb12e625e8288b6d7_Out_2_Vector3, (_Property_253da7cd929740fc979c1d0f60ca890e_Out_0_Vector4.xyz), _Blend_6fdfba80f3104b8e900e04b46ad389eb_Out_2_Vector3, _Property_54b082c94cae44c39629f2acedcc74e6_Out_0_Float);
            float4 _Property_1341ee0b4c4f4d1b8a39fa6c322eee82_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_ShadowColor) : _ShadowColor;
            float3 _Multiply_f636191ddafa4edf90057d1b44b21dcc_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Blend_6fdfba80f3104b8e900e04b46ad389eb_Out_2_Vector3, (_Property_1341ee0b4c4f4d1b8a39fa6c322eee82_Out_0_Vector4.xyz), _Multiply_f636191ddafa4edf90057d1b44b21dcc_Out_2_Vector3);
            surface.BaseColor = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = _Multiply_f636191ddafa4edf90057d1b44b21dcc_Out_2_Vector3;
            surface.Metallic = float(0);
            surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
            surface.Smoothness = float(0);
            surface.Occlusion = float(0);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include_with_pragmas "Assets/Plugins/EffectRepo/shaders/Common/ToonRampUnity6.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Blend_Overwrite_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D.tex, _Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D.samplerstate, _Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_R_4_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.r;
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_G_5_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.g;
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_B_6_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.b;
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_A_7_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.a;
            float4 Color_87f86878bf314e9e9ed41887868da672 = IsGammaSpace() ? LinearToSRGB(float4(0.1960784, 0.1960784, 0.1960784, 0)) : float4(0.1960784, 0.1960784, 0.1960784, 0);
            float Slider_121699f240344ce2a10387df59f6e66c = 0.6;
            float _Property_32a4dd9be1c942ebb2ab3ddfddbb48dc_Out_0_Float = _RAmpOffsetPoint;
            float _Property_a79242f4339742ceb7c4bbafe9324f78_Out_0_Float = _Ambient;
            float3 _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_ToonRampOutput_0_Vector3;
            float3 _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_Direction_7_Vector3;
            ToonShading_float(IN.WorldSpaceNormal, float(0), (float4(IN.ObjectSpacePosition, 1.0)), IN.WorldSpacePosition, (Color_87f86878bf314e9e9ed41887868da672.xyz), Slider_121699f240344ce2a10387df59f6e66c, _Property_32a4dd9be1c942ebb2ab3ddfddbb48dc_Out_0_Float, _Property_a79242f4339742ceb7c4bbafe9324f78_Out_0_Float, _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_ToonRampOutput_0_Vector3, _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_Direction_7_Vector3);
            float _DotProduct_b5d340636ac8400eb5879fdd30c76674_Out_2_Float;
            Unity_DotProduct_float3(IN.WorldSpaceNormal, _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_Direction_7_Vector3, _DotProduct_b5d340636ac8400eb5879fdd30c76674_Out_2_Float);
            float _Property_8888cdef954c4205b6144f43e2e217c6_Out_0_Float = _RimSize;
            float _Multiply_3bb2b92e05d542939b266f95ea0aa34e_Out_2_Float;
            Unity_Multiply_float_float(_Property_8888cdef954c4205b6144f43e2e217c6_Out_0_Float, 0.5, _Multiply_3bb2b92e05d542939b266f95ea0aa34e_Out_2_Float);
            float _OneMinus_b2975e7755ae45acba4ef3e3f6e5236e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_3bb2b92e05d542939b266f95ea0aa34e_Out_2_Float, _OneMinus_b2975e7755ae45acba4ef3e3f6e5236e_Out_1_Float);
            float _FresnelEffect_ec495c4e8b3c432497f9505eba799e46_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _OneMinus_b2975e7755ae45acba4ef3e3f6e5236e_Out_1_Float, _FresnelEffect_ec495c4e8b3c432497f9505eba799e46_Out_3_Float);
            float _Multiply_9d4660333ef845d2a1eb31519f32ff0c_Out_2_Float;
            Unity_Multiply_float_float(_DotProduct_b5d340636ac8400eb5879fdd30c76674_Out_2_Float, _FresnelEffect_ec495c4e8b3c432497f9505eba799e46_Out_3_Float, _Multiply_9d4660333ef845d2a1eb31519f32ff0c_Out_2_Float);
            float _Step_c7988b52063a4aedae06f47ffeda7362_Out_2_Float;
            Unity_Step_float(float(0.5), _Multiply_9d4660333ef845d2a1eb31519f32ff0c_Out_2_Float, _Step_c7988b52063a4aedae06f47ffeda7362_Out_2_Float);
            float4 _Multiply_fd4cab45e1604062a0948beb66857d1e_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4, (_Step_c7988b52063a4aedae06f47ffeda7362_Out_2_Float.xxxx), _Multiply_fd4cab45e1604062a0948beb66857d1e_Out_2_Vector4);
            float _Property_4aad68154aec4582a2d8da1a453f190e_Out_0_Float = _RimIntensity;
            float4 _Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_fd4cab45e1604062a0948beb66857d1e_Out_2_Vector4, (_Property_4aad68154aec4582a2d8da1a453f190e_Out_0_Float.xxxx), _Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4);
            float4 _OneMinus_7c4352dbf0cc4efaa847c540980e9542_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4, _OneMinus_7c4352dbf0cc4efaa847c540980e9542_Out_1_Vector4);
            float4 _Multiply_070b16bc404b4ab48c47aa6f5d989460_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4, _OneMinus_7c4352dbf0cc4efaa847c540980e9542_Out_1_Vector4, _Multiply_070b16bc404b4ab48c47aa6f5d989460_Out_2_Vector4);
            float4 _Add_c9c55b708ca94d85a19982c2f726973e_Out_2_Vector4;
            Unity_Add_float4(_Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4, _Multiply_070b16bc404b4ab48c47aa6f5d989460_Out_2_Vector4, _Add_c9c55b708ca94d85a19982c2f726973e_Out_2_Vector4);
            float3 _Saturate_df2534feaf3245dea248b32ace2c1b8e_Out_1_Vector3;
            Unity_Saturate_float3(_ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_ToonRampOutput_0_Vector3, _Saturate_df2534feaf3245dea248b32ace2c1b8e_Out_1_Vector3);
            float3 _Multiply_d2bfc40be0634fa49e7a06c4f07b25a3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Add_c9c55b708ca94d85a19982c2f726973e_Out_2_Vector4.xyz), _Saturate_df2534feaf3245dea248b32ace2c1b8e_Out_1_Vector3, _Multiply_d2bfc40be0634fa49e7a06c4f07b25a3_Out_2_Vector3);
            float4 _Property_f80cc75153b04608af89292a52e623be_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_ShadowColor) : _ShadowColor;
            float3 _Multiply_01744097e4e149138c97aeaf646e3aa6_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d2bfc40be0634fa49e7a06c4f07b25a3_Out_2_Vector3, (_Property_f80cc75153b04608af89292a52e623be_Out_0_Vector4.xyz), _Multiply_01744097e4e149138c97aeaf646e3aa6_Out_2_Vector3);
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            float3 _Add_e8a94e9754d3928bb12e625e8288b6d7_Out_2_Vector3;
            Unity_Add_float3(_Multiply_01744097e4e149138c97aeaf646e3aa6_Out_2_Vector3, (_DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4.xyz), _Add_e8a94e9754d3928bb12e625e8288b6d7_Out_2_Vector3);
            float4 _Property_253da7cd929740fc979c1d0f60ca890e_Out_0_Vector4 = _OverwriteColor;
            float _Property_54b082c94cae44c39629f2acedcc74e6_Out_0_Float = _OverwriteColorAlpha;
            float3 _Blend_6fdfba80f3104b8e900e04b46ad389eb_Out_2_Vector3;
            Unity_Blend_Overwrite_float3(_Add_e8a94e9754d3928bb12e625e8288b6d7_Out_2_Vector3, (_Property_253da7cd929740fc979c1d0f60ca890e_Out_0_Vector4.xyz), _Blend_6fdfba80f3104b8e900e04b46ad389eb_Out_2_Vector3, _Property_54b082c94cae44c39629f2acedcc74e6_Out_0_Float);
            float4 _Property_1341ee0b4c4f4d1b8a39fa6c322eee82_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_ShadowColor) : _ShadowColor;
            float3 _Multiply_f636191ddafa4edf90057d1b44b21dcc_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Blend_6fdfba80f3104b8e900e04b46ad389eb_Out_2_Vector3, (_Property_1341ee0b4c4f4d1b8a39fa6c322eee82_Out_0_Vector4.xyz), _Multiply_f636191ddafa4edf90057d1b44b21dcc_Out_2_Vector3);
            surface.BaseColor = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = _Multiply_f636191ddafa4edf90057d1b44b21dcc_Out_2_Vector3;
            surface.Metallic = float(0);
            surface.Specular = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
            surface.Smoothness = float(0);
            surface.Occlusion = float(0);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_INSTANCEID
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include_with_pragmas "Assets/Plugins/EffectRepo/shaders/Common/ToonRampUnity6.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Blend_Overwrite_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D.tex, _Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D.samplerstate, _Property_a6e3119ec4b240f29f93cc10d2b8426c_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_R_4_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.r;
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_G_5_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.g;
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_B_6_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.b;
            float _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_A_7_Float = _SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4.a;
            float4 Color_87f86878bf314e9e9ed41887868da672 = IsGammaSpace() ? LinearToSRGB(float4(0.1960784, 0.1960784, 0.1960784, 0)) : float4(0.1960784, 0.1960784, 0.1960784, 0);
            float Slider_121699f240344ce2a10387df59f6e66c = 0.6;
            float _Property_32a4dd9be1c942ebb2ab3ddfddbb48dc_Out_0_Float = _RAmpOffsetPoint;
            float _Property_a79242f4339742ceb7c4bbafe9324f78_Out_0_Float = _Ambient;
            float3 _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_ToonRampOutput_0_Vector3;
            float3 _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_Direction_7_Vector3;
            ToonShading_float(IN.WorldSpaceNormal, float(0), (float4(IN.ObjectSpacePosition, 1.0)), IN.WorldSpacePosition, (Color_87f86878bf314e9e9ed41887868da672.xyz), Slider_121699f240344ce2a10387df59f6e66c, _Property_32a4dd9be1c942ebb2ab3ddfddbb48dc_Out_0_Float, _Property_a79242f4339742ceb7c4bbafe9324f78_Out_0_Float, _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_ToonRampOutput_0_Vector3, _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_Direction_7_Vector3);
            float _DotProduct_b5d340636ac8400eb5879fdd30c76674_Out_2_Float;
            Unity_DotProduct_float3(IN.WorldSpaceNormal, _ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_Direction_7_Vector3, _DotProduct_b5d340636ac8400eb5879fdd30c76674_Out_2_Float);
            float _Property_8888cdef954c4205b6144f43e2e217c6_Out_0_Float = _RimSize;
            float _Multiply_3bb2b92e05d542939b266f95ea0aa34e_Out_2_Float;
            Unity_Multiply_float_float(_Property_8888cdef954c4205b6144f43e2e217c6_Out_0_Float, 0.5, _Multiply_3bb2b92e05d542939b266f95ea0aa34e_Out_2_Float);
            float _OneMinus_b2975e7755ae45acba4ef3e3f6e5236e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_3bb2b92e05d542939b266f95ea0aa34e_Out_2_Float, _OneMinus_b2975e7755ae45acba4ef3e3f6e5236e_Out_1_Float);
            float _FresnelEffect_ec495c4e8b3c432497f9505eba799e46_Out_3_Float;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _OneMinus_b2975e7755ae45acba4ef3e3f6e5236e_Out_1_Float, _FresnelEffect_ec495c4e8b3c432497f9505eba799e46_Out_3_Float);
            float _Multiply_9d4660333ef845d2a1eb31519f32ff0c_Out_2_Float;
            Unity_Multiply_float_float(_DotProduct_b5d340636ac8400eb5879fdd30c76674_Out_2_Float, _FresnelEffect_ec495c4e8b3c432497f9505eba799e46_Out_3_Float, _Multiply_9d4660333ef845d2a1eb31519f32ff0c_Out_2_Float);
            float _Step_c7988b52063a4aedae06f47ffeda7362_Out_2_Float;
            Unity_Step_float(float(0.5), _Multiply_9d4660333ef845d2a1eb31519f32ff0c_Out_2_Float, _Step_c7988b52063a4aedae06f47ffeda7362_Out_2_Float);
            float4 _Multiply_fd4cab45e1604062a0948beb66857d1e_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4, (_Step_c7988b52063a4aedae06f47ffeda7362_Out_2_Float.xxxx), _Multiply_fd4cab45e1604062a0948beb66857d1e_Out_2_Vector4);
            float _Property_4aad68154aec4582a2d8da1a453f190e_Out_0_Float = _RimIntensity;
            float4 _Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_fd4cab45e1604062a0948beb66857d1e_Out_2_Vector4, (_Property_4aad68154aec4582a2d8da1a453f190e_Out_0_Float.xxxx), _Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4);
            float4 _OneMinus_7c4352dbf0cc4efaa847c540980e9542_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4, _OneMinus_7c4352dbf0cc4efaa847c540980e9542_Out_1_Vector4);
            float4 _Multiply_070b16bc404b4ab48c47aa6f5d989460_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_1582c3bda2864f87b6826d3083600fa0_RGBA_0_Vector4, _OneMinus_7c4352dbf0cc4efaa847c540980e9542_Out_1_Vector4, _Multiply_070b16bc404b4ab48c47aa6f5d989460_Out_2_Vector4);
            float4 _Add_c9c55b708ca94d85a19982c2f726973e_Out_2_Vector4;
            Unity_Add_float4(_Multiply_f0ad9ed184a94488960eb7edaa959070_Out_2_Vector4, _Multiply_070b16bc404b4ab48c47aa6f5d989460_Out_2_Vector4, _Add_c9c55b708ca94d85a19982c2f726973e_Out_2_Vector4);
            float3 _Saturate_df2534feaf3245dea248b32ace2c1b8e_Out_1_Vector3;
            Unity_Saturate_float3(_ToonShadingCustomFunction_fc79f5117aef43dc825e3559bb7d0b78_ToonRampOutput_0_Vector3, _Saturate_df2534feaf3245dea248b32ace2c1b8e_Out_1_Vector3);
            float3 _Multiply_d2bfc40be0634fa49e7a06c4f07b25a3_Out_2_Vector3;
            Unity_Multiply_float3_float3((_Add_c9c55b708ca94d85a19982c2f726973e_Out_2_Vector4.xyz), _Saturate_df2534feaf3245dea248b32ace2c1b8e_Out_1_Vector3, _Multiply_d2bfc40be0634fa49e7a06c4f07b25a3_Out_2_Vector3);
            float4 _Property_f80cc75153b04608af89292a52e623be_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_ShadowColor) : _ShadowColor;
            float3 _Multiply_01744097e4e149138c97aeaf646e3aa6_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Multiply_d2bfc40be0634fa49e7a06c4f07b25a3_Out_2_Vector3, (_Property_f80cc75153b04608af89292a52e623be_Out_0_Vector4.xyz), _Multiply_01744097e4e149138c97aeaf646e3aa6_Out_2_Vector3);
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            float3 _Add_e8a94e9754d3928bb12e625e8288b6d7_Out_2_Vector3;
            Unity_Add_float3(_Multiply_01744097e4e149138c97aeaf646e3aa6_Out_2_Vector3, (_DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4.xyz), _Add_e8a94e9754d3928bb12e625e8288b6d7_Out_2_Vector3);
            float4 _Property_253da7cd929740fc979c1d0f60ca890e_Out_0_Vector4 = _OverwriteColor;
            float _Property_54b082c94cae44c39629f2acedcc74e6_Out_0_Float = _OverwriteColorAlpha;
            float3 _Blend_6fdfba80f3104b8e900e04b46ad389eb_Out_2_Vector3;
            Unity_Blend_Overwrite_float3(_Add_e8a94e9754d3928bb12e625e8288b6d7_Out_2_Vector3, (_Property_253da7cd929740fc979c1d0f60ca890e_Out_0_Vector4.xyz), _Blend_6fdfba80f3104b8e900e04b46ad389eb_Out_2_Vector3, _Property_54b082c94cae44c39629f2acedcc74e6_Out_0_Float);
            float4 _Property_1341ee0b4c4f4d1b8a39fa6c322eee82_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_ShadowColor) : _ShadowColor;
            float3 _Multiply_f636191ddafa4edf90057d1b44b21dcc_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Blend_6fdfba80f3104b8e900e04b46ad389eb_Out_2_Vector3, (_Property_1341ee0b4c4f4d1b8a39fa6c322eee82_Out_0_Vector4.xyz), _Multiply_f636191ddafa4edf90057d1b44b21dcc_Out_2_Vector3);
            surface.BaseColor = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
            surface.Emission = _Multiply_f636191ddafa4edf90057d1b44b21dcc_Out_2_Vector3;
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull [_Cull]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            surface.BaseColor = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float _Dissolve;
        float _NoiseScale;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _RimSize;
        float _RimIntensity;
        float4 _ShadowColor;
        float4 _OverwriteColor;
        float _OverwriteColorAlpha;
        float _RAmpOffsetPoint;
        float _Ambient;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Floor_float4(float4 In, out float4 Out)
        {
            Out = floor(In);
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float
        {
        };
        
        void SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(float Vector1_5D356830, float Vector1_4F29DBD4, float Vector1_CA439384, Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float IN, out float OutAlpha_2, out float OutEdgeMask_1)
        {
        float _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float = Vector1_4F29DBD4;
        float _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float;
        Unity_Subtract_float(float(0), _Property_a3246403d61fe683864f4d48814bf25b_Out_0_Float, _Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float);
        float _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float = Vector1_5D356830;
        float _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float;
        Unity_Lerp_float(_Subtract_fad84a983432d785b8ab81683cd30af8_Out_2_Float, float(1), _Property_c96cfc4faffb888980af248014f5193d_Out_0_Float, _Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float);
        float _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float = Vector1_CA439384;
        float _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        Unity_Step_float(_Lerp_199f673b622ea98a89a4a49b6170cb20_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float);
        float _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float = Vector1_4F29DBD4;
        float _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float;
        Unity_Add_float(float(1), _Property_4719c792d49f35819560c35c61f3f0b3_Out_0_Float, _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float);
        float _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float = Vector1_5D356830;
        float _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float;
        Unity_Lerp_float(float(0), _Add_3019a172ee751f8d82d7eff307253f65_Out_2_Float, _Property_b4a14a13ee6f3a8292553232c2b47cfb_Out_0_Float, _Lerp_1270fc00114229878913698d191c6b35_Out_3_Float);
        float _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float;
        Unity_Step_float(_Lerp_1270fc00114229878913698d191c6b35_Out_3_Float, _Property_1b8282746f928f8c8ede0fe6ec474b6b_Out_0_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float);
        float _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        Unity_Subtract_float(_Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float, _Step_ef3fa6da6320868d87c205aabc60c746_Out_2_Float, _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float);
        OutAlpha_2 = _Step_0372baee9b2ca18bad4ea71abd614ff0_Out_2_Float;
        OutEdgeMask_1 = _Subtract_52e3ef846b1a6c8ca567020b787daf69_Out_2_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        struct Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float
        {
        };
        
        void SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(float Vector1_69DBF2ED, float Vector1_25078113, float4 Color_E73EE581, float Vector1_81CD89EF, float Vector1_FAC354A, Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float IN, out float OutAlpha_2, out float OutAlphaClip_3, out float4 OutEdgeColor_1)
        {
        float _Property_822ad711843000888a68fd881907b1f8_Out_0_Float = Vector1_69DBF2ED;
        float _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float = Vector1_25078113;
        float _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float = Vector1_FAC354A;
        Bindings_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float;
        float _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float;
        SG_EdgeAndAlphaMaskSubGraph_52f069c032b433b4c8787aed317e77de_float(_Property_822ad711843000888a68fd881907b1f8_Out_0_Float, _Property_ba724c2730cec78ca73228f7899bc31c_Out_0_Float, _Property_bc17aeb423470386a7560bd2f8fdd55f_Out_0_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float);
        float _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        Unity_OneMinus_float(_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutAlpha_2_Float, _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float);
        float _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        Unity_Add_float(_OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float, float(0.0001), _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float);
        float4 _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4 = Color_E73EE581;
        float4 _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4;
        Unity_Multiply_float4_float4((_EdgeAndAlphaMaskSubGraph_c9a87afb5010768c9a21a70e14fa942a_OutEdgeMask_1_Float.xxxx), _Property_f685a66b5e1cac8394e1b82161a59a7b_Out_0_Vector4, _Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4);
        float _Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float = Vector1_81CD89EF;
        float4 _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Multiply_a794a0d3952a908fb7b41f5f743ab989_Out_2_Vector4, (_Property_6ab9c7971d71978fb1683ac16d996ae3_Out_0_Float.xxxx), _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4);
        OutAlpha_2 = _OneMinus_271879aed6fd83898f698b89e59bead0_Out_1_Float;
        OutAlphaClip_3 = _Add_8fd24fd77bd2548c85a77490701733f9_Out_2_Float;
        OutEdgeColor_1 = _Multiply_65a928cac92d2288b15c7e400f2c4988_Out_2_Vector4;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float = _Dissolve;
            float _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float = _EdgeWidth;
            float4 _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4 = IN.uv0;
            float _Float_c57ffe9039e745898712e203da647413_Out_0_Float = float(8);
            float _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float;
            Unity_Power_float(float(2), _Float_c57ffe9039e745898712e203da647413_Out_0_Float, _Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float);
            float4 _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_b6b59fd6ebdf5083bab6fe902cd0f5eb_Out_0_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4);
            float4 _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_a3e72f304f224172b225f18b616c839f_Out_2_Vector4, _Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4);
            float4 _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4;
            Unity_Divide_float4(_Floor_599088d5a654422f8324c3c07e369861_Out_1_Vector4, (_Power_4fccce46490c4a8cbc3d2bacae5030d9_Out_2_Float.xxxx), _Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4);
            float _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float = _NoiseScale;
            float _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_4c86d261ac0e4e10a53e3f9f4452aa1e_Out_2_Vector4.xy), _Property_2ca674e804ff2c8fab7edb36a08d3114_Out_0_Float, _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float;
            float _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_0ad6a25972199b8ca80f608ae46c3e13_Out_0_Float, _Property_4026ce90e1cd0c868caac7dcfc6bc618_Out_0_Float, _Property_5c52857295bc82819c4cb29b13a8ca8e_Out_0_Vector4, float(1), _SimpleNoise_7f7d5f5ddc900b8a9c082103e08a47c0_Out_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlpha_2_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float, _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutEdgeColor_1_Vector4);
            surface.BaseColor = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_27c096a8fc81a8888efce2ced32d85d7_OutAlphaClip_3_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}