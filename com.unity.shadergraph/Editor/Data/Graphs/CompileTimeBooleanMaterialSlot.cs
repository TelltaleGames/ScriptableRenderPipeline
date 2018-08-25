using System;
using System.Collections.Generic;
using UnityEditor.Graphing;
using UnityEditor.ShaderGraph.Drawing.Slots;
using UnityEngine;
using UnityEngine.Experimental.UIElements;

namespace UnityEditor.ShaderGraph
{
    [Serializable]
    public class CompileTimeBooleanMaterialSlot : MaterialSlot, IMaterialSlotHasValue<bool>
    {
        [SerializeField]
        private bool m_Value;

        [SerializeField]
        private bool m_DefaultValue;

        public CompileTimeBooleanMaterialSlot()
        {}

        public CompileTimeBooleanMaterialSlot(
            int slotId,
            string displayName,
            string shaderOutputName,
            SlotType slotType,
            bool value,
            ShaderStageCapability stageCapability = ShaderStageCapability.All,
            bool hidden = false)
            : base(slotId, displayName, shaderOutputName, slotType, stageCapability, hidden)
        {
            m_DefaultValue = value;
            m_Value = value;
        }

        public override VisualElement InstantiateControl()
        {
            return new CompileTimeBooleanSlotControlView(this);
        }

        public bool defaultValue { get { return m_DefaultValue; } }

        public bool value
        {
            get { return m_Value; }
            set { m_Value = value; }
        }

        protected override string ConcreteSlotValueAsVariable(AbstractMaterialNode.OutputPrecision precision)
        {
            return (value ? 1 : 0).ToString();
        }

        public override void AddDefaultProperty(PropertyCollector properties, GenerationMode generationMode)
        {
            if (!generationMode.IsPreview())
                return;

            var matOwner = owner as AbstractMaterialNode;
            if (matOwner == null)
                throw new Exception(string.Format("Slot {0} either has no owner, or the owner is not a {1}", this, typeof(AbstractMaterialNode)));

            var property = new CompileTimeBooleanShaderProperty()
            {
                overrideReferenceName = matOwner.GetVariableNameForSlot(id),
                generatePropertyBlock = false,
                value = value
            };
            properties.AddShaderProperty(property);
        }

        public override SlotValueType valueType { get { return SlotValueType.CompileTimeBoolean; } }
        public override ConcreteSlotValueType concreteValueType { get { return ConcreteSlotValueType.CompileTimeBoolean; } }

        public override void GetPreviewProperties(List<PreviewProperty> properties, string name)
        {
            var pp = new PreviewProperty(PropertyType.CompileTimeBoolean)
            {
                name = name,
                booleanValue = value
            };
            properties.Add(pp);
        }

        public override void CopyValuesFrom(MaterialSlot foundSlot)
        {
            var slot = foundSlot as CompileTimeBooleanMaterialSlot;
            if (slot != null)
                value = slot.value;
        }
    }
}
