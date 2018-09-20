using System;

namespace UnityEngine.Experimental.Rendering
{
    [Flags]
    public enum RenderingLayer
    {
        None = 0,
        Default = ( 1 << 0 ),
        Deformation = ( 1 << 1 ),
    }

    [ExecuteInEditMode]
    public class RenderLayerManager : MonoBehaviour
    {
        public RenderingLayer RenderingLayer = RenderingLayer.Default;

        void Awake()
        {
            UpdateRenderLayer();
        }

        public void UpdateRenderLayer()
        {
            uint mask = (uint)RenderingLayer;

            Renderer[] childRenderers = gameObject.GetComponentsInChildren<Renderer>();
            foreach( Renderer renderer in childRenderers )
            {
                renderer.renderingLayerMask = mask;
            }
        }
    }
}
