// Based on UnlitProperties.hlsl.

TEXTURE2D(_CloudHorizonMap);
SAMPLER(sampler_CloudHorizonMap);

TEXTURE2D(_CloudOverheadMap);
SAMPLER(sampler_CloudOverheadMap);

TEXTURE2D(_BackdropMap);
SAMPLER(sampler_BackdropMap);
TEXTURE2D(_BackdropEmissiveMap);
SAMPLER(sampler_BackdropEmissiveMap);

TEXTURE2D(_StarMap);
SAMPLER(sampler_StarMap);

TEXTURE2D(_StarMilkyWayMap);
SAMPLER(sampler_StarMilkyWayMap);

TEXTURE2D(_StarTwinkleMap);
SAMPLER(sampler_StarTwinkleMap);


CBUFFER_START(UnityPerMaterial)

float4 _BackdropColor;
float4 _BackdropEmissiveColor;
float4 _BackdropMap_ST;
float _BackdropFogTop;
float4 _BackdropFogTopColor;
float _BackdropFogBottom;
float4 _BackdropFogBottomColor;

float3 _SkyGradHorizonColor;
float3 _SkyGradZenithColor;
float _SkyGradCurveBias;
float _SkyGradTop;
float _SkyGradBottom;

float _HorizonGradEnable;
float _HorizonGradIntensity;
float3 _HorizonGradColor1;
float3 _HorizonGradColor0;
float _HorizonGradHeight;
float _HorizonGradColorBias;
float _HorizonGradAlphaBias;
float _HorizonGradDirection;
float4 _HorizonGradDirVector;
float _HorizonGradDirectionalAtten;

float  _CloudHorizonEnable;
float4 _CloudHorizonColor;
float3 _CloudHorizonUnlitColor;
float _CloudHorizonLighting;
float4 _CloudHorizonMap_ST;
float  _CloudHorizonScrollSpeed;
float  _CloudHorizonRim;
float  _CloudOverheadScrollHeading;

float  _CloudOverheadEnable;
float4 _CloudOverheadScrollVector;
float  _CloudOverheadHeight;
float4 _CloudOverheadColor;
float4 _CloudOverheadMap_ST;
float _CloudOverheadScrollSpeed;

float _StarEnable;
float4 _StarColor;
float4 _StarMap_ST;
float4 _StarTwinkleMap_ST;
float _StarMilkyWayIntensity;
float _StarTwinkleIntensity;
float _StarTwinkleSpeed;

float _SunEnable;
float _SunRadius;
float4 _SunColor;
float _SunElevation;
float _SunAzimuth;
float4 _SunVector;
float4 _SunGlowColor;
float _SunGlowExponent;
float4 _SunHazeColor;
float _SunHazeExponent;

// Caution: C# code in BaseLitUI.cs call LightmapEmissionFlagsProperty() which assume that there is an existing "_EmissionColor"
// value that exist to identify if the GI emission need to be enabled.
// In our case we don't use such a mechanism but need to keep the code quiet. We declare the value and always enable it.
// TODO: Fix the code in legacy unity so we can customize the behavior for GI
// float3 _EmissionColor;

// Following two variables are feeded by the C++ Editor for Scene selection
int _ObjectId;
int _PassValue;

CBUFFER_END
