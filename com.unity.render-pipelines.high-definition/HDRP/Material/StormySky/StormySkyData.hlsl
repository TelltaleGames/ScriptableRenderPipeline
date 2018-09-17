//-------------------------------------------------------------------------------------
// Fill SurfaceData/Builtin data function
//-------------------------------------------------------------------------------------
#include "../MaterialUtilities.hlsl"

float rand3( float3 co ){
    return frac( sin( dot( co.xyz ,float3(17.2486,32.76149, 368.71564) ) ) * 32168.47512);
}

half4 _FogColorDensitySky(float3 viewDir)
{
    return half4(0.5, 0.5, 0.5, 1.0-viewDir.y);
}

half4 SampleClouds ( float3 uv, half3 sunTrans, half densityAdd ){

    // wave distortion
    float2 coordsWave = float2( uv.xy *_WaveTex_ST.xy + ( _WaveTex_ST.zw * 0.01 * _Speed * _Time.y ) );
    half3 wave = SAMPLE_TEXTURE2D(_WaveTex, sampler_WaveTex, float2(coordsWave.xy)).xyz;

    // first cloud layer
    float2 coords1 = uv.xy * _CloudTex1_ST.xy + ( _CloudTex1_ST.zw * 0.01 * _Speed * _Time.y ) + ( wave.xy - 0.5 ) * _WaveDistort;
    half4 clouds = SAMPLE_TEXTURE2D( _CloudTex1, sampler_CloudTex1, float2(coords1.xy) );
    half3 cloudsFlow = SAMPLE_TEXTURE2D( _FlowTex1, sampler_FlowTex1, float2(coords1.xy) ).xyz;

    // set up time for second clouds layer
    float speed = _FlowSpeed * 0.01 * _Speed * 10;
    float timeFrac1 = frac( _Time.y * speed );
    float timeFrac2 = frac( _Time.y * speed + 0.5 );
    float timeLerp  = abs( timeFrac1 * 2.0 - 1.0 );
    timeFrac1 = ( timeFrac1 - 0.5 ) * _FlowAmount;
    timeFrac2 = ( timeFrac2 - 0.5 ) * _FlowAmount;

    // second cloud layer uses flow map
    float2 coords2 = coords1 * _CloudTex2_ST.xy + ( _CloudTex2_ST.zw * 0.01 * _Speed * _Time.y );
    half4 clouds2 = SAMPLE_TEXTURE2D( _CloudTex2, sampler_CloudTex2, float2(coords2.xy + ( cloudsFlow.xy - 0.5 ) * timeFrac1 ));
    half4 clouds2b = SAMPLE_TEXTURE2D( _CloudTex2, sampler_CloudTex2, float2(coords2.xy + ( cloudsFlow.xy - 0.5 ) * timeFrac2  + float2(0.5,0.5) ));
    clouds2 = lerp( clouds2, clouds2b, timeLerp);
    clouds += ( clouds2 - 0.5 ) * _Cloud2Amount * cloudsFlow.z;

    // add wave to cloud height
    clouds.w += ( wave.z - 0.5 ) * _WaveAmount;

    // scale and bias clouds because we are adding lots of stuff together
    // and the values cound go outside 0-1 range
    clouds.w = clouds.w * _CloudScale + _CloudBias;

    // overhead light color
    float3 coords4 = float3( uv.xy * _ColorTex_ST.xy + ( _ColorTex_ST.zw * 0.01 * _Speed * _Time.y ), 0.0 );
    half4 cloudColor = SAMPLE_TEXTURE2D( _ColorTex, sampler_ColorTex, float2(coords4.xy) );

    // cloud color based on density
    half cloudHeightMask = 1.0 - saturate( clouds.w );
    cloudHeightMask = pow( cloudHeightMask, _ColPow );
    clouds.xyz *= lerp( _Color2.xyz, _Color.xyz * cloudColor.xyz * _ColFactor, cloudHeightMask );

    // subtract alpha based on height
    half cloudSub = 1.0 - uv.z;
    clouds.w = clouds.w - cloudSub * cloudSub;

    // multiply density
    clouds.w = saturate( clouds.w * _CloudDensity );
    // add extra density
    clouds.w = saturate( clouds.w + densityAdd );
    // add Sunlight
    clouds.xyz += sunTrans * cloudHeightMask;
    // pre-multiply alpha
    clouds.xyz *= clouds.w;

    return clouds;
}




void GetSurfaceAndBuiltinData(FragInputs input, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
{

    // generate a view direction fromt he world position of the skybox mesh
    float3 viewDir = normalize( posInput.positionWS - _WorldSpaceCameraPos );

    // get the falloff to the horizon
    float viewFalloff = 1.0 - saturate( dot( viewDir, float3(0,1,0) ) );

    // Add some up vector to the horizon to pull the clouds down
    float3 traceDir = normalize( viewDir + float3(0,viewFalloff * 0.1,0) );
    //float3 traceDir = normalize( viewDir );

    // Generate uvs from the world position of the sky
    float3 worldPos = _WorldSpaceCameraPos + traceDir * ( ( _CloudHeight - _WorldSpaceCameraPos.y ) / max( traceDir.y, 0.00001) );
    float3 uv = float3( worldPos.xz / max(0.0001,_Scale), 0 );

    // Make a spot for the sun, make it brighter at the horizon
    float lightDot = saturate( dot( normalize(_SunVector), viewDir ) * 0.5 + 0.5 );
    half3 lightTrans = _SunColor * ( pow( lightDot, _LightSpread.x ) * _LightSpread.y + pow( lightDot,_LightSpread.z ) * _LightSpread.w );
    half3 lightTransTotal = lightTrans;// * pow(viewFalloff, 5 ) * 5.0 + 1.0;

    // Figure out how for to move through the uvs for each step of the parallax offset
    half3 uvStep = half3( traceDir.xz * 0.01 * _BumpOffset * ( 1.0 / traceDir.y ), 1.0 ) * ( 1.0 / _Steps );
    uv += uvStep * rand3( posInput.positionWS + _Time.y );

    // initialize the accumulated color with fog
    float dist = length(worldPos-_WorldSpaceCameraPos);
    float fogDensity = saturate(dist / _FoggyDistance);
    half4 accColor = half4(_FoggyColor.rgb*fogDensity, fogDensity);//_FogColorDensitySky(viewDir);
    half4 clouds = 0;

    [loop]for( int j = 0; j < _Steps; j++ ){
        // if we filled the alpha then break out of the loop
        if( accColor.w >= 1.0 ) { break; }

        // add the step offset to the uv
        uv += uvStep;

        // sample the clouds at the current position
        clouds = SampleClouds(uv, lightTransTotal, 0.0 );

        // add the current cloud color with front to back blending
        accColor += clouds * ( 1.0 - accColor.w );
    }

    // one last sample to fill gaps
    uv += uvStep;
    clouds = SampleClouds(uv, lightTransTotal, 1.0 );
    accColor += clouds * ( 1.0 - accColor.w );


//=====================================================================================================

    // Builtin Data
    builtinData.opacity = 1.0;
    builtinData.bakeDiffuseLighting = float3(0.0, 0.0, 0.0);
    builtinData.emissiveColor = accColor.xyz;
    builtinData.velocity = float2(0.0, 0.0);

    builtinData.shadowMask0 = 0.0;
    builtinData.shadowMask1 = 0.0;
    builtinData.shadowMask2 = 0.0;
    builtinData.shadowMask3 = 0.0;

    builtinData.distortion = float2(0.0, 0.0);
    builtinData.distortionBlur = 0.0;

    builtinData.depthOffset = 0.0;

    // SurfaceData
    surfaceData.color = float3(0.0, 0.0, 0.0);

}
