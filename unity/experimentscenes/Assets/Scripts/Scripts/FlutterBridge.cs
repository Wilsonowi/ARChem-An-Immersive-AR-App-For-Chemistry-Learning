using FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.SceneManagement;

public class FlutterBridge : MonoBehaviour
{
    public void LoadReaction(string sceneName)
    {
        if (string.IsNullOrWhiteSpace(sceneName))
        {
            Debug.LogWarning("Flutter requested a reaction scene with an empty name.");
            return;
        }

        SceneManager.LoadScene(sceneName);
    }

    public static void NotifyFlutterComplete()
    {
        if (UnityMessageManager.Instance == null)
        {
            Debug.LogWarning("UnityMessageManager.Instance is not available; reaction completion was not sent to Flutter.");
            return;
        }

        UnityMessageManager.Instance.SendMessageToFlutter("REACTION_COMPLETE");
    }
}
