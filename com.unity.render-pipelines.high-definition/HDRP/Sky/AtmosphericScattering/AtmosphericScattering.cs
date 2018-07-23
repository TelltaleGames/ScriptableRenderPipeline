using System;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine.Rendering;

namespace UnityEngine.Experimental.Rendering.HDPipeline
{
    // Keep this class first in the file. Otherwise it seems that the script type is not registered properly.
    public abstract class AtmosphericScattering : VolumeComponent
    {
        // Fog Color
        static readonly int m_ColorModeParam = Shader.PropertyToID("_FogColorMode");
        static readonly int m_FogColorDensityParam = Shader.PropertyToID("_FogColorDensity");
        static readonly int m_MipFogParam = Shader.PropertyToID("_MipFogParameters");

        readonly static int m_GradientFogParam = Shader.PropertyToID("_FogGradientTexture");

        // Fog Color
        public FogColorParameter       colorMode = new FogColorParameter(FogColorMode.SkyColor);
        [Tooltip("Constant Fog Color")]
        public ColorParameter          color = new ColorParameter(Color.grey);
        public ClampedFloatParameter   density = new ClampedFloatParameter(1.0f, 0.0f, 1.0f);
        [Tooltip("Maximum mip map used for mip fog (0 being lowest and 1 highest mip).")]
        public ClampedFloatParameter   mipFogMaxMip = new ClampedFloatParameter(0.5f, 0.0f, 1.0f);
        [Tooltip("Distance at which minimum mip of blurred sky texture is used as fog color.")]
        public MinFloatParameter       mipFogNear = new MinFloatParameter(0.0f, 0.0f);
        [Tooltip("Distance at which maximum mip of blurred sky texture is used as fog color.")]
        public MinFloatParameter       mipFogFar = new MinFloatParameter(1000.0f, 0.0f);

        [HideInInspector]
        public Gradient gradient = null;
        public GradientColorArrayParameter gradientColorArray = new GradientColorArrayParameter(null);

        private Texture2D cachedGradientTexture;
        
        public abstract void PushShaderParameters(HDCamera hdCamera, CommandBuffer cmd);

        public static void PushNeutralShaderParameters(HDCamera hdCamera, CommandBuffer cmd)
        {
            cmd.SetGlobalInt(HDShaderIDs._AtmosphericScatteringType, (int)FogType.None);

            // In case volumetric lighting is enabled, we need to make sure that all rendering passes
            // (not just the atmospheric scattering one) receive neutral parameters.
            if (hdCamera.frameSettings.enableVolumetric)
            {
                var data = DensityVolumeData.GetNeutralValues();

                cmd.SetGlobalVector(HDShaderIDs._GlobalScattering, data.scattering);
                cmd.SetGlobalFloat(HDShaderIDs._GlobalExtinction, data.extinction);
                cmd.SetGlobalFloat(HDShaderIDs._GlobalAnisotropy, 0.0f);
            }
        }

        // Not used by the volumetric fog.
        public void PushShaderParametersCommon(HDCamera hdCamera, CommandBuffer cmd, FogType type)
        {
            Debug.Assert(hdCamera.frameSettings.enableAtmosphericScattering);

            cmd.SetGlobalInt(HDShaderIDs._AtmosphericScatteringType, (int)type);

            // Fog Color
            cmd.SetGlobalFloat(m_ColorModeParam, (float)colorMode.value);
            cmd.SetGlobalColor(m_FogColorDensityParam, new Color(color.value.r, color.value.g, color.value.b, density));
            cmd.SetGlobalVector(m_MipFogParam, new Vector4(mipFogNear, mipFogFar, mipFogMaxMip, 0.0f));

            if (colorMode.value == FogColorMode.GradientColor)
            {
                UpdateGradientTexture(gradientColorArray.value);
            }

            cmd.SetGlobalTexture(m_GradientFogParam, cachedGradientTexture);
        }

        private void UpdateGradientTexture(Color[] colors)
        {
            if (colors == null || colors.Length == 0)
            {
                cachedGradientTexture = null;
                return;
            }

            if (cachedGradientTexture == null || cachedGradientTexture.width != colors.Length)
            {
                cachedGradientTexture = new Texture2D(colors.Length, 1, TextureFormat.ARGB32, false, true);
                cachedGradientTexture.wrapMode = TextureWrapMode.Clamp;
            }

            cachedGradientTexture.SetPixels(colors);
            cachedGradientTexture.Apply(false);
        }

        protected override void OnEnable()
        {
            base.OnEnable();

            // Need this here rather than OnValidate, otherwise it auto-generates a white gradient with no alpha curve:
            if (gradient == null)
            {
                gradient = new Gradient();
                gradient.colorKeys = new GradientColorKey[] { new GradientColorKey(Color.white, 1f) };
                gradient.alphaKeys = new GradientAlphaKey[] { new GradientAlphaKey(0f, 0f), new GradientAlphaKey(1f, 1f) };
            }
        }

        void OnValidate()
        {
            if (colorMode.value != FogColorMode.GradientColor)
            {
                cachedGradientTexture = null;
                return;
            }
            
            if (colorMode.value == FogColorMode.GradientColor)
            {
                gradientColorArray.CopyFromGradient(gradient);
            }
        }
    }

    [GenerateHLSL]
    public enum FogType
    {
        None,
        Linear,
        Exponential,
        Volumetric
    }

    [GenerateHLSL]
    public enum FogColorMode
    {
        ConstantColor,
        SkyColor,
        GradientColor,
    }

    [Serializable, DebuggerDisplay(k_DebuggerDisplay)]
    public sealed class FogTypeParameter : VolumeParameter<FogType>
    {
        public FogTypeParameter(FogType value, bool overrideState = false)
            : base(value, overrideState) {}
    }

    [Serializable, DebuggerDisplay(k_DebuggerDisplay)]
    public sealed class FogColorParameter : VolumeParameter<FogColorMode>
    {
        public FogColorParameter(FogColorMode value, bool overrideState = false)
            : base(value, overrideState) {}
    }

    [Serializable, DebuggerDisplay(k_DebuggerDisplay)]
    public sealed class GradientColorArrayParameter : VolumeParameter<Color[]>
    {
        private const int resolution = 256;

        public GradientColorArrayParameter(Color[] value, bool overrideState = false)
            : base(value, overrideState) { }

        public override void Interp(Color[] from, Color[] to, float t)
        {
            base.Interp(from, to, t);

            if (from == null)
            {
                if (to != null)
                {
                    m_Value = to;
                    return;
                }
                return;
            }
            else if (to == null)
            {
                m_Value = from;
                return;
            }

            m_Value = new Color[resolution];

            for (int i = 0; i < resolution; i++)
            {
                m_Value[i] = Color.Lerp(from[i], to[i], t);
            }
        }

        public void CopyFromGradient(Gradient gradient)
        {
            m_Value = new Color[resolution];
            for (int i = 0; i < resolution; ++i)
            {
                float t = (float)i / (resolution - 1);
                m_Value[i] = gradient.Evaluate(t);
            }
        }
    }

    [Serializable, DebuggerDisplay(k_DebuggerDisplay)]
    public sealed class FogGradientParameter : VolumeParameter<Gradient>
    {
        public FogGradientParameter(Gradient value, bool overrideState = false)
            : base(value, overrideState) { }
    }
}
