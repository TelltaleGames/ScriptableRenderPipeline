using System;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    class SkyDomeUnlitGUI : BaseSkyDomeUnlitGUI
    {
        protected static class Styles
        {
            public static string SkySectionText = "Sky Gradient";
            public static string HorizonSectionText = "Horizon Gradient";
            public static string CloudDistantSectionText = "Distant Clouds";
            public static string CloudOverheadSectionText = "Overhead Clouds";

            public static GUIContent skyGradZenithColorText = new GUIContent("Zenith Color", "Zenith Color");
            public static GUIContent skyGradHorizonColorText = new GUIContent("Horizon Color", "Horizon Color");
            public static GUIContent skyGradCurveBiasText = new GUIContent("Curve Bias", "Adjust midpoint");

            public static GUIContent horizonGradIntensityText = new GUIContent("Intensity", "");
            public static GUIContent horizonGradColor1Text = new GUIContent("Upper Color", "");
            public static GUIContent horizonGradColor0Text = new GUIContent("Lower Color", "");
            public static GUIContent horizonGradHeightText = new GUIContent("Height", "Height of horizon gradient");
            public static GUIContent horizonGradColorBiasText = new GUIContent("Color Bias", "Adjust midpoint");
            public static GUIContent horizonGradAlphaBiasText = new GUIContent("Alpha Bias", "Adjust midpoint");
            public static GUIContent horizonGradDirectionText = new GUIContent("Heading", "Heading (in degrees) toward strongest point of horizon gradient");
            public static GUIContent horizonGradDirectionalAttenText = new GUIContent("Attenuation", "Amount that horizon colors drop in the opposite direction");

            public static GUIContent CloudDistantMapText = new GUIContent("Cloud Texture", "");
            public static GUIContent CloudDistantColorText = new GUIContent("Cloud Tint", "");
            public static GUIContent CloudDistantScrollSpeedText = new GUIContent("Scroll Speed", "");

            public static GUIContent CloudOverheadMapText = new GUIContent("Cloud Texture", "");
            public static GUIContent CloudOverheadHeightText = new GUIContent("Cloud Height", "");
            public static GUIContent CloudOverheadColorText = new GUIContent("Cloud Tint", "");
            public static GUIContent CloudOverheadScrollSpeedText = new GUIContent("Scroll Speed", "");

            public static GUIContent StarMapText = new GUIContent("Star Texture", "");
            public static GUIContent StarColorText = new GUIContent("Star Tint/Alpha", "");

            public static GUIContent SunColorText = new GUIContent("Sun Tint/Alpha", "");
            public static GUIContent SunElevationText = new GUIContent("Sun Elevation", "Vertical angle (degrees) sun is above horizon");
            public static GUIContent SunAzimuthText = new GUIContent("Sun Azimuth", "Horizontal angle (degrees) sun is away from X axis");
            public static GUIContent SunHazeExponentText = new GUIContent("Sun Haze Exponent", "Higher values = tighter glow around sun");
        }

        protected MaterialProperty skyGradZenithColor = null;
        protected const string kSkyGradZenithColor = "_SkyGradZenithColor";
        protected MaterialProperty skyGradHorizonColor = null;
        protected const string kSkyGradHorizonColor = "_SkyGradHorizonColor";
        protected MaterialProperty skyGradCurveBias = null;
        protected const string kSkyGradCurveBias = "_SkyGradCurveBias";

        protected MaterialProperty horizonGradIntensity = null;
        protected const string kHorizonGradIntensity = "_HorizonGradIntensity";
        protected MaterialProperty horizonGradColor1 = null;
        protected const string kHorizonGradColor1 = "_HorizonGradColor1";
        protected MaterialProperty horizonGradColor0 = null;
        protected const string kHorizonGradColor0 = "_HorizonGradColor0";
        protected MaterialProperty horizonGradHeight = null;
        protected const string kHorizonGradHeight = "_HorizonGradHeight";
        protected MaterialProperty horizonGradColorBias = null;
        protected const string kHorizonGradColorBias = "_HorizonGradColorBias";
        protected MaterialProperty horizonGradAlphaBias = null;
        protected const string kHorizonGradAlphaBias = "_HorizonGradAlphaBias";
        protected MaterialProperty horizonGradDirection = null;
        protected const string kHorizonGradDirection = "_HorizonGradDirection";
        protected MaterialProperty horizonGradDirectionalAtten = null;
        protected const string kHorizonGradDirectionalAtten = "_HorizonGradDirectionalAtten";

        protected MaterialProperty cloudDistantMap = null;
        protected const string kCloudDistantMap = "_CloudDistantMap";
        protected MaterialProperty cloudDistantColor = null;
        protected const string kCloudDistantColor = "_CloudDistantColor";
        protected MaterialProperty cloudDistantScrollSpeed = null;
        protected const string kCloudDistantScrollSpeed = "_CloudDistantScrollSpeed";

        protected MaterialProperty cloudOverheadMap = null;
        protected const string kCloudOverheadMap = "_CloudOverheadMap";
        protected MaterialProperty cloudOverheadHeight = null;
        protected const string kCloudOverheadHeight = "_CloudOverheadHeight";
        protected MaterialProperty cloudOverheadColor = null;
        protected const string kCloudOverheadColor = "_CloudOverheadColor";
        protected MaterialProperty cloudOverheadScrollSpeed = null;
        protected const string kCloudOverheadScrollSpeed = "_CloudOverheadScrollSpeed";

        protected MaterialProperty starMap = null;
        protected const string kStarMap = "_StarMap";
        protected MaterialProperty starColor = null;
        protected const string kStarColor = "_StarColor";

        protected MaterialProperty sunColor = null;
        protected const string kSunColor = "_SunColor";
        protected MaterialProperty sunElevation = null;
        protected const string kSunElevation = "_SunElevation";
        protected MaterialProperty sunAzimuth = null;
        protected const string kSunAzimuth = "_SunAzimuth";
        protected MaterialProperty sunHazeExponent = null;
        protected const string kSunHazeExponent = "_SunHazeExponent";


        override protected void FindMaterialProperties(MaterialProperty[] props)
        {
            skyGradZenithColor = FindProperty(kSkyGradZenithColor, props);
            skyGradHorizonColor = FindProperty(kSkyGradHorizonColor, props);
            skyGradCurveBias = FindProperty(kSkyGradCurveBias, props);

            horizonGradIntensity = FindProperty(kHorizonGradIntensity, props);
            horizonGradColor1 = FindProperty(kHorizonGradColor1, props);
            horizonGradColor0 = FindProperty(kHorizonGradColor0, props);
            horizonGradHeight = FindProperty(kHorizonGradHeight, props);
            horizonGradColorBias = FindProperty(kHorizonGradColorBias, props);
            horizonGradAlphaBias = FindProperty(kHorizonGradAlphaBias, props);
            horizonGradDirection = FindProperty(kHorizonGradDirection, props);
            horizonGradDirectionalAtten = FindProperty(kHorizonGradDirectionalAtten, props);

            cloudDistantMap = FindProperty(kCloudDistantMap, props);
            cloudDistantColor = FindProperty(kCloudDistantColor, props);
            cloudDistantScrollSpeed = FindProperty(kCloudDistantScrollSpeed, props);

            cloudOverheadMap = FindProperty(kCloudOverheadMap, props);
            cloudOverheadHeight = FindProperty(kCloudOverheadHeight, props);
            cloudOverheadColor = FindProperty(kCloudOverheadColor, props);
            cloudOverheadScrollSpeed = FindProperty(kCloudOverheadScrollSpeed, props);

            starMap = FindProperty(kStarMap, props);
            starColor = FindProperty(kStarColor, props);

            sunColor = FindProperty(kSunColor, props);
            sunElevation = FindProperty(kSunElevation, props);
            sunAzimuth = FindProperty(kSunAzimuth, props);
            sunHazeExponent = FindProperty(kSunHazeExponent, props);
        }

        protected override void MaterialPropertiesGUI(Material material)
        {
            EditorGUILayout.LabelField("Sky Gradient", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(skyGradZenithColor, Styles.skyGradZenithColorText);
            m_MaterialEditor.ShaderProperty(skyGradHorizonColor, Styles.skyGradHorizonColorText);
            m_MaterialEditor.ShaderProperty(skyGradCurveBias, Styles.skyGradCurveBiasText);
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Horizon Gradient", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(horizonGradIntensity, Styles.horizonGradIntensityText);
            m_MaterialEditor.ShaderProperty(horizonGradColor1, Styles.horizonGradColor1Text);
            m_MaterialEditor.ShaderProperty(horizonGradColor0, Styles.horizonGradColor0Text);
            m_MaterialEditor.ShaderProperty(horizonGradHeight, Styles.horizonGradHeightText);
            m_MaterialEditor.ShaderProperty(horizonGradColorBias, Styles.horizonGradColorBiasText);
            m_MaterialEditor.ShaderProperty(horizonGradAlphaBias, Styles.horizonGradAlphaBiasText);
            EditorGUILayout.LabelField("Direction", EditorStyles.boldLabel);
                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(horizonGradDirection, Styles.horizonGradDirectionText);
                m_MaterialEditor.ShaderProperty(horizonGradDirectionalAtten, Styles.horizonGradDirectionalAttenText);
                EditorGUI.indentLevel--;
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Distant Clouds", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.TexturePropertySingleLine(Styles.CloudDistantMapText, cloudDistantMap, cloudDistantColor);
            m_MaterialEditor.TextureScaleOffsetProperty(cloudDistantMap);
            m_MaterialEditor.ShaderProperty(cloudDistantScrollSpeed, Styles.CloudDistantScrollSpeedText);
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Overhead Clouds", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.TexturePropertySingleLine(Styles.CloudOverheadMapText, cloudOverheadMap, cloudOverheadColor);
            m_MaterialEditor.TextureScaleOffsetProperty(cloudOverheadMap);
            m_MaterialEditor.ShaderProperty(cloudOverheadHeight, Styles.CloudOverheadHeightText);
            m_MaterialEditor.ShaderProperty(cloudOverheadScrollSpeed, Styles.CloudOverheadScrollSpeedText);
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Stars", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.TexturePropertySingleLine(Styles.StarMapText, starMap, starColor);
            m_MaterialEditor.TextureScaleOffsetProperty(starMap);
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Sun / Moon", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(sunColor, Styles.SunColorText);
            m_MaterialEditor.ShaderProperty(sunElevation, Styles.SunElevationText);
            m_MaterialEditor.ShaderProperty(sunAzimuth, Styles.SunAzimuthText);
            m_MaterialEditor.ShaderProperty(sunHazeExponent, Styles.SunHazeExponentText);
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();
        }

        protected override void MaterialPropertiesAdvanceGUI(Material material)
        {
        }

        protected override void VertexAnimationPropertiesGUI()
        {
        }

        protected override bool ShouldEmissionBeEnabled(Material mat)
        {
            return false;
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
        }
    }
} // namespace UnityEditor
