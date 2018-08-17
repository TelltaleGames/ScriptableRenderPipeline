using System;
using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    [CustomEditorForRenderPipeline( typeof( AOCapsule ), typeof( HDRenderPipelineAsset ) ), CanEditMultipleObjects]
    public class AOCapsuleEditor : Editor
    {
        protected virtual void OnSceneGUI()
        {
            AOCapsule capsule = (AOCapsule)target;
            /*Vector3 globalEnd = capsule.transform.TransformPoint( capsule.End );

            EditorGUI.BeginChangeCheck();
            Vector3 newGlobalEnd = Handles.PositionHandle( globalEnd, Quaternion.identity );
            if( EditorGUI.EndChangeCheck() )
            {
                Undo.RecordObject( capsule, "Change End" );
                capsule.End = capsule.transform.InverseTransformPoint( newGlobalEnd );
            }*/

            Vector3 mid = ( capsule.transform.position + capsule.End ) * 0.5f;

            EditorGUI.BeginChangeCheck();
            float newRadius = Handles.RadiusHandle( capsule.transform.rotation, mid, capsule.Radius, true );
            if( EditorGUI.EndChangeCheck() )
            {
                Undo.RecordObject( capsule, "Change Radius" );
                capsule.Radius = newRadius;
            }
        }
    }
}
