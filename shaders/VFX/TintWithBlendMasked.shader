Shader "UI/TintWithBlendMasked"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _Blend ("Blend Factor", Range(0,1)) = 1
    }

    SubShader
    {
        Tags { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil {
            Ref 1
            Comp Equal
            Pass Keep
        }

        Lighting Off
        ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            // _MainTex é fornecido automaticamente pelo Image
            sampler2D _MainTex;
            float4 _TintColor;
            float _Blend;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.texcoord);
                fixed3 tinted = lerp(texColor.rgb, _TintColor.rgb, _Blend);
                return fixed4(tinted, texColor.a); // mantém o alpha original
            }
            ENDCG
        }
    }
}
