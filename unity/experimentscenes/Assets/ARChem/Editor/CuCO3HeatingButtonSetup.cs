using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.Events;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public static class CuCO3HeatingButtonSetup
{
    private const string ScenePath = "Assets/Scenes/CuCO3_Heating.unity";

    [MenuItem("ARChem/Setup CuCO3 Button Reaction")]
    public static void Setup()
    {
        Scene scene = EditorSceneManager.GetActiveScene();
        if (scene.path != ScenePath)
        {
            scene = EditorSceneManager.OpenScene(ScenePath, OpenSceneMode.Single);
        }

        GameObject controllerObject = FindSceneObject("CuCO3_ButtonReactionController") ?? new GameObject("CuCO3_ButtonReactionController");
        CuCO3HeatingButtonReaction reaction = controllerObject.GetComponent<CuCO3HeatingButtonReaction>();
        if (reaction == null)
        {
            reaction = controllerObject.AddComponent<CuCO3HeatingButtonReaction>();
        }

        GameObject fire = FindSceneObject("Fire");
        ParticleSystem gasBubbles = FindParticleSystem("GasBubbles");
        ParticleSystem cloudyEffect = FindParticleSystem("SecondaryEffect");

        SerializedObject serialized = new SerializedObject(reaction);
        serialized.FindProperty("fire").objectReferenceValue = fire;
        AssignRendererArray(serialized.FindProperty("testTube1ContentRenderers"), FindContentRenderers("TestTube1"));
        AssignRendererArray(serialized.FindProperty("testTube2ContentRenderers"), FindContentRenderers("TestTube2"));
        serialized.FindProperty("gasBubbles").objectReferenceValue = gasBubbles;
        serialized.FindProperty("cloudyEffect").objectReferenceValue = cloudyEffect;
        serialized.FindProperty("gasDelay").floatValue = 0.5f;
        serialized.FindProperty("blackeningDelay").floatValue = 3f;
        serialized.FindProperty("cloudyDelay").floatValue = 3.5f;
        serialized.ApplyModifiedPropertiesWithoutUndo();

        Button button = EnsureStartButton();
        button.onClick.RemoveAllListeners();
        UnityAction action = reaction.StartReaction;
        UnityEventTools.AddPersistentListener(button.onClick, action);

        if (fire != null)
        {
            fire.SetActive(false);
            EditorUtility.SetDirty(fire);
        }

        if (gasBubbles != null)
        {
            gasBubbles.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            EditorUtility.SetDirty(gasBubbles);
        }

        if (cloudyEffect != null)
        {
            cloudyEffect.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            EditorUtility.SetDirty(cloudyEffect);
        }

        EditorUtility.SetDirty(button);
        EditorUtility.SetDirty(reaction);
        EditorSceneManager.MarkSceneDirty(scene);
        EditorSceneManager.SaveScene(scene);
        AssetDatabase.SaveAssets();

        Debug.Log("CuCO3 Heating button reaction is wired: button shows fire, starts gas bubbles, blackens tube 1, and clouds tube 2.");
    }

    private static GameObject FindSceneObject(string objectName)
    {
        return FindObjectsIncludingInactive().FirstOrDefault(go => go.name == objectName);
    }

    private static ParticleSystem FindParticleSystem(string objectName)
    {
        GameObject found = FindSceneObject(objectName);
        return found == null ? null : found.GetComponent<ParticleSystem>();
    }

    private static Renderer[] FindContentRenderers(string tubeName)
    {
        List<Renderer> renderers = new List<Renderer>();
        foreach (GameObject candidate in FindObjectsIncludingInactive().Where(go => go.name == "TestTubeContent"))
        {
            Transform parent = candidate.transform.parent;
            if (parent != null && parent.name == tubeName)
            {
                renderers.AddRange(candidate.GetComponentsInChildren<Renderer>(true));
            }
        }

        return renderers.ToArray();
    }

    private static IEnumerable<GameObject> FindObjectsIncludingInactive()
    {
        return Resources.FindObjectsOfTypeAll<GameObject>()
            .Where(go => go.scene.IsValid() && go.scene == SceneManager.GetActiveScene());
    }

    private static void AssignRendererArray(SerializedProperty property, Renderer[] renderers)
    {
        property.arraySize = renderers.Length;
        for (int index = 0; index < renderers.Length; index++)
        {
            property.GetArrayElementAtIndex(index).objectReferenceValue = renderers[index];
        }
    }

    private static Button EnsureStartButton()
    {
        Canvas canvas = Object.FindObjectOfType<Canvas>();
        if (canvas == null)
        {
            GameObject canvasObject = new GameObject("CuCO3_UI", typeof(RectTransform), typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
            canvas = canvasObject.GetComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;

            CanvasScaler scaler = canvasObject.GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1080f, 1920f);
        }

        GameObject buttonObject = FindSceneObject("StartReactionButton");
        if (buttonObject == null)
        {
            buttonObject = new GameObject("StartReactionButton", typeof(RectTransform), typeof(Image), typeof(Button));
            buttonObject.transform.SetParent(canvas.transform, false);
        }

        RectTransform rect = buttonObject.GetComponent<RectTransform>();
        rect.anchorMin = new Vector2(0.5f, 0f);
        rect.anchorMax = new Vector2(0.5f, 0f);
        rect.pivot = new Vector2(0.5f, 0f);
        rect.anchoredPosition = new Vector2(0f, 80f);
        rect.sizeDelta = new Vector2(360f, 96f);

        Image image = buttonObject.GetComponent<Image>();
        image.color = new Color(1f, 0.46f, 0.12f, 0.92f);

        Button button = buttonObject.GetComponent<Button>();
        ColorBlock colors = button.colors;
        colors.normalColor = image.color;
        colors.highlightedColor = new Color(1f, 0.58f, 0.2f, 0.95f);
        colors.pressedColor = new Color(0.85f, 0.28f, 0.05f, 1f);
        button.colors = colors;

        Text label = buttonObject.GetComponentInChildren<Text>();
        if (label == null)
        {
            GameObject labelObject = new GameObject("Label", typeof(RectTransform), typeof(Text));
            labelObject.transform.SetParent(buttonObject.transform, false);
            label = labelObject.GetComponent<Text>();
        }

        RectTransform labelRect = label.GetComponent<RectTransform>();
        labelRect.anchorMin = Vector2.zero;
        labelRect.anchorMax = Vector2.one;
        labelRect.offsetMin = Vector2.zero;
        labelRect.offsetMax = Vector2.zero;
        label.text = "Start Heating";
        label.alignment = TextAnchor.MiddleCenter;
        label.color = Color.white;
        label.fontSize = 32;
        label.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");

        return button;
    }
}
