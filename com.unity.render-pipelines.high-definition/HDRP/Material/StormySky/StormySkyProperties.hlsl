TEXTURE2D(_CloudTex1);
SAMPLER(sampler_CloudTex1);

TEXTURE2D(_FlowTex1);
SAMPLER(sampler_FlowTex1);

TEXTURE2D(_CloudTex2);
SAMPLER(sampler_CloudTex2);

TEXTURE2D(_WaveTex);
SAMPLER(sampler_WaveTex);

TEXTURE2D(_ColorTex);
SAMPLER(sampler_ColorTex);



CBUFFER_START(UnityPerMaterial)

//=========================================================
//  Properties from
//      http://vfxmike.blogspot.com/2018/07/dark-and-stormy.html

//float4 _Tiling1;
float4 _CloudTex1_ST;
//float4 _Tiling2;
float4 _CloudTex2_ST;
//float4 _TilingWave;
float4 _WaveTex_ST;
float4 _FlowTex1_ST;
float4 _ColorTex_ST;

float _CloudScale;
float _CloudBias;

float _Cloud2Amount;
float _WaveAmount;
float _WaveDistort;
float _FlowSpeed;
float _FlowAmount;

float4 _TilingColor;

float4 _Color;
float4 _Color2;

float _CloudDensity;

float _BumpOffset;
float _Steps;

float _CloudHeight;
float _Scale;
float _Speed;

float4 _LightSpread;

float4 _FoggyColor;
float _FoggyDistance;

float4 _SunColor;
float4 _SunVector;

float _ColPow;
float _ColFactor;

//=========================================================
/*
float4  _UnlitColor;
float4 _UnlitColorMap_ST;
float4 _UnlitColorMap_TexelSize;
float4 _UnlitColorMap_MipInfo;

float3 _EmissiveColor;
float4 _EmissiveColorMap_ST;

float _AlphaCutoff;
float _DistortionScale;
float _DistortionVectorScale;
float _DistortionVectorBias;
float _DistortionBlurScale;
float _DistortionBlurRemapMin;
float _DistortionBlurRemapMax;
*/
// Caution: C# code in BaseLitUI.cs call LightmapEmissionFlagsProperty() which assume that there is an existing "_EmissionColor"
// value that exist to identify if the GI emission need to be enabled.
// In our case we don't use such a mechanism but need to keep the code quiet. We declare the value and always enable it.
// TODO: Fix the code in legacy unity so we can customize the behavior for GI
float3 _EmissionColor;

// Following two variables are feeded by the C++ Editor for Scene selection
int _ObjectId;
int _PassValue;

CBUFFER_END
