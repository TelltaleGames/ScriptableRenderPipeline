using UnityEngine;
using UnityEditor;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    //class ParticleUberUI : BaseLitGUI
	class ParticleUberUI : ShaderGUI
	{
		MaterialEditor materialEditor;
		MaterialProperty[] properties;
		static GUIContent staticLabel = new GUIContent();

        enum BlendMode
        {
            AlphaBlend,
            Add,
            Multiply,
            MultiplyX2,
        }

        enum LayerBlend
        {
            AlphaBlend,
            Add,
            Multiply
        }

	    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
	    {
			this.materialEditor = materialEditor;
			this.properties = properties;

            Material material = materialEditor.target as Material;

			doMain(material);
		}

		MaterialProperty FindProperty (string name) {
			return FindProperty(name, properties);
		}


		static GUIContent MakeLabel (
			MaterialProperty property, string tooltip = null
		) {
			staticLabel.text = property.displayName;
			staticLabel.tooltip = tooltip;
			return staticLabel;
		}

        
        void SetLayerBlend(Material material, string  propName, string keyAdd, string keyAlpha, string keyMultiply)
        {
            MaterialProperty propLayerBlend = FindProperty(propName);

            LayerBlend layerBlend = (LayerBlend)(propLayerBlend.floatValue);
            layerBlend = (LayerBlend)EditorGUILayout.EnumPopup("Blend Mode", layerBlend);

            propLayerBlend.floatValue = (float)layerBlend;

            switch(layerBlend)
            {
                case LayerBlend.Add:
                    material.EnableKeyword( keyAdd );
                    material.DisableKeyword( keyAlpha );
                    material.DisableKeyword( keyMultiply );
                    break;

                case LayerBlend.AlphaBlend:
                    material.DisableKeyword( keyAdd );
                    material.EnableKeyword( keyAlpha );
                    material.DisableKeyword( keyMultiply );
                    break;

                case LayerBlend.Multiply:
                    material.DisableKeyword( keyAdd );
                    material.DisableKeyword( keyAlpha );
                    material.EnableKeyword( keyMultiply );
                    break;
            }

        }


        void SetBlendMode()
        {
            /*
            ////
            MaterialProperty _SurfaceType = FindProperty("_SurfaceType");
            //SurfaceType
            ??UnityEditor.Experimental.Rendering.HDPipeline.BaseUnlitGUI.SurfaceType
            UnityEngine.Rendering.BlendMode surfaceType  = (UnityEngine.Rendering.BlendMode)(_SrcBlend.floatValue);
            /// 
            */

            MaterialProperty _SrcBlend = FindProperty("_SrcBlend");
            MaterialProperty _DstBlend = FindProperty("_DstBlend");

            UnityEngine.Rendering.BlendMode srcBlend = (UnityEngine.Rendering.BlendMode)(_SrcBlend.floatValue);
            UnityEngine.Rendering.BlendMode dstBlend = (UnityEngine.Rendering.BlendMode)(_DstBlend.floatValue);
  
            BlendMode blendMode = BlendMode.Add;
            // AlphaBlend
            if(srcBlend == UnityEngine.Rendering.BlendMode.SrcAlpha && dstBlend == UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha)
                blendMode = BlendMode.AlphaBlend;
            // Add
            else if(srcBlend == UnityEngine.Rendering.BlendMode.SrcAlpha && dstBlend == UnityEngine.Rendering.BlendMode.One)
                blendMode = BlendMode.Add;
            // Multiply
            else if(srcBlend == UnityEngine.Rendering.BlendMode.DstColor && dstBlend == UnityEngine.Rendering.BlendMode.Zero)
                blendMode = BlendMode.Multiply;
            // MultiplyX2
            else if(srcBlend == UnityEngine.Rendering.BlendMode.DstColor && dstBlend == UnityEngine.Rendering.BlendMode.SrcColor)
                blendMode = BlendMode.MultiplyX2;
            else
                blendMode = BlendMode.AlphaBlend;

            blendMode = (BlendMode)EditorGUILayout.EnumPopup("Blend Mode", blendMode);

            switch(blendMode)
            {
                case BlendMode.AlphaBlend:
                    _SrcBlend.floatValue = (float)UnityEngine.Rendering.BlendMode.SrcAlpha;
                    _DstBlend.floatValue = (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha;
                    break;

               case BlendMode.Add:
                    _SrcBlend.floatValue = (float)UnityEngine.Rendering.BlendMode.SrcAlpha;
                    _DstBlend.floatValue = (float)UnityEngine.Rendering.BlendMode.One;
                    break;

                case BlendMode.Multiply:
                    _SrcBlend.floatValue = (float)UnityEngine.Rendering.BlendMode.DstColor;
                    _DstBlend.floatValue = (float)UnityEngine.Rendering.BlendMode.Zero;
                    break;

                case BlendMode.MultiplyX2:
                    _SrcBlend.floatValue = (float)UnityEngine.Rendering.BlendMode.DstColor;
                    _DstBlend.floatValue = (float)UnityEngine.Rendering.BlendMode.SrcColor;
                    break;

                default:
                    break;
            }
        }


        void MapToVector2Field(string nameX, string nameY, string name)
        {
            MaterialProperty propX = FindProperty(nameX);
            MaterialProperty propY = FindProperty(nameY);

            Vector2 XY = new Vector2(propX.floatValue, propY.floatValue);
            XY = EditorGUILayout.Vector2Field(name, XY);                    
            propX.floatValue = XY.x;
            propY.floatValue = XY.y;
        }


	    void doMain(Material material)
	    {
            SetBlendMode();    

            MaterialProperty _Culling = FindProperty("_Culling");
            UnityEngine.Rendering.CullMode cullMode = (UnityEngine.Rendering.CullMode)(_Culling.floatValue);
            cullMode = (UnityEngine.Rendering.CullMode)EditorGUILayout.EnumPopup("Cull Mode", cullMode);
            _Culling.floatValue = (float)cullMode;

            MaterialProperty _ZTest = FindProperty("_ZTest");
            UnityEngine.Rendering.CompareFunction zTest = (UnityEngine.Rendering.CompareFunction)(_ZTest.floatValue);
            zTest = (UnityEngine.Rendering.CompareFunction)EditorGUILayout.EnumPopup("Z Test", zTest);
            _ZTest.floatValue = (float)zTest;

            MaterialProperty _ZWrite = FindProperty("_ZWrite");
			materialEditor.ShaderProperty( _ZWrite, MakeLabel(_ZWrite, "_ZWrite") );

            //MaterialProperty _useFog = FindProperty("_useFog");
			//materialEditor.ShaderProperty( _useFog, MakeLabel(_useFog, "Fog" ) );
           

            //======================================================================================
            MaterialProperty _useDepth = FindProperty("_useDepth");
            //======================================================================================
			materialEditor.ShaderProperty( _useDepth, MakeLabel(_useDepth, "Depth Buffer" ) );
            if(_useDepth.floatValue == 1)
            {
                EditorGUI.indentLevel += 1;

                MaterialProperty _depthFalloff = FindProperty("_depthFalloff");
			    materialEditor.ShaderProperty( _depthFalloff, MakeLabel(_depthFalloff, "Depth bias Falloff") );

			    MaterialProperty _depthPolar = FindProperty("_depthPolar");
			    materialEditor.ShaderProperty( _depthPolar, MakeLabel(_depthPolar, "Depth bias polarity") );


                //======================================================================================
                MaterialProperty _useDepthColor = FindProperty("_useDepthColor");
                //======================================================================================
			    materialEditor.ShaderProperty( _useDepthColor, MakeLabel(_useDepthColor, "Depth Biased Color" ) );
                if(_useDepthColor.floatValue == 1)
                {
                    EditorGUI.indentLevel += 1; 

                    MaterialProperty _depthColor = FindProperty("_depthColor");
			        materialEditor.ShaderProperty( _depthColor, MakeLabel(_depthColor, "Color") );

                    MaterialProperty _depthIntensity = FindProperty("_depthIntensity");
			        materialEditor.ShaderProperty( _depthIntensity, MakeLabel(_depthIntensity, "Intensity") );

                    MaterialProperty _depthOpacity = FindProperty("_depthOpacity");
			        materialEditor.ShaderProperty( _depthOpacity, MakeLabel(_depthOpacity, "Render the actual depth buffer") );

                    EditorGUI.indentLevel -= 1;
                }

                EditorGUI.indentLevel -= 1;
            }


            MapToVector2Field("_globalTileX", "_globalTileY", "Global Tiling");     

            MaterialProperty _showAlpha = FindProperty("_showAlpha");
			materialEditor.ShaderProperty( _showAlpha, MakeLabel(_showAlpha, "_showAlpha" ) );       


            //======================================================================================
            GUILayout.Label("");
            MaterialProperty _useNoise = FindProperty("_useNoise");
            //======================================================================================
			materialEditor.ShaderProperty( _useNoise, MakeLabel(_useNoise, "Noise") );
            if(_useNoise.floatValue == 1)
            {
                EditorGUI.indentLevel += 1;

                MaterialProperty _noiseTx = FindProperty("_noiseTx");
			    materialEditor.ShaderProperty( _noiseTx, MakeLabel(_noiseTx, "Texture") );

                MaterialProperty _noiseIntensity = FindProperty("_noiseIntensity");
			    materialEditor.ShaderProperty( _noiseIntensity, MakeLabel(_noiseIntensity, "Intensity") );

                MapToVector2Field("_noisePanX", "_noisePanY", "Pan");
                
                MaterialProperty _noiseSpin = FindProperty("_noiseSpin");
			    materialEditor.ShaderProperty( _noiseSpin, MakeLabel(_noiseSpin, "Spin") );

                MaterialProperty _noiseOpacity = FindProperty("_noiseOpacity");
			    materialEditor.ShaderProperty( _noiseOpacity, MakeLabel(_noiseOpacity, "Opacity") );

                MaterialProperty _showNoise = FindProperty("_showNoise");
                materialEditor.ShaderProperty( _showNoise, MakeLabel(_showNoise, "Show" ) );       

                EditorGUI.indentLevel -= 1;
            }

            /*
            //======================================================================================
            GUILayout.Label("");
            MaterialProperty _useBackbuffer = FindProperty("_useBackbuffer");
            //======================================================================================
			materialEditor.ShaderProperty( _useBackbuffer, MakeLabel(_useBackbuffer, "Backbuffer") );
            if(_useBackbuffer.floatValue == 1)
            {
                EditorGUI.indentLevel += 1;

                MaterialProperty _DistortionVectorMap = FindProperty("_DistortionVectorMap");
			    materialEditor.ShaderProperty( _DistortionVectorMap, MakeLabel(FindProperty("_DistortionVectorMap"), "Vector Map") );

                MaterialProperty _DistortionEnable = FindProperty("_DistortionEnable");
                materialEditor.ShaderProperty( _DistortionEnable, MakeLabel(_DistortionEnable, "Enable") );

                MaterialProperty _DistortionOnly = FindProperty("_DistortionOnly");
                materialEditor.ShaderProperty( _DistortionOnly, MakeLabel(_DistortionOnly, "Distortion Only") );

                MaterialProperty _DistortionDepthTest = FindProperty("_DistortionDepthTest");
                materialEditor.ShaderProperty( _DistortionDepthTest, MakeLabel(_DistortionDepthTest, "Depth Test Enable") );


                // TODO [Enum(Add, 0, Multiply, 1)] _DistortionBlendMode("Distortion Blend Mode", Int) = 0


                MaterialProperty _DistortionScale = FindProperty("_DistortionScale");
			    materialEditor.ShaderProperty( _DistortionScale, MakeLabel(_DistortionScale, "Scale") );

                MaterialProperty _DistortionVectorScale = FindProperty("_DistortionVectorScale");
			    materialEditor.ShaderProperty( _DistortionVectorScale, MakeLabel(_DistortionVectorScale, "Vector Scale") );

                MaterialProperty _DistortionVectorBias = FindProperty("_DistortionVectorBias");
			    materialEditor.ShaderProperty( _DistortionVectorBias, MakeLabel(_DistortionVectorBias, "Vector Bias") );

                MaterialProperty _DistortionBlurScale = FindProperty("_DistortionBlurScale");
			    materialEditor.ShaderProperty( _DistortionBlurScale, MakeLabel(_DistortionBlurScale, "Blur Scale") );

                MaterialProperty _DistortionBlurRemapMin = FindProperty("_DistortionBlurRemapMin");
			    materialEditor.ShaderProperty( _DistortionBlurRemapMin, MakeLabel(_DistortionBlurRemapMin, "Blur Remap Min") );

                MaterialProperty _DistortionBlurRemapMax = FindProperty("_DistortionBlurRemapMax");
			    materialEditor.ShaderProperty( _DistortionBlurRemapMax, MakeLabel(_DistortionBlurRemapMax, "Blur Remap Max") );


          //      MaterialProperty _backbufferTint = FindProperty("_backbufferTint");
			//    materialEditor.ShaderProperty( _backbufferTint, MakeLabel(_backbufferTint, "Backbuffer Tint") );

			   // MaterialProperty _backbufferWarp = FindProperty("_backbufferWarp");
			  //  materialEditor.ShaderProperty( _backbufferWarp, MakeLabel(_backbufferWarp, "Background Distortion") );

              //  MaterialProperty _backbufferIntensity = FindProperty("_backbufferIntensity");
			 //   materialEditor.ShaderProperty( _backbufferIntensity, MakeLabel(_backbufferIntensity, "Background Intensity") );

			 //   MaterialProperty _backbufferZoom = FindProperty("_backbufferZoom");
			 //   materialEditor.ShaderProperty( _backbufferZoom, MakeLabel(_backbufferZoom, "Background Zoom") );

            //    MaterialProperty _backbufferWarpWrite = FindProperty("_backbufferWarpWrite");
			//    materialEditor.ShaderProperty( _backbufferWarpWrite, MakeLabel(_backbufferWarpWrite, "Use backbuffer color to affect distortion") );
                

                EditorGUI.indentLevel -= 1;
            }
*/

            //======================================================================================
            GUILayout.Label("");
            MaterialProperty _useBase = FindProperty("_useBase");
            //======================================================================================
			materialEditor.ShaderProperty( _useBase, MakeLabel(_useBase, "Base") );
            if(_useBase.floatValue == 1)
            {
                EditorGUI.indentLevel += 1;

                SetLayerBlend(material, "_baseMode", "BASEMODE_ADD", "BASEMODE_ALPHABLEND", "BASEMODE_MULTIPLY");

			    MaterialProperty _baseTx = FindProperty("_baseTx");
            
			    materialEditor.ShaderProperty( _baseTx, MakeLabel(_baseTx, "Texture") );

                MaterialProperty _baseTint = FindProperty("_baseTint");
			    materialEditor.ShaderProperty( _baseTint, MakeLabel(_baseTint, "Tint") );

                MaterialProperty _baseWarp = FindProperty("_baseWarp");
			    materialEditor.ShaderProperty( _baseWarp, MakeLabel(_baseWarp, "Distortion") );

                MaterialProperty _baseIntensity = FindProperty("_baseIntensity");
			    materialEditor.ShaderProperty( _baseIntensity, MakeLabel(_baseIntensity, "Intensity") );

                MaterialProperty _baseMask = FindProperty("_baseMask");
			    materialEditor.ShaderProperty( _baseMask, MakeLabel(_baseMask, "Alpha Mask") );

                //======================================================================================
                MaterialProperty _baseIsPacked = FindProperty("_baseIsPacked");
                //======================================================================================
			    materialEditor.ShaderProperty( _baseIsPacked, MakeLabel(_baseIsPacked, "Texture is packed?") );
                if(_baseIsPacked.floatValue == 1)
                {
                    EditorGUI.indentLevel += 1;

                    MaterialProperty _baseChannelFilter = FindProperty("_baseChannelFilter");
			        materialEditor.ShaderProperty( _baseChannelFilter, MakeLabel(_baseChannelFilter, "Channel Filter") );

                    EditorGUI.indentLevel -= 1;
                }
                
                EditorGUI.indentLevel -= 1;
            }
            


            //======================================================================================
            GUILayout.Label("");
            MaterialProperty _useLayer1 = FindProperty("_useLayer1");
            //======================================================================================
			materialEditor.ShaderProperty( 
				_useLayer1, MakeLabel(_useLayer1, "Layer 1 - General")
			);

            if(_useLayer1.floatValue == 1)
            {
                EditorGUI.indentLevel += 1;

                SetLayerBlend(material, "_layer1Mode", "LAYER1MODE_ADD", "LAYER1MODE_ALPHABLEND", "LAYER1MODE_MULTIPLY");

                MaterialProperty _Txt1 = FindProperty("_Txt1");
			    materialEditor.ShaderProperty( _Txt1, MakeLabel(_Txt1, "Texture") );

                MaterialProperty _tx1Tint = FindProperty("_tx1Tint");
			    materialEditor.ShaderProperty( _tx1Tint, MakeLabel(_tx1Tint, "Tint") );

                MaterialProperty _tx1Warp = FindProperty("_tx1Warp");
			    materialEditor.ShaderProperty( _tx1Warp, MakeLabel(_tx1Warp, "Distortion") );

                MaterialProperty _tx1Intensity = FindProperty("_tx1Intensity");
			    materialEditor.ShaderProperty( _tx1Intensity, MakeLabel(_tx1Intensity, "Intensity") );

                MaterialProperty _tx1Mask = FindProperty("_tx1Mask");
			    materialEditor.ShaderProperty( _tx1Mask, MakeLabel(_tx1Mask, "Alpha Mask") );

                MapToVector2Field("_tx1PanX", "_tx1PanY", "Pan");

                MaterialProperty _tx1Spin = FindProperty("_tx1Spin");
			    materialEditor.ShaderProperty( _tx1Spin, MakeLabel(_tx1Spin, "Spin") );

                //======================================================================================
                MaterialProperty _tx1IsPacked = FindProperty("_tx1IsPacked");
                //======================================================================================
			    materialEditor.ShaderProperty( _tx1IsPacked, MakeLabel(_tx1IsPacked, "Texture is packed?") );
                if(_tx1IsPacked.floatValue == 1)
                {
                    EditorGUI.indentLevel += 1;

                    MaterialProperty _tx1ChannelFilter = FindProperty("_tx1ChannelFilter");
			        materialEditor.ShaderProperty( _tx1ChannelFilter, MakeLabel(_tx1ChannelFilter, "Channel Filter") );

                    EditorGUI.indentLevel -= 1;
                }

                EditorGUI.indentLevel -= 1;
            }


            //======================================================================================
            GUILayout.Label("");
            MaterialProperty _useLayer2 = FindProperty("_useLayer2");
            //======================================================================================
			materialEditor.ShaderProperty( 
				_useLayer2, MakeLabel(_useLayer2, "Layer 2 - General")
			);

            if(_useLayer2.floatValue == 1)
            {
                EditorGUI.indentLevel += 1;

                SetLayerBlend(material, "_layer2Mode", "LAYER2MODE_ADD", "LAYER2MODE_ALPHABLEND", "LAYER2MODE_MULTIPLY");
             
                MaterialProperty _Txt2 = FindProperty("_Txt2");
			    materialEditor.ShaderProperty( _Txt2, MakeLabel(_Txt2, "Texture") );

                MaterialProperty _tx2Tint = FindProperty("_tx2Tint");
			    materialEditor.ShaderProperty( _tx2Tint, MakeLabel(_tx2Tint, "Tint") );

                MaterialProperty _tx2Warp = FindProperty("_tx2Warp");
			    materialEditor.ShaderProperty( _tx2Warp, MakeLabel(_tx2Warp, "Distortion") );

                MaterialProperty _tx2Intensity = FindProperty("_tx2Intensity");
			    materialEditor.ShaderProperty( _tx2Intensity, MakeLabel(_tx2Intensity, "Intensity") );

                MaterialProperty _tx2Mask = FindProperty("_tx2Mask");
			    materialEditor.ShaderProperty( _tx2Mask, MakeLabel(_tx2Mask, "Alpha Mask") );

                MapToVector2Field("_tx2PanX", "_tx2PanY", "Pan");

                MaterialProperty _tx2Spin = FindProperty("_tx2Spin");
			    materialEditor.ShaderProperty( _tx2Spin, MakeLabel(_tx2Spin, "Spin") );

                //======================================================================================
                MaterialProperty _tx2IsPacked = FindProperty("_tx2IsPacked");
                //======================================================================================
			    materialEditor.ShaderProperty( _tx2IsPacked, MakeLabel(_tx2IsPacked, "Texture is packed?") );
                if(_tx2IsPacked.floatValue == 1)
                {
                    EditorGUI.indentLevel += 1;

                    MaterialProperty _tx2ChannelFilter = FindProperty("_tx2ChannelFilter");
			        materialEditor.ShaderProperty( _tx2ChannelFilter, MakeLabel(_tx2ChannelFilter, "Channel Filter") );

                    EditorGUI.indentLevel -= 1;
                }


                EditorGUI.indentLevel -= 1;
            }


            //======================================================================================
            GUILayout.Label("");
            MaterialProperty _useLayer3 = FindProperty("_useLayer3");
            //======================================================================================
			materialEditor.ShaderProperty( 
				_useLayer3, MakeLabel(_useLayer3, "Layer 3 - General + Edge Texture")
			);

            if(_useLayer3.floatValue == 1)
            {
                EditorGUI.indentLevel += 1;

                SetLayerBlend(material, "_layer3Mode", "LAYER3MODE_ADD", "LAYER3MODE_ALPHABLEND", "LAYER3MODE_MULTIPLY");

                MaterialProperty _Txt3 = FindProperty("_Txt3");
			    materialEditor.ShaderProperty( _Txt3, MakeLabel(_Txt3, "Texture") );

                MaterialProperty _tx3Tint = FindProperty("_tx3Tint");
			    materialEditor.ShaderProperty( _tx3Tint, MakeLabel(_tx3Tint, "Tint") );

                MaterialProperty _tx3Warp = FindProperty("_tx3Warp");
			    materialEditor.ShaderProperty( _tx3Warp, MakeLabel(_tx3Warp, "Distortion") );

                MaterialProperty _tx3Intensity = FindProperty("_tx3Intensity");
			    materialEditor.ShaderProperty( _tx3Intensity, MakeLabel(_tx3Intensity, "Intensity") );

                MapToVector2Field("_tx3PanX", "_tx3PanY", "Pan");

                MaterialProperty _tx3Spin = FindProperty("_tx3Spin");
			    materialEditor.ShaderProperty( _tx3Spin, MakeLabel(_tx3Spin, "Spin") );

                //======================================================================================
                MaterialProperty _tx3IsPacked = FindProperty("_tx3IsPacked");
                //======================================================================================
			    materialEditor.ShaderProperty( _tx3IsPacked, MakeLabel(_tx3IsPacked, "Texture is packed?") );
                if(_tx3IsPacked.floatValue == 1)
                {
                    EditorGUI.indentLevel += 1;

                    MaterialProperty _tx3ChannelFilter = FindProperty("_tx3ChannelFilter");
			        materialEditor.ShaderProperty( _tx3ChannelFilter, MakeLabel(_tx3ChannelFilter, "Channel Filter") );

                    EditorGUI.indentLevel -= 1;
                }

                EditorGUI.indentLevel -= 1;
            }


            //======================================================================================
            GUILayout.Label("");
            MaterialProperty _useWipe = FindProperty("_useWipe");
            //======================================================================================
			materialEditor.ShaderProperty( _useWipe, MakeLabel(_useWipe, "Wipe") );

            if(_useWipe.floatValue == 1)
            {
                EditorGUI.indentLevel += 1;

			    MaterialProperty _wipeLerp = FindProperty("_wipeLerp");
			    materialEditor.ShaderProperty( _wipeLerp, MakeLabel(_wipeLerp, "Wipe Lerp") );

                MaterialProperty _wipeWidth = FindProperty("_wipeWidth");
			    materialEditor.ShaderProperty( _wipeWidth, MakeLabel(_wipeWidth, "Wipe Width") );

                MaterialProperty _wipeTint = FindProperty("_wipeTint");
			    materialEditor.ShaderProperty( _wipeTint, MakeLabel(_wipeTint, "Wipe Edge Tint") );

                MaterialProperty _wipeIntensity = FindProperty("_wipeIntensity");
			    materialEditor.ShaderProperty( _wipeIntensity, MakeLabel(_wipeIntensity, "Wipe Edge Intensity") );

                MaterialProperty _wipeEdgeColFO = FindProperty("_wipeEdgeColFO");
			    materialEditor.ShaderProperty( _wipeEdgeColFO, MakeLabel(_wipeEdgeColFO, "Wipe Edge color falloff") );

                MaterialProperty _wipeEdgeScale = FindProperty("_wipeEdgeScale");
			    materialEditor.ShaderProperty( _wipeEdgeScale, MakeLabel(_wipeEdgeScale, "Wipe Edge scale") );

                EditorGUI.indentLevel -= 1;
            }

	    }
	}
}

