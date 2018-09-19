using UnityEngine.Rendering;

namespace UnityEngine.Experimental.Rendering.HDPipeline
{
    public class DeformationSystem
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
            DeformationRoot root = DeformationRoot.Instance;
            if( root == null )
            {
                return;
            }

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
            HDCamera hdCamera = root.GetRenderCamera();
            Quaternion cameraRotation = Quaternion.LookRotation( Vector3.up, Vector3.right );
            Transform cameraTransform = hdCamera.camera.transform;
            cameraTransform.localPosition = Vector3.zero;
            cameraTransform.rotation = cameraRotation;

            Vector3 projScale = hdCamera.projMatrix.lossyScale;
            Vector3 worldToTexelScale = new Vector3( -0.5f * kTextureSize * projScale.y, 1.0f, 0.5f * kTextureSize * projScale.x );
            Vector3 cameraWorldPosition = cameraTransform.position;
            Vector3 cameraTexelPosition = Vector3.Scale( cameraWorldPosition, worldToTexelScale );
            cameraTexelPosition.x = Mathf.Floor( cameraTexelPosition.x );
            cameraTexelPosition.z = Mathf.Floor( cameraTexelPosition.z );
            cameraWorldPosition.x = ( cameraTexelPosition.x + 0.5f ) / worldToTexelScale.x;
            cameraWorldPosition.z = ( cameraTexelPosition.z + 0.5f ) / worldToTexelScale.z;
            cameraTransform.position = cameraWorldPosition;

            root.DeltaTexelPosition = cameraTexelPosition;

            //hdCamera.camera.worldToCameraMatrix = GeometryUtils.CalculateWorldToCameraMatrixRHS( cameraWorldPosition, cameraRotation );
            hdCamera.Update( root.FrameSettings, null, null );

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
            int cameraTexelPositionU = (int)cameraTexelPosition.z & ( kTextureSize - 1 );
            int cameraTexelPositionV = (int)cameraTexelPosition.x & ( kTextureSize - 1 );
            float cameraOffsetU = ( cameraTexelPositionU + 0.5f ) / kTextureSize;
            float cameraOffsetV = ( cameraTexelPositionV + 0.5f ) / kTextureSize;
            Matrix4x4 projToTexture = Matrix4x4.TRS( new Vector3( 0.5f, 0.5f, 0.0f ), Quaternion.identity, new Vector3( 0.5f, -0.5f, 1.0f ) );
            Matrix4x4 worldToTexture = projToTexture * hdCamera.viewProjMatrix;
            if( ShaderConfig.s_CameraRelativeRendering != 0 )
            {
                worldToTexture = worldToTexture * Matrix4x4.Translate( -cameraWorldPosition );
            }

            cmd.SetGlobalTexture( HDShaderIDs._DeformationTexture, mDeformationTarget );
            cmd.SetGlobalMatrix( HDShaderIDs._DeformationWorldToTextureMatrix, worldToTexture );
            cmd.SetGlobalVector( HDShaderIDs._DeformationParams, new Vector4( -cameraOffsetU, -cameraOffsetV, hdCamera.camera.farClipPlane, 0.0f ) );

            //Vector3 deltaTexelPosition = cameraTexelPosition - mPrevCameraTexelPosition;
            //mPrevCameraTexelPosition = cameraTexelPosition;

            cmd.SetComputeIntParams( mResources.deformationAccumulateComputeShader,
                HDShaderIDs._DeformationTexelParams,
                cameraTexelPositionU, cameraTexelPositionV, kTextureSize - 1 );

            cmd.SetComputeTextureParam( mResources.deformationAccumulateComputeShader,
                mDeformationAccumulateKernel,
                HDShaderIDs._DeformationDepthTexture,
                mDeformationDepth );
            cmd.SetComputeTextureParam( mResources.deformationAccumulateComputeShader,
                mDeformationAccumulateKernel,
                HDShaderIDs._DeformationTexture,
                mDeformationTarget );

            uint tileSizeX = 0u;
            uint tileSizeY = 0u;
            uint tileSizeZ = 0u;
            mResources.deformationAccumulateComputeShader.GetKernelThreadGroupSizes( mDeformationAccumulateKernel,
                out tileSizeX, out tileSizeY, out tileSizeZ );

            int numTilesX = ( kTextureSize + (int)tileSizeX - 1 ) / (int)tileSizeX;
            int numTilesY = ( kTextureSize + (int)tileSizeY - 1 ) / (int)tileSizeY;

            cmd.DispatchCompute( mResources.deformationAccumulateComputeShader, mDeformationAccumulateKernel, numTilesX, numTilesY, 1 );
        }

        private RenderPipelineResources mResources;
        private int mDeformationAccumulateKernel = -1;
        
        private RTHandleSystem.RTHandle mDeformationDepth;
        private RTHandleSystem.RTHandle mDeformationTarget;
        //private Vector3 mPrevCameraTexelPosition;
    }
}
