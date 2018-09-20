using UnityEngine.Experimental.Rendering;

namespace UnityEditor.Experimental.Rendering
{
    [CustomEditor( typeof( RenderLayerManager ) )]
    public class RenderLayerManagerEditor : Editor
    {
        private SerializedProperty mRenderLayerProperty;

        private void OnUndoRedoPerformed()
        {
            RenderLayerManager manager = (RenderLayerManager)target;
            manager.UpdateRenderLayer();
        }

        private void OnEnable()
        {
            mRenderLayerProperty = serializedObject.Find( ( RenderLayerManager x ) => x.RenderingLayer );
            Undo.undoRedoPerformed += OnUndoRedoPerformed;
        }

        private void OnDisable()
        {
            Undo.undoRedoPerformed -= OnUndoRedoPerformed;
        }

        public override void OnInspectorGUI()
        {
            EditorGUI.BeginChangeCheck();

            RenderingLayer result = ( RenderingLayer)EditorGUILayout.EnumFlagsField( mRenderLayerProperty.displayName, (RenderingLayer)mRenderLayerProperty.intValue );
            mRenderLayerProperty.intValue = (int)result;

            if( EditorGUI.EndChangeCheck() )
            {
                serializedObject.ApplyModifiedProperties();
                RenderLayerManager manager = (RenderLayerManager)target;
                manager.UpdateRenderLayer();
            }
        }
    }
}
