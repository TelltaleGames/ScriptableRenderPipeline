using System;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    public class DecalUI : ShaderGUI
    {
        protected static class Styles
        {
            public static string InputsText = "Inputs";

            public static GUIContent baseColorText = new GUIContent("Albedo (RGB)", "Albedo (RGB)");
            public static GUIContent baseColorText2 = new GUIContent("Blend Factor (A)", "Blend Factor (A)");
            public static GUIContent normalMapText = new GUIContent("Normal Map", "Normal Map (BC7/BC5/DXT5(nm))");
            public static GUIContent normalMapIntensityText = new GUIContent("Normal Map Intensity", "Normal Map Intensity");
            public static GUIContent normalAddText = new GUIContent("Normal Added", "Normal Map added to underlying normal instead of blocking it");
            public static GUIContent maskMapText = new GUIContent("Mask Map - Metallic(R), Smoothness(A)", "Mask map");
            public static GUIContent metallicText = new GUIContent("Metallic", "Metallic scale factor");
            public static GUIContent smoothnessText = new GUIContent("Smoothness", "Smoothness scale factor");
            public static GUIContent smoothnessRemappingText = new GUIContent("Smoothness Remapping", "Smoothness remapping");
            public static GUIContent decalBlendText = new GUIContent("Decal Blend", "Whole decal blend");
            public static GUIContent BlendText = new GUIContent("Decal Blend", "Whole decal blend");
            public static GUIContent AlbedoModeText = new GUIContent("Albedo contribution", "Base color + Blend, Blend only");
            public static GUIContent MaskModeText = new GUIContent("Mask contribution", "Affects Metallic(R), and Smoothness(A).  Other channels unused.");
        }

        protected MaterialProperty baseColorMap = new MaterialProperty();
        protected const string kBaseColorMap = "_BaseColorMap";

        protected MaterialProperty baseColor = new MaterialProperty();
        protected const string kBaseColor = "_BaseColor";

        protected MaterialProperty normalMap = new MaterialProperty();
        protected const string kNormalMap = "_NormalMap";

        protected MaterialProperty normalMapIntensity = new MaterialProperty();
        protected const string kNormalMapIntensity = "_NormalMapIntensity";
        protected MaterialProperty normalAdd = new MaterialProperty();
        protected const string kNormalAdd = "_NormalAdd";

        protected MaterialProperty maskMap = new MaterialProperty();
        protected const string kMaskMap = "_MaskMap";

        protected MaterialProperty metallic = new MaterialProperty();
        protected const string kMetallic = "_Metallic";
        protected MaterialProperty smoothness = new MaterialProperty();
        protected const string kSmoothness = "_Smoothness";
        protected MaterialProperty smoothnessRemapMin = new MaterialProperty();
        protected const string kSmoothnessRemapMin = "_SmoothnessRemapMin";
        protected MaterialProperty smoothnessRemapMax = new MaterialProperty();
        protected const string kSmoothnessRemapMax = "_SmoothnessRemapMax";

        protected MaterialProperty decalBlend = new MaterialProperty();
        protected const string kDecalBlend = "_DecalBlend";

        protected MaterialProperty albedoMode = new MaterialProperty();
        protected const string kAlbedoMode = "_AlbedoMode";

        protected MaterialProperty maskMode = new MaterialProperty();
        protected const string kMaskMode = "_MaskMode";


        protected MaterialEditor m_MaterialEditor;

        // This is call by the inspector

        void FindMaterialProperties(MaterialProperty[] props)
        {
            baseColor = FindProperty(kBaseColor, props);
            baseColorMap = FindProperty(kBaseColorMap, props);
            normalMap = FindProperty(kNormalMap, props);
            normalMapIntensity = FindProperty(kNormalMapIntensity, props);
            normalAdd = FindProperty(kNormalAdd, props);
            maskMap = FindProperty(kMaskMap, props);
            metallic = FindProperty(kMetallic, props);
            smoothness = FindProperty(kSmoothness, props);
            smoothnessRemapMin = FindProperty(kSmoothnessRemapMin, props);
            smoothnessRemapMax = FindProperty(kSmoothnessRemapMax, props);
            decalBlend = FindProperty(kDecalBlend, props);
            albedoMode = FindProperty(kAlbedoMode, props);
            maskMode = FindProperty(kMaskMode, props);
            // always instanced
            SerializedProperty instancing = m_MaterialEditor.serializedObject.FindProperty("m_EnableInstancingVariants");
            instancing.boolValue = true;
        }

        // All Setup Keyword functions must be static. It allow to create script to automatically update the shaders with a script if code change
        static public void SetupMaterialKeywordsAndPass(Material material)
        {
            CoreUtils.SetKeyword(material, "_ALBEDOCONTRIBUTION", material.GetFloat(kAlbedoMode) == 1.0f);
            CoreUtils.SetKeyword(material, "_MASKCONTRIBUTION", material.GetFloat(kMaskMode) == 1.0f);
            CoreUtils.SetKeyword(material, "_COLORMAP", material.GetTexture(kBaseColorMap));
            CoreUtils.SetKeyword(material, "_NORMALMAP", material.GetTexture(kNormalMap));
            CoreUtils.SetKeyword(material, "_MASKMAP", material.GetTexture(kMaskMap));
        }

        protected void SetupMaterialKeywordsAndPassInternal(Material material)
        {
            SetupMaterialKeywordsAndPass(material);
        }

        public void ShaderPropertiesGUI(Material material)
        {
            // Use default labelWidth
            EditorGUIUtility.labelWidth = 0f;

            // Detect any changes to the material
            EditorGUI.BeginChangeCheck();
            {
                EditorGUILayout.LabelField(Styles.InputsText, EditorStyles.boldLabel);

                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(albedoMode, Styles.AlbedoModeText);
                if (material.GetFloat(kAlbedoMode) == 1.0f)
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.baseColorText, baseColorMap, baseColor);
                }
                else
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.baseColorText2, baseColorMap, baseColor);
                }
                m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, normalMap, normalMapIntensity);
                if (normalMap.textureValue != null)
                {
                    m_MaterialEditor.ShaderProperty(normalAdd, Styles.normalAddText);
                }

                m_MaterialEditor.ShaderProperty(maskMode, Styles.MaskModeText);
                if (material.GetFloat(kMaskMode) == 1.0f)
                {
                    m_MaterialEditor.TexturePropertySingleLine(Styles.maskMapText, maskMap);

                    EditorGUI.indentLevel++;

                    m_MaterialEditor.ShaderProperty(metallic, Styles.metallicText);

                    if (maskMap.textureValue == null)
                    {
                        m_MaterialEditor.ShaderProperty(smoothness, Styles.smoothnessText);
                    }
                    else
                    {
                        float remapMin = smoothnessRemapMin.floatValue;
                        float remapMax = smoothnessRemapMax.floatValue;
                        EditorGUI.BeginChangeCheck();
                        EditorGUILayout.MinMaxSlider(Styles.smoothnessRemappingText, ref remapMin, ref remapMax, 0.0f, 1.0f);
                        if (EditorGUI.EndChangeCheck())
                        {
                            smoothnessRemapMin.floatValue = remapMin;
                            smoothnessRemapMax.floatValue = remapMax;
                        }
                    }
                }
                EditorGUI.indentLevel--;

                m_MaterialEditor.ShaderProperty(decalBlend, Styles.decalBlendText);
                EditorGUI.indentLevel--;
            }

            if (EditorGUI.EndChangeCheck())
            {
                foreach (var obj in m_MaterialEditor.targets)
                    SetupMaterialKeywordsAndPassInternal((Material)obj);
            }
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            m_MaterialEditor = materialEditor;
            // We should always do this call at the beginning
            m_MaterialEditor.serializedObject.Update();

            FindMaterialProperties(props);

            Material material = materialEditor.target as Material;
            ShaderPropertiesGUI(material);

            // We should always do this call at the end
            m_MaterialEditor.serializedObject.ApplyModifiedProperties();
        }
    }
}
