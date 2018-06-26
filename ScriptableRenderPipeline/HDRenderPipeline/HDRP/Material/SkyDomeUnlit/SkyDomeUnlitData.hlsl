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


    // HORIZON GRADIENT
    //============================================================================================
    // horizon grad can be stronger in a particular direction.  dot() the horizontal components of viewing direction with
    // vector from heading parameter, and lower the gradient in the direction opposite that heading.
    float3 headingVector = float3(sin(_HorizonGradDirection*3.14159/180.0), 0.0, cos(_HorizonGradDirection*3.14159/180.0) ); // MOVE THIS INTO .CS SCRIPT
    float3 dirFlat = normalize(dir*float3(1,0,1));
    float dirAtten = 0.5 - 0.5*( dot(dirFlat, headingVector) );
    float horizonHeightRemap = max(0.001, min((dir.y+dirAtten*_HorizonGradDirectionalAtten)/_HorizonGradHeight,1.0));
    float horizonColorMix = pow( horizonHeightRemap, exp(3*_HorizonGradColorBias));
    float horizonAlpha = 1.0 - pow( horizonHeightRemap, exp(3*_HorizonGradAlphaBias));
    // lerp horizon colors
    float3 horizonColor = lerp(_HorizonGradColor0, _HorizonGradColor1, horizonColorMix);
    // mix horizon colors into output color
    surfaceData.color = lerp( surfaceData.color, horizonColor, horizonAlpha * _HorizonGradIntensity);
    // TO-DO
    // compute heading vector in C# and pass in as float2
    // investigate other biasing options that are smoother?


    // DISTANT CLOUDS
    //============================================================================================
    // using cylindrical mapped uv0 set for this.  distortion near zenith won't be an issue
    float2 cloudDistantMapUv = TRANSFORM_TEX(input.texCoord0, _CloudDistantMap);
    cloudDistantMapUv.x += _Time.x * _CloudDistantScrollSpeed;
    // texture is set to repeat, needed for horiz tiling, but clamp in vertical
    cloudDistantMapUv.y = clamp(cloudDistantMapUv.y, 0, 1);
    float3 distantCloudColor = SAMPLE_TEXTURE2D(_CloudDistantMap, sampler_CloudDistantMap, cloudDistantMapUv).rgb * _CloudDistantColor.rgb;
    float  distantCloudAlpha = SAMPLE_TEXTURE2D(_CloudDistantMap, sampler_CloudDistantMap, cloudDistantMapUv).a * _CloudDistantColor.a;
    // mix cloud colors into output color
    surfaceData.color = lerp( surfaceData.color, distantCloudColor, distantCloudAlpha);
    // TO-DO:
    //     Different channels in the image mask rim light, etc.
    //     give clouds/rim different colors towards vs away from headingVector


    // OVERHEAD CLOUDS
    //============================================================================================
    // uv mapping as if clouds are on flat plane above ground
    // dir/dir.y projects onto y=1 plane, then mult by height param
    // lookup texture using xz
    float2 cloudOverheadMapUv = (dir/dir.y).xz * _CloudOverheadHeight;
    // need a float2 for scroll direction, or heading angle similar to above
    cloudOverheadMapUv.x += _Time.x * _CloudOverheadScrollSpeed;
    // clouds need to be huge @ altitude, this makes ui tiling values easier
    _CloudOverheadMap_ST.x *= 0.0001;
    _CloudOverheadMap_ST.y *= 0.0001;
    cloudOverheadMapUv = TRANSFORM_TEX(cloudOverheadMapUv, _CloudOverheadMap);
    float3 overheadCloudColor = SAMPLE_TEXTURE2D(_CloudOverheadMap, sampler_CloudOverheadMap, cloudOverheadMapUv).rgb * _CloudOverheadColor.rgb;
    float  overheadCloudAlpha = SAMPLE_TEXTURE2D(_CloudOverheadMap, sampler_CloudOverheadMap, cloudOverheadMapUv).a * _CloudOverheadColor.a;
    // clouds fade out at low angle, otherwise you see the infinite tiling @ horizon
    overheadCloudAlpha *= max(0.0,dir.y);
    // mix cloud colors into output color
    surfaceData.color = lerp(surfaceData.color, overheadCloudColor, overheadCloudAlpha);
    // TO-DO
    // 2d scrolling direction

    // STARS
    //============================================================================================
    float2 starMapUv = TRANSFORM_TEX(input.texCoord1, _StarMap);
    float3 stars = SAMPLE_TEXTURE2D(_StarMap, sampler_StarMap, starMapUv).r * _StarColor.rgb * _StarColor.a;
    // add star color into output color
    surfaceData.color += stars;
    // TO-DO
    // twinkling
    // blocked by clouds

    // SUN/MOON
    //============================================================================================
    // Convert azimuth/elevation to dir vector, then dot w/ view dir
    float elevationRadians = _SunElevation*3.1415/180.0;
    float azimuthRadians = _SunAzimuth*3.1415/180.0;
    float hyp = cos(elevationRadians);
    float3 sunDir = float3(hyp*sin(azimuthRadians), sin(elevationRadians), hyp*cos(azimuthRadians));
    float sunDotDir = max(0.0,dot(dir,sunDir));
    float sunDisk = clamp((sunDotDir-0.997)*3000, 0, 1);
    surfaceData.color += _SunColor.rgb * sunDisk;
    surfaceData.color += _SunColor.rgb * _SunColor.a * pow(sunDotDir, _SunHazeExponent);
    // TO-DO
    // Move conversion of azimuth/elevation to vector to the C# side, and pass vector to shader
    // texture for sun/moon?




    // DEBUG
    //surfaceData.color = overheadCloudColor*overheadCloudAlpha;


#if defined(DEBUG_DISPLAY)
    if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
    {
        // surfaceData.color = GetTextureDataDebug(_DebugMipMapMode, skyColorMapUv, _UnlitColorMap, _UnlitColorMap_TexelSize, _UnlitColorMap_MipInfo, surfaceData.color);
    }
#endif
}
