Shader "Basic1"
{
    Properties
    {
        _intensity("intensity", Float) = 0.0
        _BaseColor("BaseColor", Color) = (0, 0, 1, 1)
        
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            
        }
        
        Pass
        {
            HLSLPROGRAM

            //diretiva de compilação
            //instrução para o compilador dizendo como montar o shader
            #pragma  vertex  vert
            #pragma fragment  frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            float4 _BaseColor;
            float _intensity;
            
            struct appData
            {
                //position object space
                float4 positionOS : POSITION;
            };

            //vertex to fragment
            struct v2f
            {
                //SV_POSITION is the position in clip space
                float4 positionCS : SV_POSITION;
            };

            
            v2f vert(appData v)
            {
                v2f o = (v2f)0;
                o.positionCS = TransformObjectToHClip(v.positionOS);
                return o;
                
            }

            //SV_Target is the color output of the fragment shader
            float4 frag(v2f i ) : SV_Target
            {
                return _BaseColor * _intensity;
            }

            
            ENDHLSL
        }
    }
    
    
}
