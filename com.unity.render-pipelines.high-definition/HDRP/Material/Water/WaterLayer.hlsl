void ADD_IDX(ComputeLayerTexCoord)( // Uv related parameters
                                    float2 texCoord0, float2 texCoord1, float2 texCoord2, float2 texCoord3, float4 uvMappingMask, float4 uvMappingMaskDetails,
                                    // scale and bias for base and detail + global tiling factor (for layered lit only)
                                    float2 texScale, float2 texBias, float2 texScaleDetails, float2 texBiasDetails, float additionalTiling, float linkDetailsWithBase,
                                    // parameter for planar/triplanar
                                    float3 positionWS, float worldScale,
                                    // mapping type and output
                                    int mappingType, inout LayerTexCoord layerTexCoord)
{
    // Handle uv0, uv1, uv2, uv3 based on _UVMappingMask weight (exclusif 0..1)
    float2 uvBase = uvMappingMask.x * texCoord0 +
                    uvMappingMask.y * texCoord1 +
                    uvMappingMask.z * texCoord2 +
                    uvMappingMask.w * texCoord3;

    // Only used with layered, allow to have additional tiling
    uvBase *= additionalTiling.xx;


    float2 uvDetails =  uvMappingMaskDetails.x * texCoord0 +
                        uvMappingMaskDetails.y * texCoord1 +
                        uvMappingMaskDetails.z * texCoord2 +
                        uvMappingMaskDetails.w * texCoord3;

    uvDetails *= additionalTiling.xx;

    // If base is planar/triplanar then detail map is forced to be planar/triplanar
    ADD_IDX(layerTexCoord.details).mappingType = ADD_IDX(layerTexCoord.base).mappingType = mappingType;
    ADD_IDX(layerTexCoord.details).normalWS = ADD_IDX(layerTexCoord.base).normalWS = layerTexCoord.vertexNormalWS;
    // Copy data for the uvmapping
    ADD_IDX(layerTexCoord.details).triplanarWeights = ADD_IDX(layerTexCoord.base).triplanarWeights = layerTexCoord.triplanarWeights;

    // TODO: Currently we only handle world planar/triplanar but we may want local planar/triplanar.
    // In this case both position and normal need to be convert to object space.

    // planar/triplanar
    float2 uvXZ;
    float2 uvXY;
    float2 uvZY;

    GetTriplanarCoordinate(GetAbsolutePositionWS(positionWS) * worldScale, uvXZ, uvXY, uvZY);

    // Planar is just XZ of triplanar
    if (mappingType == UV_MAPPING_PLANAR)
    {
        uvBase = uvDetails = uvXZ;
    }

    // Apply tiling options
    ADD_IDX(layerTexCoord.base).uv = uvBase * texScale + texBias;
    // Detail map tiling option inherit from the tiling of the base
    ADD_IDX(layerTexCoord.details).uv = uvDetails * texScaleDetails + texBiasDetails;
    if (linkDetailsWithBase > 0.0)
    {
        ADD_IDX(layerTexCoord.details).uv = ADD_IDX(layerTexCoord.details).uv * texScale + texBias;
    }

    ADD_IDX(layerTexCoord.base).uvXZ = uvXZ * texScale + texBias;
    ADD_IDX(layerTexCoord.base).uvXY = uvXY * texScale + texBias;
    ADD_IDX(layerTexCoord.base).uvZY = uvZY * texScale + texBias;

    ADD_IDX(layerTexCoord.details).uvXZ = uvXZ * texScaleDetails + texBiasDetails;
    ADD_IDX(layerTexCoord.details).uvXY = uvXY * texScaleDetails + texBiasDetails;
    ADD_IDX(layerTexCoord.details).uvZY = uvZY * texScaleDetails + texBiasDetails;

    if (linkDetailsWithBase > 0.0)
    {
        ADD_IDX(layerTexCoord.details).uvXZ = ADD_IDX(layerTexCoord.details).uvXZ * texScale + texBias;
        ADD_IDX(layerTexCoord.details).uvXY = ADD_IDX(layerTexCoord.details).uvXY * texScale + texBias;
        ADD_IDX(layerTexCoord.details).uvZY = ADD_IDX(layerTexCoord.details).uvZY * texScale + texBias;
    }


    #ifdef SURFACE_GRADIENT
    // This part is only relevant for normal mapping with UV_MAPPING_UVSET
    // Note: This code work only in pixel shader (as we rely on ddx), it should not be use in other context
    ADD_IDX(layerTexCoord.base).tangentWS = uvMappingMask.x * layerTexCoord.vertexTangentWS0 +
                                            uvMappingMask.y * layerTexCoord.vertexTangentWS1 +
                                            uvMappingMask.z * layerTexCoord.vertexTangentWS2 +
                                            uvMappingMask.w * layerTexCoord.vertexTangentWS3;

    ADD_IDX(layerTexCoord.base).bitangentWS =   uvMappingMask.x * layerTexCoord.vertexBitangentWS0 +
                                                uvMappingMask.y * layerTexCoord.vertexBitangentWS1 +
                                                uvMappingMask.z * layerTexCoord.vertexBitangentWS2 +
                                                uvMappingMask.w * layerTexCoord.vertexBitangentWS3;

    ADD_IDX(layerTexCoord.details).tangentWS =  uvMappingMaskDetails.x * layerTexCoord.vertexTangentWS0 +
                                                uvMappingMaskDetails.y * layerTexCoord.vertexTangentWS1 +
                                                uvMappingMaskDetails.z * layerTexCoord.vertexTangentWS2 +
                                                uvMappingMaskDetails.w * layerTexCoord.vertexTangentWS3;

    ADD_IDX(layerTexCoord.details).bitangentWS =    uvMappingMaskDetails.x * layerTexCoord.vertexBitangentWS0 +
                                                    uvMappingMaskDetails.y * layerTexCoord.vertexBitangentWS1 +
                                                    uvMappingMaskDetails.z * layerTexCoord.vertexBitangentWS2 +
                                                    uvMappingMaskDetails.w * layerTexCoord.vertexBitangentWS3;
    #endif
}



// Caution: Duplicate from GetNormalTS - keep in sync!

float3 ADD_IDX(GetBentNormalTS)(FragInputs input, LayerTexCoord layerTexCoord, float3 normalTS, float3 detailNormalTS, float detailMask)
{
    float3 bentNormalTS;
    bentNormalTS = normalTS;
    return bentNormalTS;
}


// Return opacity
float ADD_IDX(GetSurfaceData)(FragInputs input, LayerTexCoord layerTexCoord, out SurfaceData surfaceData, out float mask, out float3 normalTS, out float3 bentNormalTS, float extDetailMask = 1.0)
{
    float alpha = SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_BaseColorMap), ADD_ZERO_IDX(sampler_BaseColorMap), ADD_IDX(layerTexCoord.base)).a * ADD_IDX(_BaseColor).a;

    float linearEyeDepth = LinearEyeDepth(LOAD_TEXTURE2D(_MainDepthTexture, input.positionSS.xy).x,_ZBufferParams);
    float waterDepth = abs(linearEyeDepth - input.positionSS.w);
    float density = max(_MurkDensity,0.0);
    //alpha = saturate(waterDepth/density);
    //alpha = 1.0 - ( 1.0 / pow(2.718,waterDepth*density) );
    alpha = 1.0 - ( 1.0 / exp(waterDepth*density) );
    //alpha = 0.1 + 0.9*alpha;

    float softDepth = max(_SoftDepth,0.0);
    mask = saturate(waterDepth/softDepth);

    float3 detailNormalTS = float3(0.0, 0.0, 0.0);
    float detailMask = 0.0;
#ifdef _DETAIL_MAP_IDX
    detailMask = extDetailMask;
    #ifdef _MASKMAP_IDX
        detailMask = extDetailMask * SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_MaskMap), SAMPLER_MASKMAP_IDX, ADD_IDX(layerTexCoord.base)).b;
    #endif
    float2 detailAlbedoAndSmoothness = SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_DetailMap), SAMPLER_DETAILMAP_IDX, ADD_IDX(layerTexCoord.details)).rb;
    // TT Mod - Old code commented out.  New version includes the offset and scaling, to avoid repeating the same math several times below.
    // This only works with the newer overlay functions below, not with the originals.
    //float detailAlbedo = detailAlbedoAndSmoothness.r;
    //float detailSmoothness = detailAlbedoAndSmoothness.g;
    float detailAlbedo = _DetailAlbedoScale * (detailAlbedoAndSmoothness.r - 0.5);
    float detailSmoothness = _DetailSmoothnessScale * (detailAlbedoAndSmoothness.g - 0.5);
    // Resample the detail map but this time for the normal map. This call should be optimize by the compiler
    // We split both call due to trilinear mapping
    detailNormalTS = SAMPLE_UVMAPPING_NORMALMAP_AG(ADD_IDX(_DetailMap), SAMPLER_DETAILMAP_IDX, ADD_IDX(layerTexCoord.details), ADD_IDX(_DetailNormalScale));
#endif

    surfaceData.baseColor = SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_BaseColorMap), ADD_ZERO_IDX(sampler_BaseColorMap), ADD_IDX(layerTexCoord.base)).rgb * ADD_IDX(_BaseColor).rgb;
    float3 shorewaveMap = SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_ShorelineMap), ADD_ZERO_IDX(sampler_ShorelineMap), ADD_IDX(layerTexCoord.base)).rgb;
    float shorewaveWeight = saturate( 1-2.2*(abs(shorewaveMap.b-0.5)) );
    shorewaveWeight *= SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_ShorelineMap), ADD_ZERO_IDX(sampler_ShorelineMap), ADD_IDX(layerTexCoord.base)).a;
    float shorewaveSpeed = 5.0;
    float shorewaves = sin(_Time.y * shorewaveSpeed + shorewaveMap.b * 100.0);
    shorewaves *= shorewaveWeight;
    //surfaceData.baseColor = float3(shorewaves,shorewaves,shorewaves);
/*
    // offsetting the normal for the shoreline waves.  Totally getting the wrong result here...
    normalTS = float3(-1+2*shorewaveMap.r, 0.0, -1+2*shorewaveMap.g)*shorewaves;
    normalTS = normalize(float3(normalTS.x, 1.0, normalTS.z));
    normalTS = float3(shorewaveMap.r, 1.0, shorewaveMap.g);
*/

#ifdef _DETAIL_MAP_IDX
    // Use overlay blend mode for detail abledo: (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
    // float3 baseColorOverlay = (detailAlbedo < 0.5) ?
    //                            surfaceData.baseColor * PositivePow(2.0 * detailAlbedo, ADD_IDX(_DetailAlbedoScale)) :
    //                            1.0 - (1.0 - surfaceData.baseColor) * PositivePow(2.0 * (1.0 - detailAlbedo), ADD_IDX(_DetailAlbedoScale));
    // TT Mod - This is much improved, linear in response, and has no problems with black or white signal in the detail maps.
    float3 baseColorOverlay = (detailAlbedo < 0.0) ?
                                    surfaceData.baseColor + surfaceData.baseColor*detailAlbedo :
                                    surfaceData.baseColor + (1.0-surfaceData.baseColor)*detailAlbedo;


    // Lerp with details mask
    surfaceData.baseColor = lerp(surfaceData.baseColor, saturate(baseColorOverlay), detailMask);
#endif

    surfaceData.specularOcclusion = 1.0; // Will be setup outside of this function
    surfaceData.normalWS = float3(0.0, 0.0, 0.0); // Need to init this to keep quiet the compiler, but this is overriden later (0, 0, 0) so if we forget to override the compiler may comply.

// using this flag for flow map for water.  tangent map never used for water.
#ifdef _TANGENTMAP
    float flowSpeed = _TangentFlowSpeed;
    float flowDistance = 0.1;
    float2 tangentTS = SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_TangentFlowMap), ADD_ZERO_IDX(sampler_TangentFlowMap), ADD_IDX(layerTexCoord.base)).xy;
    tangentTS = flowDistance * 2.0 * float2( tangentTS.x-0.5, tangentTS.y-0.5 );
    //surfaceData.tangentWS = tangentTS;
    float flowWeightA = 2.0 * abs(fmod(_Time.y*flowSpeed,1.0) - 0.5);
    float flowWeightB = 1.0 - flowWeightA;
    float2 flowOffsetA = 2.0 * (fmod(_Time.y*flowSpeed-0.5,1.0) - 0.5) * tangentTS;
    float2 flowOffsetB = 2.0 * (fmod(_Time.y*flowSpeed,1.0) - 0.5) * tangentTS;
#else
    //float3 tangentTS = float3(1,0,0);
#endif
    surfaceData.tangentWS = float3(1.0,0.0,0.0); // not used, just filling in struct


#ifdef _NORMALMAP_IDX

    UVMapping waves_uv = layerTexCoord.base;
    waves_uv.uv = layerTexCoord.base.uv * _NormalFrequency;
    UVMapping norm1_uv = waves_uv;
    UVMapping norm2_uv = waves_uv;
    float2 timeOffset1 = _Time.y * _NormalMap1Vec.xz * _NormalMap1Vec.w;
    float2 timeOffset2 = _Time.y * _NormalMap2Vec.xz * _NormalMap2Vec.w;
    float norm1scale = _NormalScale1; // * (1.0-shorewaves);
    float norm2scale = _NormalScale2; // * (1.0-shorewaves);
    // check for flow map - need to read textures twice & blend if using flow
    #ifdef _TANGENTMAP
        // flow texture A
        norm1_uv.uv = waves_uv.uv + timeOffset1 + flowOffsetA;
        norm2_uv.uv = waves_uv.uv + timeOffset2 + flowOffsetA;
        float3 normalTS1 = SAMPLE_UVMAPPING_NORMALMAP(ADD_IDX(_NormalMap1), SAMPLER_NORMALMAP1_IDX, ADD_IDX(norm1_uv), ADD_IDX(norm1scale));
        normalTS1 += SAMPLE_UVMAPPING_NORMALMAP(ADD_IDX(_NormalMap2), SAMPLER_NORMALMAP2_IDX, ADD_IDX(norm2_uv), ADD_IDX(norm2scale));
        // flow texture B
        norm1_uv.uv = waves_uv.uv + timeOffset1 + flowOffsetB;
        norm2_uv.uv = waves_uv.uv + timeOffset2 + flowOffsetB;
        float3 normalTS2 = SAMPLE_UVMAPPING_NORMALMAP(ADD_IDX(_NormalMap1), SAMPLER_NORMALMAP1_IDX, ADD_IDX(norm1_uv), ADD_IDX(norm1scale));
        normalTS2 += SAMPLE_UVMAPPING_NORMALMAP(ADD_IDX(_NormalMap2), SAMPLER_NORMALMAP2_IDX, ADD_IDX(norm2_uv), ADD_IDX(norm2scale));
        // final mix
        normalTS = flowWeightA * normalTS1 + flowWeightB * normalTS2;
    #else
        norm1_uv.uv = waves_uv.uv + _Time.y * _NormalMap1Vec.xz * _NormalMap1Vec.w;
        norm2_uv.uv = waves_uv.uv + _Time.y * _NormalMap2Vec.xz * _NormalMap2Vec.w;
        normalTS = SAMPLE_UVMAPPING_NORMALMAP(ADD_IDX(_NormalMap1), SAMPLER_NORMALMAP1_IDX, ADD_IDX(norm1_uv), ADD_IDX(norm1scale));
        normalTS += SAMPLE_UVMAPPING_NORMALMAP(ADD_IDX(_NormalMap2), SAMPLER_NORMALMAP2_IDX, ADD_IDX(norm2_uv), ADD_IDX(norm2scale));
    #endif
#else
    normalTS = float3(0.0, 0.0, 1.0);
#endif



    // this just sets bnm to normal for water shader
    bentNormalTS = ADD_IDX(GetBentNormalTS)(input, layerTexCoord, normalTS, detailNormalTS, detailMask);

#if defined(_MASKMAP_IDX)
    surfaceData.perceptualSmoothness = SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_MaskMap), SAMPLER_MASKMAP_IDX, ADD_IDX(layerTexCoord.base)).a;
    surfaceData.perceptualSmoothness = lerp(ADD_IDX(_SmoothnessRemapMin), ADD_IDX(_SmoothnessRemapMax), surfaceData.perceptualSmoothness);
#else
    surfaceData.perceptualSmoothness = ADD_IDX(_Smoothness);
#endif

#ifdef _DETAIL_MAP_IDX
    // Use overlay blend mode for detail abledo: (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
    //float smoothnessOverlay = (detailSmoothness < 0.5) ?
    //                            surfaceData.perceptualSmoothness * PositivePow(2.0 * detailSmoothness, ADD_IDX(_DetailSmoothnessScale)) :
    //                            1.0 - (1.0 - surfaceData.perceptualSmoothness) * PositivePow(2.0 * (1.0 - detailSmoothness), ADD_IDX(_DetailSmoothnessScale));
    // TT Mod - This is much improved, linear in response, and has no problems with black or white signal in the detail maps.
    float smoothnessOverlay = (detailSmoothness < 0.0) ?
                                    surfaceData.perceptualSmoothness + surfaceData.perceptualSmoothness*detailSmoothness :
                                    surfaceData.perceptualSmoothness + (1.0-surfaceData.perceptualSmoothness)*detailSmoothness;
    // Lerp with details mask
    surfaceData.perceptualSmoothness = lerp(surfaceData.perceptualSmoothness, saturate(smoothnessOverlay), detailMask);
#endif

    // MaskMap is RGBA: Metallic, Ambient Occlusion (Optional), detail Mask (Optional), Smoothness
#ifdef _MASKMAP_IDX
    surfaceData.metallic = SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_MaskMap), SAMPLER_MASKMAP_IDX, ADD_IDX(layerTexCoord.base)).r;
    surfaceData.ambientOcclusion = SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_MaskMap), SAMPLER_MASKMAP_IDX, ADD_IDX(layerTexCoord.base)).g;
    surfaceData.ambientOcclusion = lerp(ADD_IDX(_AORemapMin), ADD_IDX(_AORemapMax), surfaceData.ambientOcclusion);
#else
    surfaceData.metallic = 1.0;
    surfaceData.ambientOcclusion = 1.0;
#endif
    surfaceData.metallic *= ADD_IDX(_Metallic);

    surfaceData.diffusionProfile = ADD_IDX(_DiffusionProfile);
    surfaceData.subsurfaceMask = ADD_IDX(_SubsurfaceMask);

#ifdef _SUBSURFACE_MASK_MAP_IDX
    surfaceData.subsurfaceMask *= SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_SubsurfaceMaskMap), SAMPLER_SUBSURFACE_MASK_MAP_IDX, ADD_IDX(layerTexCoord.base)).r;
#endif

#ifdef _THICKNESSMAP_IDX
    surfaceData.thickness = SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_ThicknessMap), SAMPLER_THICKNESSMAP_IDX, ADD_IDX(layerTexCoord.base)).r;
    surfaceData.thickness = ADD_IDX(_ThicknessRemap).x + ADD_IDX(_ThicknessRemap).y * surfaceData.thickness;
#else
    surfaceData.thickness = ADD_IDX(_Thickness);
#endif

    // This part of the code is not used in case of layered shader but we keep the same macro system for simplicity
#if !defined(LAYERED_LIT_SHADER)

    // These static material feature allow compile time optimization
    surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;

//#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
//    surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
//#endif
//#ifdef _MATERIAL_FEATURE_TRANSMISSION
//    surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
//#endif
//#ifdef _MATERIAL_FEATURE_ANISOTROPY
//    surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
//#endif
//#ifdef _MATERIAL_FEATURE_CLEAR_COAT
//    surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
//#endif
//#ifdef _MATERIAL_FEATURE_IRIDESCENCE
//    surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
//#endif
//#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
//    surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
//#endif
//#ifdef _MATERIAL_FEATURE_HAIR
//    surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_HAIR;
//#endif

    surfaceData.anisotropy = 0.0; //*= ADD_IDX(_Anisotropy);
    surfaceData.specularColor = _SpecularColor.rgb;
/*
#ifdef _SPECULARCOLORMAP
    surfaceData.specularColor *= SAMPLE_UVMAPPING_TEXTURE2D(_SpecularColorMap, sampler_SpecularColorMap, layerTexCoord.base).rgb;
#endif
#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
    // Require to have setup baseColor
    // Reproduce the energy conservation done in legacy Unity. Not ideal but better for compatibility and users can unchek it
    surfaceData.baseColor *= _EnergyConservingSpecularColor > 0.0 ? (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b)) : 1.0;
#endif
*/

#if HAS_REFRACTION
    surfaceData.ior = _Ior;
    surfaceData.transmittanceColor = _TransmittanceColor;
    #ifdef _TRANSMITTANCECOLORMAP
    surfaceData.transmittanceColor *= SAMPLE_UVMAPPING_TEXTURE2D(_TransmittanceColorMap, sampler_TransmittanceColorMap, ADD_IDX(layerTexCoord.base)).rgb;
    #endif

    surfaceData.atDistance = _ATDistance;
    // Thickness already defined with SSS (from both thickness and thicknessMap)
    surfaceData.thickness *= _ThicknessMultiplier;
    // Rough refraction don't use opacity. Instead we use opacity as a transmittance mask.
    surfaceData.transmittanceMask = 1.0 - alpha;
    alpha = 1.0;
#else
    surfaceData.ior = 1.0;
    surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
    surfaceData.atDistance = 1.0;
    surfaceData.transmittanceMask = 0.0;
#endif
/*
#ifdef _MATERIAL_FEATURE_CLEAR_COAT
    surfaceData.coatMask = _CoatMask;
    // To shader feature for keyword to limit the variant
    surfaceData.coatMask *= SAMPLE_UVMAPPING_TEXTURE2D(ADD_IDX(_CoatMaskMap), ADD_ZERO_IDX(sampler_CoatMaskMap), ADD_IDX(layerTexCoord.base)).r;
#else
*/
    surfaceData.coatMask = 0.0;
//#endif
/*
#ifdef _MATERIAL_FEATURE_IRIDESCENCE
    #ifdef _IRIDESCENCE_THICKNESSMAP
    surfaceData.iridescenceThickness = SAMPLE_UVMAPPING_TEXTURE2D(_IridescenceThicknessMap, sampler_IridescenceThicknessMap, layerTexCoord.base).r;
    surfaceData.iridescenceThickness = _IridescenceThicknessRemap.x + _IridescenceThicknessRemap.y * surfaceData.iridescenceThickness;
    #else
    surfaceData.iridescenceThickness = _IridescenceThickness;
    #endif
    surfaceData.iridescenceMask = _IridescenceMask;
    surfaceData.iridescenceMask *= SAMPLE_UVMAPPING_TEXTURE2D(_IridescenceMaskMap, sampler_IridescenceMaskMap, layerTexCoord.base).r;
#else
*/
    surfaceData.iridescenceThickness = 0.0;
    surfaceData.iridescenceMask = 0.0;
//#endif

// Using the Character shader, but maybe not hair, so we have to fill in the struct data
/*
#ifdef UNITY_MATERIAL_CHARACTERLIT
    surfaceData.hairShiftPrimary = 0.0;
    surfaceData.hairShiftSecondary = 0.0;
    surfaceData.hairSmoothnessPrimary = 0.0;
    surfaceData.hairSmoothnessSecondary = 0.0;
    surfaceData.specularColor = float3(1,1,1);
    surfaceData.hairOffset = 0.0;
    surfaceData.anisotropy = 0.0;//_Anisotropy;
#endif
#ifdef _MATERIAL_FEATURE_HAIR
    surfaceData.hairShiftPrimary = _HairShiftPrimary;
    surfaceData.hairShiftSecondary = _HairShiftSecondary;
    surfaceData.hairSmoothnessPrimary = _HairSmoothnessPrimary;
    surfaceData.hairSmoothnessSecondary = _HairSmoothnessSecondary;
    surfaceData.specularColor = tex2D(_HairSpecularMap, layerTexCoord.base.uv).rgb * _HairSpecularColor;
    surfaceData.anisotropy = 0.8; // used for IBL, not direct lighting of hair
#endif
*/
#else // #if !defined(LAYERED_LIT_SHADER)

    // Mandatory to setup value to keep compiler quiet

    // Layered shader material feature are define outside of this call
    surfaceData.materialFeatures = 0;

    // All these parameters are ignore as they are re-setup outside of the layers function
    // Note: any parameters set here must also be set in GetSurfaceAndBuiltinData() layer version
    surfaceData.tangentWS = float3(0.0, 0.0, 0.0);
    surfaceData.anisotropy = 0.0;
    surfaceData.specularColor = float3(0.0, 0.0, 0.0);
    surfaceData.iridescenceThickness = 0.0;
    surfaceData.iridescenceMask = 0.0;
    surfaceData.coatMask = 0.0;

    // Transparency
    surfaceData.ior = 1.0;
    surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
    surfaceData.atDistance = 1000000.0;
    surfaceData.transmittanceMask = 0.0;

#endif // #if !defined(LAYERED_LIT_SHADER)

    return alpha;
}
