//-------------------------------------------------------------------------------------
// Fill SurfaceData/Builtin data function
//-------------------------------------------------------------------------------------
#include "../MaterialUtilities.hlsl"

void GetSurfaceAndBuiltinData(FragInputs input, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
{

    // Builtin Data - a bunch of stuff that skyDome doesn't need to set
    builtinData.opacity = 1.0;
    builtinData.bakeDiffuseLighting = float3(0.0, 0.0, 0.0);
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
    float skyY = clamp( (dir.y - _SkyGradBottom)/(_SkyGradTop -_SkyGradBottom), 0, 1);
    float gradCoord = pow(max(0.001,skyY), exp(4*_SkyGradCurveBias));
    // lerp between colors
    surfaceData.color = lerp(_SkyGradHorizonColor, _SkyGradZenithColor, gradCoord );
    // TO-DO
    // how to avoid color banding? - possibly add noise texture

    // HORIZON GRADIENT
    //============================================================================================
    // horizon grad can be stronger in a particular direction.  dot() the horizontal components of viewing direction with
    // vector from heading parameter, and lower the gradient in the direction opposite that heading.
    //float3 headingVector = float3(sin(_HorizonGradDirection*3.14159/180.0), 0.0, cos(_HorizonGradDirection*3.14159/180.0) ); // MOVED THIS INTO .CS SCRIPT, PASSED IN AS _HorizonGradDirVector
#ifdef _HORIZON_GRADIENT
    float3 dirFlat = normalize(dir*float3(1,0,1));
    float dirAtten = 0.5 - 0.5*( dirFlat.x*_HorizonGradDirVector.x + dirFlat.z*_HorizonGradDirVector.z);
    float hrzY = clamp( (dir.y - _SkyGradBottom)/(1.0 -_SkyGradBottom), 0, 1);
    float horizonHeightRemap = max(0.001, min((hrzY+dirAtten*_HorizonGradDirectionalAtten)/_HorizonGradHeight,1.0));
    float horizonColorMix = pow( horizonHeightRemap, exp(3*_HorizonGradColorBias));
    float horizonAlpha = 1.0 - pow( horizonHeightRemap, exp(3*_HorizonGradAlphaBias));
    // lerp horizon colors
    float3 horizonColor = lerp(_HorizonGradColor0, _HorizonGradColor1, horizonColorMix);
    // mix horizon colors into output color
    surfaceData.color = lerp( surfaceData.color, horizonColor, horizonAlpha * _HorizonGradIntensity);
    // TO-DO
    // investigate other biasing options that are smoother?
#endif

    // use the sun dir only if it's visible. otherwise, cloud lighting and rim are unaffected
    float sunDotDir = 0;
#ifdef _VISIBLE_SUNMOON
    sunDotDir = max(0.0,dot(dir,_SunVector.rgb));
#endif

    // HORIZON CLOUDS
    //============================================================================================
    float cloudHorizonBlocker = 0.0;
    float3 horizonCloudColorMap = float3(0,0,0);
#ifdef _CLOUDS_HORIZON
    // using cylindrical mapped uv0 set for this.  distortion near zenith won't be an issue
    float2 cloudHorizonMapUv = TRANSFORM_TEX(input.texCoord0, _CloudHorizonMap);
    cloudHorizonMapUv.x += _Time.x * _CloudHorizonScrollSpeed;
    // texture is set to repeat, needed for horiz tiling, but clamp in vertical
    cloudHorizonMapUv.y = clamp(cloudHorizonMapUv.y, 0, 1);
    horizonCloudColorMap = SAMPLE_TEXTURE2D(_CloudHorizonMap, sampler_CloudHorizonMap, cloudHorizonMapUv).rgb;
    float3 horizonCloudColor = _CloudHorizonUnlitColor + horizonCloudColorMap.r * _CloudHorizonColor.rgb * (1.0 - sunDotDir) * _CloudHorizonLighting;
    float cloudHorizonAlpha = horizonCloudColorMap.b * _CloudHorizonColor.a;
    cloudHorizonBlocker = horizonCloudColorMap.b;
    // mix cloud colors into output color
    surfaceData.color = lerp( surfaceData.color, horizonCloudColor, cloudHorizonAlpha);
    // TO-DO:
    //     give clouds/rim different colors towards vs away from headingVector
#endif

   // SUN/MOON
    //============================================================================================
#ifdef _VISIBLE_SUNMOON
    // last operation of horizon clouds - the rim lighting - only happens if sun/moon is also visible
    surfaceData.color += 2.0* _CloudHorizonRim * sunDotDir * sunDotDir * horizonCloudColorMap.g * _SunColor.rgb * _CloudHorizonColor.a;
    // Convert azimuth/elevation to dir vector, then dot w/ view dir
    //float elevationRadians = _SunElevation*3.1415/180.0;
    //float azimuthRadians = _SunAzimuth*3.1415/180.0;
    //float hyp = cos(elevationRadians);
    //float3 sunDir = float3(hyp*sin(azimuthRadians), sin(elevationRadians), hyp*cos(azimuthRadians));  // MOVED THIS INTO .CS SCRIPT, PASSED IN AS _SunVector
    float sunRadius = cos(max(0,_SunRadius)*3.1415/180.0);
    float sunDisk = clamp((sunDotDir-sunRadius)*10000, 0, 1);
    float3 sunColor = _SunColor.rgb * sunDisk;
    float3 sunGlow = min(10.0, pow(max(0, sunDotDir + 1-sunRadius), _SunGlowExponent) * _SunGlowColor.rgb * _SunGlowColor.a);
    float3 sunHaze = min(10.0, pow(max(0, sunDotDir + 1-sunRadius), _SunHazeExponent) * _SunHazeColor.rgb * _SunHazeColor.a);
    // add sun color into output color
    surfaceData.color += (sunColor + sunGlow + sunHaze)  * (1.0 - cloudHorizonBlocker);
    // TO-DO
    // texture for sun/moon?
#endif

    // OVERHEAD CLOUDS
    //============================================================================================
#ifdef _CLOUDS_OVERHEAD
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
    surfaceData.color = lerp(surfaceData.color, _CloudOverheadColor.rgb, overheadCloudAlpha * (1.0 - cloudHorizonBlocker));
    // TO-DO
    // some kind of normal map or multicolor
    // flow map / distortion?
    // control which is in front - overhead or horizon clouds?
#endif

    // STARS
    //============================================================================================
#ifdef _STARS
    float2 starMapUv = TRANSFORM_TEX(input.texCoord1, _StarMap);
    float2 starTwinkleUv = TRANSFORM_TEX(input.texCoord1, _StarTwinkleMap);
    starTwinkleUv += float2(0, _StarTwinkleSpeed * _Time.x);
    float starTwinkle = SAMPLE_TEXTURE2D(_StarTwinkleMap, sampler_StarTwinkleMap, starTwinkleUv).r;
    float3 stars = SAMPLE_TEXTURE2D(_StarMap, sampler_StarMap, starMapUv).rgb;
    stars = lerp(stars, stars*starTwinkle, _StarTwinkleIntensity) * _StarColor.rgb * _StarColor.a;
    // TO-DO

    // MILKY WAY
    //============================================================================================
    stars += _StarMilkyWayIntensity * SAMPLE_TEXTURE2D(_StarMilkyWayMap, sampler_StarMilkyWayMap, input.texCoord1).rgb;
    stars *= gradCoord;
    // add star color into output color
    surfaceData.color += stars * (1.0 - cloudHorizonBlocker);
#endif


    // BACKDROP
    //============================================================================================
#ifdef _BACKDROP
    float2 backdropMapUv = TRANSFORM_TEX(input.texCoord0, _BackdropMap);
    backdropMapUv.y = clamp(backdropMapUv.y, 0.02, 0.98);
    float3 backdropColor = SAMPLE_TEXTURE2D(_BackdropMap, sampler_BackdropMap, backdropMapUv).rgb * _BackdropColor.rgb;
    float backdropAlpha = SAMPLE_TEXTURE2D(_BackdropMap, sampler_BackdropMap, backdropMapUv).a * _BackdropColor.a;
    float3 backdropEmissiveColor = SAMPLE_TEXTURE2D(_BackdropEmissiveMap, sampler_BackdropEmissiveMap, backdropMapUv).rgb * _BackdropEmissiveColor.rgb;
    float backdropEmissiveAlpha = SAMPLE_TEXTURE2D(_BackdropEmissiveMap, sampler_BackdropEmissiveMap, backdropMapUv).a * _BackdropEmissiveColor.a;
    float4 backdropFog = lerp(_BackdropFogBottomColor, _BackdropFogTopColor, clamp((backdropMapUv.y-_BackdropFogBottom)/(_BackdropFogTop-_BackdropFogBottom), 0, 1));
    backdropColor += backdropEmissiveColor * backdropEmissiveAlpha;
    backdropColor = lerp(backdropColor, backdropFog.rgb, backdropFog.a);

    surfaceData.color = lerp(surfaceData.color, backdropColor, backdropAlpha);
    // TO-DO
#endif

    // FOR DEBUGGING
    //surfaceData.color = float3();


#if defined(DEBUG_DISPLAY)
    if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
    {
        // surfaceData.color = GetTextureDataDebug(_DebugMipMapMode, skyColorMapUv, _UnlitColorMap, _UnlitColorMap_TexelSize, _UnlitColorMap_MipInfo, surfaceData.color);
    }
#endif
}
