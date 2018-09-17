using System;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    class StormySkyGUI : BaseUnlitGUI
    {
        protected static class Styles
        {
            //public static GUIContent colorText = new GUIContent("Color", "Color");
            //public static GUIContent emissiveText = new GUIContent("Emissive Color", "Emissive");

            public static GUIContent cloudMap1Text = new GUIContent("Cloud Map", "Main Cloud Map");
            public static GUIContent flowMapText = new GUIContent("Flow Map", "Flow Map");
            public static GUIContent flowSpeedText = new GUIContent("Flow Speed", "Flow Speed");
            public static GUIContent flowAmountText = new GUIContent("Flow Amount", "Flow Amount");

            public static GUIContent cloudMap2Text = new GUIContent("Cloud Detail Map", "Detail Cloud Map");
            public static GUIContent cloud2AmountText = new GUIContent("Cloud Detail Amount", "Cloud Detail Amount");

            public static GUIContent waveMapText = new GUIContent("Wave Map", "Wave Map");
            public static GUIContent waveAmountText = new GUIContent("Wave Amount", "Wave Amount");
            public static GUIContent waveDistortText = new GUIContent("Wave Distortion", "Wave Distortion");

            public static GUIContent cloudScaleText = new GUIContent("Cloud Scale", "Cloud Scale");
            public static GUIContent cloudBiasText = new GUIContent("Cloud Bias", "Cloud Bias");

            public static GUIContent colorMapText = new GUIContent("Color Map", "Color Map");

            public static GUIContent colorPowerText = new GUIContent("Color Power", "Color Power");
            public static GUIContent colorFactorText = new GUIContent("Color Factor", "Color Factor");
            public static GUIContent color1Text = new GUIContent("Color 1", "Color 1");
            public static GUIContent color2Text = new GUIContent("Color 2", "Color 2");

            public static GUIContent cloudDensityText = new GUIContent("Cloud Density", "Cloud Density");
            public static GUIContent bumpOffsetText = new GUIContent("Bump Offset", "Bump Offset");
            public static GUIContent stepsText = new GUIContent("Steps", "Steps");
            public static GUIContent cloudHeightText = new GUIContent("CloudHeight", "CloudHeight");

            public static GUIContent scaleText = new GUIContent("Scale", "Scale");
            public static GUIContent speedText = new GUIContent("Speed", "Speed");

            public static GUIContent lightSpreadText = new GUIContent("Light Spread", "Light Spread");

            public static GUIContent fogColorText = new GUIContent("Fog Color", "Fog Color");
            public static GUIContent fogDistanceText = new GUIContent("Fog Distance", "Fog Distance");

            public static GUIContent sunColorText = new GUIContent("Sun Color", "Sun Color");
            public static GUIContent sunVectorText = new GUIContent("Sun Direction", "Sun Direction");
        }

        protected MaterialProperty cloudMap1 = null;
        protected const string kCloudMap1 = "_CloudTex1";
        protected MaterialProperty flowMap = null;
        protected const string kFlowMap = "_FlowTex1";
        protected MaterialProperty flowSpeed = null;
        protected const string kFlowSpeed = "_FlowSpeed";
        protected MaterialProperty flowAmount = null;
        protected const string kFlowAmount = "_FlowAmount";
        protected MaterialProperty cloudMap2 = null;
        protected const string kCloudMap2 = "_CloudTex2";
        protected MaterialProperty cloud2Amount = null;
        protected const string kCloud2Amount = "_Cloud2Amount";
        protected MaterialProperty waveMap = null;
        protected const string kWaveMap = "_WaveTex";
        protected MaterialProperty waveAmount = null;
        protected const string kWaveAmount = "_WaveAmount";
        protected MaterialProperty waveDistort = null;
        protected const string kWaveDistort = "_WaveDistort";
        protected MaterialProperty cloudScale = null;
        protected const string kCloudScale = "_CloudScale";
        protected MaterialProperty cloudBias = null;
        protected const string kCloudBias = "_CloudBias";
        protected MaterialProperty colorMap = null;
        protected const string kColorMap = "_ColorTex";
        protected MaterialProperty colorPower = null;
        protected const string kColorPower = "_ColPow";
        protected MaterialProperty colorFactor = null;
        protected const string kColorFactor = "_ColFactor";
        protected MaterialProperty color1 = null;
        protected const string kColor1 = "_Color";
        protected MaterialProperty color2 = null;
        protected const string kColor2 = "_Color2";
        protected MaterialProperty cloudDensity = null;
        protected const string kCloudDensity = "_CloudDensity";
        protected MaterialProperty bumpOffset = null;
        protected const string kBumpOffset = "_BumpOffset";
        protected MaterialProperty steps = null;
        protected const string kSteps = "_Steps";
        protected MaterialProperty cloudHeight = null;
        protected const string kCloudHeight = "_CloudHeight";
        protected MaterialProperty scale = null;
        protected const string kScale = "_Scale";
        protected MaterialProperty speed = null;
        protected const string kSpeed = "_Speed";
        protected MaterialProperty lightSpread = null;
        protected const string kLightSpread = "_LightSpread";
        protected MaterialProperty fogColor = null;
        protected const string kFogColor = "_FoggyColor";
        protected MaterialProperty fogDistance = null;
        protected const string kFogDistance = "_FoggyDistance";
        protected MaterialProperty sunColor = null;
        protected const string kSunColor = "_SunColor";
        protected MaterialProperty sunVector = null;
        protected const string kSunVector = "_SunVector";

        override protected void FindMaterialProperties(MaterialProperty[] props)
        {
            cloudMap1 = FindProperty(kCloudMap1, props);
            flowMap = FindProperty(kFlowMap, props);
            flowSpeed = FindProperty(kFlowSpeed, props);
            flowAmount = FindProperty(kFlowAmount, props);
            cloudMap2 = FindProperty(kCloudMap2, props);
            cloud2Amount = FindProperty(kCloud2Amount, props);
            waveMap = FindProperty(kWaveMap, props);
            waveAmount = FindProperty(kWaveAmount, props);
            waveDistort = FindProperty(kWaveDistort, props);
            cloudScale = FindProperty(kCloudScale, props);
            cloudBias = FindProperty(kCloudBias, props);
            colorMap = FindProperty(kColorMap, props);
            colorPower = FindProperty(kColorPower, props);
            colorFactor = FindProperty(kColorFactor, props);
            color1 = FindProperty(kColor1, props);
            color2 = FindProperty(kColor2, props);
            cloudDensity = FindProperty(kCloudDensity, props);
            bumpOffset = FindProperty(kBumpOffset, props);
            steps = FindProperty(kSteps, props);
            cloudHeight = FindProperty(kCloudHeight, props);
            scale = FindProperty(kScale, props);
            speed = FindProperty(kSpeed, props);
            lightSpread = FindProperty(kLightSpread, props);
            fogColor = FindProperty(kFogColor, props);
            fogDistance = FindProperty(kFogDistance, props);
            sunColor = FindProperty(kSunColor, props);
            sunVector = FindProperty(kSunVector, props);
        }

        protected override void MaterialPropertiesGUI(Material material)
        {
            EditorGUILayout.LabelField("Clouds - Main", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.TexturePropertySingleLine(Styles.cloudMap1Text, cloudMap1);
            if (material.GetTexture(kCloudMap1))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(cloudMap1);
            }
            EditorGUI.indentLevel--;

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Waves", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.TexturePropertySingleLine(Styles.waveMapText, waveMap);
            if (material.GetTexture(kWaveMap))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(waveMap);
                m_MaterialEditor.ShaderProperty(waveAmount, Styles.waveAmountText);
                m_MaterialEditor.ShaderProperty(waveDistort, Styles.waveDistortText);
            }
            EditorGUI.indentLevel--;

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Clouds - Detail", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.TexturePropertySingleLine(Styles.cloudMap2Text, cloudMap2);
            if (material.GetTexture(kCloudMap2))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(cloudMap2);
                m_MaterialEditor.ShaderProperty(cloud2Amount, Styles.cloud2AmountText);
                m_MaterialEditor.ShaderProperty(flowAmount, Styles.flowAmountText);
                m_MaterialEditor.ShaderProperty(flowSpeed, Styles.flowSpeedText);
            }
            EditorGUI.indentLevel--;

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Cloud Colors", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.TexturePropertySingleLine(Styles.colorMapText, colorMap);
            if (material.GetTexture(kColorMap))
            {
                m_MaterialEditor.TextureScaleOffsetProperty(colorMap);
                m_MaterialEditor.ShaderProperty(color1, Styles.color1Text);
                m_MaterialEditor.ShaderProperty(color2, Styles.color2Text);
                m_MaterialEditor.ShaderProperty(colorPower, Styles.colorPowerText);
                m_MaterialEditor.ShaderProperty(colorFactor, Styles.colorFactorText);
            }
            EditorGUI.indentLevel--;

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Sun", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(sunColor, Styles.sunColorText);
            m_MaterialEditor.ShaderProperty(sunVector, Styles.sunVectorText);
            m_MaterialEditor.ShaderProperty(lightSpread, Styles.lightSpreadText);
            EditorGUI.indentLevel--;

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Fog", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(fogColor, Styles.fogColorText);
            m_MaterialEditor.ShaderProperty(fogDistance, Styles.fogDistanceText);
            EditorGUI.indentLevel--;

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Global", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(cloudDensity, Styles.cloudDensityText);
            m_MaterialEditor.ShaderProperty(cloudScale, Styles.cloudScaleText);
            m_MaterialEditor.ShaderProperty(cloudBias, Styles.cloudBiasText);
            m_MaterialEditor.ShaderProperty(bumpOffset, Styles.bumpOffsetText);
            m_MaterialEditor.ShaderProperty(steps, Styles.stepsText);
            m_MaterialEditor.ShaderProperty(cloudHeight, Styles.cloudHeightText);
            m_MaterialEditor.ShaderProperty(scale, Styles.scaleText);
            m_MaterialEditor.ShaderProperty(speed, Styles.speedText);
            EditorGUI.indentLevel--;

        }

        protected override void MaterialPropertiesAdvanceGUI(Material material)
        {
        }

        protected override void VertexAnimationPropertiesGUI()
        {
        }

        protected override bool ShouldEmissionBeEnabled(Material material)
        {
            return false;//(material.GetColor(kEmissiveColor) != Color.black) || material.GetTexture(kEmissiveColorMap);
        }

        protected override void SetupMaterialKeywordsAndPassInternal(Material material)
        {
            SetupMaterialKeywordsAndPass(material);
        }

        // All Setup Keyword functions must be static. It allow to create script to automatically update the shaders with a script if code change
        static public void SetupMaterialKeywordsAndPass(Material material)
        {
            SetupBaseUnlitKeywords(material);
            SetupBaseUnlitMaterialPass(material);

            //CoreUtils.SetKeyword(material, "_EMISSIVE_COLOR_MAP", material.GetTexture(kEmissiveColorMap));
        }
    }
} // namespace UnityEditor
