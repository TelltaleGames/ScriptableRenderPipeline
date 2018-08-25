using System.Reflection;
using UnityEngine;

namespace UnityEditor.ShaderGraph
{
    [Title("Utility", "Compile Time Logic", "Branch")]
    public class CompileTimeBranchNode : CodeFunctionNode
    {
        public CompileTimeBranchNode()
        {
            name = "Compile Time Branch";
        }

        public override string documentationURL
        {
            get { return "https://github.com/Unity-Technologies/ShaderGraph/wiki/Branch-Node"; }
        }

        protected override MethodInfo GetFunctionToConvert()
        {
            return GetType().GetMethod("Unity_Compile_Time_Branch", BindingFlags.Static | BindingFlags.NonPublic);
        }

        static string Unity_Compile_Time_Branch(
            [Slot(0, Binding.None)] CompileTimeBoolean Predicate,
            [Slot(1, Binding.None, 1, 1, 1, 1)] DynamicDimensionVector True,
            [Slot(2, Binding.None, 0, 0, 0, 0)] DynamicDimensionVector False,
            [Slot(3, Binding.None)] out DynamicDimensionVector Out)
        {
            return
                @"
{
    Out = Predicate ? True : False;
}
";
        }
    }
}
