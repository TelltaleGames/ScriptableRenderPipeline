Shader "HDRenderPipeline/SkyDomeUnlit"
{
    Properties
    {
        // Main Sky Texture Gradient
        _SkyGradHorizonColor("Horizon Color", Color) = (1, 1, 1, 1)
        _SkyGradZenithColor("Zenith Color", Color) = (0.1, 0.2, 1.0, 1)
        _SkyGradCurveBias("Curve Bias", Range(-1,1)) = 0.0

        _HorizonGradIntensity("Horizon Intensity", Range(0,1)) = 1
        _HorizonGradColor1("Horizon Top Color", Color) = (1, 1, 1, 1)
        _HorizonGradColor0("Horizon Bottom Color", Color) = (1, 1, 1, 1)
        _HorizonGradHeight("Height", Range(0,1)) = 0.2
        _HorizonGradColorBias("Color Ramp Bias", Range(-1,1)) = 0.0
        _HorizonGradAlphaBias("Alpha Ramp Bias", Range(-1,1)) = 0.0
        _HorizonGradDirection("Heading", Range(0,360)) = 0.0
        _HorizonGradDirVector("Dir Vector", Vector) = (1,0,0,1)
        _HorizonGradDirectionalAtten("Attenuation", Range(0,1)) = 0.0

        _CloudDistantMap("Distant Clouds", 2D) = "black" {}
        _CloudDistantColor("Cloud Tint", Color) = (1,1,1,1)
        _CloudRimIntensity("Cloud Rim Intensity", Range(0,1)) = 1
        _CloudDistantScrollSpeed("Cloud Speed", Float) = 0

        _CloudOverheadMap("Overhead Clouds", 2D) = "black" {}
        _CloudOverheadColor("Cloud Tint", Color) = (1,1,1,1)
        _CloudOverheadHeight("Cloud Height", Float) = 0
        _CloudOverheadScrollHeading("Cloud Heading", Float) = 0
        _CloudOverheadScrollVector("Cloud Vector", Vector) = (1,0,0,1)
        _CloudOverheadScrollSpeed("Cloud Speed", Float) = 0

        _StarMap("Star Map", 2D) = "black" {}
        _StarColor("Star Color", Color) = (1,1,1,1)

        _SunColor("Sun Color", Color) = (1,1,1,1)
        _SunElevation("Sun Elevation", Range(-90.0, 90.0)) = 45.0
        _SunAzimuth("Sun Azimuth", Range(0.0, 360.0)) = 0.0
        _SunVector("Sun Vector", Vector) = (0.0, 0.707, 0.707, 1.0)
        _SunHazeExponent("Sun Haze Exponent", Range(1,100)) = 50.0

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
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal

    //-------------------------------------------------------------------------------------
    // Variants
    //-------------------------------------------------------------------------------------

    //#pragma shader_feature _DISTANT_CLOUD_MAP
    //#pragma shader_feature _OVERHEAD_CLOUD_MAP
    //#pragma shader_feature _VISIBLE_SUNMOON

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
            Name "Depth prepass"
            Tags{ "LightMode" = "DepthForwardOnly" }

            Cull[_CullMode]

            ZWrite On

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
