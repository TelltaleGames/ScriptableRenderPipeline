using UnityEngine.Rendering;

namespace UnityEngine.Experimental.Rendering.HDPipeline
{
    public class DeformationManager
    {
        public static readonly int kTextureSize = 1024;

        public void Build( HDRenderPipelineAsset hdAsset )
        {
            mResources = hdAsset.renderPipelineResources;
            mDeformationDepth = RTHandles.Alloc( kTextureSize, kTextureSize, depthBufferBits: DepthBits.Depth24, colorFormat: RenderTextureFormat.Depth );
            mDeformationTarget = RTHandles.Alloc( kTextureSize, kTextureSize, colorFormat: RenderTextureFormat.RFloat, enableRandomWrite: true );
            mDeformationAccumulateKernel = -1;
        }

        public void Cleanup()
        {
            RTHandles.Release( mDeformationDepth );
            RTHandles.Release( mDeformationTarget );
        }

        public void Update( ScriptableRenderContext renderContext, float time, float lastTime, uint frameCount )
        {
#if false
            float orthoSize = 32.0f;
            float nearClip = 0.01f;
            float farClip = 10.0f;
            Vector3 cameraPosition = Vector3.zero;
            Matrix4x4 viewFromWorld = Matrix4x4.LookAt( cameraPosition, Vector3.up, Vector3.right );
            Matrix4x4 projFromView = Matrix4x4.Ortho( -orthoSize, orthoSize, -orthoSize, orthoSize, nearClip, farClip );
            Matrix4x4 projFromWorld = projFromView * viewFromWorld;
            Plane[] frustum = GeometryUtility.CalculateFrustumPlanes( projFromWorld );

            ScriptableCullingParameters cullParams = new ScriptableCullingParameters();
            cullParams.cullingMatrix = projFromWorld;
            cullParams.position = cameraPosition;
            cullParams.sceneMask = long.MaxValue;
            for( int i = 0; i < frustum.Length; ++i )
            {
                cullParams.SetCullingPlane( i, frustum[i] );
            }

            cullParams.lodParameters = new LODParameters
            {
                cameraPosition = cameraPosition,
                orthoSize = orthoSize,
                isOrthographic = true,
            };

            CullResults cullResults = new CullResults();
            CullResults.Cull( ref cullParams, renderContext, ref cullResults );
#endif
            //
            if( mDeformationAccumulateKernel < 0 && mResources.deformationAccumulateComputeShader != null )
            {
                mDeformationAccumulateKernel = mResources.deformationAccumulateComputeShader.FindKernel( "DeformationAccumulate" );
            }

            if( mDeformationAccumulateKernel < 0 )
            {
                return;
            }

            //
            HDCamera hdCamera = GetRenderCamera();
            Vector3 cameraPosition = new Vector3();
            Quaternion cameraRotation = Quaternion.LookRotation( Vector3.up, Vector3.right );
            Transform cameraTransform = hdCamera.camera.transform;
            cameraTransform.position = cameraPosition;
            cameraTransform.rotation = cameraRotation;
            hdCamera.camera.worldToCameraMatrix = GeometryUtils.CalculateWorldToCameraMatrixRHS( cameraPosition, cameraRotation );
            hdCamera.Update( mFrameSettings, null, null );

            //
            ScriptableCullingParameters cullParams = new ScriptableCullingParameters();
            if( !CullResults.GetCullingParameters( hdCamera.camera, out cullParams ) )
            {
                return;
            }

            CullResults cullResults = CullResults.Cull( ref cullParams, renderContext );

            CommandBuffer cmd = CommandBufferPool.Get( "Deformation" );
            renderContext.SetupCameraProperties( hdCamera.camera, false );
            hdCamera.SetupGlobalParams( cmd, time, lastTime, frameCount );

            CoreUtils.SetRenderTarget( cmd, mDeformationDepth, ClearFlag.Depth );
            renderContext.ExecuteCommandBuffer( cmd );
            CommandBufferPool.Release( cmd );

            //
            DrawRendererSettings rendererSettings = new DrawRendererSettings();
            rendererSettings.sorting.flags = SortFlags.OptimizeStateChanges;
            rendererSettings.SetShaderPassName( 0, HDShaderPassNames.s_DepthOnlyName );

            FilterRenderersSettings filterSettings = new FilterRenderersSettings( true )
            {
                renderQueueRange = HDRenderQueue.k_RenderQueue_AllOpaque,
            };

            renderContext.DrawRenderers( cullResults.visibleRenderers, ref rendererSettings, filterSettings );

            //
            Matrix4x4 projToTexture = Matrix4x4.TRS( new Vector3( 0.5f, 0.5f, 0.0f ), Quaternion.identity, new Vector3( 0.5f, -0.5f, 1.0f ) );
            Matrix4x4 worldToTexture = projToTexture * hdCamera.viewProjMatrix;
            cmd.SetGlobalTexture( HDShaderIDs._DeformationTexture, mDeformationTarget );
            cmd.SetGlobalMatrix( HDShaderIDs._DeformationWorldToTextureMatrix, worldToTexture );
            cmd.SetGlobalFloat( HDShaderIDs._DeformationMaxDepth, hdCamera.camera.farClipPlane );

            int tileSize = 16; // Must match TelltaleContactShadow.compute
            int numTilesX = ( kTextureSize + tileSize - 1 ) / tileSize;
            int numTilesY = ( kTextureSize + tileSize - 1 ) / tileSize;

            cmd.SetComputeTextureParam( mResources.deformationAccumulateComputeShader,
                mDeformationAccumulateKernel,
                HDShaderIDs._DeformationDepthTexture,
                mDeformationDepth );
            cmd.SetComputeTextureParam( mResources.deformationAccumulateComputeShader,
                mDeformationAccumulateKernel,
                HDShaderIDs._DeformationTexture,
                mDeformationTarget );
            cmd.DispatchCompute( mResources.deformationAccumulateComputeShader, mDeformationAccumulateKernel, numTilesX, numTilesY, 1 );
        }

        private HDCamera GetRenderCamera()
        {
            if( smHDRenderCamera == null )
            {
                var go = GameObject.Find( "__Deformation Render Camera" ) ?? new GameObject( "__Deformation Render Camera" );
                go.hideFlags = HideFlags.DontSave;// HideFlags.HideAndDontSave;

                Camera camera = go.GetComponent<Camera>();
                if( camera == null || camera.Equals( null ) )
                    camera = go.AddComponent<Camera>();

                camera.farClipPlane = 10.0f;
                camera.nearClipPlane = 0.001f;
                camera.orthographic = true;
                camera.orthographicSize = 16.0f;
                camera.aspect = 1.0f;

                // We need to setup cameraType before adding additional camera
                camera.cameraType = CameraType.Reflection;

                smRenderCameraData = go.GetComponent<HDAdditionalCameraData>();
                if( smRenderCameraData == null || smRenderCameraData.Equals( null ) )
                    smRenderCameraData = go.AddComponent<HDAdditionalCameraData>();

                smHDRenderCamera = new HDCamera( camera );

                go.SetActive( false );
            }

            return smHDRenderCamera;
        }

        private RenderPipelineResources mResources;
        private int mDeformationAccumulateKernel = -1;
        private static HDCamera smHDRenderCamera;
        private static HDAdditionalCameraData smRenderCameraData;
        private FrameSettings mFrameSettings = new FrameSettings();
        private RTHandleSystem.RTHandle mDeformationDepth;
        private RTHandleSystem.RTHandle mDeformationTarget;
    }
}
