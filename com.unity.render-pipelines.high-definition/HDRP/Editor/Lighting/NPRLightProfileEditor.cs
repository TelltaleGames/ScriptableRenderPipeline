using System;
using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    [CustomEditor( typeof( NPRLightProfile ) )]
    public class NPRLightProfileEditor : Editor
    {
        private NPRLightProfileComponentEditor mComponentEditor;

        void OnEnable()
        {
            mComponentEditor = new NPRLightProfileComponentEditor( this );
            mComponentEditor.Init( target as NPRLightProfile, serializedObject );
        }

        void OnDisable()
        {
            if( mComponentEditor != null )
                mComponentEditor.Clear();
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            mComponentEditor.OnGUI();
            serializedObject.ApplyModifiedProperties();
        }
    }

    //
    public sealed class NPRLightProfileComponentEditor
    {
        private Editor mBaseEditor;
        private NPRLightProfile mAsset;
        private SerializedObject mSerializedObject;

        private SerializedProperty mSerializedIntensityCurve;
        private SerializedProperty mSerializedOpacityCurve;
        private SerializedProperty mSerializedSaturationCurve;

        public NPRLightProfile Asset { get { return mAsset; } }

        public NPRLightProfileComponentEditor( Editor editor )
        {
            Assert.IsNotNull( editor );
            mBaseEditor = editor;
        }

        public void Init( NPRLightProfile asset, SerializedObject serializedObject )
        {
            Assert.IsNotNull( asset );
            Assert.IsNotNull( serializedObject );

            mAsset = asset;
            mSerializedObject = serializedObject;
            mSerializedIntensityCurve = serializedObject.Find( ( NPRLightProfile x ) => x.IntensityCurve );
            mSerializedOpacityCurve = serializedObject.Find( ( NPRLightProfile x ) => x.OpacityCurve );
            mSerializedSaturationCurve = serializedObject.Find( ( NPRLightProfile x ) => x.SaturationCurve );

            // Keep track of undo/redo to redraw the inspector when that happens
            Undo.undoRedoPerformed += OnUndoRedoPerformed;
        }

        private void OnUndoRedoPerformed()
        {
            //mAsset.isDirty = true;

            // Dumb hack to make sure the serialized object is up to date on undo (else there'll be
            // a state mismatch when this class is used in a GameObject inspector).
            mSerializedObject.Update();
            mSerializedObject.ApplyModifiedProperties();

            // Seems like there's an issue with the inspector not repainting after some undo events
            // This will take care of that
            mBaseEditor.Repaint();
        }

        public void Clear()
        {
            Undo.undoRedoPerformed -= OnUndoRedoPerformed;
        }

        public void OnGUI()
        {
            bool isEditable = !VersionControl.Provider.isActive
                || AssetDatabase.IsOpenForEdit( mAsset, StatusQueryOptions.UseCachedIfPossible );

            using( new EditorGUI.DisabledScope( !isEditable ) )
            {
                EditorGUILayout.CurveField( mSerializedIntensityCurve,
                    Color.blue,
                    new Rect( 0.0f, 0.0f, 1.0f, 1.0f ),
                    CoreEditorUtils.GetContent( "Intensity Curve" ) );

                EditorGUILayout.CurveField( mSerializedOpacityCurve,
                    Color.blue,
                    new Rect( 0.0f, 0.0f, 1.0f, 1.0f ),
                    CoreEditorUtils.GetContent( "Opacity Curve" ) );

                EditorGUILayout.CurveField( mSerializedSaturationCurve,
                    Color.blue,
                    new Rect( 0.0f, 0.0f, 1.0f, 8.0f ),
                    CoreEditorUtils.GetContent( "Saturation Curve" ) );

                mSerializedObject.ApplyModifiedProperties();
            }
        }
    }
}
