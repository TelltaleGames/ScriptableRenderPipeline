using System.Collections.Generic;
using UnityEditor.ShaderGraph.Drawing.Controls;
using UnityEngine;
using UnityEditor.Graphing;

namespace UnityEditor.ShaderGraph
{
    [Title("Input", "Basic", "Boolean")]
    public class CompileTimeBooleanNode : AbstractMaterialNode, IGeneratesBodyCode, IPropertyFromNode
    {
        [SerializeField]
        private bool m_Value;

        public const int OutputSlotId = 0;
        private const string kOutputSlotName = "Out";

        public CompileTimeBooleanNode()
        {
            name = "Compile Time Boolean";
            UpdateNodeAfterDeserialization();
        }

        public override string documentationURL
        {
            get { return "https://github.com/Unity-Technologies/ShaderGraph/wiki/Boolean-Node"; }
        }

        public sealed override void UpdateNodeAfterDeserialization()
        {
            AddSlot(new CompileTimeBooleanMaterialSlot(OutputSlotId, kOutputSlotName, kOutputSlotName, SlotType.Output, false));
            RemoveSlotsNameNotMatching(new[] { OutputSlotId });
        }

        [ToggleControl("")]
        public ToggleData value
        {
            get { return new ToggleData(m_Value); }
            set
            {
                if (m_Value == value.isOn)
                    return;
                m_Value = value.isOn;
                Dirty(ModificationScope.Node);
            }
        }

        public override void CollectShaderProperties(PropertyCollector properties, GenerationMode generationMode)
        {
            if (!generationMode.IsPreview())
                return;

            properties.AddShaderProperty(new CompileTimeBooleanShaderProperty()
            {
                overrideReferenceName = GetVariableNameForNode(),
                generatePropertyBlock = false,
                value = m_Value
            });
        }

        public void GenerateNodeCode(ShaderGenerator visitor, GenerationMode generationMode)
        {
            if (generationMode.IsPreview())
                return;

            visitor.AddShaderChunk("bool " + GetVariableNameForNode() + " = " + (m_Value ? "true" : "false") + ";", true);
        }

        public override string GetVariableNameForSlot(int slotId)
        {
            return GetVariableNameForNode();
        }

        public override void CollectPreviewMaterialProperties(List<PreviewProperty> properties)
        {
            properties.Add(new PreviewProperty(PropertyType.CompileTimeBoolean)
            {
                name = GetVariableNameForNode(),
                booleanValue = m_Value
            });
        }

        public IShaderProperty AsShaderProperty()
        {
            return new CompileTimeBooleanShaderProperty { value = m_Value };
        }

        public int outputSlotId { get { return OutputSlotId; } }
    }
}
