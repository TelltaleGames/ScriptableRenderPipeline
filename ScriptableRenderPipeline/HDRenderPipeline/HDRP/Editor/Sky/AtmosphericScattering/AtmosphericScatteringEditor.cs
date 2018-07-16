using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    public class AtmosphericScatteringEditor : VolumeComponentEditor
    {
        SerializedDataParameter m_Density;
        SerializedDataParameter m_ColorMode;
        SerializedDataParameter m_Color;
        SerializedDataParameter m_MipFogNear;
        SerializedDataParameter m_MipFogFar;
        SerializedDataParameter m_MipFogMaxMip;

        SerializedDataParameter m_GradientColorArray;
        SerializedProperty m_Gradient;

        public override void OnEnable()
        {
            var o = new PropertyFetcher<AtmosphericScattering>(serializedObject);

            m_Density = Unpack(o.Find(x => x.density));

            // Fog Color
            m_ColorMode = Unpack(o.Find(x => x.colorMode));
            m_Color = Unpack(o.Find(x => x.color));
            m_MipFogNear = Unpack(o.Find(x => x.mipFogNear));
            m_MipFogFar = Unpack(o.Find(x => x.mipFogFar));
            m_MipFogMaxMip = Unpack(o.Find(x => x.mipFogMaxMip));

            m_GradientColorArray = Unpack(o.Find(x => x.gradientColorArray));
            m_Gradient = o.Find(x => x.gradient);
        }

        public override void OnInspectorGUI()
        {
            PropertyField(m_Density);
            PropertyField(m_ColorMode);
            EditorGUI.indentLevel++;
            if (!m_ColorMode.value.hasMultipleDifferentValues && (FogColorMode)m_ColorMode.value.intValue == FogColorMode.ConstantColor)
            {
                PropertyField(m_Color);
            }
            else if (!m_ColorMode.value.hasMultipleDifferentValues && (FogColorMode)m_ColorMode.value.intValue == FogColorMode.GradientColor)
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    DrawOverrideCheckbox(m_GradientColorArray);
                    using (new EditorGUI.DisabledScope(!m_GradientColorArray.overrideState.boolValue))
                    {
                        EditorGUILayout.PropertyField(m_Gradient);
                    }
                }
            }
            else
            {
                PropertyField(m_MipFogNear);
                PropertyField(m_MipFogFar);
                PropertyField(m_MipFogMaxMip);
            }
            EditorGUI.indentLevel--;
        }
    }
}
