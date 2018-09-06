using UnityEngine;
using System.Collections.Generic;

namespace UnityEngine.Experimental.Rendering.HDPipeline
{
    public class NPRLightProfile : ScriptableObject
    {
        public AnimationCurve IntensityCurve = AnimationCurve.Linear( 0.0f, 0.0f, 1.0f, 1.0f );
        public AnimationCurve OpacityCurve = AnimationCurve.Constant( 0.0f, 1.0f, 0.0f );
        public AnimationCurve SaturationCurve = AnimationCurve.Constant( 0.0f, 1.0f, 0.0f );
    }
}
