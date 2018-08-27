#ifndef UNITY_DECALPROPERTIES_INCLUDED
#define UNITY_DECALPROPERTIES_INCLUDED

TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_MaskMap);
SAMPLER(sampler_MaskMap);

float _Metallic;
float _Smoothness;
float _SmoothnessRemapMin;
float _SmoothnessRemapMax;

float _NormalMapIntensity;
float _NormalAdd;
float _DecalBlend;
float4 _BaseColor;

#endif
