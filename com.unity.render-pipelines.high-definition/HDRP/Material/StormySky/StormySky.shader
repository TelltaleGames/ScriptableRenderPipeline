//
//  Stormy Sky shader adapted from:
//      http://vfxmike.blogspot.com/2018/07/dark-and-stormy.html
//

Shader "HDRenderPipeline/StormySky"
{
    Properties
    {
        // Versioning of material to help for upgrading
        [HideInInspector] _HdrpVersion("_HdrpVersion", Float) = 1

        // Be careful, do not change the name here to _Color. It will conflict with the "fake" parameters (see end of properties) required for GI.
        //_UnlitColor("Color", Color) = (1,1,1,1)
        //_UnlitColorMap("ColorMap", 2D) = "white" {}

        [NoScaleOffset] _CloudTex1 ("Clouds 1", 2D) = "white" {}
        [NoScaleOffset] _FlowTex1 ("Flow Tex 1", 2D) = "grey" {}
        _Tiling1("Tiling 1", Vector) = (1,0.01,0,0)

        [NoScaleOffset] _CloudTex2 ("Clouds 2", 2D) = "white" {}
        [NoScaleOffset] _Tiling2("Tiling 2", Vector) = (1,1,0,0)
        _Cloud2Amount ("Cloud 2 Amount", float) = 0.5
        _FlowSpeed ("Flow Speed", float) = 1
        _FlowAmount ("Flow Amount", float) = 1

        [NoScaleOffset] _WaveTex ("Wave", 2D) = "white" {}
        _TilingWave("Tiling Wave", Vector) = (1,1,0,0)
        _WaveAmount ("Wave Amount", float) = 0.5
        _WaveDistort ("Wave Distort", float) = 0.05

        _CloudScale ("Clouds Scale", float) = 1.0
        _CloudBias ("Clouds Bias", float) = 0.0

        [NoScaleOffset] _ColorTex ("Color Tex", 2D) = "white" {}
        _TilingColor("Tiling Color", Vector) = (1,1,0,0)
        _ColPow ("Color Power", float) = 1
        _ColFactor ("Color Factor", float) = 1

        _Color ("Color", Color) = (1.0,1.0,1.0,1)
        _Color2 ("Color2", Color) = (1.0,1.0,1.0,1)

        _CloudDensity ("Cloud Density", float) = 5.0

        _BumpOffset ("BumpOffset", float) = 0.1
        _Steps ("Steps", float) = 10

        _CloudHeight ("Cloud Height", float) = 100
        _Scale ("Scale", float) = 10

        _Speed ("Speed", float) = 1

        _LightSpread ("Light Spread PFPF", Vector) = (2.0,1.0,50.0,3.0)

        _FoggyColor ("Fog Color", Color) = (0.05,0.05,0.05,1.0)
        _FoggyDistance ("Fog Distance", Float) = 1000

        _SunColor ("Sun Color", Color) = (0.05,0.05,0.05,1.0)
        _SunVector ("Sun Direction", Vector) = (0,1,0,0)

        [HideInInspector] _SurfaceType("__surfacetype", Float) = 0.0
        // HACK: GI Baking system relies on some properties existing in the shader ("_MainTex", "_Cutoff" and "_Color") for opacity handling, so we need to store our version of those parameters in the hard-coded name the GI baking system recognizes.
        //_MainTex("Albedo", 2D) = "white" {}
        //_Color("Color", Color) = (1,1,1,1)
        //_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _EmissionColor ("Emission Color", Color) = (1.0, 0.0, 0.0, 1.0)
    }

    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

    //-------------------------------------------------------------------------------------
    // Variant
    //-------------------------------------------------------------------------------------

    #pragma shader_feature _ALPHATEST_ON
    // #pragma shader_feature _DOUBLESIDED_ON - We have no lighting, so no need to have this combination for shader, the option will just disable backface culling

    #pragma shader_feature _EMISSIVE_COLOR_MAP

    // Keyword for transparent
    #pragma shader_feature _SURFACE_TYPE_TRANSPARENT
    #pragma shader_feature _ _BLENDMODE_ALPHA _BLENDMODE_ADD _BLENDMODE_PRE_MULTIPLY
    #pragma shader_feature _ENABLE_FOG_ON_TRANSPARENT

    //enable GPU instancing support
    #pragma multi_compile_instancing

    //-------------------------------------------------------------------------------------
    // Define
    //-------------------------------------------------------------------------------------

    #define UNITY_MATERIAL_UNLIT // Need to be define before including Material.hlsl

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

    #include "StormySkyProperties.hlsl"

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

            Cull Off

            ZWrite On

            HLSLPROGRAM

            // Note: Require _ObjectId and _PassValue variables

            #define SHADERPASS SHADERPASS_DEPTH_ONLY
            #define SCENESELECTIONPASS // This will drive the output of the scene selection shader
            #define VARYINGS_NEED_POSITION_WS
            #include "../../Material/Material.hlsl"
            #include "../Unlit/ShaderPass/UnlitDepthPass.hlsl"

            #include "StormySkyData.hlsl"
            #include "../../ShaderPass/ShaderPassDepthOnly.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Depth prepass"
            Tags{ "LightMode" = "DepthForwardOnly" }

            Cull Off

            ZWrite On

            ColorMask 0 // We don't have WRITE_NORMAL_BUFFER for unlit, but as we bind a buffer we shouldn't write into it.

            HLSLPROGRAM

            #define SHADERPASS SHADERPASS_DEPTH_ONLY
            #define VARYINGS_NEED_POSITION_WS
            #include "../../Material/Material.hlsl"

            #include "../Unlit/ShaderPass/UnlitDepthPass.hlsl"
            #include "StormySkyData.hlsl"
            #include "../../ShaderPass/ShaderPassDepthOnly.hlsl"

            ENDHLSL
        }

        // Unlit shader always render in forward
        Pass
        {
            Name "Forward Unlit"
            Tags { "LightMode" = "ForwardOnly" }

            Blend One Zero
            ZWrite On
            Cull Off

            HLSLPROGRAM

            #pragma multi_compile _ DEBUG_DISPLAY

            #ifdef DEBUG_DISPLAY
            #include "../../Debug/DebugDisplay.hlsl"
            #endif

            #define SHADERPASS SHADERPASS_FORWARD_UNLIT
            #define VARYINGS_NEED_POSITION_WS
            #include "../../Material/Material.hlsl"

            #include "../Unlit/ShaderPass/UnlitSharePass.hlsl"
            #include "StormySkyData.hlsl"
            #include "../../ShaderPass/ShaderPassForwardUnlit.hlsl"

            ENDHLSL
        }

        // Extracts information for lightmapping, GI (emission, albedo, ...)
        // This pass it not used during regular rendering.
/*
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
            #include "StormySkyData.hlsl"
            #include "../../ShaderPass/ShaderPassLightTransport.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Distortion" // Name is not used
            Tags { "LightMode" = "DistortionVectors" } // This will be only for transparent object based on the RenderQueue index

            // TODO: None of the [] settings below are set by properties. Either add properties or set hardcoded values in uncommenting this code.
            Blend [_DistortionSrcBlend] [_DistortionDstBlend], [_DistortionBlurSrcBlend] [_DistortionBlurDstBlend]
            BlendOp Add, [_DistortionBlurBlendOp]
            ZTest [_ZTestModeDistortion]
            ZWrite off
            Cull [_CullMode]

            HLSLPROGRAM

            #define SHADERPASS SHADERPASS_DISTORTION
            #include "../../Material/Material.hlsl"
            #include "../Unlit/ShaderPass/UnlitDistortionPass.hlsl"
            #include "StormySkyData.hlsl"
            #include "../../ShaderPass/ShaderPassDistortion.hlsl"

            ENDHLSL
        }
*/
    }

    CustomEditor "Experimental.Rendering.HDPipeline.StormySkyGUI"
}
