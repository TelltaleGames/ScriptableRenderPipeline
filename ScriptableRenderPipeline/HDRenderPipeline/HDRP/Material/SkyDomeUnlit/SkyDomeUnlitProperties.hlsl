
CBUFFER_START(UnityPerMaterial)

float4 _SkyColor;
float4 _SkyColorMap_ST;
float4 _SkyColorMap_TexelSize;
float4 _SkyColorMap_MipInfo;

float3 _SkyGradHorizonColor;
float3 _SkyGradZenithColor;
float _SkyGradCurveBias;

float _HorizonGradIntensity;
float3 _HorizonGradColor1;
float3 _HorizonGradColor0;
float _HorizonGradHeight;
float _HorizonGradColorBias;
float _HorizonGradAlphaBias;
float _HorizonGradDirection;
float4 _HorizonGradDirVector;
float _HorizonGradDirectionalAtten;

TEXTURE2D(_CloudDistantMap);
SAMPLER(sampler_CloudDistantMap);
float4 _CloudDistantColor;
float4 _CloudDistantMap_ST;
float  _CloudDistantScrollSpeed;
float  _CloudOverheadScrollHeading;
float4 _CloudOverheadScrollVector;
float  _CloudRimIntensity;

TEXTURE2D(_CloudOverheadMap);
SAMPLER(sampler_CloudOverheadMap);
float  _CloudOverheadHeight;
float4 _CloudOverheadColor;
float4 _CloudOverheadMap_ST;
float _CloudOverheadScrollSpeed;

TEXTURE2D(_StarMap);
SAMPLER(sampler_StarMap);
float4 _StarColor;
float4 _StarMap_ST;

float4 _SunColor;
float _SunElevation;
float _SunAzimuth;
float _SunHazeExponent;
float4 _SunVector;

// Caution: C# code in BaseLitUI.cs call LightmapEmissionFlagsProperty() which assume that there is an existing "_EmissionColor"
// value that exist to identify if the GI emission need to be enabled.
// In our case we don't use such a mechanism but need to keep the code quiet. We declare the value and always enable it.
// TODO: Fix the code in legacy unity so we can customize the behavior for GI
// float3 _EmissionColor;

CBUFFER_END
