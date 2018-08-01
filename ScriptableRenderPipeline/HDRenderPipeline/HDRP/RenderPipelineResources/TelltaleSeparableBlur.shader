Shader "Hidden/TelltaleSeparableBlur"
{
	Properties
	{
        _MainTex("Texture", 2D) = "white" {}
		_SampleRadius("Sample Radius", Int) = 3
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
        
        // 0 - Separable blur (horizontal pass) 
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #define BLUR_HORIZONTAL
			#include "TelltaleSeparableBlur.hlsl" 
			ENDCG
		}

        // 1 - Separable blur (vertical pass) 
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #define BLUR_VERTICAL
			#include "TelltaleSeparableBlur.hlsl"
			ENDCG
		}
	}
}
