using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace UnityEngine.Experimental.Rendering.HDPipeline
{
    [CustomEditor( typeof( AOCapsule ) ), CanEditMultipleObjects]
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

        private static void DrawCircle( Vector3 position, Vector3 up, Color color, float radius = 1.0f )
        {
            up = ( ( up == Vector3.zero ) ? Vector3.up : up ).normalized * radius;
            Vector3 _forward = Vector3.Slerp( up, -up, 0.5f );
            Vector3 _right = Vector3.Cross( up, _forward ).normalized * radius;

            Matrix4x4 matrix = new Matrix4x4();

            matrix[0] = _right.x;
            matrix[1] = _right.y;
            matrix[2] = _right.z;

            matrix[4] = up.x;
            matrix[5] = up.y;
            matrix[6] = up.z;

            matrix[8] = _forward.x;
            matrix[9] = _forward.y;
            matrix[10] = _forward.z;

            Vector3 _lastPoint = position + matrix.MultiplyPoint3x4( new Vector3( Mathf.Cos( 0 ), 0, Mathf.Sin( 0 ) ) );
            Vector3 _nextPoint = Vector3.zero;

            Color oldColor = Gizmos.color;
            Gizmos.color = ( color == default( Color ) ) ? Color.white : color;

            for( var i = 0; i < 91; i++ )
            {
                _nextPoint.x = Mathf.Cos( ( i * 4 ) * Mathf.Deg2Rad );
                _nextPoint.z = Mathf.Sin( ( i * 4 ) * Mathf.Deg2Rad );
                _nextPoint.y = 0;

                _nextPoint = position + matrix.MultiplyPoint3x4( _nextPoint );

                Gizmos.DrawLine( _lastPoint, _nextPoint );
                _lastPoint = _nextPoint;
            }

            Gizmos.color = oldColor;
        }

        private static void DrawCapsule( Vector3 start, Vector3 end, Color color, float radius = 1 )
        {
            Vector3 up = ( end - start ).normalized * radius;
            Vector3 forward = Vector3.Slerp( up, -up, 0.5f );
            Vector3 right = Vector3.Cross( up, forward ).normalized * radius;

            Color oldColor = Gizmos.color;
            Gizmos.color = color;

            float height = ( start - end ).magnitude;
            float sideLength = Mathf.Max( 0, ( height * 0.5f ) - radius );
            Vector3 middle = ( end + start ) * 0.5f;

            start = middle + ( ( start - middle ).normalized * sideLength );
            end = middle + ( ( end - middle ).normalized * sideLength );

            //Radial circles
            DrawCircle( start, up, color, radius );
            DrawCircle( end, -up, color, radius );

            //Side lines
            Gizmos.DrawLine( start + right, end + right );
            Gizmos.DrawLine( start - right, end - right );

            Gizmos.DrawLine( start + forward, end + forward );
            Gizmos.DrawLine( start - forward, end - forward );

            for( int i = 1; i < 26; i++ )
            {

                //Start endcap
                Gizmos.DrawLine( Vector3.Slerp( right, -up, i / 25.0f ) + start, Vector3.Slerp( right, -up, ( i - 1 ) / 25.0f ) + start );
                Gizmos.DrawLine( Vector3.Slerp( -right, -up, i / 25.0f ) + start, Vector3.Slerp( -right, -up, ( i - 1 ) / 25.0f ) + start );
                Gizmos.DrawLine( Vector3.Slerp( forward, -up, i / 25.0f ) + start, Vector3.Slerp( forward, -up, ( i - 1 ) / 25.0f ) + start );
                Gizmos.DrawLine( Vector3.Slerp( -forward, -up, i / 25.0f ) + start, Vector3.Slerp( -forward, -up, ( i - 1 ) / 25.0f ) + start );

                //End endcap
                Gizmos.DrawLine( Vector3.Slerp( right, up, i / 25.0f ) + end, Vector3.Slerp( right, up, ( i - 1 ) / 25.0f ) + end );
                Gizmos.DrawLine( Vector3.Slerp( -right, up, i / 25.0f ) + end, Vector3.Slerp( -right, up, ( i - 1 ) / 25.0f ) + end );
                Gizmos.DrawLine( Vector3.Slerp( forward, up, i / 25.0f ) + end, Vector3.Slerp( forward, up, ( i - 1 ) / 25.0f ) + end );
                Gizmos.DrawLine( Vector3.Slerp( -forward, up, i / 25.0f ) + end, Vector3.Slerp( -forward, up, ( i - 1 ) / 25.0f ) + end );
            }

            Gizmos.color = oldColor;
        }

        private void DrawGizmo( bool selected )
        {
            if( Target != null )
            {
                Color color = Color.blue;
                color.a = selected ? 0.6f : 0.1f;
                DrawCapsule( transform.position, Target.position, color, Radius );
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
    }
}
