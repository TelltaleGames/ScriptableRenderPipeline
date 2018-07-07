using System;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    class SkyDomeUnlitGUI : BaseSkyDomeUnlitGUI
    {
        protected static class Styles
        {
            public static GUIContent skyGradZenithColorText = new GUIContent("Zenith Color", "Zenith Color");
            public static GUIContent skyGradHorizonColorText = new GUIContent("Horizon Color", "Horizon Color");
            public static GUIContent skyGradTopText = new GUIContent("Top", "Adjust upper angle of sky gradient");
            public static GUIContent skyGradBottomText = new GUIContent("Bottom", "Adjust lower angle of sky gradient");
            public static GUIContent skyGradCurveBiasText = new GUIContent("Curve Bias", "Adjust midpoint");

            public static GUIContent horizonGradEnableText = new GUIContent("Enable", "");
            public static GUIContent horizonGradIntensityText = new GUIContent("Intensity", "");
            public static GUIContent horizonGradColor1Text = new GUIContent("Upper Color", "");
            public static GUIContent horizonGradColor0Text = new GUIContent("Lower Color", "");
            public static GUIContent horizonGradHeightText = new GUIContent("Height", "Height of horizon gradient");
            public static GUIContent horizonGradColorBiasText = new GUIContent("Color Bias", "Adjust midpoint");
            public static GUIContent horizonGradAlphaBiasText = new GUIContent("Alpha Bias", "Adjust midpoint");
            public static GUIContent horizonGradDirectionText = new GUIContent("Heading", "Heading (in degrees) toward strongest point of horizon gradient");
            public static GUIContent horizonGradDirectionalAttenText = new GUIContent("Attenuation", "Amount that horizon colors drop in the opposite direction");

            public static GUIContent cloudHorizonEnableText = new GUIContent("Enable", "");
            public static GUIContent cloudHorizonMapText = new GUIContent("Texture", "");
            public static GUIContent cloudHorizonColorText = new GUIContent("Tint", "");
            public static GUIContent cloudHorizonUnlitColorText = new GUIContent("Unlit Color", "");
            public static GUIContent cloudHorizonLightingText = new GUIContent("Lighting", "");
            public static GUIContent cloudHorizonRimText = new GUIContent("Rim Intensity", "");
            public static GUIContent cloudHorizonScrollSpeedText = new GUIContent("Scroll Speed", "");

            public static GUIContent cloudOverheadEnableText = new GUIContent("Enable", "");
            public static GUIContent cloudOverheadMapText = new GUIContent("Texture", "");
            public static GUIContent cloudOverheadHeightText = new GUIContent("Height", "");
            public static GUIContent cloudOverheadColorText = new GUIContent("Tint", "");
            public static GUIContent cloudOverheadScrollSpeedText = new GUIContent("Scroll Speed", "");
            public static GUIContent cloudOverheadScrollHeadingText = new GUIContent("Scroll Heading", "");

            public static GUIContent backdropEnableText = new GUIContent("Enable", "");
            public static GUIContent backdropMapText = new GUIContent("Texture", "");
            public static GUIContent backdropEmissiveMapText = new GUIContent("Emissive", "");
            public static GUIContent backdropFogTopText = new GUIContent("Fog Top", "");
            public static GUIContent backdropFogTopColorText = new GUIContent("Fog Top Color", "");
            public static GUIContent backdropFogBottomText = new GUIContent("Fog Bottom", "");
            public static GUIContent backdropFogBottomColorText = new GUIContent("Fog Bottom Color", "");

            public static GUIContent starEnableText = new GUIContent("Enable", "");
            public static GUIContent starMapText = new GUIContent("Texture", "");
            public static GUIContent starTwinkleMapText = new GUIContent("Twinkle Texture", "");
            public static GUIContent starTwinkleIntensityText = new GUIContent("Twinkle Intensity", "");
            public static GUIContent starTwinkleSpeedText = new GUIContent("Twinkle Speed", "");
            public static GUIContent starColorText = new GUIContent("Tint/Alpha", "");
            public static GUIContent starMilkyWayMapText = new GUIContent("Galaxy Texture", "");

            public static GUIContent sunEnableText = new GUIContent("Enable", "");
            public static GUIContent sunRadiusText = new GUIContent("Sun Radius", "");
            public static GUIContent sunColorText = new GUIContent("Tint/Alpha", "");
            public static GUIContent sunElevationText = new GUIContent("Elevation", "Vertical angle (degrees) sun is above horizon");
            public static GUIContent sunAzimuthText = new GUIContent("Azimuth", "Horizontal angle (degrees) sun is away from X axis");
            public static GUIContent sunHazeColorText = new GUIContent("Haze Tint/Alpha", "");
            public static GUIContent sunHazeExponentText = new GUIContent("Haze Exponent", "Higher values = tighter haze around sun");
            public static GUIContent sunGlowColorText = new GUIContent("Glow Tint/Alpha", "");
            public static GUIContent sunGlowExponentText = new GUIContent("Glow Exponent", "Higher values = tighter glow around sun");
        }

        protected MaterialProperty skyGradZenithColor = null;
        protected const string kSkyGradZenithColor = "_SkyGradZenithColor";
        protected MaterialProperty skyGradHorizonColor = null;
        protected const string kSkyGradHorizonColor = "_SkyGradHorizonColor";
        protected MaterialProperty skyGradTop = null;
        protected const string kSkyGradTop = "_SkyGradTop";
        protected MaterialProperty skyGradBottom = null;
        protected const string kSkyGradBottom = "_SkyGradBottom";
        protected MaterialProperty skyGradCurveBias = null;
        protected const string kSkyGradCurveBias = "_SkyGradCurveBias";

        protected MaterialProperty horizonGradEnable = null;
        protected const string kHorizonGradEnable = "_HorizonGradEnable";
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

        protected MaterialProperty cloudHorizonEnable = null;
        protected const string kCloudHorizonEnable = "_CloudHorizonEnable";
        protected MaterialProperty cloudHorizonMap = null;
        protected const string kCloudHorizonMap = "_CloudHorizonMap";
        protected MaterialProperty cloudHorizonColor = null;
        protected const string kCloudHorizonColor = "_CloudHorizonColor";
        protected MaterialProperty cloudHorizonUnlitColor = null;
        protected const string kCloudHorizonUnlitColor = "_CloudHorizonUnlitColor";
        protected MaterialProperty cloudHorizonLighting = null;
        protected const string kCloudHorizonLighting = "_CloudHorizonLighting";
        protected MaterialProperty cloudHorizonRim = null;
        protected const string kCloudHorizonRim = "_CloudHorizonRim";
        protected MaterialProperty cloudHorizonScrollSpeed = null;
        protected const string kCloudHorizonScrollSpeed = "_CloudHorizonScrollSpeed";
        protected MaterialProperty cloudHorizonScrollHeading = null;
        protected const string kCloudHorizonScrollHeading = "_CloudHorizonScrollHeading";

        protected MaterialProperty cloudOverheadEnable = null;
        protected const string kCloudOverheadEnable = "_CloudOverheadEnable";
        protected MaterialProperty cloudOverheadMap = null;
        protected const string kCloudOverheadMap = "_CloudOverheadMap";
        protected MaterialProperty cloudOverheadHeight = null;
        protected const string kCloudOverheadHeight = "_CloudOverheadHeight";
        protected MaterialProperty cloudOverheadColor = null;
        protected const string kCloudOverheadColor = "_CloudOverheadColor";
        protected MaterialProperty cloudOverheadScrollSpeed = null;
        protected const string kCloudOverheadScrollSpeed = "_CloudOverheadScrollSpeed";
        protected MaterialProperty cloudOverheadScrollHeading = null;
        protected const string kCloudOverheadScrollHeading = "_CloudOverheadScrollHeading";

        protected MaterialProperty backdropEnable = null;
        protected const string kBackdropEnable = "_BackdropEnable";
        protected MaterialProperty backdropMap = null;
        protected const string kBackdropMap = "_BackdropMap";
        protected MaterialProperty backdropColor = null;
        protected const string kBackdropColor = "_BackdropColor";
        protected MaterialProperty backdropEmissiveMap = null;
        protected const string kBackdropEmissiveMap = "_BackdropEmissiveMap";
        protected MaterialProperty backdropEmissiveColor = null;
        protected const string kBackdropEmissiveColor = "_BackdropEmissiveColor";
        protected MaterialProperty backdropFogTop = null;
        protected const string kBackdropFogTop = "_BackdropFogTop";
        protected MaterialProperty backdropFogTopColor = null;
        protected const string kBackdropFogTopColor = "_BackdropFogTopColor";
        protected MaterialProperty backdropFogBottom = null;
        protected const string kBackdropFogBottom = "_BackdropFogBottom";
        protected MaterialProperty backdropFogBottomColor = null;
        protected const string kBackdropFogBottomColor = "_BackdropFogBottomColor";

        protected MaterialProperty starEnable = null;
        protected const string kStarEnable = "_StarEnable";
        protected MaterialProperty starMap = null;
        protected const string kStarMap = "_StarMap";
        protected MaterialProperty starColor = null;
        protected const string kStarColor = "_StarColor";
        protected MaterialProperty starTwinkleMap = null;
        protected const string kStarTwinkleMap = "_StarTwinkleMap";
        protected MaterialProperty starTwinkleIntensity = null;
        protected const string kStarTwinkleIntensity = "_StarTwinkleIntensity";
        protected MaterialProperty starTwinkleSpeed = null;
        protected const string kStarTwinkleSpeed = "_StarTwinkleSpeed";
        protected MaterialProperty starMilkyWayMap = null;
        protected const string kStarMilkyWayMap = "_StarMilkyWayMap";
        protected MaterialProperty starMilkyWayIntensity = null;
        protected const string kStarMilkyWayIntensity = "_StarMilkyWayIntensity";

        protected MaterialProperty sunEnable = null;
        protected const string kSunEnable = "_SunEnable";
        protected MaterialProperty sunRadius = null;
        protected const string kSunRadius = "_SunRadius";
        protected MaterialProperty sunColor = null;
        protected const string kSunColor = "_SunColor";
        protected MaterialProperty sunElevation = null;
        protected const string kSunElevation = "_SunElevation";
        protected MaterialProperty sunAzimuth = null;
        protected const string kSunAzimuth = "_SunAzimuth";
        protected MaterialProperty sunHazeColor = null;
        protected const string kSunHazeColor = "_SunHazeColor";
        protected MaterialProperty sunHazeExponent = null;
        protected const string kSunHazeExponent = "_SunHazeExponent";
        protected MaterialProperty sunGlowColor = null;
        protected const string kSunGlowColor = "_SunGlowColor";
        protected MaterialProperty sunGlowExponent = null;
        protected const string kSunGlowExponent = "_SunGlowExponent";


        protected override void FindMaterialProperties(MaterialProperty[] props)
        {
            skyGradZenithColor = FindProperty(kSkyGradZenithColor, props);
            skyGradHorizonColor = FindProperty(kSkyGradHorizonColor, props);
            skyGradTop = FindProperty(kSkyGradTop, props);
            skyGradBottom = FindProperty(kSkyGradBottom, props);
            skyGradCurveBias = FindProperty(kSkyGradCurveBias, props);

            horizonGradEnable = FindProperty(kHorizonGradEnable, props);
            horizonGradIntensity = FindProperty(kHorizonGradIntensity, props);
            horizonGradColor1 = FindProperty(kHorizonGradColor1, props);
            horizonGradColor0 = FindProperty(kHorizonGradColor0, props);
            horizonGradHeight = FindProperty(kHorizonGradHeight, props);
            horizonGradColorBias = FindProperty(kHorizonGradColorBias, props);
            horizonGradAlphaBias = FindProperty(kHorizonGradAlphaBias, props);
            horizonGradDirection = FindProperty(kHorizonGradDirection, props);
            horizonGradDirectionalAtten = FindProperty(kHorizonGradDirectionalAtten, props);

            cloudHorizonEnable = FindProperty(kCloudHorizonEnable, props);
            cloudHorizonMap = FindProperty(kCloudHorizonMap, props);
            cloudHorizonColor = FindProperty(kCloudHorizonColor, props);
            cloudHorizonUnlitColor = FindProperty(kCloudHorizonUnlitColor, props);
            cloudHorizonLighting = FindProperty(kCloudHorizonLighting, props);
            cloudHorizonRim = FindProperty(kCloudHorizonRim, props);
            cloudHorizonScrollSpeed = FindProperty(kCloudHorizonScrollSpeed, props);

            cloudOverheadEnable = FindProperty(kCloudOverheadEnable, props);
            cloudOverheadMap = FindProperty(kCloudOverheadMap, props);
            cloudOverheadHeight = FindProperty(kCloudOverheadHeight, props);
            cloudOverheadColor = FindProperty(kCloudOverheadColor, props);
            cloudOverheadScrollSpeed = FindProperty(kCloudOverheadScrollSpeed, props);
            cloudOverheadScrollHeading = FindProperty(kCloudOverheadScrollHeading, props);

            backdropEnable = FindProperty(kBackdropEnable, props);
            backdropMap = FindProperty(kBackdropMap, props);
            backdropColor = FindProperty(kBackdropColor, props);
            backdropEmissiveMap = FindProperty(kBackdropEmissiveMap, props);
            backdropEmissiveColor = FindProperty(kBackdropEmissiveColor, props);
            backdropFogTop = FindProperty(kBackdropFogTop, props);
            backdropFogTopColor = FindProperty(kBackdropFogTopColor, props);
            backdropFogBottom = FindProperty(kBackdropFogBottom, props);
            backdropFogBottomColor = FindProperty(kBackdropFogBottomColor, props);

            starEnable = FindProperty(kStarEnable, props);
            starMap = FindProperty(kStarMap, props);
            starColor = FindProperty(kStarColor, props);
            starTwinkleMap = FindProperty(kStarTwinkleMap, props);
            starTwinkleIntensity = FindProperty(kStarTwinkleIntensity, props);
            starTwinkleSpeed = FindProperty(kStarTwinkleSpeed, props);
            starMilkyWayMap = FindProperty(kStarMilkyWayMap, props);
            starMilkyWayIntensity = FindProperty(kStarMilkyWayIntensity, props);

            sunEnable = FindProperty(kSunEnable, props);
            sunRadius = FindProperty(kSunRadius, props);
            sunColor = FindProperty(kSunColor, props);
            sunElevation = FindProperty(kSunElevation, props);
            sunAzimuth = FindProperty(kSunAzimuth, props);
            sunGlowExponent = FindProperty(kSunGlowExponent, props);
            sunGlowColor = FindProperty(kSunGlowColor, props);
            sunHazeExponent = FindProperty(kSunHazeExponent, props);
            sunHazeColor = FindProperty(kSunHazeColor, props);
        }

        protected override void MaterialPropertiesGUI(Material material)
        {
            EditorGUILayout.LabelField("Sky Gradient", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(skyGradZenithColor, Styles.skyGradZenithColorText);
            m_MaterialEditor.ShaderProperty(skyGradHorizonColor, Styles.skyGradHorizonColorText);
            m_MaterialEditor.ShaderProperty(skyGradTop, Styles.skyGradTopText);
            m_MaterialEditor.ShaderProperty(skyGradBottom, Styles.skyGradBottomText);
            m_MaterialEditor.ShaderProperty(skyGradCurveBias, Styles.skyGradCurveBiasText);
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Horizon Gradient", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(horizonGradEnable, Styles.horizonGradEnableText);
            if (horizonGradEnable.floatValue > 0.0f)
            {
                m_MaterialEditor.ShaderProperty(horizonGradIntensity, Styles.horizonGradIntensityText);
                m_MaterialEditor.ShaderProperty(horizonGradColor1, Styles.horizonGradColor1Text);
                m_MaterialEditor.ShaderProperty(horizonGradColor0, Styles.horizonGradColor0Text);
                m_MaterialEditor.ShaderProperty(horizonGradHeight, Styles.horizonGradHeightText);
                m_MaterialEditor.ShaderProperty(horizonGradColorBias, Styles.horizonGradColorBiasText);
                m_MaterialEditor.ShaderProperty(horizonGradAlphaBias, Styles.horizonGradAlphaBiasText);
                EditorGUILayout.LabelField("Direction", EditorStyles.boldLabel);
                EditorGUI.indentLevel++;
                EditorGUI.BeginChangeCheck();
                m_MaterialEditor.ShaderProperty(horizonGradDirection, Styles.horizonGradDirectionText);
                if (EditorGUI.EndChangeCheck())
                {
                    float horX = Mathf.Sin(material.GetFloat("_HorizonGradDirection") * Mathf.PI / 180.0f);
                    float horZ = Mathf.Cos(material.GetFloat("_HorizonGradDirection") * Mathf.PI / 180.0f);
                    material.SetVector( "_HorizonGradDirVector", new Vector4(horX, 0.0f, horZ, 1.0f) );
                }
                m_MaterialEditor.ShaderProperty(horizonGradDirectionalAtten, Styles.horizonGradDirectionalAttenText);
                EditorGUI.indentLevel--;
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Horizon Clouds", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(cloudHorizonEnable, Styles.cloudHorizonEnableText);
            if (cloudHorizonEnable.floatValue > 0.0f)
            {
                m_MaterialEditor.TexturePropertySingleLine(Styles.cloudHorizonMapText, cloudHorizonMap, cloudHorizonColor);
                m_MaterialEditor.TextureScaleOffsetProperty(cloudHorizonMap);
                m_MaterialEditor.ShaderProperty(cloudHorizonUnlitColor, Styles.cloudHorizonUnlitColorText);
                m_MaterialEditor.ShaderProperty(cloudHorizonLighting, Styles.cloudHorizonLightingText);
                m_MaterialEditor.ShaderProperty(cloudHorizonRim, Styles.cloudHorizonRimText);
                m_MaterialEditor.ShaderProperty(cloudHorizonScrollSpeed, Styles.cloudHorizonScrollSpeedText);
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Overhead Clouds", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(cloudOverheadEnable, Styles.cloudOverheadEnableText);
            if (cloudOverheadEnable.floatValue > 0.0f)
            {
                m_MaterialEditor.TexturePropertySingleLine(Styles.cloudOverheadMapText, cloudOverheadMap, cloudOverheadColor);
                m_MaterialEditor.TextureScaleOffsetProperty(cloudOverheadMap);
                m_MaterialEditor.ShaderProperty(cloudOverheadHeight, Styles.cloudOverheadHeightText);
                m_MaterialEditor.ShaderProperty(cloudOverheadScrollSpeed, Styles.cloudOverheadScrollSpeedText);
                EditorGUI.BeginChangeCheck();
                m_MaterialEditor.ShaderProperty(cloudOverheadScrollHeading, Styles.cloudOverheadScrollHeadingText);
                if (EditorGUI.EndChangeCheck())
                {
                    float ovdScrollX = Mathf.Sin(material.GetFloat("_CloudOverheadScrollHeading") * Mathf.PI / 180.0f);
                    float ovdScrollZ = Mathf.Cos(material.GetFloat("_CloudOverheadScrollHeading") * Mathf.PI / 180.0f);
                    material.SetVector( "_CloudOverheadScrollVector", new Vector4(-ovdScrollX, 0.0f, -ovdScrollZ, 1.0f) );
                }
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Backdrop", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(backdropEnable, Styles.backdropEnableText);
            if (backdropEnable.floatValue > 0.0f)
            {
                m_MaterialEditor.TexturePropertySingleLine(Styles.backdropMapText, backdropMap, backdropColor);
                m_MaterialEditor.TexturePropertySingleLine(Styles.backdropEmissiveMapText, backdropEmissiveMap, backdropEmissiveColor);
                m_MaterialEditor.TextureScaleOffsetProperty(backdropMap);
                m_MaterialEditor.ShaderProperty(backdropFogTop, Styles.backdropFogTopText);
                m_MaterialEditor.ShaderProperty(backdropFogTopColor, Styles.backdropFogTopColorText);
                m_MaterialEditor.ShaderProperty(backdropFogBottom, Styles.backdropFogBottomText);
                m_MaterialEditor.ShaderProperty(backdropFogBottomColor, Styles.backdropFogBottomColorText);
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Stars", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(starEnable, Styles.starEnableText);
            if (starEnable.floatValue > 0.0f)
            {
                m_MaterialEditor.TexturePropertySingleLine(Styles.starMapText, starMap, starColor);
                m_MaterialEditor.TextureScaleOffsetProperty(starMap);
                m_MaterialEditor.TexturePropertySingleLine(Styles.starTwinkleMapText, starTwinkleMap, starTwinkleIntensity);
                m_MaterialEditor.TextureScaleOffsetProperty(starTwinkleMap);
                m_MaterialEditor.ShaderProperty(starTwinkleSpeed, Styles.starTwinkleSpeedText);
                EditorGUILayout.Space();
                m_MaterialEditor.TexturePropertySingleLine(Styles.starMilkyWayMapText, starMilkyWayMap, starMilkyWayIntensity);
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Sun / Moon", EditorStyles.boldLabel);
            EditorGUI.indentLevel++;
            m_MaterialEditor.ShaderProperty(sunEnable, Styles.sunEnableText);
            if (sunEnable.floatValue > 0.0f)
            {
                m_MaterialEditor.ShaderProperty(sunRadius, Styles.sunRadiusText);
                m_MaterialEditor.ShaderProperty(sunColor, Styles.sunColorText);
                EditorGUI.BeginChangeCheck();
                m_MaterialEditor.ShaderProperty(sunElevation, Styles.sunElevationText);
                m_MaterialEditor.ShaderProperty(sunAzimuth, Styles.sunAzimuthText);
                if (EditorGUI.EndChangeCheck())
                {
                    float elevRadians = material.GetFloat("_SunElevation") * Mathf.PI / 180.0f;
                    float azimRadians = material.GetFloat("_SunAzimuth") * Mathf.PI / 180.0f;
                    float hyp = Mathf.Cos(elevRadians);
                    float sunX = hyp * Mathf.Sin(azimRadians);
                    float sunY = Mathf.Sin(elevRadians);
                    float sunZ = hyp * Mathf.Cos(azimRadians);
                    material.SetVector( "_SunVector", new Vector4(sunX, sunY, sunZ, 1.0f) );
                }
                m_MaterialEditor.ShaderProperty(sunGlowColor, Styles.sunGlowColorText);
                m_MaterialEditor.ShaderProperty(sunGlowExponent, Styles.sunGlowExponentText);
                m_MaterialEditor.ShaderProperty(sunHazeColor, Styles.sunHazeColorText);
                m_MaterialEditor.ShaderProperty(sunHazeExponent, Styles.sunHazeExponentText);
            }
            EditorGUI.indentLevel--;
            EditorGUILayout.Space();
        }

        protected override void MaterialPropertiesAdvanceGUI(Material material)
        {
        }

        protected override void VertexAnimationPropertiesGUI()
        {
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
