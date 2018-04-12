using System;
using UnityEditor.Graphing;
using UnityEngine;

namespace UnityEditor.ShaderGraph
{
    [Serializable]
    public abstract class AbstractShaderProperty<T> : IShaderProperty
    {
        [SerializeField]
        private T m_Value;

        [SerializeField]
        private string m_Name;

        [SerializeField]
        private string m_CustomReferenceName;

        [SerializeField]
        private bool m_GeneratePropertyBlock = true;

        [SerializeField]
        private bool m_UseCustomReferenceName = false;

        [SerializeField]
        private SerializableGuid m_Guid = new SerializableGuid();

        public T value
        {
            get { return m_Value; }
            set { m_Value = value; }
        }

        public string displayName
        {
            get
            {
                if (string.IsNullOrEmpty(m_Name))
                    return guid.ToString();
                return m_Name;
            }
            set { m_Name = value; }
        }

        public string customReferenceName
        {
            get
            {
                if (string.IsNullOrEmpty(m_CustomReferenceName))
                    m_CustomReferenceName = "_" + displayName;
                return m_CustomReferenceName;
            }
            set { m_CustomReferenceName = value; }
        }

        string m_DefaultReferenceName;

        public string referenceName
        {
            get
            {
                if (useCustomReferenceName)
                {
                    return customReferenceName;
                }

                if (string.IsNullOrEmpty(overrideReferenceName))
                {
                    if (string.IsNullOrEmpty(m_DefaultReferenceName))
                        m_DefaultReferenceName = string.Format("{0}_{1}", propertyType, GuidEncoder.Encode(guid));
                    return m_DefaultReferenceName;
                }
                return overrideReferenceName;
            }
        }

        public string overrideReferenceName { get; set; }

        public abstract PropertyType propertyType { get; }

        public Guid guid
        {
            get { return m_Guid.guid; }
        }

        public bool generatePropertyBlock
        {
            get { return m_GeneratePropertyBlock; }
            set { m_GeneratePropertyBlock = value; }
        }

        public bool useCustomReferenceName
        {
            get { return m_UseCustomReferenceName; }
            set { m_UseCustomReferenceName = value; }
        }

        public abstract Vector4 defaultValue { get; }
        public abstract string GetPropertyBlockString();
        public abstract string GetPropertyDeclarationString(string delimiter = ";");

        public virtual string GetPropertyAsArgumentString()
        {
            return GetPropertyDeclarationString(string.Empty);
        }

        public abstract PreviewProperty GetPreviewMaterialProperty();
        public abstract INode ToConcreteNode();
    }
}
