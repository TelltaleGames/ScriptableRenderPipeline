// Based on Unlit.shader.

Shader "HDRenderPipeline/SkyDomeUnlit"
{
    Properties
    {
        // Versioning of material to help for upgrading
        [HideInInspector] _HdrpVersion("_HdrpVersion", Float) = 1

        // Main Sky Texture Gradient
        _SkyGradHorizonColor("Horizon Color", Color) = (1, 1, 1, 1)
        _SkyGradZenithColor("Zenith Color", Color) = (0.1, 0.2, 1.0, 1)
        _SkyGradTop("Top", Range(0,1)) = 1.0
        _SkyGradBottom("Bottom", Range(-1,1)) = 0.0
        _SkyGradCurveBias("Curve Bias", Range(-1,1)) = 0.0

        // Horizon Secondary Gradient
        [Toggle(_HORIZON_GRADIENT)]  _HorizonGradEnable("Horizon Gradient", Float) = 0.0
        _HorizonGradIntensity("Horizon Intensity", Range(0,1)) = 1
        _HorizonGradColor1("Horizon Top Color", Color) = (1, 1, 1, 1)
        _HorizonGradColor0("Horizon Bottom Color", Color) = (1, 1, 1, 1)
        _HorizonGradHeight("Height", Range(0,1)) = 0.2
        _HorizonGradColorBias("Color Ramp Bias", Range(-1,1)) = 0.0
        _HorizonGradAlphaBias("Alpha Ramp Bias", Range(-1,1)) = 0.0
        _HorizonGradDirection("Heading", Range(0,360)) = 0.0
        _HorizonGradDirVector("Dir Vector", Vector) = (1,0,0,1)
        _HorizonGradDirectionalAtten("Attenuation", Range(0,1)) = 0.0

        // Clouds mapped cylindrically above the horizon
        [Toggle(_CLOUDS_HORIZON)]  _CloudHorizonEnable("Horizon Clouds", Float) = 0.0
        _CloudHorizonMap("Distant Clouds", 2D) = "black" {}
        _CloudHorizonColor("Cloud Tint", Color) = (1,1,1,1)
        _CloudHorizonUnlitColor("Unlit Color", Color) = (0,0,0,0)
        _CloudHorizonLighting("Lighting", Range(0,1)) = 1
        _CloudHorizonRim("Cloud Rim Intensity", Range(0,1)) = 1
        _CloudHorizonScrollSpeed("Cloud Speed", Float) = 0

        // Clouds mapped onto virtual overhead plane
        [Toggle(_CLOUDS_OVERHEAD)]  _CloudOverheadEnable("Overhead Clouds", Float) = 0.0
        _CloudOverheadMap("Overhead Clouds", 2D) = "black" {}
        _CloudOverheadColor("Cloud Tint", Color) = (1,1,1,1)
        _CloudOverheadHeight("Cloud Height", Float) = 0
        _CloudOverheadScrollHeading("Cloud Heading", Float) = 0
        _CloudOverheadScrollVector("Cloud Vector", Vector) = (1,0,0,1)
        _CloudOverheadScrollSpeed("Cloud Speed", Float) = 0

        // Backdrop
        [Toggle(_BACKDROP)]  _BackdropEnable("Backdrop", Float) = 0.0
        _BackdropMap("Backdrop Map", 2D) = "black" {}
        _BackdropEmissiveMap("Backdrop Emissive Map", 2D) = "black" {}
        _BackdropEmissiveColor("Backdrop Emissive Color", Color) = (1,1,1,1)
        _BackdropColor("Backdrop Tint", Color) = (1,1,1,1)
        _BackdropFogTop("Backdrop Fog Top Position", Range(-1,1)) = 0.1
        _BackdropFogTopColor("Backdrop Fog Top Color/Alpha", Color) = (1,1,1,0)
        _BackdropFogBottom("Backdrop Fog Bottom Position", Range(-1,1)) = 0
        _BackdropFogBottomColor("Backdrop Fog Bottom Color/Alpha", Color) = (1,1,1,1)

        // Tiling star map using uv1
        [Toggle(_STARS)]  _StarEnable("Stars", Float) = 0.0
        _StarMap("Star Map", 2D) = "black" {}
        _StarMilkyWayMap("Star MilkyWay Map", 2D) = "black" {}
        _StarMilkyWayIntensity("Star MilkyWay Intensity", Range(0,1)) = 1
        _StarTwinkleMap("Star Twinkle Map", 2D) = "white" {}
        _StarTwinkleIntensity("Star Twinkle Intensity", Range(0,1)) = 1
        _StarTwinkleSpeed("Star Twinkle Speed", Float) = 1
        _StarColor("Star Color", Color) = (1,1,1,1)

        // Sun or Moon + Glow & Haze
        [Toggle(_VISIBLE_SUNMOON)]  _SunEnable("Sun/Moon", Float) = 0.0
        _SunElevation("Sun Elevation", Range(-90.0, 90.0)) = 45.0
        _SunAzimuth("Sun Azimuth", Range(0.0, 360.0)) = 0.0
        _SunRadius("Sun Radius", Float) = 5
        _SunColor("Sun Color", Color) = (1,1,1,1)
        [HideInInspector] _SunVector("Sun Vector", Vector) = (0.0, 0.707, 0.707, 1.0)
        _SunGlowColor("Sun Glow Color", Color) = (1,1,1,1)
        _SunGlowExponent("Sun Glow Exponent", Range(1,1500)) = 150.0
        _SunHazeColor("Sun Haze Color", Color) = (1,1,1,1)
        _SunHazeExponent("Sun Haze Exponent", Range(1,500)) = 20.0


        // Blending state
        [HideInInspector] _SurfaceType("__surfacetype", Float) = 0.0
        [HideInInspector] _BlendMode("__blendmode", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 0.0
        [HideInInspector] _CullMode("__cullmode", Float) = 2.0
        [HideInInspector] _ZTestModeDistortion("_ZTestModeDistortion", Int) = 8

        // HACK: GI Baking system relies on some properties existing in the shader ("_MainTex", "_Cutoff" and "_Color") for opacity handling, so we need to store our version of those parameters in the hard-coded name the GI baking system recognizes.
        _MainTex("Albedo", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
    }

    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

    //-------------------------------------------------------------------------------------
    // Variants
    //-------------------------------------------------------------------------------------

    #pragma shader_feature _HORIZON_GRADIENT
    #pragma shader_feature _CLOUDS_HORIZON
    #pragma shader_feature _CLOUDS_OVERHEAD
    #pragma shader_feature _BACKDROP
    #pragma shader_feature _STARS
    #pragma shader_feature _VISIBLE_SUNMOON

    //-------------------------------------------------------------------------------------
    // Define
    //-------------------------------------------------------------------------------------

    #define UNITY_MATERIAL_UNLIT // Need to be define before including Material.hlsl
    #define ATTRIBUTES_NEED_TEXCOORD0
    #define ATTRIBUTES_NEED_TEXCOORD1
    #define VARYINGS_NEED_TEXCOORD0
    #define VARYINGS_NEED_TEXCOORD1
    #define VARYINGS_NEED_POSITION_WS

    //-------------------------------------------------------------------------------------
    // Include
    //-------------------------------------------------------------------------------------

    #include "CoreRP/ShaderLibrary/Common.hlsl"
    #include "../../ShaderVariables.hlsl"
    #include "../../ShaderPass/FragInputs.hlsl"
    #include "../../ShaderPass/ShaderPass.cs.hlsl"

    //-------------------------------------------------------------------------------------
    // variable declaration
    //-------------------------------------------------------------------------------------

    #include "SkyDomeUnlitProperties.hlsl"

    // All our shaders use same name for entry point
    #pragma vertex Vert
    #pragma fragment Frag

    ENDHLSL

    SubShader
    {
        // This tags allow to use the shader replacement features
        Tags{ "RenderPipeline" = "HDRenderPipeline" "RenderType" = "HDUnlitShader" }

        // Caution: The outline selection in the editor use the vertex shader/hull/domain shader of the first pass declare. So it should not be the meta pass.

        Pass
        {
            Name "SceneSelectionPass"
            Tags{ "LightMode" = "SceneSelectionPass" }

            Cull[_CullMode]

            ZWrite On

            HLSLPROGRAM

            // Note: Require _ObjectId and _PassValue variables

            #define SHADERPASS SHADERPASS_DEPTH_ONLY
            #define SCENESELECTIONPASS // This will drive the output of the scene selection shader
            #include "../../Material/Material.hlsl"
            #include "../Unlit/ShaderPass/UnlitDepthPass.hlsl"
            #include "SkyDomeUnlitData.hlsl"
            #include "../../ShaderPass/ShaderPassDepthOnly.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Depth prepass"
            Tags{ "LightMode" = "DepthForwardOnly" }

            Cull[_CullMode]

            ZWrite On

            ColorMask 0 // We don't have WRITE_NORMAL_BUFFER for unlit, but as we bind a buffer we shouldn't write into it.

            HLSLPROGRAM

            #define SHADERPASS SHADERPASS_DEPTH_ONLY
            #include "../../Material/Material.hlsl"
            #include "../Unlit/ShaderPass/UnlitDepthPass.hlsl"
            #include "SkyDomeUnlitData.hlsl"
            #include "../../ShaderPass/ShaderPassDepthOnly.hlsl"

            ENDHLSL
        }

        // Unlit shader always render in forward
        Pass
        {
            Name "Forward Unlit"
            Tags { "LightMode" = "ForwardOnly" }

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_CullMode]

            HLSLPROGRAM

            #pragma multi_compile _ DEBUG_DISPLAY

            #ifdef DEBUG_DISPLAY
            #include "../../Debug/DebugDisplay.hlsl"
            #endif

            #define SHADERPASS SHADERPASS_FORWARD_UNLIT
            #include "../../Material/Material.hlsl"
            #include "../Unlit/ShaderPass/UnlitSharePass.hlsl"
            #include "SkyDomeUnlitData.hlsl"
            #include "../../ShaderPass/ShaderPassForwardUnlit.hlsl"

            ENDHLSL
        }

        // Extracts information for lightmapping, GI (emission, albedo, ...)
        // This pass it not used during regular rendering.
        Pass
        {
            Name "META"
            Tags{ "LightMode" = "Meta" }

            Cull Off

            HLSLPROGRAM

            // Lightmap memo
            // DYNAMICLIGHTMAP_ON is used when we have an "enlighten lightmap" ie a lightmap updated at runtime by enlighten.This lightmap contain indirect lighting from realtime lights and realtime emissive material.Offline baked lighting(from baked material / light,
            // both direct and indirect lighting) will hand up in the "regular" lightmap->LIGHTMAP_ON.

            #define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
            #include "../../Material/Material.hlsl"
            #include "../Unlit/ShaderPass/UnlitSharePass.hlsl"
            #include "SkyDomeUnlitData.hlsl"
            #include "../../ShaderPass/ShaderPassLightTransport.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Distortion" // Name is not used
            Tags { "LightMode" = "DistortionVectors" } // This will be only for transparent object based on the RenderQueue index

            Blend [_DistortionSrcBlend] [_DistortionDstBlend], [_DistortionBlurSrcBlend] [_DistortionBlurDstBlend]
            BlendOp Add, [_DistortionBlurBlendOp]
            ZTest [_ZTestModeDistortion]
            ZWrite off
            Cull [_CullMode]

            HLSLPROGRAM

            #define SHADERPASS SHADERPASS_DISTORTION
            #include "../../Material/Material.hlsl"
            #include "../Unlit/ShaderPass/UnlitDistortionPass.hlsl"
            #include "SkyDomeUnlitData.hlsl"
            #include "../../ShaderPass/ShaderPassDistortion.hlsl"

            ENDHLSL
        }
    }

    CustomEditor "Experimental.Rendering.HDPipeline.SkyDomeUnlitGUI"
}
