using UnityEngine.Rendering;
using UnityEditor;

namespace UnityEngine.Experimental.Rendering.HDPipeline
{
    [ExecuteInEditMode]
    public class DeformationRoot : MonoBehaviour
    {
        public static DeformationRoot Instance = null;
        public FrameSettings FrameSettings = new FrameSettings();

        public float DeformationHeight = 10.0f;
        public float DeformationFillRate = 0.01f;
        public float DeformationExtent = 16.0f;

        public HDCamera HDCamera { get { return mHDRenderCamera; } }

        public bool UpdateCamera()
        {
            bool bDirty = false;
            if( mHDRenderCamera == null )
            {
                Transform cameraTransform = gameObject.transform.Find( "__Deformation Camera" );
                if( cameraTransform == null )
                {
                    GameObject cameraObject = new GameObject( "__Deformation Camera" );
                    cameraObject.hideFlags = HideFlags.HideAndDontSave;
                    cameraTransform = cameraObject.transform;
                    cameraTransform.parent = transform;
                }

                Camera camera = cameraTransform.gameObject.GetComponent<Camera>();
                if( camera == null || camera.Equals( null ) )
                    camera = cameraTransform.gameObject.AddComponent<Camera>();

                camera.enabled = false;
                camera.nearClipPlane = 0.0f;
                camera.orthographic = true;
                camera.aspect = 1.0f;

                // We need to setup cameraType before adding additional camera
                camera.cameraType = CameraType.Reflection;

                mRenderCameraData = cameraTransform.gameObject.GetComponent<HDAdditionalCameraData>();
                if( mRenderCameraData == null || mRenderCameraData.Equals( null ) )
                    mRenderCameraData = cameraTransform.gameObject.AddComponent<HDAdditionalCameraData>();

                mHDRenderCamera = new HDCamera( camera );
                mHDRenderCamera.Update( FrameSettings, null, null );
                bDirty = true;
            }

            if( mHDRenderCamera.camera.orthographicSize != DeformationExtent )
            {
                mHDRenderCamera.camera.orthographicSize = DeformationExtent;
                bDirty = true;
            }
            if( mHDRenderCamera.camera.farClipPlane != DeformationHeight )
            {
                mHDRenderCamera.camera.farClipPlane = DeformationHeight;
                bDirty = true;
            }

            return bDirty;
        }

        void Awake()
        {
            if( Instance == null )
            {
                Instance = this;
            }
            else if( Instance != this )
            {
                Destroy( gameObject );
                return;
            }
        }

        void Update()
        {
            if( Instance == null )
            {
                Instance = this;
            }
        }

        private HDCamera mHDRenderCamera;
        private HDAdditionalCameraData mRenderCameraData;
    }

    /*[CustomEditor( typeof( DeformationRoot ) )]
    class DeformationRootEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            DeformationRoot root = (DeformationRoot)target;

            Rect rect = EditorGUILayout.GetControlRect();
            float size = Mathf.Max( rect.width, rect.height );
            rect.width = size;
            rect.height = size;
            if( root.mPreviewTexture != null )
            {
                EditorGUI.DrawTextureAlpha( rect, root.mPreviewTexture );
                EditorGUILayout.BeginFadeGroup
            }
        }
    }*/
}
