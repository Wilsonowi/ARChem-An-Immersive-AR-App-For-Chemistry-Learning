using UnityEngine;
using UnityEngine.SceneManagement;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class SceneSwitcher : MonoBehaviour
{
    public void LoadScene(string sceneName)
    {
        Debug.Log($"SceneSwitcher requested to load scene: {sceneName}");

        if (string.IsNullOrWhiteSpace(sceneName))
        {
            Debug.LogError("SceneSwitcher: Scene name was empty.");
            return;
        }

        if (!IsSceneInBuildSettings(sceneName))
        {
            Debug.LogError($"SceneSwitcher: Scene '{sceneName}' is not present in build settings.");
            return;
        }

        SceneManager.LoadScene(sceneName);
    }

    private static bool IsSceneInBuildSettings(string sceneName)
    {
#if UNITY_EDITOR
        foreach (var scene in EditorBuildSettings.scenes)
        {
            if (scene == null)
            {
                continue;
            }

            string builtSceneName = System.IO.Path.GetFileNameWithoutExtension(scene.path);
            if (string.Equals(builtSceneName, sceneName, System.StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }
#else
        for (int i = 0; i < SceneManager.sceneCountInBuildSettings; i++)
        {
            string scenePath = SceneUtility.GetScenePathByBuildIndex(i);
            string builtSceneName = System.IO.Path.GetFileNameWithoutExtension(scenePath);
            if (string.Equals(builtSceneName, sceneName, System.StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }
#endif

        return false;
    }
}
