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
int _SampleRadius;

// ApplyFilter
// Based on Telltale's FullScreenShadowFilter:
half4 ApplyFilter(float2 texelPosition, float2 direction)
{
    half4 baseShadow = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, texelPosition);
    float baseDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, texelPosition).x;

    float4 totalValue = baseShadow;
    float totalWeight = 1.0f;

    [unroll] for (int passIndex = 0; passIndex < 2; ++passIndex)
    {
        float2 passDirection = (passIndex == 0) ? direction : -direction;

        [unroll(5)] for (int sampleIndex = 1; sampleIndex <= _SampleRadius; ++sampleIndex)
        {
            float2 samplePosition = texelPosition + sampleIndex * passDirection;

            // TODO: pack depth into shadow alpha, save a lookup?
            half4 sampleShadow = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, samplePosition);
            float sampleDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, samplePosition).x;

            float sampleWeight = saturate(1.0f - abs(baseDepth - sampleDepth) * 1000.0f);

            totalValue += sampleShadow * sampleWeight;
            totalWeight += sampleWeight;
        }
    }

    totalValue = saturate(totalValue * rcp(totalWeight));
    return totalValue;
}

fixed4 frag (v2f i) : SV_Target
{                
    const float blurWidth = 3.0;

    #if defined(BLUR_HORIZONTAL)
        float2 delta = float2(_MainTex_TexelSize.x * blurWidth, 0.0);
        //return ApplyFilter(i.uv, delta);
    #else
        float2 delta = float2(0.0, _MainTex_TexelSize.y * blurWidth);
        //return ApplyFilter(i.uv, delta);
    #endif
    

    // Unity's Gaussian Method (adapted from PostProcessing/ScalableAO):

    half4 p0  = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
    float p0Depth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, i.uv).x;

    half4 p1a = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv - delta));
    float p1aDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, (i.uv - delta)).x;

    half4 p1b = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv + delta));
    float p1bDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, (i.uv + delta)).x;

    half4 p2a = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv - delta * 2.0));
    float p2aDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, (i.uv - delta * 2.0)).x;

    half4 p2b = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv + delta * 2.0));
    float p2bDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, (i.uv + delta * 2.0)).x;

    half4 p3a = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv - delta * 3.2307692308));
    float p3aDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, (i.uv - delta * 3.2307692308)).x;

    half4 p3b = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.uv + delta * 3.2307692308));
    float p3bDepth = SAMPLE_TEXTURE2D(_MainDepthTexture, sampler_MainDepthTexture, (i.uv + delta * 3.2307692308)).x;

    const half depthThreshold = 500.0f;
    half w0 = 0.37004405286;
    half w1a = 0.31718061674 * saturate(1.0f - abs(p0Depth - p1aDepth) * depthThreshold);
    half w1b = 0.31718061674 * saturate(1.0f - abs(p0Depth - p1bDepth) * depthThreshold);
    half w2a = 0.19823788546 * saturate(1.0f - abs(p0Depth - p2aDepth) * depthThreshold);
    half w2b = 0.19823788546 * saturate(1.0f - abs(p0Depth - p2bDepth) * depthThreshold);
    half w3a = 0.11453744493 * saturate(1.0f - abs(p0Depth - p3aDepth) * depthThreshold);
    half w3b = 0.11453744493 * saturate(1.0f - abs(p0Depth - p3bDepth) * depthThreshold);

    half4 s;
    s =  (p0)  * w0;
    s += (p1a) * w1a;
    s += (p1b) * w1b;
    s += (p2a) * w2a;
    s += (p2b) * w2b;
    s += (p3a) * w3a;
    s += (p3b) * w3b;

    s /= w0 + w1a + w1b + w2a + w2b + w3a + w3b;

    return s;
}
