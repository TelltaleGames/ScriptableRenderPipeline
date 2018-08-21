using System;
using System.Text;
using UnityEditor.Graphing;
using UnityEngine;

namespace UnityEditor.ShaderGraph
{
    [Serializable]
    public class HideInInspectorPropertyDecorator : IShaderProperty
    {
        [SerializeField]
        IShaderProperty decorated;

        public HideInInspectorPropertyDecorator(IShaderProperty property)
        {
            decorated = property;
        }

        public string displayName
        {
            get { return decorated.displayName; }
            set { decorated.displayName = value; }
        }

        public string referenceName { get { return decorated.referenceName; } }

        public PropertyType propertyType
        {
            get { return decorated.propertyType; }
        }

        public Guid guid { get { return decorated.guid; } }

        public bool generatePropertyBlock
        {
            get { return decorated.generatePropertyBlock; }
            set { decorated.generatePropertyBlock = value; }
        }

        public Vector4 defaultValue
        {
            get { return decorated.defaultValue; }
        }

        public string overrideReferenceName
        {
            get { return decorated.overrideReferenceName; }
            set { decorated.overrideReferenceName = value; }
        }

        public string GetPropertyBlockString()
        {
            return "[HideInInspector] " + decorated.GetPropertyBlockString();
        }

        public string GetPropertyDeclarationString(string delimiter = ";")
        {
            return decorated.GetPropertyDeclarationString(delimiter);
        }

        public string GetPropertyAsArgumentString()
        {
            return decorated.GetPropertyAsArgumentString();
        }

        public PreviewProperty GetPreviewMaterialProperty()
        {
            return decorated.GetPreviewMaterialProperty();
        }

        public INode ToConcreteNode()
        {
            return decorated.ToConcreteNode();
        }

        public IShaderProperty Copy()
        {
            return new HideInInspectorPropertyDecorator(decorated.Copy());
        }
    }
}
