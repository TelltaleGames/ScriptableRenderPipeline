Shader "HDRenderPipeline/Particle Uber" 
{
    Properties 
    {   
        // Blending state
        //[HideInInspector] _SurfaceType("__surfacetype", Float) = 0.0
        [HideInInspector] _SrcBlend("Src Blend", Float) = 1.0
        [HideInInspector] _DstBlend("Dst Blend", Float) = 0.0
        [HideInInspector] _Culling("Culling", Float) = 0.0
        [HideInInspector] _ZTest("ZTest", Float) = 4.0
        [Toggle] _ZWrite("Z Write", Int) = 0

        /*
        [HideInInspector] _SurfaceType("__surfacetype", Float) = 0.0
        [HideInInspector] _BlendMode("__blendmode", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _CullMode("__cullmode", Float) = 2.0
        [HideInInspector] _ZTestModeDistortion("_ZTestModeDistortion", Int) = 8
        */
          
        [Toggle(SHOW_NOISE)] _showNoise("Show", Int) = 0
        [Toggle(SHOW_ALPHA)] _showAlpha("Show Alpha", Int) = 0
        //[Toggle(USE_FOG)] _useFog("Fog", Int) = 0
        [Toggle(USE_DEPTH)] _useDepth("Depth Buffer", Int) = 0
        [Toggle(USE_DEPTHCOLOR)] _useDepthColor("Color", Int) = 0
        [Toggle(USE_BACKBUFFER)] _useBackbuffer("Backbuffer", Int) = 0
        [Toggle(USE_NOISE)] _useNoise("Noise", Int) = 0
        [Toggle(USE_BASE)] _useBase("Base", Int) = 0
        [Toggle(USE_WIPE)] _useWipe("Wipe", Int) = 0
        [Toggle(USE_LAYER1)] _useLayer1("Layer 1", Int) = 0
        [Toggle(USE_LAYER2)] _useLayer2("Layer 2", Int) = 0
        [Toggle(USE_LAYER3)] _useLayer3("Layer 3", Int) = 0


        _depthFalloff("Falloff", Float) = 1.0
        _depthPolar("Polarity", Float) = 0.0
        _depthIntensity("Intensity", Float) = 1.0
        _depthColor("Color", Color) = (1,1,1,1)
        _depthOpacity("Show Depth Buffer", Range(0, 1)) = 0

        _globalTileX("Tile X", Float) = 1.0
        _globalTileY("Tile Y", Float) = 1.0

        /*
        _backbufferTint("Tint", Color) = (1,1,1,1)
	    _backbufferWarp("Distortion", Range(0, 0.2)) = 0
        _backbufferIntensity("Intensity", Float) = 1
	    _backbufferZoom("Zoom", Range(0.5, 1)) = 0.5
        _backbufferWarpWrite("Distortion Write", Range(0, 1)) = 0
        */

        _wipeLerp("Lerp", Range(0, 1)) = 1.0
        _wipeWidth("Width", Range(0, 1)) = 1.0
        _wipeIntensity("Edge Intensity", Float) = 1
        _wipeEdgeColFO("Edge Falloff", Float) = 1.0
        _wipeEdgeScale("Edge Softness", Float) = 0.01
        _wipeTint("Edge Color", Color) = (1,1,1,0)

        _noiseTx("Texture", 2D) = "white" {}
        _noiseIntensity("Intensity", Float) = 1
        _noisePanX("Pan X", Float) = 0
        _noisePanY("Pan Y", Float) = 0
        _noiseSpin("Spin", Float) = 0
        _noiseOpacity("Opacity", Range(0, 1)) = 0

        _baseMode("Base - Blend Mode", Float) = 0
        _baseTx("Texture", 2D) = "white" {}
        _baseTint("Tint", Color) = (1,1,1,1)
        _baseWarp("Distortion", Range(0, 0.1)) = 0
        _baseIntensity("Intensity", Float) = 1
        _baseMask("Alpha Mask", Range(0, 1)) = 0
        [Toggle(BASE_ISPACKED)] _baseIsPacked("Is Packed", Int) = 0
        _baseChannelFilter("Channel Filter", Color) = (1,0,0,0)
        
        _layer1Mode("Layer 1 - Blend Mode", Float) = 0
        _Txt1 ("Texture", 2D) = "white" {}
        _tx1Tint ("Tint", Color) = (1,1,1,1)
        _tx1Warp("Distortion", Range(0, 0.1)) = 0
        _tx1Intensity("Intensity", Float) = 1
        _tx1Mask("Alpha Mask", Range(0, 1)) = 0
        _tx1PanX("Pan X", Float) = 0
        _tx1PanY("Pan Y", Float) = 0
        _tx1Spin("Spin", Float) = 0
        [Toggle(LAYER1_ISPACKED)] _tx1IsPacked("Is Packed", Int) = 0
        _tx1ChannelFilter("Channel Filter", Color) = (1,0,0,0)
    
        _layer2Mode("Layer 2 - Blend Mode", Float) = 0
        _Txt2 ("Texture", 2D) = "white" {}
        _tx2Tint ("Tint", Color) = (1,1,1,1)
        _tx2Warp("Distortion", Range(0, 0.1)) = 0
        _tx2Intensity("Intensity", Float) = 1
        _tx2Mask("Alpha Mask", Range(0, 1)) = 0
        _tx2PanX("Pan X", Float) = 0
        _tx2PanY("Pan Y", Float) = 0
        _tx2Spin("Spin", Float) = 0
        [Toggle(LAYER2_ISPACKED)] _tx2IsPacked("Is Packed", Int) = 0
        _tx2ChannelFilter("Channel Filter", Color) = (1,0,0,0)
    
        _layer3Mode("Layer 3 - Blend Mode", Float) = 0
        _Txt3 ("Texture", 2D) = "white" {}
        _tx3Tint ("Tint", Color) = (1,1,1,1)
        _tx3Warp("Distortion", Range(0, 0.1)) = 0
        _tx3Intensity("Intensity", Float) = 1
        _tx3PanX("Pan X", Float) = 0
        _tx3PanY("Pan Y", Float) = 0
        _tx3Spin("Spin", Float) = 0
        [Toggle(LAYER3_ISPACKED)] _tx3IsPacked("Is Packed", Int) = 0
        _tx3ChannelFilter("Channel Filter", Color) = (1,0,0,0)



/*
        /////////////////////////////////////////////////////////////////////////
        // Standard Unlit properties
        /////////////////////////////////////////////////////////////////////////

        // Be careful, do not change the name here to _Color. It will conflict with the "fake" parameters (see end of properties) required for GI.
        _UnlitColor("Color", Color) = (1, 1, 1, 1)
        _UnlitColorMap("ColorMap", 2D) = "white" {}

        _EmissiveColor("EmissiveColor", Color) = (1, 1, 1)
        _EmissiveColorMap("EmissiveColorMap", 2D) = "white" {}
        _EmissiveIntensity("EmissiveIntensity", Float) = 0

        _DistortionVectorMap("DistortionVectorMap", 2D) = "black" {}
        [ToggleUI] _DistortionEnable("Enable Distortion", Float) = 0.0
        [ToggleUI] _DistortionOnly("Distortion Only", Float) = 0.0
        [ToggleUI] _DistortionDepthTest("Distortion Depth Test Enable", Float) = 1.0
        [Enum(Add, 0, Multiply, 1)] _DistortionBlendMode("Distortion Blend Mode", Int) = 0
        [HideInInspector] _DistortionSrcBlend("Distortion Blend Src", Int) = 0
        [HideInInspector] _DistortionDstBlend("Distortion Blend Dst", Int) = 0
        [HideInInspector] _DistortionBlurSrcBlend("Distortion Blur Blend Src", Int) = 0
        [HideInInspector] _DistortionBlurDstBlend("Distortion Blur Blend Dst", Int) = 0
        [HideInInspector] _DistortionBlurBlendMode("Distortion Blur Blend Mode", Int) = 0
        _DistortionScale("Distortion Scale", Float) = 1
        _DistortionVectorScale("Distortion Vector Scale", Float) = 2
        _DistortionVectorBias("Distortion Vector Bias", Float) = -1
        _DistortionBlurScale("Distortion Blur Scale", Float) = 1
        _DistortionBlurRemapMin("DistortionBlurRemapMin", Float) = 0.0
        _DistortionBlurRemapMax("DistortionBlurRemapMax", Float) = 1.0

        // Transparency
        [ToggleUI] _PreRefractionPass("PreRefractionPass", Float) = 0.0

        [ToggleUI]  _AlphaCutoffEnable("Alpha Cutoff Enable", Float) = 0.0
        _AlphaCutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _TransparentSortPriority("_TransparentSortPriority", Float) = 0

        // Blending state
        [HideInInspector] _SurfaceType("__surfacetype", Float) = 0.0
        [HideInInspector] _BlendMode("__blendmode", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _CullMode("__cullmode", Float) = 2.0
        [HideInInspector] _ZTestModeDistortion("_ZTestModeDistortion", Int) = 8

        [ToggleUI] _EnableFogOnTransparent("Enable Fog", Float) = 0.0
        [ToggleUI] _DoubleSidedEnable("Double sided enable", Float) = 0.0

        // Stencil state
        [HideInInspector] _StencilRef("_StencilRef", Int) = 2 // StencilLightingUsage.RegularLighting  (fixed at compile time)
        [HideInInspector] _StencilWriteMask("_StencilWriteMask", Int) = 7 // StencilMask.Lighting  (fixed at compile time)
        [HideInInspector] _StencilRefMV("_StencilRefMV", Int) = 128 // StencilLightingUsage.RegularLighting  (fixed at compile time)
        [HideInInspector] _StencilWriteMaskMV("_StencilWriteMaskMV", Int) = 128 // StencilMask.ObjectsVelocity  (fixed at compile time)

                                                                                // Caution: C# code in BaseLitUI.cs call LightmapEmissionFlagsProperty() which assume that there is an existing "_EmissionColor"
                                                                                // value that exist to identify if the GI emission need to be enabled.
                                                                                // In our case we don't use such a mechanism but need to keep the code quiet. We declare the value and always enable it.
                                                                                // TODO: Fix the code in legacy unity so we can customize the beahvior for GI
        _EmissionColor("Color", Color) = (1, 1, 1)

        // HACK: GI Baking system relies on some properties existing in the shader ("_MainTex", "_Cutoff" and "_Color") for opacity handling, so we need to store our version of those parameters in the hard-coded name the GI baking system recognizes.
        _MainTex("Albedo", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        */
    }

       
    HLSLINCLUDE


    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal

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
    //#pragma multi_compile_instancing
    #pragma multi_compile_particles 
    //#if USE_FOG
    //    #pragma multi_compile_fog
    //#endif

    //-------------------------------------------------------------------------------------
    // Define
    //-------------------------------------------------------------------------------------

    #define UNITY_MATERIAL_UNLIT // Need to be define before including Material.hlsl

    //-------------------------------------------------------------------------------------
    // Include
    //-------------------------------------------------------------------------------------

    //#include "UnityCG.cginc"
    #include "UnityCG.cginc"
    #include "CoreRP/ShaderLibrary/Common.hlsl"
    #include "../ShaderVariables.hlsl"
    #include "../ShaderPass/FragInputs.hlsl"
    #include "../ShaderPass/ShaderPass.cs.hlsl" 

    

    //-------------------------------------------------------------------------------------
    // variable declaration
    //-------------------------------------------------------------------------------------

    #include "../Material/Unlit/UnlitProperties.hlsl"

    // All our shaders use same name for entry point
    #pragma vertex Vert
    #pragma fragment Frag

    ENDHLSL
     
        
    SubShader 
    { 
        Tags{ "Queue" = "Transparent+3" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        //Tags{ "RenderPipeline" = "HDRenderPipeline" "RenderType" = "HDUnlitShader" }

        ColorMask RGB
        Lighting Off
        Fog{ Color(0,0,0,0) }

        //GrabPass { "_Grab" }

      /*
        Pass
        {
            Name "Depth prepass"
            Tags{ "LightMode" = "DepthForwardOnly" }

            Cull[_CullMode]

            ZWrite On

            HLSLPROGRAM

            #define SHADERPASS SHADERPASS_DEPTH_ONLY
            #include "../Material/Material.hlsl"
            #include "particle_UnlitDepthPass.hlsl"
            #include "particle_uberData.hlsl"
            #include "../ShaderPass/ShaderPassDepthOnly.hlsl"

            ENDHLSL
        }
        */

        // Unlit shader always render in forward 
        Pass 
        {   
            Name "Forward Unlit"
            Tags{ "LightMode" = "ForwardOnly" }

            Blend [_SrcBlend] [_DstBlend] 
            Cull[_Culling]
            ZWrite[_ZWrite] 
            ZWrite off
            ZTest[_ZTest]
            //Offset 0, 0
                
            HLSLPROGRAM

            #pragma shader_feature SHOW_NOISE
            #pragma shader_feature SHOW_ALPHA
            #pragma shader_feature USE_FOG
            #pragma shader_feature USE_NOISE
            #pragma shader_feature USE_DEPTH
            #pragma shader_feature USE_DEPTHCOLOR
            #pragma shader_feature USE_BACKBUFFER
            #pragma shader_feature USE_WIPE

            #pragma shader_feature USE_BASE
            #pragma shader_feature BASE_ISPACKED
            #pragma shader_feature BASEMODE_ALPHABLEND
            #pragma shader_feature BASEMODE_ADD
            #pragma shader_feature BASEMODE_MULTIPLY

            #pragma shader_feature USE_LAYER1
            #pragma shader_feature LAYER1_ISPACKED
            #pragma shader_feature LAYER1MODE_ALPHABLEND
            #pragma shader_feature LAYER1MODE_ADD
            #pragma shader_feature LAYER1MODE_MULTIPLY

            #pragma shader_feature USE_LAYER2
            #pragma shader_feature LAYER2_ISPACKED
            #pragma shader_feature LAYER2MODE_ALPHABLEND
            #pragma shader_feature LAYER2MODE_ADD
            #pragma shader_feature LAYER2MODE_MULTIPLY

            #pragma shader_feature USE_LAYER3
            #pragma shader_feature LAYER3_ISPACKED
            #pragma shader_feature LAYER3MODE_ALPHABLEND
            #pragma shader_feature LAYER3MODE_ADD
            #pragma shader_feature LAYER3MODE_MULTIPLY

            #if USE_BASE
                sampler2D _baseTx;
                uniform float4 _baseTx_ST;
                half _baseIntensity;
                half _baseMask;
                half4 _baseTint;
                half _baseWarp;
            #endif

            #if USE_BASE && BASE_ISPACKED
                half4 _baseChannelFilter;
            #endif


            //#if USE_BACKBUFFER
			//    sampler2D _Grab;
            //    uniform float4 _GrabTexture_TexelSize;
            //    half4 _backbufferTint;
            //    half _backbufferWarp;
            //    half _backbufferIntensity;
            //    half _backbufferZoom;
            //    half _backbufferWarpWrite;
            //#endif
                
			   
            #if USE_NOISE
                sampler2D _noiseTx;
                uniform float4 _noiseTx_ST;
                half _noiseIntensity;
                half _noisePanX;
                half _noisePanY;
                half _noiseOpacity;
            #endif 

            #if USE_LAYER1
			    sampler2D _Txt1;
                uniform float4 _Txt1_ST;
                half4 _tx1Tint;
                half _tx1Warp;
                half _tx1Intensity;
                half _tx1Mask;
                half _tx1PanX;
                half _tx1PanY;
            #endif

            #if USE_LAYER1 && LAYER1_ISPACKED
                half4 _tx1ChannelFilter;
            #endif

            #if USE_LAYER2
			    sampler2D _Txt2;
                uniform float4 _Txt2_ST;
                half4 _tx2Tint;
                half _tx2Warp;
                half _tx2Intensity;
                half _tx2Mask;
                half _tx2PanX;
                half _tx2PanY;
            #endif

            #if USE_LAYER2 && LAYER2_ISPACKED
                half4 _tx2ChannelFilter;
            #endif

            #if USE_LAYER3
			    sampler2D _Txt3;
                uniform float4 _Txt3_ST;
                half4 _tx3Tint;
                half _tx3Warp;
                half _tx3Intensity;
                half _tx3PanX;
                half _tx3PanY;
            #endif

            #if USE_LAYER3 && LAYER3_ISPACKED
                half4 _tx3ChannelFilter;
            #endif

            #if USE_WIPE
                half _wipeLerp;
                half _wipeIntensity;
                half _wipeEdgeColFO;
                half _wipeEdgeScale;
                half _wipeWidth;
                half4 _wipeTint;
            #endif

            #if USE_DEPTH
                sampler2D _CameraDepthTexture;
                half _depthFalloff;
                half _depthPolar;
            #endif

            #if USE_DEPTH && USE_DEPTHCOLOR
                half4 _depthColor;
                half _depthIntensity;
                half _depthOpacity;
            #endif
			    
            float _globalTileX;
            float _globalTileY;
            half _noiseSpin;
            half _tx1Spin;
            half _tx2Spin;
            half _tx3Spin;
			static const half PI2 = 3.14159265f * 2;
            static const half alphaCutoff = 0.01f;
			
			struct VertexInput {
			    float4 vertex : POSITION;
			    float4 texcoord : TEXCOORD0;
			    half4 color : COLOR;
			};
			
			struct VertexOutput {
                float4 vertex : POSITION;
			    half4 color : COLOR; 
                
                //#if USE_BACKBUFFER
                //    float4 uvgrab : TEXCOORD0;
                //#endif
                
                #if USE_NOISE
                    half2 uvNoise : TEXCOORD1;
                #endif
                #if USE_BASE
                    half2 uvBase : TEXCOORD2;
                #endif
                #if USE_LAYER1
                    half2 uvTxt1 : TEXCOORD3;
                #endif
                #if USE_LAYER2
                    half2 uvTxt2 : TEXCOORD4;
                #endif
                #if USE_LAYER3
                    half2 uvTxt3 : TEXCOORD5;
                #endif
                #if USE_DEPTH
                    float4 projPos : TEXCOORD6;
                #endif
                    
                //#if USE_FOG
                //    UNITY_FOG_COORDS(1)
                //#endif
			};
 
    
            VertexOutput Vert(VertexInput v)
			{ 
                VertexOutput o;
			  	    
			    o.vertex = UnityObjectToClipPos(v.vertex);      // compute transformed vertex position
                 
                // TODO: Switch this out with particle life value
                half particleLife = _Time.y;

				// Calc rotation
				half4 rSin, rCos;
				half4 angle = PI2 * (particleLife * half4(_tx1Spin, _tx2Spin, _tx3Spin, _noiseSpin));
				sincos(angle, rSin, rCos);
                float2 globalTile = float2(_globalTileX, _globalTileY);

                #if USE_BASE
                    o.uvBase = TRANSFORM_TEX(v.texcoord * globalTile, _baseTx);   // compute the texcoords
                #endif
                    
                // _noiseTx
                #if USE_NOISE
                    o.uvNoise = TRANSFORM_TEX(v.texcoord, _noiseTx);   // compute the texcoords
                    o.uvNoise -= 0.5;
                    o.uvNoise = (rCos.w * o.uvNoise) + (half2(-rSin.w, rSin.w) * o.uvNoise.yx) + 0.5; // Rotate
                    o.uvNoise += frac(half2(_noisePanX, _noisePanY) * particleLife); // Apply UV offset
                #endif

                // _Txt1
                #if USE_LAYER1
                    o.uvTxt1 = TRANSFORM_TEX(v.texcoord * globalTile, _Txt1);   // compute the texcoords
				    o.uvTxt1 -= 0.5;
				    o.uvTxt1 = (rCos.x * o.uvTxt1) + (half2(-rSin.x, rSin.x) * o.uvTxt1.yx) + 0.5; // Rotate
                    o.uvTxt1 += frac(half2(_tx1PanX, _tx1PanY) * particleLife); // Apply UV offset
                #endif

			    // _Txt2
                #if USE_LAYER2
                    o.uvTxt2 = TRANSFORM_TEX(v.texcoord * globalTile, _Txt2);   // compute the texcoords
				    o.uvTxt2 -= 0.5;
			        o.uvTxt2 = (rCos.y * o.uvTxt2) + (half2(-rSin.y, rSin.y) * o.uvTxt2.yx) + 0.5; // Rotate
                    o.uvTxt2 += frac(half2(_tx2PanX, _tx2PanY) * particleLife); // Apply UV offset
                #endif

			    // _Txt3
                #if USE_LAYER3
                    o.uvTxt3 = TRANSFORM_TEX(v.texcoord * globalTile, _Txt3);   // compute the texcoords
				    o.uvTxt3 -= 0.5;
			        o.uvTxt3 = (rCos.z * o.uvTxt3) + (half2(-rSin.z, rSin.z) * o.uvTxt3.yx) + 0.5; // Rotate
                    o.uvTxt3 += frac(half2(_tx3PanX, _tx3PanY) * particleLife); // Apply UV offset
                #endif

			    
                // Backbuffer
                //#if USE_BACKBUFFER
                //    // UV flip fixup
                //    #if UNITY_UV_STARTS_AT_TOP
                //        float scale = -1.0;
                //    #else
                //        float scale = 1.0;
                //    #endif
				//    o.uvgrab.xy = float2(o.vertex.x, o.vertex.y*scale);
			    //    o.uvgrab.zw = o.vertex.zw;
                //#endif


				// Vert color
				o.color = v.color; 
                #if USE_WIPE
				    o.color.r *= _wipeLerp;
                #endif
				
				// Get depth
                #if USE_DEPTH
				    o.projPos = ComputeScreenPos(o.vertex);
				    COMPUTE_EYEDEPTH(o.projPos.z);
                #endif

                //#if USE_FOG
                //    UNITY_TRANSFER_FOG(o, o.pos);
                //#endif

				return o;
			}
   
   
  
			half4 Frag( VertexOutput i ) : COLOR
			{ 
                half4 warpCol = half4(0, 0, 0, 0);
                half4 color = half4(0, 0, 0, 0);
                half alphaMask = 1.f;
                half2 distortUV;

                // Depth bias
                #if USE_DEPTH
                    half sceneZ = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos))));
                    half depthFade = saturate(_depthFalloff * (sceneZ - i.projPos.z));
                    half2 depth = half2(1 - _depthPolar, _depthPolar) * half2(depthFade, 1 - depthFade);
                    depthFade = depth.x + depth.y;

                    #if USE_DEPTHCOLOR
                        color += half4(depthFade, 0, 0, 1).xxxw * _depthOpacity;
                    #endif
                    // warpCol = half4(depthFade, 0, 0, 1).xxxw; // Distort by depth
                #endif
                    

                #if USE_NOISE
                    warpCol += tex2D(_noiseTx, i.uvNoise) * _noiseIntensity;
                    color += warpCol * _noiseOpacity;

                    #if SHOW_NOISE
                        return warpCol;
                    #endif
                #endif
                

                //#if USE_BACKBUFFER
                //    // compute screen texture coordinates
                //    half2 screenPos = (i.uvgrab.xy / i.uvgrab.w);// *_backbufferZoom;   // screenpos ranges from -1 to 1 + Zoom
                //    screenPos = (screenPos + 1) * 0.5; // Rescale 0 to 1 
                //
                //    // Distort background by Noise
                //    half s = 1 + (((warpCol.r + warpCol.g) - 1) * _backbufferWarp);
			    //   half2 screenUV = (s * (screenPos - 0.5)) + 0.5;
                //
                //    color += tex2D( _Grab, screenUV) * _backbufferTint * half4(_backbufferIntensity,0,0,1).xxxw;
                //    warpCol = frac(warpCol + (color * _backbufferWarpWrite));
                //#endif
                

                // Base color
                #if USE_BASE
                    distortUV = (half2(warpCol.r, warpCol.b) + half2(warpCol.g, warpCol.r) - 1) * _baseWarp;
                    half4 baseCol = tex2D(_baseTx, i.uvBase + distortUV); 

                    #if BASE_ISPACKED
                        baseCol *= _baseChannelFilter;
                        baseCol.a = saturate(baseCol.r + baseCol.g + baseCol.b + baseCol.a);
                        baseCol = half4(1,1,1,baseCol.a);
                    #endif

                    baseCol *= half4(_baseIntensity * baseCol.a, 0, 0, 1).xxxw * _baseTint; // Tint and multiply by intensity

                    #if BASEMODE_ALPHABLEND
                        color = lerp(
                            half4(color.r, color.g, color.b, color.a),
                            half4(baseCol.r, baseCol.g, baseCol.b, color.a),
                            baseCol.a);
                    #endif

                    #if BASEMODE_ADD
                        color.rgb += baseCol.rgb;
                    #endif

                    #if BASEMODE_MULTIPLY
                        color.rgb *= baseCol.rgb;
                    #endif

                    color.a = baseCol.a;
                    alphaMask *= lerp(1, baseCol.a,_baseMask);
                #endif

                        
	            // Layer 1 
                #if USE_LAYER1
              	    distortUV = (half2(warpCol.r, warpCol.b) + half2(warpCol.g, warpCol.r) -1) * _tx1Warp;
                    half4 txtCol1 = tex2D(_Txt1, i.uvTxt1 + distortUV);

                    #if LAYER1_ISPACKED
                        txtCol1 *= _tx1ChannelFilter;
                        txtCol1.a = saturate(txtCol1.r + txtCol1.g + txtCol1.b + txtCol1.a);
                        txtCol1 = half4(1, 1, 1, txtCol1.a);
                    #endif

                    txtCol1.a *= alphaMask;
                    txtCol1 *= half4(_tx1Intensity * _tx1Tint.a, 0, 0, 1).xxxw * _tx1Tint; // Tint and multiply by intensity
                        
                    #if LAYER1MODE_ALPHABLEND
                        color = lerp(
                            half4(color.r, color.g, color.b, color.a),
                            half4(txtCol1.r, txtCol1.g, txtCol1.b, color.a),
                            txtCol1.a);
                    #endif

                    #if LAYER1MODE_ADD
                        color.rgb += txtCol1.rgb;
                    #endif

                    #if LAYER1MODE_MULTIPLY
                        color.rgb *= txtCol1.rgb;
                    #endif
                        
                    color.a = saturate(color.a + txtCol1.a);
                    alphaMask *= lerp(1, txtCol1.a, _tx1Mask);
                #else
                    half4 txtCol1 = half4(0, 0, 0, 0);
                #endif


                // Layer 2
                #if USE_LAYER2
                    distortUV = (half2(warpCol.g, warpCol.r) + half2(warpCol.b, warpCol.g) -1) * _tx2Warp;
                    half4 txtCol2 = tex2D(_Txt2, i.uvTxt2 + distortUV);
                        
                    #if LAYER2_ISPACKED
                        txtCol2 *= _tx2ChannelFilter;
                        txtCol2.a = saturate(txtCol2.r + txtCol2.g + txtCol2.b + txtCol2.a);
                        txtCol2 = half4(1, 1, 1, txtCol2.a);
                    #endif

                    txtCol2.a *= alphaMask;
                    txtCol2 *= half4(_tx2Intensity * _tx2Tint.a, 0, 0, 1).xxxw * _tx2Tint; // Tint and multiply by intensity

                    #if LAYER2MODE_ALPHABLEND
                        color = lerp(
                            half4(color.r, color.g, color.b, color.a),
                            half4(txtCol2.r, txtCol2.g, txtCol2.b, color.a),
                            txtCol2.a);
                    #endif

                    #if LAYER2MODE_ADD
                        color.rgb += txtCol2.rgb;
                    #endif

                    #if LAYER2MODE_MULTIPLY
                        color.rgb *= txtCol2.rgb;
                    #endif

                    color.a = saturate(color.a + txtCol2.a);
                    alphaMask *= lerp(1, txtCol2.a, _tx2Mask);
                #endif


                // Layer 3
                #if USE_LAYER3
                    distortUV = (half2(warpCol.b, warpCol.g) + half2(warpCol.g, warpCol.b) -1) * _tx3Warp;
                    half4 txtCol3 = tex2D(_Txt3, i.uvTxt3 + distortUV);

                    #if LAYER3_ISPACKED
                        txtCol3 *= _tx3ChannelFilter;
                        txtCol3.a = saturate(txtCol3.r + txtCol3.g + txtCol3.b + txtCol3.a);
                        txtCol3 = half4(1, 1, 1, txtCol3.a);
                    #endif

                    txtCol3.a *= alphaMask;
                    txtCol3 *= half4(_tx3Intensity * _tx3Tint.a, 0, 0, 1).xxxw * _tx3Tint; // Tint and multiply by intensity
                        
                    #if LAYER3MODE_ALPHABLEND
                        color = lerp(
                            half4(color.r, color.g, color.b, color.a),
                            half4(txtCol3.r, txtCol3.g, txtCol3.b, color.a),
                            txtCol3.a);
                    #endif

                    #if LAYER3MODE_ADD
                        color.rgb += txtCol3.rgb;
                    #endif

                    #if LAYER3MODE_MULTIPLY
                        color.rgb *= txtCol3.rgb;
                    #endif
                        
                    color.a = saturate(color.a + txtCol3.a);
                #endif

                #if USE_DEPTH
                    #if USE_DEPTHCOLOR
                        color.rgb = lerp(_depthColor * _depthIntensity, color, depthFade).rgb; // Color
                        color.a = lerp(color.a * depthFade, color.a, _depthColor.a);
                    #else
                        color.a *= depthFade; // Fade
                    #endif
                    color.a = saturate(color.a);
                #endif
                           

                #if USE_WIPE
			        // Wipe Alpha. Wipe R channel defines lerp ( for now )
                    half wipeAlpha = (i.color.r - (1 - color.a) - (_wipeWidth)) / _wipeWidth;
			        wipeAlpha *= wipeAlpha;
			    
			        // Edge col
			        half edge = pow(wipeAlpha, _wipeEdgeColFO);
                    color = lerp(color, color * half4(1-edge,0,0,1).xxxw, _wipeTint.a);
                    color += (_wipeTint * half4(edge, 0, 0, 1).xxxw * _wipeTint.a) * _wipeIntensity;

                    color.a = saturate(color.a * (1 - wipeAlpha) / _wipeEdgeScale);
                #endif
                    

                //#if USE_FOG
                //    UNITY_APPLY_FOG_COLOR(i.fogCoord, color, half4(0.5, 0.5, 0.5, 1));
                //#endif

                // Vertex color
                #if USE_WIPE
                    color.a *= i.color.a;
                #else
                    color *= i.color;
                #endif

                clip(color.a < alphaCutoff ? -1 : 1);

                #if SHOW_ALPHA
                    return half4(color.a, color.a, color.a, 1);
                #endif
                     
				return color;
			}

            ENDHLSL
        }
        
        
/*
        // Unlit shader always render in forward
        Pass
        {
            Name "Forward Unlit"
            Tags{ "LightMode" = "ForwardOnly" }

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_CullMode]

            HLSLPROGRAM

            #pragma multi_compile _ DEBUG_DISPLAY

            #ifdef DEBUG_DISPLAY
            #include "../../Debug/DebugDisplay.hlsl"
            #endif

            #define SHADERPASS SHADERPASS_FORWARD_UNLIT
            #include "../Material/Material.hlsl"
            #include "particle_UnlitSharePass.hlsl"
            #include "particle_uberData.hlsl"
            #include "../ShaderPass/ShaderPassForwardUnlit.hlsl"

            ENDHLSL
        }
        */
        
        /*
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
            #include "../Material/Material.hlsl"
            #include "particle_UnlitSharePass.hlsl"
            #include "particle_uberData.hlsl"
            #include "../ShaderPass/ShaderPassLightTransport.hlsl"

            ENDHLSL
        }
        */

        /*
        Pass
        {
            Name "Distortion" // Name is not used
            Tags{ "LightMode" = "DistortionVectors" } // This will be only for transparent object based on the RenderQueue index

            Blend[_DistortionSrcBlend][_DistortionDstBlend],[_DistortionBlurSrcBlend][_DistortionBlurDstBlend]
            BlendOp Add,[_DistortionBlurBlendOp]
            ZTest[_ZTestModeDistortion]
            ZWrite off
            Cull[_CullMode]

            HLSLPROGRAM

            #define SHADERPASS SHADERPASS_DISTORTION
            #include "../Material/Material.hlsl"
            #include "particle_UnlitDistortionPass.hlsl" 
            #include "../Material/Unlit/UnlitData.hlsl"
            #include "../ShaderPass/ShaderPassDistortion.hlsl"

            ENDHLSL
        }
        */
        
    }
   
    CustomEditor "Experimental.Rendering.HDPipeline.ParticleUberUI"
}
