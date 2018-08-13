//-------------------------------------------------------------------------------------
// Fill SurfaceData/Builtin data function
//-------------------------------------------------------------------------------------
#include "../MaterialUtilities.hlsl"

void GetSurfaceAndBuiltinData(FragInputs input, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
{
    float2 unlitColorMapUv = TRANSFORM_TEX(input.texCoord0, _UnlitColorMap);
    surfaceData.color = SAMPLE_TEXTURE2D(_UnlitColorMap, sampler_UnlitColorMap, unlitColorMapUv).rgb * _UnlitColor.rgb;
    float alpha = SAMPLE_TEXTURE2D(_UnlitColorMap, sampler_UnlitColorMap, unlitColorMapUv).a * _UnlitColor.a;

    if(_UseVertexColor)
    {
        surfaceData.color *= input.color.rgb;

        #if _SURFACE_TYPE_TRANSPARENT
            alpha             *= input.color.a;
        #endif
    }

    if (_SoftDepthEnable) alpha *= applySoftDepth(input, _SoftDepthFactor);

    if (_NoiseMapEnable)
    {
        float2 noiseMapUv = TRANSFORM_TEX(input.texCoord0, _NoiseMap);
        float noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, noiseMapUv).r;

        alpha = lerp(alpha, alpha*noise, _NoiseIntensity); 
    }

#ifdef _ALPHATEST_ON
    DoAlphaTest(alpha, _AlphaCutoff);
#endif

    // Modify opacity by the facing ratio
    #if defined(_SURFACE_TYPE_TRANSPARENT) && (_USE_FRESNEL)
        float3 normalWS = input.worldToTangent[2];
        float VdotN = dot(normalWS, V);

        if(_DoubleSidedEnable)
        {
            VdotN = abs(VdotN);
        }

        VdotN = saturate(VdotN);

        #if _ONE_MINUS_FRESNEL
            VdotN = 1-VdotN;
        #endif

        float intensityFresnelModifier = pow(VdotN, abs(_FresnelExponent));

        alpha *= intensityFresnelModifier;
    #endif
    
    // Builtin Data
    builtinData.opacity = alpha;

    builtinData.bakeDiffuseLighting = float3(0.0, 0.0, 0.0);

#ifdef _EMISSIVE_COLOR_MAP
    builtinData.emissiveColor = SAMPLE_TEXTURE2D(_EmissiveColorMap, sampler_EmissiveColorMap, TRANSFORM_TEX(input.texCoord0, _EmissiveColorMap)).rgb * _EmissiveColor;
#else
    builtinData.emissiveColor = _EmissiveColor;
#endif

    builtinData.velocity = float2(0.0, 0.0);

    builtinData.shadowMask0 = 0.0;
    builtinData.shadowMask1 = 0.0;
    builtinData.shadowMask2 = 0.0;
    builtinData.shadowMask3 = 0.0;

#if (SHADERPASS == SHADERPASS_DISTORTION) || defined(DEBUG_DISPLAY)
    float3 distortion = SAMPLE_TEXTURE2D(_DistortionVectorMap, sampler_DistortionVectorMap, input.texCoord0).rgb;
    distortion.rg = distortion.rg * _DistortionVectorScale.xx + _DistortionVectorBias.xx;
    builtinData.distortion = distortion.rg * _DistortionScale;
    builtinData.distortionBlur = clamp(distortion.b * _DistortionBlurScale, 0.0, 1.0) * (_DistortionBlurRemapMax - _DistortionBlurRemapMin) + _DistortionBlurRemapMin;
#else
    builtinData.distortion = float2(0.0, 0.0);
    builtinData.distortionBlur = 0.0;
#endif

    builtinData.depthOffset = 0.0;

#if defined(DEBUG_DISPLAY)
    if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
    {
        surfaceData.color = GetTextureDataDebug(_DebugMipMapMode, unlitColorMapUv, _UnlitColorMap, _UnlitColorMap_TexelSize, _UnlitColorMap_MipInfo, surfaceData.color);
    }
#endif
}
