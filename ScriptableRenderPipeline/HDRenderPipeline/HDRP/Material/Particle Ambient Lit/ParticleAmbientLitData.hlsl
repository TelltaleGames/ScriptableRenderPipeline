//-------------------------------------------------------------------------------------
// Fill SurfaceData/Builtin data function
//-------------------------------------------------------------------------------------
#include "../MaterialUtilities.hlsl"

void GetSurfaceAndBuiltinData(FragInputs input, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
{
    float2 unlitColorMapUv = TRANSFORM_TEX(input.texCoord0, _UnlitColorMap);
    surfaceData.color = SAMPLE_TEXTURE2D(_UnlitColorMap, sampler_UnlitColorMap, unlitColorMapUv).rgb * _UnlitColor.rgb;
    float alpha = SAMPLE_TEXTURE2D(_UnlitColorMap, sampler_UnlitColorMap, unlitColorMapUv).a * _UnlitColor.a;

    surfaceData.color *= input.color.rgb;
    alpha             *= input.color.a;

    float sceneDepth = LinearEyeDepth(LOAD_TEXTURE2D(_MainDepthTexture, input.positionSS.xy).x,_ZBufferParams);    
    float diff = abs(sceneDepth - input.positionSS.w) / _SoftDepthFactor;

    alpha *= saturate(diff);

#ifdef _ALPHATEST_ON
    DoAlphaTest(alpha, _AlphaCutoff);
#endif

    // Builtin Data
    builtinData.opacity = alpha;

    // Need to figure out why this doesn't work
    //builtinData.bakeDiffuseLighting = SampleBakedGI(input.positionWS, input.worldToTangent[2], input.texCoord1, input.texCoord2);
    builtinData.bakeDiffuseLighting = float3(0.0, 0.0, 0.0);

    float3 bakedGI = SampleBakedGI(input.positionWS, input.worldToTangent[2], input.texCoord1, input.texCoord2);
    surfaceData.color = lerp(surfaceData.color, surfaceData.color * bakedGI, _LightingContribution);

    // Emissive Intensity is only use here, but is part of BuiltinData to enforce UI parameters as we want the users to fill one color and one intensity
    builtinData.emissiveIntensity = _EmissiveIntensity;

#ifdef _EMISSIVE_COLOR_MAP
    builtinData.emissiveColor = SAMPLE_TEXTURE2D(_EmissiveColorMap, sampler_EmissiveColorMap, TRANSFORM_TEX(input.texCoord0, _EmissiveColorMap)).rgb * _EmissiveColor * builtinData.emissiveIntensity;
#else

    builtinData.emissiveColor = _EmissiveColor * builtinData.emissiveIntensity;
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
