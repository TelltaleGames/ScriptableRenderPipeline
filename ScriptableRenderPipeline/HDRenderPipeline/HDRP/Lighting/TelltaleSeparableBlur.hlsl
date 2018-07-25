#include "UnityCG.cginc"
#include "CoreRP/ShaderLibrary/Common.hlsl"

struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
};

struct v2f
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION; 
};

v2f vert (appdata v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = v.uv;
	return o;
}

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
float4 _MainTex_TexelSize;

TEXTURE2D(_MainDepthTexture); 
SAMPLER(sampler_MainDepthTexture);

sampler2D _SecondTex;
float _Blend;

// ApplyFilter
// Based on Telltale's FullScreenShadowFilter:
#define kSampleRadius 3
half4 ApplyFilter(float2 texelPosition, float2 direction)
{
    half4 baseShadow = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, texelPosition);
    float baseDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, texelPosition).x;

    float4 totalValue = baseShadow;
    float totalWeight = 1.0f;

    [unroll] for (int passIndex = 0; passIndex < 2; ++passIndex)
    {
        float2 passDirection = (passIndex == 0) ? direction : -direction;

        [unroll] for (int sampleIndex = 1; sampleIndex <= kSampleRadius; ++sampleIndex)
        {
            float2 samplePosition = texelPosition + sampleIndex * passDirection;

            // TODO: pack depth into shadow alpha, save a lookup?
            half4 sampleShadow = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, samplePosition);
            float sampleDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, samplePosition).x;

            float sampleWeight = saturate(1.0f - abs(baseDepth - sampleDepth) * 100.0f);

            totalValue += sampleShadow * sampleWeight;
            totalWeight += sampleWeight;
        }
    }

    totalValue = saturate(totalValue * rcp(totalWeight));

    return totalValue;
}

fixed4 frag (v2f i) : SV_Target
{                
    const float blurWidth = 2.0;

    #if defined(BLUR_HORIZONTAL)
        float2 delta = float2(_MainTex_TexelSize.x * blurWidth, 0.0);
    #else
        float2 delta = float2(0.0, _MainTex_TexelSize.y * blurWidth);
    #endif
    
    return ApplyFilter(i.uv, delta);

    /* Unity's Gaussian Method (adapted from PostProcessing/ScalableAO):

    half4 p0  = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
    half4 p1a = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv - delta));
    half4 p1b = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv + delta));
    half4 p2a = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv - delta * 2.0));
    half4 p2b = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv + delta * 2.0));
    half4 p3a = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv - delta * 3.2307692308));
    half4 p3b = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv + delta * 3.2307692308));

    half4 s;
    s =  (p0)  * 0.37004405286;
    s += (p1a) * 0.31718061674;
    s += (p1b) * 0.31718061674;
    s += (p2a) * 0.19823788546;
    s += (p2b) * 0.19823788546;
    s += (p3a) * 0.11453744493;
    s += (p3b) * 0.11453744493;

    return s;
    */
}