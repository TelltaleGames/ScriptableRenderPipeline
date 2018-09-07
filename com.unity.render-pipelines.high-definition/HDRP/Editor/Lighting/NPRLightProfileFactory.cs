using System.IO;
using UnityEditor.ProjectWindowCallback;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
    public class NPRLightProfileFactory
    {
        [MenuItem( "Assets/Create/NPR Light Profile", priority = 201 )]
        static void CreateProfile()
        {
            ProjectWindowUtil.StartNameEditingIfProjectWindowExists( 0, ScriptableObject.CreateInstance<DoCreateNPRLightProfile>(),
                "New NPR Lioght Profile.asset", null, null );
        }

        public static NPRLightProfile CreateProfileAtPath( string path )
        {
            var profile = ScriptableObject.CreateInstance<NPRLightProfile>();
            profile.name = Path.GetFileName( path );
            AssetDatabase.CreateAsset( profile, path );
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            return profile;
        }

        public static NPRLightProfile CreateProfile( Scene scene, string targetName )
        {
            var path = string.Empty;

            if( string.IsNullOrEmpty( scene.path ) )
            {
                path = "Assets/";
            }
            else
            {
                var scenePath = Path.GetDirectoryName( scene.path );
                var extPath = scene.name + "_Profiles";
                var profilePath = scenePath + "/" + extPath;

                if( !AssetDatabase.IsValidFolder( profilePath ) )
                    AssetDatabase.CreateFolder( scenePath, extPath );

                path = profilePath + "/";
            }

            path += targetName + " NPRProfile.asset";
            path = AssetDatabase.GenerateUniqueAssetPath( path );

            var profile = ScriptableObject.CreateInstance<NPRLightProfile>();
            AssetDatabase.CreateAsset( profile, path );
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            return profile;
        }
    }

    class DoCreateNPRLightProfile : EndNameEditAction
    {
        public override void Action( int instanceId, string pathName, string resourceFile )
        {
            var profile = NPRLightProfileFactory.CreateProfileAtPath( pathName );
            ProjectWindowUtil.ShowCreatedAsset( profile );
        }
    }
}
