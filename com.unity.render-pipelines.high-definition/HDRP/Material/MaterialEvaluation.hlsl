// This files include various function uses to evaluate material

//-----------------------------------------------------------------------------
// Lighting structure for light accumulation
//-----------------------------------------------------------------------------

#if defined( TT_NPR_LIGHTING )
#define kNPRLightStackCapacity 4
#endif // TT_NPR_LIGHTING

// These structure allow to accumulate lighting accross the Lit material
// AggregateLighting is init to zero and transfer to EvaluateBSDF, but the LightLoop can't access its content.
struct DirectLighting
{
    float3 diffuse;
    float3 specular;
#if defined( TT_NPR_LIGHTING )
    float nprTranslucency;
    float nprWeight;
    bool nprIsEnabled;
#endif // TT_NPR_LIGHTING
};

struct IndirectLighting
{
    float3 specularReflected;
    float3 specularTransmitted;
};

struct AggregateLighting
{
#if defined( TT_NPR_LIGHTING )
    uint4 nprLightStack[kNPRLightStackCapacity];
    float3 nprOverflowDiffuse;
    float3 nprOverflowSpecular;
#endif // TT_NPR_LIGHTING
    DirectLighting   direct;
    IndirectLighting indirect;
};

#if defined( TT_NPR_LIGHTING )

uint4 PackNPRLighting( DirectLighting src )
{
    uint4 result;
    result.x = f32tof16( src.diffuse.r ) | ( f32tof16( src.diffuse.g ) << 16 );
    result.y = f32tof16( src.diffuse.b ) | ( f32tof16( src.nprTranslucency ) << 16 );
    result.z = f32tof16( src.nprWeight ) | ( f32tof16( src.specular.r ) << 16 );
    result.w = f32tof16( src.specular.g ) | ( f32tof16( src.specular.b ) << 16 );
    return result;
}

DirectLighting UnpackNPRLighting( uint4 src )
{
    DirectLighting result;
    result.diffuse.r = f16tof32( src.x );
    result.diffuse.g = f16tof32( src.x >> 16 );
    result.diffuse.b = f16tof32( src.y );
    result.nprTranslucency = f16tof32( src.y >> 16 );
    result.nprWeight = f16tof32( src.z );
    result.specular.r = f16tof32( src.z >> 16 );
    result.specular.g = f16tof32( src.w );
    result.specular.b = f16tof32( src.w >> 16 );
    result.nprIsEnabled = true;
    return result;
}

#endif // TT_NPR_LIGHTING

void AccumulateDirectLighting(DirectLighting src, float weight, inout AggregateLighting dst)
{
#if defined( TT_NPR_LIGHTING )
    if( src.nprIsEnabled )
    {
        src.diffuse *= weight;
        src.specular *= weight;
        src.nprWeight *= weight;
        for( int i = 0; i < kNPRLightStackCapacity; ++i )
        {
            DirectLighting prev = UnpackNPRLighting( dst.nprLightStack[i] );
            if( src.nprWeight >= prev.nprWeight )
            {
                for( int j = 3; j > i; --j )
                {
                    dst.nprLightStack[j] = dst.nprLightStack[j - 1];
                }
                dst.nprLightStack[i] = PackNPRLighting( src );
                return;
            }
        }

        // TODO - overflow

        return;
    }
#endif // TT_NPR_LIGHTING

    dst.direct.diffuse += src.diffuse * weight;
    dst.direct.specular += src.specular * weight;
}

void AccumulateIndirectLighting(IndirectLighting src, inout AggregateLighting dst)
{
    dst.indirect.specularReflected += src.specularReflected;
    dst.indirect.specularTransmitted += src.specularTransmitted;
}

#if defined( TT_NPR_LIGHTING )

float EvaluateNPRLightStack( inout AggregateLighting dst )
{
    float opacity = 1.0f;
    for( int i = 0; i < kNPRLightStackCapacity; ++i )
    {
        DirectLighting src = UnpackNPRLighting( dst.nprLightStack[i] );
        if( src.nprWeight > 0.0f )
        {
            dst.direct.diffuse += src.diffuse * opacity;
            dst.direct.specular += src.specular * opacity;
            opacity *= src.nprTranslucency;
        }
    }

    return opacity;
}

#endif // TT_NPR_LIGHTING

//-----------------------------------------------------------------------------
// Ambient occlusion helper
//-----------------------------------------------------------------------------

// Ambient occlusion
struct AmbientOcclusionFactor
{
    float3 indirectAmbientOcclusion;
    float3 directAmbientOcclusion;
    float3 indirectSpecularOcclusion;

    float indirectAmbientOcclusionRaw;
    float directAmbientOcclusionRaw;
    float indirectSpecularOcclusionRaw;
};

void GetScreenSpaceAmbientOcclusion(float2 positionSS, float NdotV, float perceptualRoughness, float ambientOcclusionFromData, float specularOcclusionFromData, out AmbientOcclusionFactor aoFactor)
{
    // Note: When we ImageLoad outside of texture size, the value returned by Load is 0 (Note: On Metal maybe it clamp to value of texture which is also fine)
    // We use this property to have a neutral value for AO that doesn't consume a sampler and work also with compute shader (i.e use ImageLoad)
    // We store inverse AO so neutral is black. So either we sample inside or outside the texture it return 0 in case of neutral

    // Ambient occlusion use for indirect lighting (reflection probe, baked diffuse lighting)
#ifndef _SURFACE_TYPE_TRANSPARENT
    float indirectAmbientOcclusion = 1.0 - LOAD_TEXTURE2D(_AmbientOcclusionTexture, positionSS).x;
    // Ambient occlusion use for direct lighting (directional, punctual, area)
    float directAmbientOcclusion = lerp(1.0, indirectAmbientOcclusion, _AmbientOcclusionParam.w);
#else
    float indirectAmbientOcclusion = 1.0;
    float directAmbientOcclusion = 1.0;
#endif

    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    float specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(NdotV), indirectAmbientOcclusion, roughness);

    aoFactor.indirectSpecularOcclusion = lerp(_AmbientOcclusionParam.rgb, float3(1.0, 1.0, 1.0), min(specularOcclusionFromData, specularOcclusion));
    aoFactor.indirectAmbientOcclusion = lerp(_AmbientOcclusionParam.rgb, float3(1.0, 1.0, 1.0), min(ambientOcclusionFromData, indirectAmbientOcclusion));
    aoFactor.directAmbientOcclusion = lerp(_AmbientOcclusionParam.rgb, float3(1.0, 1.0, 1.0), directAmbientOcclusion);
    aoFactor.indirectAmbientOcclusionRaw = indirectAmbientOcclusion;
    aoFactor.directAmbientOcclusionRaw = directAmbientOcclusion;
    aoFactor.indirectSpecularOcclusionRaw = specularOcclusion;
}

void GetScreenSpaceAmbientOcclusionMultibounce(float2 positionSS, float NdotV, float perceptualRoughness, float ambientOcclusionFromData, float specularOcclusionFromData, float3 diffuseColor, float3 fresnel0, out AmbientOcclusionFactor aoFactor)
{
    // Use GTAOMultiBounce approximation for ambient occlusion (allow to get a tint from the diffuseColor)
    // Note: When we ImageLoad outside of texture size, the value returned by Load is 0 (Note: On Metal maybe it clamp to value of texture which is also fine)
    // We use this property to have a neutral value for AO that doesn't consume a sampler and work also with compute shader (i.e use ImageLoad)
    // We store inverse AO so neutral is black. So either we sample inside or outside the texture it return 0 in case of neutral

    // Ambient occlusion use for indirect lighting (reflection probe, baked diffuse lighting)
#ifndef _SURFACE_TYPE_TRANSPARENT
    float indirectAmbientOcclusion = 1.0 - LOAD_TEXTURE2D(_AmbientOcclusionTexture, positionSS).x;
    // Ambient occlusion use for direct lighting (directional, punctual, area)
    float directAmbientOcclusion = lerp(1.0, indirectAmbientOcclusion, _AmbientOcclusionParam.w);
#else
    float indirectAmbientOcclusion = 1.0;
    float directAmbientOcclusion = 1.0;
#endif

    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    float specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(NdotV), indirectAmbientOcclusion, roughness);

    aoFactor.indirectSpecularOcclusion = GTAOMultiBounce(min(specularOcclusionFromData, specularOcclusion), fresnel0);
    aoFactor.indirectAmbientOcclusion = GTAOMultiBounce(min(ambientOcclusionFromData, indirectAmbientOcclusion), diffuseColor);
    aoFactor.directAmbientOcclusion = GTAOMultiBounce(directAmbientOcclusion, diffuseColor);
    aoFactor.indirectAmbientOcclusionRaw = indirectAmbientOcclusion;
    aoFactor.directAmbientOcclusionRaw = directAmbientOcclusion;
    aoFactor.indirectSpecularOcclusionRaw = specularOcclusion;
}

void ApplyAmbientOcclusionFactor(AmbientOcclusionFactor aoFactor, inout BakeLightingData bakeLightingData, inout AggregateLighting lighting)
{
    // Note: in case of Lit, bakeLightingData.bakeDiffuseLighting contain indirect diffuse + emissive,
    // so Ambient occlusion is multiply by emissive which is wrong but not a big deal
    bakeLightingData.bakeDiffuseLighting *= aoFactor.indirectAmbientOcclusion;
    lighting.indirect.specularReflected *= aoFactor.indirectSpecularOcclusion;
#ifndef TELLTALE_CHARACTER_LIGHTING
    lighting.direct.diffuse *= aoFactor.directAmbientOcclusion;
#endif
}

#ifdef DEBUG_DISPLAY
// mipmapColor is color use to store texture streaming information in XXXData.hlsl (look for DEBUGMIPMAPMODE_NONE)
void PostEvaluateBSDFDebugDisplay(  AmbientOcclusionFactor aoFactor, BakeLightingData bakeLightingData, AggregateLighting lighting, float3 mipmapColor,
                                    inout float3 diffuseLighting, inout float3 specularLighting)
{
    if (_DebugLightingMode != 0)
    {
        // Caution: _DebugLightingMode is used in other part of the code, don't do anything outside of
        // current cases
        switch (_DebugLightingMode)
        {
        case DEBUGLIGHTINGMODE_LUX_METER:
            diffuseLighting = lighting.direct.diffuse + bakeLightingData.bakeDiffuseLighting;

            //Compress lighting values for color picker if enabled
            if (_ColorPickerMode != COLORPICKERDEBUGMODE_NONE)
                diffuseLighting = diffuseLighting / LUXMETER_COMPRESSION_RATIO;
            
            specularLighting = float3(0.0, 0.0, 0.0); // Disable specular lighting
            break;

        case DEBUGLIGHTINGMODE_INDIRECT_DIFFUSE_OCCLUSION:
            diffuseLighting = aoFactor.indirectAmbientOcclusion;
            specularLighting = float3(0.0, 0.0, 0.0); // Disable specular lighting
            break;

        case DEBUGLIGHTINGMODE_INDIRECT_SPECULAR_OCCLUSION:
            diffuseLighting = aoFactor.indirectSpecularOcclusion;
            specularLighting = float3(0.0, 0.0, 0.0); // Disable specular lighting
            break;

        case DEBUGLIGHTINGMODE_SCREEN_SPACE_TRACING_REFRACTION:
            if (_DebugLightingSubMode != DEBUGSCREENSPACETRACING_COLOR)
                diffuseLighting = lighting.indirect.specularTransmitted;
            break;

        case DEBUGLIGHTINGMODE_SCREEN_SPACE_TRACING_REFLECTION:
            if (_DebugLightingSubMode != DEBUGSCREENSPACETRACING_COLOR)
                diffuseLighting = lighting.indirect.specularReflected;
            break;

        case DEBUGLIGHTINGMODE_VISUALIZE_SHADOW_MASKS:
            #ifdef SHADOWS_SHADOWMASK
            diffuseLighting = float3(
                bakeLightingData.bakeShadowMask.r / 2 + bakeLightingData.bakeShadowMask.g / 2,
                bakeLightingData.bakeShadowMask.g / 2 + bakeLightingData.bakeShadowMask.b / 2,
                bakeLightingData.bakeShadowMask.b / 2 + bakeLightingData.bakeShadowMask.a / 2
            );
            specularLighting = float3(0, 0, 0);
            #endif
            break ;
        }
    }
    else if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
    {
        diffuseLighting = mipmapColor;
        specularLighting = float3(0.0, 0.0, 0.0); // Disable specular lighting
    }
}
#endif
