using System;
using System.Collections.Generic;
using UnityEditor.Build;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    public class AbientLitShaderPreprocessor : UnlitShaderPreprocessor
    {
        bool AbientLitShaderStripper(HDRenderPipelineAsset hdrpAsset, Shader shader, ShaderSnippetData snippet, ShaderCompilerData inputData)
        {
            if (UnlitShaderStripper(hdrpAsset, shader, snippet, inputData))
            {
                return true;
            }

            // Add any specific stripping here.

            return false;
        }

        public override void AddStripperFuncs(Dictionary<string, VariantStrippingFunc> stripperFuncs)
        {
            // Add name of the shader and corresponding delegate to call to strip variant
            stripperFuncs.Add("HDRenderPipeline/FX/Particle Ambient Lit", AbientLitShaderStripper);
        }
    }
}
