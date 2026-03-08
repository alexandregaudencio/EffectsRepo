Shader "Custom/RiverFlow"
{
    Properties
    {
        _WaterColor ("Water Color", Color) = (0.1,0.4,0.6,1)
        _FoamColor ("Foam Color", Color) = (1,1,1,1)

        _MainTex ("Water Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}

        _FlowSpeed ("Flow Speed", Float) = 1
        _NormalSpeed ("Normal Speed", Float) = 0.5

        _FoamTex ("Foam Texture", 2D) = "white" {}
        _FoamDistance ("Foam Distance", Float) = 0.5
        _FoamIntensity ("Foam Intensity", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _FoamTex;
            sampler2D _CameraDepthTexture;

            float4 _WaterColor;
            float4 _FoamColor;

            float _FlowSpeed;
            float _NormalSpeed;
            float _FoamDistance;
            float _FoamIntensity;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.screenPos = ComputeScreenPos(o.pos);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float time = _Time.y;

                float2 flowUV = i.uv + float2(time * _FlowSpeed, 0);

                float4 waterTex = tex2D(_MainTex, flowUV);

                float2 normalUV = i.uv + float2(time * _NormalSpeed, time * _NormalSpeed);

                float3 normal = UnpackNormal(tex2D(_NormalMap, normalUV));

                float depth = SAMPLE_DEPTH_TEXTURE_PROJ(
                    _CameraDepthTexture,
                    UNITY_PROJ_COORD(i.screenPos)
                );

                float sceneDepth = LinearEyeDepth(depth);
                float waterDepth = i.screenPos.w;

                float depthDiff = sceneDepth - waterDepth;

                float foamMask = saturate(1 - depthDiff / _FoamDistance);

                float4 foam = tex2D(_FoamTex, flowUV * 2);

                float foamFinal = foamMask * foam.r * _FoamIntensity;

                float3 color = _WaterColor.rgb * waterTex.rgb;

                color = lerp(color, _FoamColor.rgb, foamFinal);

                return float4(color, 0.8);
            }

            ENDCG
        }
    }
}