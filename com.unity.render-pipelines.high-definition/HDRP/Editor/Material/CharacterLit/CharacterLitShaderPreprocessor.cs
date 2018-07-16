using System;
using System.Collections.Generic;
using UnityEditor.Build;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    public class CharacterLitShaderPreprocessor : LitShaderPreprocessor
    {
        public CharacterLitShaderPreprocessor()
        {
            m_WriteNormalBuffer = new ShaderKeyword("WRITE_NORMAL_BUFFER");
        }

        protected bool CharacterLitShaderStripper(HDRenderPipelineAsset hdrpAsset, Shader shader, ShaderSnippetData snippet, ShaderCompilerData inputData)
        {
            if (LitShaderStripper(hdrpAsset, shader, snippet, inputData))
            {
                return true;
            }

            // Add any CharacterLit specific stripping here.

            return false;
        }

        public override void AddStripperFuncs(Dictionary<string, VariantStrippingFunc> stripperFuncs)
        {
            // Add name of the shader and corresponding delegate to call to strip variant
            stripperFuncs.Add("HDRenderPipeline/CharacterLit", CharacterLitShaderStripper);
        }
    }
}
