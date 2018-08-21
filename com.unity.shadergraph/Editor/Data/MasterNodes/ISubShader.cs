using System;
using System.Collections.Generic;

namespace UnityEditor.ShaderGraph
{
    public interface ISubShader
    {
        string GetSubshader(IMasterNode masterNode, GenerationMode mode, List<string> sourceAssetDependencyPaths = null);

        // Allows sub-shader to add additional properties.
        void CollectShaderProperties(PropertyCollector properties, GenerationMode mode);
    }
}
