//-------------------------------------------------------------------------------------
// Fill SurfaceData/Builtin data function
//-------------------------------------------------------------------------------------
#include "CoreRP/ShaderLibrary/Sampling/SampleUVMapping.hlsl"
#include "../MaterialUtilities.hlsl"

uniform sampler2D _DecalChannelMap;
uniform sampler2D _DecalMaskMap;
uniform sampler2D _DecalColorMap;
uniform sampler2D _DecalNormalMap;
float4 _DecalColor;
float _DecalAIntensity;
float _DecalBIntensity;
float _DecalCIntensity;
float _DecalDIntensity;
float _DecalAsperity;
float _DecalNormalScale;
float _DecalSmoothnessRemapMin;
float _DecalSmoothnessRemapMax;
float _DecalAORemapMin;
float _DecalAORemapMax;
float4 _UVMappingMaskDecals;

uniform sampler2D _GrimeMaskMap;
float _GrimeAIntensity;
float _GrimeBIntensity;
float _GrimeCIntensity;
float _GrimeDIntensity;
float4 _GrimeAColor;
float4 _GrimeBColor;
float4 _GrimeCColor;
float4 _GrimeDColor;
float _GrimeASmoothness;
float _GrimeBSmoothness;
float _GrimeCSmoothness;
float _GrimeDSmoothness;

// TODO: move this function to commonLighting.hlsl once validated it work correctly
float GetSpecularOcclusionFromBentAO(float3 V, float3 bentNormalWS, SurfaceData surfaceData)
{
    // Retrieve cone angle
    // Ambient occlusion is cosine weighted, thus use following equation. See slide 129
    float cosAv = sqrt(1.0 - surfaceData.ambientOcclusion);
    float roughness = max(PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness), 0.01); // Clamp to 0.01 to avoid edge cases
    float cosAs = exp2((-log(10.0)/log(2.0)) * Sq(roughness));
    float cosB = dot(bentNormalWS, reflect(-V, surfaceData.normalWS));

    return SphericalCapIntersectionSolidArea(cosAv, cosAs, cosB) / (TWO_PI * (1.0 - cosAs));
}

// Struct that gather UVMapping info of all layers + common calculation
// This is use to abstract the mapping that can differ on layers
struct LayerTexCoord
{
#ifndef LAYERED_LIT_SHADER
    UVMapping base;
    UVMapping details;
#else
    // Regular texcoord
    UVMapping base0;
    UVMapping base1;
    UVMapping base2;
    UVMapping base3;

    UVMapping details0;
    UVMapping details1;
    UVMapping details2;
    UVMapping details3;

    // Dedicated for blend mask
    UVMapping blendMask;
#endif

    // Store information that will be share by all UVMapping
    float3 vertexNormalWS; // TODO: store also object normal map for object triplanar
    float3 triplanarWeights;

#ifdef SURFACE_GRADIENT
    // tangent basis for each UVSet - up to 4 for now
    float3 vertexTangentWS0, vertexBitangentWS0;
    float3 vertexTangentWS1, vertexBitangentWS1;
    float3 vertexTangentWS2, vertexBitangentWS2;
    float3 vertexTangentWS3, vertexBitangentWS3;
#endif
};

#ifdef SURFACE_GRADIENT
void GenerateLayerTexCoordBasisTB(FragInputs input, inout LayerTexCoord layerTexCoord)
{
    float3 vertexNormalWS = input.worldToTangent[2];

    layerTexCoord.vertexTangentWS0 = input.worldToTangent[0];
    layerTexCoord.vertexBitangentWS0 = input.worldToTangent[1];

    // TODO: We should use relative camera position here - This will be automatic when we will move to camera relative space.
    float3 dPdx = ddx_fine(input.positionWS);
    float3 dPdy = ddy_fine(input.positionWS);

    float3 sigmaX = dPdx - dot(dPdx, vertexNormalWS) * vertexNormalWS;
    float3 sigmaY = dPdy - dot(dPdy, vertexNormalWS) * vertexNormalWS;
    //float flipSign = dot(sigmaY, cross(vertexNormalWS, sigmaX) ) ? -1.0 : 1.0;
    float flipSign = dot(dPdy, cross(vertexNormalWS, dPdx)) < 0.0 ? -1.0 : 1.0; // gives same as the commented out line above

    // TODO: Optimize! The compiler will not be able to remove the tangent space that are not use because it can't know due to our UVMapping constant we use for both base and details
    // To solve this we should track which UVSet is use for normal mapping... Maybe not as simple as it sounds
    SurfaceGradientGenBasisTB(vertexNormalWS, sigmaX, sigmaY, flipSign, input.texCoord1, layerTexCoord.vertexTangentWS1, layerTexCoord.vertexBitangentWS1);
    #if defined(_REQUIRE_UV2) || defined(_REQUIRE_UV3)
    SurfaceGradientGenBasisTB(vertexNormalWS, sigmaX, sigmaY, flipSign, input.texCoord2, layerTexCoord.vertexTangentWS2, layerTexCoord.vertexBitangentWS2);
    #endif
    #if defined(_REQUIRE_UV3)
    SurfaceGradientGenBasisTB(vertexNormalWS, sigmaX, sigmaY, flipSign, input.texCoord3, layerTexCoord.vertexTangentWS3, layerTexCoord.vertexBitangentWS3);
    #endif
}
#endif

#ifndef LAYERED_LIT_SHADER

// Want to use only one sampler for normalmap/bentnormalmap either we use OS or TS. And either we have normal map or bent normal or both.
#ifdef _NORMALMAP_TANGENT_SPACE
    #if defined(_NORMALMAP)
    #define SAMPLER_NORMALMAP_IDX sampler_NormalMap
    #elif defined(_BENTNORMALMAP)
    #define SAMPLER_NORMALMAP_IDX sampler_BentNormalMap
    #endif
#else
    #if defined(_NORMALMAP)
    #define SAMPLER_NORMALMAP_IDX sampler_NormalMapOS
    #elif defined(_BENTNORMALMAP)
    #define SAMPLER_NORMALMAP_IDX sampler_BentNormalMapOS
    #endif
#endif

#define SAMPLER_DETAILMAP_IDX sampler_DetailMap
#define SAMPLER_MASKMAP_IDX sampler_MaskMap
#define SAMPLER_HEIGHTMAP_IDX sampler_HeightMap

#define SAMPLER_SUBSURFACE_MASKMAP_IDX sampler_SubsurfaceMaskMap
#define SAMPLER_THICKNESSMAP_IDX sampler_ThicknessMap

// include LitDataIndividualLayer to define GetSurfaceData
#define LAYER_INDEX 0
#define ADD_IDX(Name) Name
#define ADD_ZERO_IDX(Name) Name
#ifdef _NORMALMAP
#define _NORMALMAP_IDX
#endif
#ifdef _NORMALMAP_TANGENT_SPACE
#define _NORMALMAP_TANGENT_SPACE_IDX
#endif
#ifdef _DETAIL_MAP
#define _DETAIL_MAP_IDX
#endif
#ifdef _SUBSURFACE_MASK_MAP
#define _SUBSURFACE_MASK_MAP_IDX
#endif
#ifdef _THICKNESSMAP
#define _THICKNESSMAP_IDX
#endif
#ifdef _MASKMAP
#define _MASKMAP_IDX
#endif
#ifdef _BENTNORMALMAP
#define _BENTNORMALMAP_IDX
#endif
#include "../Lit/LitDataIndividualLayer.hlsl"

// This maybe call directly by tessellation (domain) shader, thus all part regarding surface gradient must be done
// in function with FragInputs input as parameters
// layerTexCoord must have been initialize to 0 outside of this function
void GetLayerTexCoord(float2 texCoord0, float2 texCoord1, float2 texCoord2, float2 texCoord3,
                      float3 positionWS, float3 vertexNormalWS, inout LayerTexCoord layerTexCoord)
{
    layerTexCoord.vertexNormalWS = vertexNormalWS;
    layerTexCoord.triplanarWeights = ComputeTriplanarWeights(vertexNormalWS);

    int mappingType = UV_MAPPING_UVSET;
#if defined(_MAPPING_PLANAR)
    mappingType = UV_MAPPING_PLANAR;
#elif defined(_MAPPING_TRIPLANAR)
    mappingType = UV_MAPPING_TRIPLANAR;
#endif

    // Be sure that the compiler is aware that we don't use UV1 to UV3 for main layer so it can optimize code
    ComputeLayerTexCoord(   texCoord0, texCoord1, texCoord2, texCoord3, _UVMappingMask, _UVDetailsMappingMask,
                            _BaseColorMap_ST.xy, _BaseColorMap_ST.zw, _DetailMap_ST.xy, _DetailMap_ST.zw, 1.0, _LinkDetailsWithBase,
                            positionWS, _TexWorldScale,
                            mappingType, layerTexCoord);
}

// This is call only in this file
// layerTexCoord must have been initialize to 0 outside of this function
void GetLayerTexCoord(FragInputs input, inout LayerTexCoord layerTexCoord)
{
#ifdef SURFACE_GRADIENT
    GenerateLayerTexCoordBasisTB(input, layerTexCoord);
#endif

    GetLayerTexCoord(   input.texCoord0, input.texCoord1, input.texCoord2, input.texCoord3,
                        input.positionWS, input.worldToTangent[2].xyz, layerTexCoord);
}

#include "../Lit/LitDataDisplacement.hlsl"
#include "../Lit/LitBuiltinData.hlsl"

void GetSurfaceAndBuiltinData(FragInputs input, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
{
#ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
    LODDitheringTransition(posInput.positionSS, unity_LODFade.x);
#endif

    ApplyDoubleSidedFlipOrMirror(input); // Apply double sided flip on the vertex normal

    LayerTexCoord layerTexCoord;
    ZERO_INITIALIZE(LayerTexCoord, layerTexCoord);
    GetLayerTexCoord(input, layerTexCoord);

    float depthOffset = ApplyPerPixelDisplacement(input, V, layerTexCoord);

#ifdef _DEPTHOFFSET_ON
    ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
#endif

    // Grab the decal channels masks early so we can mask out the detail in decal areas.
    float extDetailMask = 1.0;
#ifdef _ENABLEDECALS
    float2 uvDecals =
        _UVMappingMaskDecals.x * input.texCoord0.xy +
        _UVMappingMaskDecals.y * input.texCoord1.xy +
        _UVMappingMaskDecals.z * input.texCoord2.xy +
        _UVMappingMaskDecals.w * input.texCoord3.xy;

    // Read Decal Channel texture, mult by Decal parameters
    float4 decalChannels = float4(_DecalAIntensity, _DecalBIntensity, _DecalCIntensity, _DecalDIntensity) * tex2D(_DecalChannelMap, input.texCoord0.xy);
    float4 decalColor = _DecalColor * tex2D(_DecalColorMap, uvDecals);
    float decalAlpha = decalColor.a * max(decalChannels.r, max(decalChannels.g, max(decalChannels.b, decalChannels.a)));
    extDetailMask = 1.0-decalAlpha;
#endif

    // We perform the conversion to world of the normalTS outside of the GetSurfaceData
    // so it allow us to correctly deal with detail normal map and optimize the code for the layered shaders
    float3 normalTS;
    float3 bentNormalTS;
    float3 bentNormalWS;
    float alpha = GetSurfaceData(input, layerTexCoord, surfaceData, normalTS, bentNormalTS, extDetailMask);
    GetNormalWS(input, V, normalTS, surfaceData.normalWS);

    // define here so it can be assigned in different code branches below
    float asperityMix  =_AsperityAmount;


#ifdef _ENABLEDECALS
    // Apply Decal textures info over base layer
    //=================================================

    // Decal channels and main image are accessed above, before computing the detail normals,
    // so that they can be masked by the decal alpha.

    // Read Decal normal
    float4 decalNormalRaw = tex2D(_DecalNormalMap, uvDecals);
    float3 decalNormalTS = float3(decalNormalRaw.a * 2.0 - 1.0, decalNormalRaw.g * 2.0 - 1.0, 0.0);
    decalNormalTS.z = 1.0 - decalNormalTS.x*decalNormalTS.x - decalNormalTS.y*decalNormalTS.y;
    decalNormalTS.xy = decalNormalTS.xy / decalNormalTS.z * _DecalNormalScale;

    // Read Decal Mask
    float4 decalMaskRaw = tex2D(_DecalMaskMap, uvDecals);

    // Remap Decal AO and Smoothness
    float decalSmoothness = lerp(_DecalSmoothnessRemapMin, _DecalSmoothnessRemapMax, decalMaskRaw.a);
    float decalAO = lerp(_DecalAORemapMin, _DecalAORemapMax, decalMaskRaw.g);

    // Lerp between base and Decal everything, aplying color tint when mixed
    surfaceData.baseColor.rgb = lerp( surfaceData.baseColor.rgb, decalColor.rgb, decalAlpha );
    surfaceData.normalWS = normalize(surfaceData.normalWS + (decalNormalTS.r * decalAlpha * surfaceData.tangentWS) + (decalNormalTS.g * decalAlpha * cross(surfaceData.tangentWS,surfaceData.normalWS)) );
    surfaceData.ambientOcclusion = lerp( surfaceData.ambientOcclusion, surfaceData.ambientOcclusion*decalAO, decalAlpha );
    // metallic is inactive for surfaces with SSS.  Would love to override this in the future in case we want metallic decal/damage types
    //surfaceData.metallic = lerp( surfaceData.metallic, decalMaskRaw.r, decalAlpha );
    surfaceData.perceptualSmoothness = lerp(surfaceData.perceptualSmoothness, decalSmoothness, decalAlpha);
    asperityMix = lerp(asperityMix, _DecalAsperity, decalAlpha);
#endif


#ifdef _ENABLEGRIME
    float4 grimeChannels = float4(_GrimeAIntensity, _GrimeBIntensity, _GrimeCIntensity, _GrimeDIntensity) * tex2D(_GrimeMaskMap, input.texCoord0.xy);

    surfaceData.baseColor.rgb = lerp( surfaceData.baseColor.rgb, _GrimeAColor, grimeChannels.r );
    surfaceData.baseColor.rgb = lerp( surfaceData.baseColor.rgb, _GrimeBColor, grimeChannels.g );
    surfaceData.baseColor.rgb = lerp( surfaceData.baseColor.rgb, _GrimeCColor, grimeChannels.b );
    surfaceData.baseColor.rgb = lerp( surfaceData.baseColor.rgb, _GrimeDColor, grimeChannels.a );
    surfaceData.perceptualSmoothness = lerp(surfaceData.perceptualSmoothness, _GrimeASmoothness, grimeChannels.r);
    surfaceData.perceptualSmoothness = lerp(surfaceData.perceptualSmoothness, _GrimeBSmoothness, grimeChannels.g);
    surfaceData.perceptualSmoothness = lerp(surfaceData.perceptualSmoothness, _GrimeCSmoothness, grimeChannels.b);
    surfaceData.perceptualSmoothness = lerp(surfaceData.perceptualSmoothness, _GrimeDSmoothness, grimeChannels.a);
    //assuming all grime is non-metallic
    surfaceData.metallic = lerp(surfaceData.metallic, 0.0, grimeChannels.r);
    surfaceData.metallic = lerp(surfaceData.metallic, 0.0, grimeChannels.g);
    surfaceData.metallic = lerp(surfaceData.metallic, 0.0, grimeChannels.b);
    surfaceData.metallic = lerp(surfaceData.metallic, 0.0, grimeChannels.a);

#endif


    // Use bent normal to sample GI if available
#ifdef _BENTNORMALMAP
    GetNormalWS(input, V, bentNormalTS, bentNormalWS);
#else
    bentNormalWS = surfaceData.normalWS;
#endif

    // By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
    // If user provide bent normal then we process a better term
#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
    // If we have bent normal and ambient occlusion, process a specular occlusion
    surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData);
#elif defined(_MASKMAP)
    surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
#else
    surfaceData.specularOcclusion = 1.0;
#endif

    // This is use with anisotropic material
    surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);

//#ifndef _DISABLE_DBUFFER
//    AddDecalContribution(posInput, surfaceData);
//#endif

#if defined(DEBUG_DISPLAY)
    if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
    {
        surfaceData.baseColor = GetTextureDataDebug(_DebugMipMapMode, layerTexCoord.base.uv, _BaseColorMap, _BaseColorMap_TexelSize, _BaseColorMap_MipInfo, surfaceData.baseColor);
        surfaceData.metallic = 0;
    }
#endif

    asperityMix *= pow( abs(1.0 - ClampNdotV(dot(surfaceData.normalWS, V))), _AsperityExponent );
    surfaceData.baseColor.rgb = lerp(surfaceData.baseColor.rgb, float3(1.0,1.0,1.0), asperityMix);

    // Caution: surfaceData must be fully initialize before calling GetBuiltinData
    GetBuiltinData(input, surfaceData, alpha, bentNormalWS, depthOffset, builtinData);
}

#define _CHARACTER
#include "../Lit/LitDataMeshModification.hlsl"

#endif // #ifndef LAYERED_LIT_SHADER
