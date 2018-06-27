//-------------------------------------------------------------------------------------
// Fill SurfaceData/Builtin data function
//-------------------------------------------------------------------------------------
#include "../MaterialUtilities.hlsl"

void GetSurfaceAndBuiltinData(FragInputs input, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
{

    // Builtin Data - a bunch of stuff that skyDome doesn't need to set
    builtinData.opacity = 1.0;
    builtinData.bakeDiffuseLighting = float3(0.0, 0.0, 0.0);
    builtinData.emissiveIntensity = 0.0;
    builtinData.emissiveColor = float3(0.0, 0.0, 0.0);
    builtinData.velocity = float2(0.0, 0.0);
    builtinData.shadowMask0 = 0.0;
    builtinData.shadowMask1 = 0.0;
    builtinData.shadowMask2 = 0.0;
    builtinData.shadowMask3 = 0.0;
    builtinData.distortion = float2(0.0, 0.0);
    builtinData.distortionBlur = 0.0;
    builtinData.depthOffset = 0.0;


    // SKY GRADIENT
    //============================================================================================
    // skyDome is large enough that position can be used for viewing direction
    float3 dir = normalize(posInput.positionWS);
    // vertical component of viewing dir, adjusted with bias
    float gradCoord = pow(max(0.001,dir.y), exp(4*_SkyGradCurveBias));
    // lerp between colors
    surfaceData.color = lerp(_SkyGradHorizonColor, _SkyGradZenithColor, gradCoord );
    // TO-DO
    // how to avoid color banding?

    // STARS
    //============================================================================================
    float2 starMapUv = TRANSFORM_TEX(input.texCoord1, _StarMap);
    float3 stars = SAMPLE_TEXTURE2D(_StarMap, sampler_StarMap, starMapUv).r * _StarColor.rgb * _StarColor.a;
    // TO-DO
    // twinkling
    // blocked by clouds


    // HORIZON GRADIENT
    //============================================================================================
    // horizon grad can be stronger in a particular direction.  dot() the horizontal components of viewing direction with
    // vector from heading parameter, and lower the gradient in the direction opposite that heading.
    //float3 headingVector = float3(sin(_HorizonGradDirection*3.14159/180.0), 0.0, cos(_HorizonGradDirection*3.14159/180.0) ); // MOVED THIS INTO .CS SCRIPT, PASSED IN AS _HorizonGradDirVector
    float3 dirFlat = normalize(dir*float3(1,0,1));
    float dirAtten = 0.5 - 0.5*( dot(dirFlat, _HorizonGradDirVector) );
    float horizonHeightRemap = max(0.001, min((dir.y+dirAtten*_HorizonGradDirectionalAtten)/_HorizonGradHeight,1.0));
    float horizonColorMix = pow( horizonHeightRemap, exp(3*_HorizonGradColorBias));
    float horizonAlpha = 1.0 - pow( horizonHeightRemap, exp(3*_HorizonGradAlphaBias));
    // lerp horizon colors
    float3 horizonColor = lerp(_HorizonGradColor0, _HorizonGradColor1, horizonColorMix);
    // mix horizon colors into output color
    surfaceData.color = lerp( surfaceData.color, horizonColor, horizonAlpha * _HorizonGradIntensity);
    // TO-DO
    // investigate other biasing options that are smoother?


    // SUN/MOON
    //============================================================================================
    // Convert azimuth/elevation to dir vector, then dot w/ view dir
    //float elevationRadians = _SunElevation*3.1415/180.0;
    //float azimuthRadians = _SunAzimuth*3.1415/180.0;
    //float hyp = cos(elevationRadians);
    //float3 sunDir = float3(hyp*sin(azimuthRadians), sin(elevationRadians), hyp*cos(azimuthRadians));  // MOVED THIS INTO .CS SCRIPT, PASSED IN AS _SunVector
    float sunDotDir = max(0.0,dot(dir,_SunVector.rgb));
    float sunDisk = clamp((sunDotDir-0.997)*3000, 0, 1);
    float3 sunColor = _SunColor.rgb * sunDisk;
    // TO-DO
    // texture for sun/moon?


    // OVERHEAD CLOUDS
    //============================================================================================
    // uv mapping as if clouds are on flat plane above ground
    // dir/dir.y projects onto y=1 plane, then mult by height param
    // lookup texture using xz
    float2 cloudOverheadMapUv = (dir/dir.y).xz * _CloudOverheadHeight;
    // _CloudOverheadScrollVector is computed in GUI C# script from _CloudOverheadScrollHeading (compass heading in degrees)
    cloudOverheadMapUv += _Time.x * _CloudOverheadScrollSpeed * float2(_CloudOverheadScrollVector.x, _CloudOverheadScrollVector.z);
    // clouds need to be huge @ altitude, this makes ui tiling values easier
    _CloudOverheadMap_ST.x *= 0.0001;
    _CloudOverheadMap_ST.y *= 0.0001;
    cloudOverheadMapUv = TRANSFORM_TEX(cloudOverheadMapUv, _CloudOverheadMap);
    float  overheadCloudAlpha = SAMPLE_TEXTURE2D(_CloudOverheadMap, sampler_CloudOverheadMap, cloudOverheadMapUv).r * _CloudOverheadColor.a;
    // clouds fade out at low angle, otherwise you see the infinite tiling @ horizon
    overheadCloudAlpha *= max(0.0,dir.y);
    // mix cloud colors into output color
    surfaceData.color = lerp(surfaceData.color, _CloudOverheadColor.rgb, overheadCloudAlpha);

    // HORIZON CLOUDS
    //============================================================================================
    // using cylindrical mapped uv0 set for this.  distortion near zenith won't be an issue
    float2 cloudDistantMapUv = TRANSFORM_TEX(input.texCoord0, _CloudDistantMap);
    cloudDistantMapUv.x += _Time.x * _CloudDistantScrollSpeed;
    // texture is set to repeat, needed for horiz tiling, but clamp in vertical
    cloudDistantMapUv.y = clamp(cloudDistantMapUv.y, 0, 1);
    float3 distantCloudColorMap = SAMPLE_TEXTURE2D(_CloudDistantMap, sampler_CloudDistantMap, cloudDistantMapUv).rgb;
    float3 distantCloudColor = _CloudDistantColor.rgb;
    float  distantCloudAlpha = distantCloudColorMap.r * _CloudDistantColor.a;
    // mix cloud colors into output color
    surfaceData.color = lerp( surfaceData.color, distantCloudColor, distantCloudAlpha);
    surfaceData.color += 2.0* _CloudRimIntensity * sunDotDir * sunDotDir * distantCloudColorMap.g * _SunColor.rgb;
    // TO-DO:
    //     Different channels in the image mask rim light, etc.
    //     give clouds/rim different colors towards vs away from headingVector

    // add sun color into output color
    surfaceData.color += sunColor * (1.0 - distantCloudColorMap.b);
    surfaceData.color += _SunColor.rgb * _SunColor.a * pow(sunDotDir, _SunHazeExponent) * (1.0 - distantCloudColorMap.b * _CloudDistantColor.a);
    // add star color into output color
    surfaceData.color += stars * (1.0 - distantCloudColorMap.b);



    // DEBUG
    //surfaceData.color = float3(_CloudOverheadScrollVector.x, _CloudOverheadScrollVector.y, _CloudOverheadScrollVector.z);


#if defined(DEBUG_DISPLAY)
    if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
    {
        // surfaceData.color = GetTextureDataDebug(_DebugMipMapMode, skyColorMapUv, _UnlitColorMap, _UnlitColorMap_TexelSize, _UnlitColorMap_MipInfo, surfaceData.color);
    }
#endif
}
