using System;
using System.Text;
using UnityEditor.Graphing;
using UnityEditor.ShaderGraph.Drawing.Controls;
using UnityEngine;

namespace UnityEditor.ShaderGraph
{
    [Serializable]
    public class CompileTimeBooleanShaderProperty : AbstractShaderProperty<bool>, IShaderKeywordProperty
    {
        public CompileTimeBooleanShaderProperty()
        {
            displayName = "Compile Time Boolean";
        }

        public override PropertyType propertyType
        {
            get { return PropertyType.CompileTimeBoolean; }
        }

        public override Vector4 defaultValue
        {
            get { return new Vector4(); }
        }

        public override string GetPropertyBlockString()
        {
            var result = new StringBuilder();
            result.Append("[Toggle(");
            result.Append(shaderKeywordName);
            result.Append(")] ");
            result.Append(referenceName);
            result.Append("(\"");
            result.Append(displayName);
            result.Append("\", Float) = ");
            result.Append(value == true ? 1 : 0);
            return result.ToString();
        }

        public override string GetPropertyDeclarationString(string delimiter = ";")
        {
            if (generatePropertyBlock)
            {
                return string.Format("#pragma shader_feature {0}", shaderKeywordName);
            }
            else if (value)
            {
                return string.Format("#define {0}", shaderKeywordName);
            }
            else
            {
                return "";
            }
        }

        public override PreviewProperty GetPreviewMaterialProperty()
        {
            return new PreviewProperty(PropertyType.CompileTimeBoolean)
            {
                name = referenceName,
                booleanValue = value
            };
        }

        public override INode ToConcreteNode()
        {
            return new CompileTimeBooleanNode { value = new ToggleData(value) };
        }

        public override IShaderProperty Copy()
        {
            var copied = new CompileTimeBooleanShaderProperty();
            copied.displayName = displayName;
            copied.value = value;
            return copied;
        }

        [SerializeField]
        private string m_OverrideShaderKeywordName;

        private string m_DefaultShaderKeywordName;

        public string shaderKeywordName
        {
            get
            {
                if (string.IsNullOrEmpty(overrideShaderKeywordName))
                {
                    if (string.IsNullOrEmpty(m_DefaultShaderKeywordName))
                    {
                        m_DefaultShaderKeywordName = string.Format("_{0}_{1}", propertyType.ToString().ToUpper(), GuidEncoder.Encode(guid));
                    }
                    return m_DefaultShaderKeywordName;
                }
                return overrideShaderKeywordName;
            }
        }

        public string overrideShaderKeywordName
        {
            get { return m_OverrideShaderKeywordName; }
            set { m_OverrideShaderKeywordName = value; }
        }
    }
}
