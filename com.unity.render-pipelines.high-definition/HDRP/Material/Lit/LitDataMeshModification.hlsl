float3 GetVertexDisplacement(float3 positionWS, float3 normalWS, float2 texCoord0, float2 texCoord1, float2 texCoord2, float2 texCoord3, float4 vertexColor)
{
    // This call will work for both LayeredLit and Lit shader
    LayerTexCoord layerTexCoord;
    ZERO_INITIALIZE(LayerTexCoord, layerTexCoord);
    GetLayerTexCoord(texCoord0, texCoord1, texCoord2, texCoord3, positionWS, normalWS, layerTexCoord);

    // TODO: do this algorithm for lod fetching as lod not available in vertex/domain shader
    // http://www.sebastiansylvan.com/post/the-problem-with-tessellation-in-directx-11/
    float lod = 0.0;
    return ComputePerVertexDisplacement(layerTexCoord, vertexColor, lod) * normalWS;
}

#if defined( _GLOBAL_DEFORMATION_HEIGHTMAP )

TEXTURE2D( _DeformationTexture );

CBUFFER_START( DeformationParameters )
float4x4 _DeformationWorldToTextureMatrix;
float4 _DeformationParams;
CBUFFER_END

//
void ApplyGlobalDeformation( inout float3 positionWS )
{
    float3 absolutePositionWS = GetAbsolutePositionWS( positionWS );
    float4 deformationUV = mul( _DeformationWorldToTextureMatrix, float4( absolutePositionWS, 1.0f ) );
    if( min( deformationUV.x, min( deformationUV.y, deformationUV.z ) ) >= 0.0f &&
        max( deformationUV.x, max( deformationUV.y, deformationUV.z ) ) <= 1.0f )
    {
        float deformedDepth = SAMPLE_TEXTURE2D_LOD( _DeformationTexture, s_linear_repeat_sampler, deformationUV.xy + _DeformationParams.xy, 0.0f ).r;
        absolutePositionWS.y = min( deformedDepth, absolutePositionWS.y );
        positionWS = GetCameraRelativePositionWS( absolutePositionWS );
    }
}

#endif // _GLOBAL_DEFORMATION_HEIGHTMAP

void ApplyVertexModification(AttributesMesh input, float3 normalWS, inout float3 positionWS, float4 time)
{
#if defined(_VERTEX_DISPLACEMENT)

    positionWS += GetVertexDisplacement(positionWS, normalWS,
    #ifdef ATTRIBUTES_NEED_TEXCOORD0
        input.uv0,
    #else
        float2(0.0, 0.0),
    #endif
    #ifdef ATTRIBUTES_NEED_TEXCOORD1
        input.uv1,
    #else
        float2(0.0, 0.0),
    #endif
    #ifdef ATTRIBUTES_NEED_TEXCOORD2
        input.uv2,
    #else
        float2(0.0, 0.0),
    #endif
    #ifdef ATTRIBUTES_NEED_TEXCOORD3
        input.uv3,
    #else
        float2(0.0, 0.0),
    #endif
    #ifdef ATTRIBUTES_NEED_COLOR
        input.color
    #else
        float4(0.0, 0.0, 0.0, 0.0)
    #endif
        );
#endif

#ifdef _VERTEX_WIND
    float3 rootWP = mul(GetObjectToWorldMatrix(), float4(0, 0, 0, 1)).xyz;
#ifdef UNITY_MATERIAL_CHARACTERLIT
    ApplyWindDisplacement(positionWS, normalWS, rootWP, _Stiffness, _Drag, _ShiverDrag, _ShiverDirectionality, _InitialBend, _DownwindWeight, input.color.rgb, time);
#else
    ApplyWindDisplacement(positionWS, normalWS, rootWP, _Stiffness, _Drag, _ShiverDrag, _ShiverDirectionality, _InitialBend, input.uv2.x, time);
#endif
#endif

#if defined( _GLOBAL_DEFORMATION_HEIGHTMAP ) && !defined( TESSELLATION_ON )
    ApplyGlobalDeformation( positionWS );
#endif // _GLOBAL_DEFORMATION_HEIGHTMAP
}

#ifdef TESSELLATION_ON

float4 GetTessellationFactors(float3 p0, float3 p1, float3 p2, float3 n0, float3 n1, float3 n2)
{
    float maxDisplacement = GetMaxDisplacement();

    // For tessellation we want to process tessellation factor always from the point of view of the camera (to be consistent and avoid Z-fight).
    // For the culling part however we want to use the current view (shadow view).
    // Thus the following code play with both.
    float frustumEps = -maxDisplacement; // "-" Expected parameter for CullTriangleEdgesFrustum

    // TODO: the only reason I test the near plane here is that I am not sure that the product of other tessellation factors
    // (such as screen-space/distance-based) results in the tessellation factor of 1 for the geometry behind the near plane.
    // If that is the case (and, IMHO, it should be), we shouldn't have to test the near plane here.
    bool3 frustumCullEdgesMainView = CullTriangleEdgesFrustum(p0, p1, p2, frustumEps, _FrustumPlanes, 5); // Do not test the far plane

#if defined(SHADERPASS) && (SHADERPASS != SHADERPASS_SHADOWS)
    bool frustumCullCurrView = all(frustumCullEdgesMainView);
#else
    // 'unity_CameraWorldClipPlanes' are camera-relative rendering aware.
    bool frustumCullCurrView = CullTriangleFrustum(p0, p1, p2, frustumEps, unity_CameraWorldClipPlanes, 4); // Do not test near/far planes
#endif

    bool faceCull = false;

#ifndef _DOUBLESIDED_ON
    if (_TessellationBackFaceCullEpsilon > -1.0) // Is back-face culling enabled ?
    {
        // Handle transform mirroring (like negative scaling)
        // Note: We don't need to handle handness of view matrix here as the backface is perform in worldspace
        // note2: When we have an orthogonal matrix (cascade shadow map), we need to use the direction of the light.
        // Otherwise we use only p0 instead of the mean of P0, p1,p2 to save ALU as with tessellated geomerty it is rarely needed and user can still control _TessellationBackFaceCullEpsilon.
        float winding = unity_WorldTransformParams.w;
        faceCull = CullTriangleBackFaceView(p0, p1, p2, _TessellationBackFaceCullEpsilon, GetWorldSpaceNormalizeViewDir(p0), winding); // Use shadow view
    }
#endif

    if (frustumCullCurrView || faceCull)
    {
        // Settings factor to 0 will kill the triangle
        return 0;
    }

    // For performance reasons, we choose not to tessellate outside of the main camera view
    // (we perform this test both during the regular scene rendering and the shadow pass).
    // For edges not visible from the main view, our goal is to set the tessellation factor to 1.
    // In this case, we set the tessellation factor to 0 here.
    // That way, all scaling of this tessellation factor will still result in 0.
    // Before we call CalcTriTessFactorsFromEdgeTessFactors(), all factors are clamped by max(f, 1),
    // which achieves the desired effect.
    float3 edgeTessFactors = float3(frustumCullEdgesMainView.x ? 0 : 1, frustumCullEdgesMainView.y ? 0 : 1, frustumCullEdgesMainView.z ? 0 : 1);

    // Adaptive screen space tessellation
    if (_TessellationFactorTriangleSize > 0.0)
    {
        // return a value between 0 and 1
        // Warning: '_ViewProjMatrix' is not the same as UNITY_MATRIX_VP for shadow views!
        edgeTessFactors *= GetScreenSpaceTessFactor( p0, p1, p2, _ViewProjMatrix, _ScreenSize, _TessellationFactorTriangleSize); // Use primary camera view
    }

    // Distance based tessellation
    if (_TessellationFactorMaxDistance > 0.0)
    {
        float3 distFactor = GetDistanceBasedTessFactor(p0, p1, p2, GetPrimaryCameraPosition(), _TessellationFactorMinDistance, _TessellationFactorMaxDistance);  // Use primary camera view
        // We square the disance factor as it allow a better percptual descrease of vertex density.
        edgeTessFactors *= distFactor * distFactor;
    }

    edgeTessFactors *= _TessellationFactor;

    // TessFactor below 1.0 have no effect. At 0 it kill the triangle, so clamp it to 1.0
    edgeTessFactors = max(edgeTessFactors, float3(1.0, 1.0, 1.0));

    return CalcTriTessFactorsFromEdgeTessFactors(edgeTessFactors);
}

// tessellationFactors
// x - 1->2 edge
// y - 2->0 edge
// z - 0->1 edge
// w - inside tessellation factor
void ApplyTessellationModification(VaryingsMeshToDS input, float3 normalWS, inout float3 positionWS)
{
#if defined(_TESSELLATION_DISPLACEMENT)

    positionWS += GetVertexDisplacement(positionWS, normalWS,
    #ifdef VARYINGS_DS_NEED_TEXCOORD0
        input.texCoord0,
    #else
        float2(0.0, 0.0),
    #endif
    #ifdef VARYINGS_DS_NEED_TEXCOORD1
        input.texCoord1,
    #else
        float2(0.0, 0.0),
    #endif
    #ifdef VARYINGS_DS_NEED_TEXCOORD2
        input.texCoord2,
    #else
        float2(0.0, 0.0),
    #endif
    #ifdef VARYINGS_DS_NEED_TEXCOORD3
        input.texCoord3,
    #else
        float2(0.0, 0.0),
    #endif
    #ifdef VARYINGS_DS_NEED_COLOR
        input.color
    #else
        float4(0.0, 0.0, 0.0, 0.0)
    #endif
        );
#endif // _TESSELLATION_DISPLACEMENT

#if defined( _GLOBAL_DEFORMATION_HEIGHTMAP )
    ApplyGlobalDeformation( positionWS );
#endif // _GLOBAL_DEFORMATION_HEIGHTMAP
}

#endif // #ifdef TESSELLATION_ON
