Shader "Shader Graphs/OutlineDissolve"
{
    Properties
    {
        _Thickness("Thickness", Range(0, 5)) = 0.02
        _zDistance("zDistance", Range(-1, 0)) = -0.2
        _Dissolve("Dissolve", Range(0, 1)) = 0
        _NoiseScale("NoiseScale", Float) = 59
        [HDR]_EdgeColor("EdgeColor", Color) = (0.2475036, 0, 1.498039, 0)
        _EdgeWitdth("EdgeWitdth", Range(0, 1)) = 0.09
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
            "UniversalMaterialType" = "Unlit"
            "Queue"="AlphaTest"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
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
                // LightMode: <None>
            }
        
        // Render State
        Cull Front
        Blend One Zero
        ZTest LEqual
        ZWrite On
        AlphaToMask On
        
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
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        
        
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
             float3 ObjectSpaceViewDirection;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
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
            output.texCoord0.xyzw = input.texCoord0;
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
        float _Thickness;
        float _zDistance;
        float _EdgeWitdth;
        float _Dissolve;
        float4 _EdgeColor;
        float _NoiseScale;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
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
            float3 _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3;
            Unity_Normalize_float3(IN.ObjectSpaceViewDirection, _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3);
            float _Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float = _zDistance;
            float3 _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3, (_Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float.xxx), _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3);
            float _Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float = _Thickness;
            float3 _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float.xxx), _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3);
            float3 _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3);
            float3 _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
            Unity_Add_float3(_Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3, _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3);
            description.Position = _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
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
            float _Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float = _Dissolve;
            float _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float = _EdgeWitdth;
            float4 _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4 = IN.uv0;
            float _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float = float(8);
            float _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float;
            Unity_Power_float(float(2), _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float, _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float);
            float4 _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4);
            float4 _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4, _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4);
            float4 _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4;
            Unity_Divide_float4(_Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4);
            float _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float = _NoiseScale;
            float _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4.xy), _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float, _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float, _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float, _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4, float(1), _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4);
            surface.BaseColor = (_DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4.xyz);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.WorldSpaceViewDirection =                    GetWorldSpaceNormalizeViewDir(output.WorldSpacePosition);
            output.ObjectSpaceViewDirection =                   TransformWorldToObjectDir(output.WorldSpaceViewDirection);
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
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
        Cull Front
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
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        
        
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
             float3 ObjectSpaceViewDirection;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
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
        float _Thickness;
        float _zDistance;
        float _EdgeWitdth;
        float _Dissolve;
        float4 _EdgeColor;
        float _NoiseScale;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
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
            float3 _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3;
            Unity_Normalize_float3(IN.ObjectSpaceViewDirection, _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3);
            float _Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float = _zDistance;
            float3 _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3, (_Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float.xxx), _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3);
            float _Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float = _Thickness;
            float3 _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float.xxx), _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3);
            float3 _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3);
            float3 _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
            Unity_Add_float3(_Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3, _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3);
            description.Position = _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
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
            float _Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float = _Dissolve;
            float _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float = _EdgeWitdth;
            float4 _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4 = IN.uv0;
            float _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float = float(8);
            float _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float;
            Unity_Power_float(float(2), _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float, _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float);
            float4 _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4);
            float4 _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4, _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4);
            float4 _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4;
            Unity_Divide_float4(_Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4);
            float _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float = _NoiseScale;
            float _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4.xy), _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float, _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float, _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float, _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4, float(1), _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.WorldSpaceViewDirection =                    GetWorldSpaceNormalizeViewDir(output.WorldSpacePosition);
            output.ObjectSpaceViewDirection =                   TransformWorldToObjectDir(output.WorldSpaceViewDirection);
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
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull Front
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
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        #define _ALPHATEST_ON 1
        
        
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
             float3 ObjectSpaceViewDirection;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
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
        float _Thickness;
        float _zDistance;
        float _EdgeWitdth;
        float _Dissolve;
        float4 _EdgeColor;
        float _NoiseScale;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
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
            float3 _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3;
            Unity_Normalize_float3(IN.ObjectSpaceViewDirection, _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3);
            float _Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float = _zDistance;
            float3 _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3, (_Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float.xxx), _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3);
            float _Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float = _Thickness;
            float3 _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float.xxx), _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3);
            float3 _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3);
            float3 _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
            Unity_Add_float3(_Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3, _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3);
            description.Position = _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
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
            float _Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float = _Dissolve;
            float _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float = _EdgeWitdth;
            float4 _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4 = IN.uv0;
            float _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float = float(8);
            float _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float;
            Unity_Power_float(float(2), _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float, _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float);
            float4 _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4);
            float4 _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4, _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4);
            float4 _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4;
            Unity_Divide_float4(_Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4);
            float _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float = _NoiseScale;
            float _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4.xy), _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float, _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float, _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float, _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4, float(1), _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
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
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.WorldSpaceViewDirection =                    GetWorldSpaceNormalizeViewDir(output.WorldSpacePosition);
            output.ObjectSpaceViewDirection =                   TransformWorldToObjectDir(output.WorldSpaceViewDirection);
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
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Front
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
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _ALPHATEST_ON 1
        
        
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
             float3 ObjectSpaceViewDirection;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
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
        float _Thickness;
        float _zDistance;
        float _EdgeWitdth;
        float _Dissolve;
        float4 _EdgeColor;
        float _NoiseScale;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
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
            float3 _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3;
            Unity_Normalize_float3(IN.ObjectSpaceViewDirection, _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3);
            float _Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float = _zDistance;
            float3 _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3, (_Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float.xxx), _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3);
            float _Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float = _Thickness;
            float3 _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float.xxx), _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3);
            float3 _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3);
            float3 _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
            Unity_Add_float3(_Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3, _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3);
            description.Position = _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
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
            float _Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float = _Dissolve;
            float _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float = _EdgeWitdth;
            float4 _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4 = IN.uv0;
            float _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float = float(8);
            float _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float;
            Unity_Power_float(float(2), _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float, _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float);
            float4 _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4);
            float4 _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4, _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4);
            float4 _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4;
            Unity_Divide_float4(_Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4);
            float _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float = _NoiseScale;
            float _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4.xy), _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float, _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float, _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float, _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4, float(1), _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.WorldSpaceViewDirection =                    GetWorldSpaceNormalizeViewDir(output.WorldSpacePosition);
            output.ObjectSpaceViewDirection =                   TransformWorldToObjectDir(output.WorldSpaceViewDirection);
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
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Front
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
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
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _ALPHATEST_ON 1
        
        
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
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
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
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpaceViewDirection;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP0;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP1;
            #endif
             float4 texCoord0 : INTERP2;
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
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            output.texCoord0.xyzw = input.texCoord0;
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
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            output.texCoord0 = input.texCoord0.xyzw;
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
        float _Thickness;
        float _zDistance;
        float _EdgeWitdth;
        float _Dissolve;
        float4 _EdgeColor;
        float _NoiseScale;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
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
            float3 _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3;
            Unity_Normalize_float3(IN.ObjectSpaceViewDirection, _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3);
            float _Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float = _zDistance;
            float3 _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3, (_Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float.xxx), _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3);
            float _Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float = _Thickness;
            float3 _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float.xxx), _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3);
            float3 _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3);
            float3 _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
            Unity_Add_float3(_Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3, _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3);
            description.Position = _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
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
            float _Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float = _Dissolve;
            float _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float = _EdgeWitdth;
            float4 _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4 = IN.uv0;
            float _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float = float(8);
            float _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float;
            Unity_Power_float(float(2), _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float, _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float);
            float4 _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4);
            float4 _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4, _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4);
            float4 _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4;
            Unity_Divide_float4(_Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4);
            float _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float = _NoiseScale;
            float _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4.xy), _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float, _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float, _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float, _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4, float(1), _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4);
            surface.BaseColor = (_DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4.xyz);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.WorldSpaceViewDirection =                    GetWorldSpaceNormalizeViewDir(output.WorldSpacePosition);
            output.ObjectSpaceViewDirection =                   TransformWorldToObjectDir(output.WorldSpaceViewDirection);
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"
        
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
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
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
        #define _ALPHATEST_ON 1
        
        
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
             float3 ObjectSpaceViewDirection;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
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
        float _Thickness;
        float _zDistance;
        float _EdgeWitdth;
        float _Dissolve;
        float4 _EdgeColor;
        float _NoiseScale;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
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
            float3 _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3;
            Unity_Normalize_float3(IN.ObjectSpaceViewDirection, _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3);
            float _Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float = _zDistance;
            float3 _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3, (_Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float.xxx), _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3);
            float _Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float = _Thickness;
            float3 _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float.xxx), _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3);
            float3 _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3);
            float3 _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
            Unity_Add_float3(_Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3, _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3);
            description.Position = _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
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
            float _Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float = _Dissolve;
            float _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float = _EdgeWitdth;
            float4 _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4 = IN.uv0;
            float _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float = float(8);
            float _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float;
            Unity_Power_float(float(2), _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float, _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float);
            float4 _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4);
            float4 _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4, _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4);
            float4 _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4;
            Unity_Divide_float4(_Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4);
            float _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float = _NoiseScale;
            float _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4.xy), _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float, _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float, _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float, _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4, float(1), _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.WorldSpaceViewDirection =                    GetWorldSpaceNormalizeViewDir(output.WorldSpacePosition);
            output.ObjectSpaceViewDirection =                   TransformWorldToObjectDir(output.WorldSpaceViewDirection);
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
        Cull Front
        
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
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
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
        #define _ALPHATEST_ON 1
        
        
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
             float3 ObjectSpaceViewDirection;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
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
        float _Thickness;
        float _zDistance;
        float _EdgeWitdth;
        float _Dissolve;
        float4 _EdgeColor;
        float _NoiseScale;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
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
        
        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
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
            float3 _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3;
            Unity_Normalize_float3(IN.ObjectSpaceViewDirection, _Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3);
            float _Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float = _zDistance;
            float3 _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Normalize_34bceafb07a54cf4bbf0858d711e3a6e_Out_1_Vector3, (_Property_561020db397f4ab8959c5c539d17e83f_Out_0_Float.xxx), _Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3);
            float _Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float = _Thickness;
            float3 _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Property_07fb51133af5455ea40e05f0692aace1_Out_0_Float.xxx), _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3);
            float3 _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_425c8f1fb8694a86bcb9720b86090c8e_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3);
            float3 _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
            Unity_Add_float3(_Multiply_63eb6ad876ec43b188f76b3d68381e0b_Out_2_Vector3, _Add_655777889cf84ef69d30d555bb0c8e1c_Out_2_Vector3, _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3);
            description.Position = _Add_69683bb3a51942eb8b090f8d0211882a_Out_2_Vector3;
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
            float _Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float = _Dissolve;
            float _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float = _EdgeWitdth;
            float4 _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EdgeColor) : _EdgeColor;
            float4 _UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4 = IN.uv0;
            float _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float = float(8);
            float _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float;
            Unity_Power_float(float(2), _Float_f11a7fb3b4464056b291a6b7f909eb98_Out_0_Float, _Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float);
            float4 _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_UV_6a6aff1b35404940b06e6c7b42d5eef2_Out_0_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4);
            float4 _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4;
            Unity_Floor_float4(_Multiply_94583f4713464dd3bd0009446766dcc1_Out_2_Vector4, _Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4);
            float4 _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4;
            Unity_Divide_float4(_Floor_9ca02ce198dc4eca9b119a88e542fd15_Out_1_Vector4, (_Power_6d412d7ab3d6450eaad4601383d96653_Out_2_Float.xxxx), _Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4);
            float _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float = _NoiseScale;
            float _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Divide_aa6a26ba551f4312b051effeb6bcfb83_Out_2_Vector4.xy), _Property_f93bb0d87fb2456f890a15a9a0a2b371_Out_0_Float, _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float);
            Bindings_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float;
            float _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
            float4 _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4;
            SG_DissolveSubGraph_bab8923640a48a4459b7a740e97b66ec_float(_Property_fa874c46762b47c48874a4e5bf95ce51_Out_0_Float, _Property_0d572a1387e548799285ca7f8dc020f8_Out_0_Float, _Property_f42cdd2c978442c99093ba63c393953a_Out_0_Vector4, float(1), _SimpleNoise_76aa6f09fa6d4f8a8233814b4c5a2179_Out_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlpha_2_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float, _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4);
            surface.BaseColor = (_DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutEdgeColor_1_Vector4.xyz);
            surface.Alpha = float(1);
            surface.AlphaClipThreshold = _DissolveSubGraph_fd93e7be92d44825ad9b05d763a12caf_OutAlphaClip_3_Float;
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
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.WorldSpaceViewDirection =                    GetWorldSpaceNormalizeViewDir(output.WorldSpacePosition);
            output.ObjectSpaceViewDirection =                   TransformWorldToObjectDir(output.WorldSpaceViewDirection);
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
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}