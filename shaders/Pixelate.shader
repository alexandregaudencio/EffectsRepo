Shader "Transitions/Pixelate"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
        _WidthAspectMultiplier( "Width Aspect Multiplier", Range(0.0,3.0 )) = 1.0
		_Progress("Progress", Range(0.0, 1.0)) = 0.0
		_ProgressColor("Progress Color", Color) = (0,0,0,1)
	}

	SubShader
	{
		Pass
		{
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }

CGPROGRAM

#pragma vertex vert_img
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

sampler2D _MainTex;
fixed _WidthAspectMultiplier;
fixed _Progress;
fixed4 _ProgressColor;

static const float MIN_CELL_SIZE = 0.001;
static const float MAX_CELL_SIZE = 0.08;

fixed4 frag( v2f_img i ):COLOR
{
    // pixel interpolation
    float cellSize = lerp(MIN_CELL_SIZE, MAX_CELL_SIZE, _Progress);
    float2 cellSizeVec = float2(cellSize * _WidthAspectMultiplier, cellSize);
    float2 steppedUV = i.uv.xy;
    steppedUV /= cellSizeVec;
    steppedUV = round(steppedUV);
    steppedUV *= cellSizeVec;

    fixed4 pixelColor = tex2D(_MainTex, steppedUV);

    // blend color by Progress
    fixed4 finalColor = lerp(pixelColor, _ProgressColor, _Progress);

    return finalColor;
}

ENDCG
		}
	}

	FallBack off
}
