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
            cameraTexelPosition.x = Mathf.Round( cameraTexelPosition.x );
            cameraTexelPosition.z = Mathf.Round( cameraTexelPosition.z );
            Vector3 deltaTexelPosition = cameraTexelPosition - mPrevCameraPosition;
            cameraWorldPosition.x = ( cameraTexelPosition.x + 0.5f ) / worldToTexelScale.x;
            cameraWorldPosition.z = ( cameraTexelPosition.z + 0.5f ) / worldToTexelScale.z;

            cameraTransform.position = cameraWorldPosition;
            mPrevCameraPosition = cameraTexelPosition;

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
            Matrix4x4 projToTexture = Matrix4x4.TRS( new Vector3( 0.5f, 0.5f, 0.0f ), Quaternion.identity, new Vector3( 0.5f, -0.5f, 1.0f ) );
            Matrix4x4 worldToTexture = projToTexture * hdCamera.viewProjMatrix;
            if( ShaderConfig.s_CameraRelativeRendering != 0 )
            {
                worldToTexture = worldToTexture * Matrix4x4.Translate( -cameraWorldPosition );
            }

            cmd.SetGlobalTexture( HDShaderIDs._DeformationTexture, mDeformationTarget );
            cmd.SetGlobalMatrix( HDShaderIDs._DeformationWorldToTextureMatrix, worldToTexture );
            cmd.SetGlobalFloat( HDShaderIDs._DeformationMaxDepth, hdCamera.camera.farClipPlane );

            int tileSize = 16; // Must match TelltaleContactShadow.compute
            int numTilesX = ( kTextureSize + tileSize - 1 ) / tileSize;
            int numTilesY = ( kTextureSize + tileSize - 1 ) / tileSize;

            cmd.SetComputeIntParams( mResources.deformationAccumulateComputeShader,
                HDShaderIDs._DeformationTexelOffset,
                -(int)deltaTexelPosition.z, -(int)deltaTexelPosition.x );

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

        private RenderPipelineResources mResources;
        private int mDeformationAccumulateKernel = -1;
        
        private RTHandleSystem.RTHandle mDeformationDepth;
        private RTHandleSystem.RTHandle mDeformationTarget;
        private Vector3 mPrevCameraPosition;
    }
}
