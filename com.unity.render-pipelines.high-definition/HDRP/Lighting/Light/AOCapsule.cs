using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Experimental.Rendering.HDPipeline;
#endif
using System.Collections.Generic;

namespace UnityEngine.Experimental.Rendering.HDPipeline
{
    [ExecuteInEditMode]
    public class AOCapsule : MonoBehaviour
    {
        public static List<AOCapsule> smCapsules = new List<AOCapsule>();

        public float Radius;
        public Transform Target;

        public Vector3 End
        {
            get { return Target != null ? Target.position : transform.position; }
        }

        private void OnEnable()
        {
            smCapsules.Add( this );
        }

        private void OnDisable()
        {
            smCapsules.Remove( this );
        }

#if UNITY_EDITOR
        private void DrawGizmo( bool selected )
        {
            Color color = Color.blue;
            color.a = selected ? 0.6f : 0.1f;
            if( Target != null )
            {
                HDLightEditorUtilities.DrawCapsule( transform.position, Target.position, color, Radius );
            }
            else
            {
                Gizmos.color = color;
                Gizmos.DrawWireSphere( transform.position, Radius );
            }
        }

        public void OnDrawGizmosSelected()
        {
            DrawGizmo( true );
        }

        public void OnDrawGizmos()
        {
            DrawGizmo( false );
        }
#endif // UNITY_EDITOR
    }
}
