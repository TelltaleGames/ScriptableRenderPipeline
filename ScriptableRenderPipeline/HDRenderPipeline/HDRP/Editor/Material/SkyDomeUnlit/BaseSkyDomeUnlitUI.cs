using System;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    // A Material can be authored from the shader graph or by hand. When written by hand we need to provide an inspector.
    // Such a Material will share some properties between it various variant (shader graph variant or hand authored variant).
    // This is the purpose of BaseLitGUI. It contain all properties that are common to all Material based on Lit template.
    // For the default hand written Lit material see LitUI.cs that contain specific properties for our default implementation.
    public abstract class BaseSkyDomeUnlitGUI : ShaderGUI
    {
        protected MaterialEditor m_MaterialEditor;


        protected virtual void FindMaterialProperties(MaterialProperty[] props)
        {
        }

        protected virtual void MaterialPropertiesGUI(Material material)
        {
        }

        protected virtual void MaterialPropertiesAdvanceGUI(Material material)
        {
        }

        protected virtual void VertexAnimationPropertiesGUI()
        {
        }

        protected virtual bool ShouldEmissionBeEnabled(Material material)
        {
            return false;
        }

        protected virtual void SetupMaterialKeywordsAndPassInternal(Material material)
        {
        }

        static public void SetupBaseUnlitMaterialPass(Material material)
        {
        }

        public enum SurfaceType
        {
            Opaque,
            Transparent
        }

        // Enum values are hardcoded for retro-compatibility. Don't change them.
        public enum BlendMode
        {
            Alpha = 0,
            Additive = 1,
            PremultipliedAlpha = 4
        }

        // All Setup Keyword functions must be static. It allow to create script to automatically update the shaders with a script if ocde change
        static public void SetupBaseUnlitKeywords(Material material)
        {
            //bool alphaTestEnable = material.HasProperty(kAlphaCutoffEnabled) && material.GetFloat(kAlphaCutoffEnabled) > 0.0f;
            CoreUtils.SetKeyword(material, "_ALPHATEST_ON", false);

            SurfaceType surfaceType = 0; // OPAQUE
            CoreUtils.SetKeyword(material, "_SURFACE_TYPE_TRANSPARENT", false);

            // These need to always be set either with opaque or transparent! So a users can switch to opaque and remove the keyword correctly
            CoreUtils.SetKeyword(material, "_BLENDMODE_ALPHA", false);
            CoreUtils.SetKeyword(material, "_BLENDMODE_ADD", false);
            CoreUtils.SetKeyword(material, "_BLENDMODE_PRE_MULTIPLY", false);

            material.SetOverrideTag("RenderType", "");
            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
            material.SetInt("_ZWrite", 0);
            material.renderQueue = (int)HDRenderQueue.Priority.Opaque;

            //bool fogEnabled = material.HasProperty(kEnableFogOnTransparent) && material.GetFloat(kEnableFogOnTransparent) > 0.0f && surfaceType == SurfaceType.Transparent;
            CoreUtils.SetKeyword(material, "_ENABLE_FOG_ON_TRANSPARENT", false);

            bool isBackFaceEnable = false;//material.HasProperty(kTransparentBackfaceEnable) && material.GetFloat(kTransparentBackfaceEnable) > 0.0f && surfaceType == SurfaceType.Transparent;
            bool doubleSidedEnable = false;//material.HasProperty(kDoubleSidedEnable) && material.GetFloat(kDoubleSidedEnable) > 0.0f;

            material.SetInt("_CullMode", (int)UnityEngine.Rendering.CullMode.Back);
        }

        public void ShaderPropertiesGUI(Material material)
        {
            // Use default labelWidth
            EditorGUIUtility.labelWidth = 0f;

            // Detect any changes to the material
            EditorGUI.BeginChangeCheck();
            {
                MaterialPropertiesGUI(material);
            }
            if (EditorGUI.EndChangeCheck())
            {
                foreach (var obj in m_MaterialEditor.targets)
                    SetupMaterialKeywordsAndPassInternal((Material)obj);
            }
        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            SetupMaterialKeywordsAndPassInternal(material);
        }

        // This is call by the inspector
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            m_MaterialEditor = materialEditor;
            // We should always do this call at the beginning
            m_MaterialEditor.serializedObject.Update();

            // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
            FindMaterialProperties(props);
            Material material = materialEditor.target as Material;
            ShaderPropertiesGUI(material);

            // We should always do this call at the end
            m_MaterialEditor.serializedObject.ApplyModifiedProperties();
        }
    }
}
