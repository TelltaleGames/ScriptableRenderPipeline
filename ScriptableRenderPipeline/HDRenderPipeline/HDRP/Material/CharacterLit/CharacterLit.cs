using System;
using UnityEngine.Rendering;

namespace UnityEngine.Experimental.Rendering.HDPipeline
{
    public partial class CharacterLit : Lit
    {
        // Currently we have only one materialId (Standard GGX), so it is not store in the GBuffer and we don't test for it

        // If change, be sure it match what is done in Lit.hlsl: MaterialFeatureFlagsFromGBuffer
        // Material bit mask must match the size define LightDefinitions.s_MaterialFeatureMaskFlags value
        [GenerateHLSL(PackingRules.Exact)]
        new public enum MaterialFeatureFlags
        {
            LitStandard             = 1 << 0,   // For material classification we need to identify that we are indeed use as standard material, else we are consider as sky/background element
            LitSpecularColor        = 1 << 1,   // LitSpecularColor is not use statically but only dynamically
            LitSubsurfaceScattering = 1 << 2,
            LitTransmission         = 1 << 3,
            LitAnisotropy           = 1 << 4,
            LitIridescence          = 1 << 5,
            LitClearCoat            = 1 << 6,
            LitHair                 = 1 << 7    // Only used in CharacterLit shader
        };


        //-----------------------------------------------------------------------------
        // SurfaceData
        //-----------------------------------------------------------------------------

        // Main structure that store the user data (i.e user input of master node in material graph)
        [GenerateHLSL(PackingRules.Exact, false, true, 1000)]
        new public struct SurfaceData
        {
            [SurfaceDataAttributes("MaterialFeatures")]
            public uint materialFeatures;

            // Standard
            [SurfaceDataAttributes("Base Color", false, true)]
            public Vector3 baseColor;
            [SurfaceDataAttributes("Specular Occlusion")]
            public float specularOcclusion;

            [SurfaceDataAttributes(new string[]{"Normal", "Normal View Space"}, true)]
            public Vector3 normalWS;
            [SurfaceDataAttributes("Smoothness")]
            public float perceptualSmoothness;

            [SurfaceDataAttributes("Ambient Occlusion")]
            public float ambientOcclusion;

            [SurfaceDataAttributes("Metallic")]
            public float metallic;

            [SurfaceDataAttributes("Coat mask")]
            public float coatMask;

            // MaterialFeature dependent attribute

            // Hair
            [SurfaceDataAttributes("Hair Shift Primary", false, true)]
            public float hairShiftPrimary;
            [SurfaceDataAttributes("Hair Shift Secondary", false, true)]
            public float hairShiftSecondary;
            [SurfaceDataAttributes("Hair Smoothness Primary", false, true)]
            public float hairSmoothnessPrimary;
            [SurfaceDataAttributes("Hair Smoothness Secondary", false, true)]
            public float hairSmoothnessSecondary;
            [SurfaceDataAttributes("Hair Highlight Offset", false, true)]
            public float hairOffset;

            // Specular Color
            [SurfaceDataAttributes("Specular Color", false, true)]
            public Vector3 specularColor;

            // SSS
            [SurfaceDataAttributes("Diffusion Profile")]
            public uint diffusionProfile;
            [SurfaceDataAttributes("Subsurface Mask")]
            public float subsurfaceMask;

            // Transmission
            // + Diffusion Profile
            [SurfaceDataAttributes("Thickness")]
            public float thickness;

            // Anisotropic
            [SurfaceDataAttributes("Tangent", true)]
            public Vector3 tangentWS;
            [SurfaceDataAttributes("Anisotropy")]
            public float anisotropy; // anisotropic ratio(0->no isotropic; 1->full anisotropy in tangent direction, -1->full anisotropy in bitangent direction)

            // Iridescence
            [SurfaceDataAttributes("Iridescence Layer Thickness")]
            public float iridescenceThickness;
            [SurfaceDataAttributes("Iridescence Mask")]
            public float iridescenceMask;

            // Forward property only

            // Transparency
            // Reuse thickness from SSS

            [SurfaceDataAttributes("Index of refraction")]
            public float ior;
            [SurfaceDataAttributes("Transmittance Color")]
            public Vector3 transmittanceColor;
            [SurfaceDataAttributes("Transmittance Absorption Distance")]
            public float atDistance;
            [SurfaceDataAttributes("Transmittance mask")]
            public float transmittanceMask;
        };

        //-----------------------------------------------------------------------------
        // BSDFData
        //-----------------------------------------------------------------------------

        [GenerateHLSL(PackingRules.Exact, false, true, 1030)]
        new public struct BSDFData
        {
            public uint materialFeatures;

            [SurfaceDataAttributes("", false, true)]
            public Vector3 diffuseColor;
            public Vector3 fresnel0;

            public float specularOcclusion;

            [SurfaceDataAttributes(new string[] { "Normal WS", "Normal View Space" }, true)]
            public Vector3 normalWS;
            public float perceptualRoughness;

            public float coatMask;

            // MaterialFeature dependent attribute

            // SpecularColor fold into fresnel0

            // SSS
            public uint diffusionProfile;
            public float subsurfaceMask;

            // Transmission
            // + Diffusion Profile
            public float thickness;
            public bool useThickObjectMode; // Read from the diffusion profile
            public Vector3 transmittance;   // Precomputation of transmittance

            // Anisotropic
            [SurfaceDataAttributes("", true)]
            public Vector3 tangentWS;
            [SurfaceDataAttributes("", true)]
            public Vector3 bitangentWS;
            public float roughnessT;
            public float roughnessB;
            public float anisotropy;

            // Iridescence
            public float iridescenceThickness;
            public float iridescenceMask;

            // ClearCoat
            public float coatRoughness; // Automatically fill

            // Forward property only

            // Transparency
            public float ior;
            // Reuse thickness from SSS
            public Vector3 absorptionCoefficient;
            public float transmittanceMask;
        };


        public CharacterLit() {}

    }
}
