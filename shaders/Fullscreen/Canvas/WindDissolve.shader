Shader "Canvas/WindDissolve"
{
	Properties
	{
		[HideInInspector] _MainTex ( "Base (RGB)", 2D ) = "white" {}
		_Progress ( "Progress", Range( 0.0, 1.0 ) ) = 0.0
		_Size ( "Size", Range( 0.1, 0.6 ) ) = 0.3
		_WindVerticalSegments ( "Wind Height", Range( 1.0, 1000.0 ) ) = 100.0
		_Color ("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
CGPROGRAM
#pragma exclude_renderers ps3 xbox360
#pragma fragmentoption ARB_precision_hint_fastest
#pragma vertex vert_img
#pragma fragment frag

#include "UnityCG.cginc"


sampler2D _MainTex;
uniform float _Progress;
uniform float _Size;
uniform float _WindVerticalSegments;
uniform float4 _Color;


float rand( float2 co )
{
	float x = sin( dot( co.xy, float2( 12.9898, 78.233 ) ) ) * 43758.5453;
	return x - floor( x );
}


fixed4 frag( v2f_img i ) : COLOR
{
	float r = rand( floor( float2( 0.0, i.uv.y * _WindVerticalSegments ) ) );
	float m = smoothstep( 0.0, -_Size, i.uv.x * ( 1.0 - _Size ) + _Size * r - ( _Progress * ( 1.0 + _Size ) ) );

	return lerp( tex2D( _MainTex, i.uv ), fixed4( 0.0, 0.0, 0.0, 0.0 ), m )*_Color;

}

ENDCG
		} 
	} 

	FallBack "Diffuse"
}
