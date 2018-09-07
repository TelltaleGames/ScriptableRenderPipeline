using System;
using System.Collections.Generic;
using UnityEngine.Experimental.Rendering.HDPipeline.Internal;
using UnityEngine.Rendering;
using UnityEngine.Rendering.PostProcessing;

namespace UnityEngine.Experimental.Rendering.HDPipeline
{
    public class NPRLightCache
    {
        public void Release()
        {
            CoreUtils.Destroy( mTexture );
            mTexture = null;
        }

        public void NewFrame()
        {
            if( mTexture == null )
            {
                mTexture = new Texture2D( kTextureSize, kCurveCapacity, TextureFormat.RGBAFloat, false );
            }

            mCurveCount = 0;
        }

        public void SubmitFrame( CommandBuffer cmd )
        {
            mTexture.LoadRawTextureData( mTextureData );
            mTexture.Apply();

            cmd.SetGlobalTexture( HDShaderIDs._NPRLightCurveTexture, mTexture );
        }

        public unsafe float AddLight( Color lightColor, NPRLightProfile profile )
        {
            int curveIndex = mCurveCount++;
            int nprCurveOffset = curveIndex * 4 * kTextureSize;

            float gray = lightColor.grayscale;
            fixed ( byte* pLightCurvePointer = &mTextureData[0] )
            {
                float* pNPRLightCurveCacheData = (float*)pLightCurvePointer;
                for( int i = 0; i < kTextureSize; ++i )
                {
                    float t = (float)i / (float)kTextureSize;
                    float intensity = Mathf.Clamp( ( profile != null ) ? profile.IntensityCurve.Evaluate( t ) : t, 0.0f, 0.99f );
                    float opacity = ( profile != null ) ? Mathf.Clamp( profile.OpacityCurve.Evaluate( t ), 0.0f, 1.0f ) : 0.0f;
                    float saturation = ( profile != null ) ? profile.SaturationCurve.Evaluate( t ) : 1.0f;
                    float tonemapIntensity = intensity / ( 1.0f - intensity );

                    float r = gray + saturation * ( lightColor.r - gray );
                    float g = gray + saturation * ( lightColor.g - gray );
                    float b = gray + saturation * ( lightColor.b - gray );

                    pNPRLightCurveCacheData[nprCurveOffset++] = tonemapIntensity * r;
                    pNPRLightCurveCacheData[nprCurveOffset++] = tonemapIntensity * g;
                    pNPRLightCurveCacheData[nprCurveOffset++] = tonemapIntensity * b;
                    pNPRLightCurveCacheData[nprCurveOffset++] = opacity;
                }
            }

            return ( (float)curveIndex + 0.5f ) / (float)kCurveCapacity;
        }

        private static readonly int kTextureSize = 1024;
        private static readonly int kCurveCapacity = 256;
        private Texture2D mTexture;
        private byte[] mTextureData = new byte[kTextureSize * kCurveCapacity * 16];
        private int mCurveCount = 0;
    }
}
