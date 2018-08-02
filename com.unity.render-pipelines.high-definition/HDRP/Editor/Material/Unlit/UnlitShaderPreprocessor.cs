using System;
using System.Collections.Generic;
using UnityEditor.Build;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    // Telltale folks: Don't cut and past this preprocessor. Instead, cut and paste one from another shader based on Unlit. SkyDomeUnlitShaderPreprocessor.cs for example.
    public class UnlitShaderPreprocessor : BaseShaderPreprocessor
    {
        protected bool UnlitShaderStripper(HDRenderPipelineAsset hdrpAsset, Shader shader, ShaderSnippetData snippet, ShaderCompilerData inputData)
        {
            return CommonShaderStripper(hdrpAsset, shader, snippet, inputData);
        }

        public override void AddStripperFuncs(Dictionary<string, VariantStrippingFunc> stripperFuncs)
        {
            // Add name of the shader and corresponding delegate to call to strip variant
            stripperFuncs.Add("HDRenderPipeline/Unlit", UnlitShaderStripper);
        }
    }
}
