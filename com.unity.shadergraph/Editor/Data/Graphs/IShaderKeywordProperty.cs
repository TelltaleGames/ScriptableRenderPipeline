using System;
using UnityEditor.Graphing;
using UnityEngine;

namespace UnityEditor.ShaderGraph
{
    public interface IShaderKeywordProperty
    {
        string shaderKeywordName { get; }
        string overrideShaderKeywordName { get; set; }
    }
}
