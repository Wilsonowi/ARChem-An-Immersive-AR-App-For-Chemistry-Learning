using System.Collections.Generic;
using TMPro;
using UnityEditor;
using UnityEditor.Animations;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using Vuforia;

public static class ARChemSceneBuilder
{
    private const string Root = "Assets/ARChem";
    private const string ScenesPath = Root + "/Scenes";
    private const string MaterialsPath = Root + "/Materials";
    private const string PrefabsPath = Root + "/Prefabs";
    private const string AnimationsPath = Root + "/Animations";
    private const string TriggerName = "StartReaction";

    private static readonly Dictionary<string, Material> Materials = new Dictionary<string, Material>();

    [MenuItem("ARChem/Build AR Chemistry Scenes")]
    public static void BuildAllScenes()
    {
        EnsureFolders();
        CreateMaterials();

        BuildCuCO3Scene();
        BuildNH4ClScene();
        BuildPbI2Scene();
        UpdateBuildSettings();

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("ARChem scenes, materials, animations, prefabs, and build scene list generated.");
    }

    private static void EnsureFolders()
    {
        EnsureFolder("Assets", "ARChem");
        EnsureFolder(Root, "Scenes");
        EnsureFolder(Root, "Scripts");
        EnsureFolder(Root, "Materials");
        EnsureFolder(Root, "Prefabs");
        EnsureFolder(Root, "Animations");
        EnsureFolder(Root, "Editor");
    }

    private static void EnsureFolder(string parent, string child)
    {
        string path = parent + "/" + child;
        if (!AssetDatabase.IsValidFolder(path))
        {
            AssetDatabase.CreateFolder(parent, child);
        }
    }

    private static void CreateMaterials()
    {
        Materials["CuCO3_Green"] = CreateMaterial("CuCO3_Green", ColorFromRgb(46, 125, 50), false, "Standard");
        Materials["CuO_Black"] = CreateMaterial("CuO_Black", ColorFromRgb(20, 20, 20), false, "Standard");
        Materials["PbI2_Clear"] = CreateMaterial("PbI2_Clear", new Color(1f, 1f, 1f, 0.3f), true, "Standard");
        Materials["PbI2_Yellow"] = CreateMaterial("PbI2_Yellow", new Color(1f, 215f / 255f, 0f, 0.85f), true, "Standard");
        Materials["GasParticle"] = CreateMaterial("GasParticle", new Color(1f, 1f, 1f, 0.75f), true, "Particles/Standard Unlit");
        Materials["PrecipParticle"] = CreateMaterial("PrecipParticle", new Color(1f, 215f / 255f, 0f, 0.9f), true, "Particles/Standard Unlit");

        Materials["Glass_Clear"] = CreateMaterial("Glass_Clear", new Color(0.8f, 0.95f, 1f, 0.25f), true, "Standard");
        Materials["Limewater_Clear"] = CreateMaterial("Limewater_Clear", new Color(0.85f, 1f, 1f, 0.35f), true, "Standard");
        Materials["Cloudy_White"] = CreateMaterial("Cloudy_White", new Color(1f, 1f, 1f, 0.82f), true, "Particles/Standard Unlit");
    }

    private static Material CreateMaterial(string name, Color color, bool transparent, string preferredShader)
    {
        string path = MaterialsPath + "/" + name + ".mat";
        Material material = AssetDatabase.LoadAssetAtPath<Material>(path);
        Shader shader = Shader.Find(preferredShader) ?? Shader.Find("Standard");

        if (material == null)
        {
            material = new Material(shader);
            AssetDatabase.CreateAsset(material, path);
        }
        else
        {
            material.shader = shader;
        }

        material.color = color;
        if (material.HasProperty("_BaseColor"))
        {
            material.SetColor("_BaseColor", color);
        }

        if (transparent)
        {
            material.SetOverrideTag("RenderType", "Transparent");
            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
            material.SetInt("_ZWrite", 0);
            material.EnableKeyword("_ALPHABLEND_ON");
            material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
            if (material.HasProperty("_Mode"))
            {
                material.SetFloat("_Mode", 3f);
            }
        }
        else
        {
            material.SetOverrideTag("RenderType", "Opaque");
            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
            material.SetInt("_ZWrite", 1);
            material.DisableKeyword("_ALPHABLEND_ON");
            material.renderQueue = -1;
            if (material.HasProperty("_Mode"))
            {
                material.SetFloat("_Mode", 0f);
            }
        }

        EditorUtility.SetDirty(material);
        return material;
    }

    private static void BuildCuCO3Scene()
    {
        Scene scene = CreateBaseScene("CuCO3_Heating");
        GameObject imageTarget = CreateImageTarget();
        GameObject rig = CreateRig(imageTarget.transform);

        GameObject tubeA = CreateCylinder("TestTube_CuCO3", rig.transform, new Vector3(-0.35f, 0.24f, 0f), new Vector3(0.16f, 0.62f, 0.16f), Materials["Glass_Clear"]);
        tubeA.transform.rotation = Quaternion.Euler(0f, 0f, -12f);
        GameObject powder = CreateCylinder("Powder", tubeA.transform, new Vector3(0f, -0.36f, 0f), new Vector3(0.12f, 0.08f, 0.12f), Materials["CuCO3_Green"]);

        GameObject tubeB = CreateCylinder("TestTube_Limewater", rig.transform, new Vector3(0.45f, 0.2f, 0f), new Vector3(0.16f, 0.55f, 0.16f), Materials["Glass_Clear"]);
        GameObject limewater = CreateCylinder("Limewater", tubeB.transform, new Vector3(0f, -0.2f, 0f), new Vector3(0.13f, 0.24f, 0.13f), Materials["Limewater_Clear"]);
        limewater.transform.localPosition = new Vector3(0f, -0.21f, 0f);

        CreateTubeBetween("DeliveryTube", rig.transform, new Vector3(-0.2f, 0.47f, 0f), new Vector3(0.33f, 0.39f, 0f), 0.018f, Materials["Glass_Clear"]);
        ParticleSystem gas = CreateParticleSystem("GasBubbles", rig.transform, new Vector3(0.35f, 0.3f, 0f), ColorFromRgb(220, 245, 255), true, 15f, 1.2f, 0.16f, 0.35f, 0f, Materials["GasParticle"]);
        ParticleSystem cloudy = CreateParticleSystem("SecondaryEffect", tubeB.transform, new Vector3(0f, -0.12f, 0f), Color.white, true, 28f, 0.8f, 0.08f, 0.08f, 0f, Materials["Cloudy_White"]);
        cloudy.gameObject.name = "SecondaryEffect";

        EquationTextReveal equation = CreateEquationText(rig.transform, "CuCO3(s) -> CuO(s) + CO2(g)");
        AnimationClip clip = CreateCuCO3Clip(rig.transform, powder.transform);
        Animator animator = CreateAnimator(rig, "CuCO3_Decompose", clip);
        ConfigureController(rig, animator, gas, cloudy, 1.5f, equation, 2.4f);

        SaveRigPrefab(rig, "CuCO3_Heating_ReactionRig");
        EditorSceneManager.SaveScene(scene, ScenesPath + "/CuCO3_Heating.unity");
    }

    private static void BuildNH4ClScene()
    {
        Scene scene = CreateBaseScene("NH4Cl_Formation");
        GameObject imageTarget = CreateImageTarget();
        GameObject rig = CreateRig(imageTarget.transform);

        GameObject tubeA = CreateCylinder("TestTube_HCl", rig.transform, new Vector3(-0.36f, 0.22f, 0f), new Vector3(0.15f, 0.58f, 0.15f), Materials["Glass_Clear"]);
        tubeA.transform.rotation = Quaternion.Euler(0f, 0f, 88f);
        GameObject tubeB = CreateCylinder("TestTube_NH3", rig.transform, new Vector3(0.36f, 0.22f, 0f), new Vector3(0.15f, 0.58f, 0.15f), Materials["Glass_Clear"]);
        tubeB.transform.rotation = Quaternion.Euler(0f, 0f, -88f);

        ParticleSystem streamA = CreateParticleSystem("GasBubbles", rig.transform, new Vector3(-0.22f, 0.22f, 0f), new Color(1f, 1f, 1f, 0.22f), true, 12f, 1f, 0.03f, 0.25f, 0f, Materials["GasParticle"]);
        streamA.transform.rotation = Quaternion.Euler(0f, 90f, 0f);
        ParticleSystem streamB = CreateParticleSystem("GasStreamB", streamA.transform, new Vector3(0.44f, 0f, 0f), new Color(1f, 1f, 1f, 0.22f), true, 12f, 1f, 0.03f, 0.25f, 0f, Materials["GasParticle"]);
        streamB.transform.rotation = Quaternion.Euler(0f, 180f, 0f);

        ParticleSystem fume = CreateParticleSystem("SecondaryEffect", rig.transform, new Vector3(0f, 0.22f, 0f), Color.white, false, 0f, 0.9f, 0.2f, 0.1f, 0f, Materials["Cloudy_White"]);
        AddBurst(fume, 70, 0.05f);

        EquationTextReveal equation = CreateEquationText(rig.transform, "HCl(g) + NH3(g) -> NH4Cl(s)");
        Animator animator = CreateAnimator(rig, "NH4Cl_Idle", null);
        ConfigureController(rig, animator, streamA, fume, 0.8f, equation, 1.7f);

        SaveRigPrefab(rig, "NH4Cl_Formation_ReactionRig");
        EditorSceneManager.SaveScene(scene, ScenesPath + "/NH4Cl_Formation.unity");
    }

    private static void BuildPbI2Scene()
    {
        Scene scene = CreateBaseScene("PbI2_Precipitation");
        GameObject imageTarget = CreateImageTarget();
        GameObject rig = CreateRig(imageTarget.transform);

        GameObject beaker = CreateCylinder("MainBeaker", rig.transform, new Vector3(0f, 0.18f, 0f), new Vector3(0.38f, 0.42f, 0.38f), Materials["Glass_Clear"]);
        GameObject liquid = CreateCylinder("Liquid", beaker.transform, new Vector3(0f, -0.12f, 0f), new Vector3(0.34f, 0.22f, 0.34f), Materials["PbI2_Clear"]);
        GameObject pour = CreateCylinder("PouringLiquid", rig.transform, new Vector3(-0.36f, 0.58f, 0f), new Vector3(0.08f, 0.34f, 0.08f), Materials["PbI2_Clear"]);
        pour.transform.rotation = Quaternion.Euler(0f, 0f, -42f);

        ParticleSystem settling = CreateParticleSystem("SecondaryEffect", liquid.transform, new Vector3(0f, 0.08f, 0f), ColorFromRgb(255, 215, 0), true, 32f, 1.4f, 0.015f, 0.02f, 0.3f, Materials["PrecipParticle"]);

        EquationTextReveal equation = CreateEquationText(rig.transform, "Pb(NO3)2(aq) + 2KI(aq) -> PbI2(s) + 2KNO3(aq)");
        AnimationClip clip = CreatePbI2Clip(rig.transform, liquid.transform, pour.transform);
        Animator animator = CreateAnimator(rig, "PbI2_Pour", clip);
        ConfigureController(rig, animator, null, settling, 1f, equation, 2.2f);

        SaveRigPrefab(rig, "PbI2_Precipitation_ReactionRig");
        EditorSceneManager.SaveScene(scene, ScenesPath + "/PbI2_Precipitation.unity");
    }

    private static Scene CreateBaseScene(string name)
    {
        Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        scene.name = name;

        GameObject camera = new GameObject("AR Camera");
        Camera cameraComponent = camera.AddComponent<Camera>();
        cameraComponent.clearFlags = CameraClearFlags.SolidColor;
        cameraComponent.backgroundColor = new Color(0.04f, 0.04f, 0.05f);
        camera.AddComponent<AudioListener>();
        camera.AddComponent<VuforiaBehaviour>();
        camera.transform.position = new Vector3(0f, 1.1f, -2.2f);
        camera.transform.LookAt(Vector3.zero);

        GameObject light = new GameObject("Directional Light");
        Light lightComponent = light.AddComponent<Light>();
        lightComponent.type = LightType.Directional;
        lightComponent.intensity = 1.1f;
        light.transform.rotation = Quaternion.Euler(50f, -35f, 0f);

        GameObject loader = new GameObject("SceneLoader");
        loader.AddComponent<FlutterBridge>();

        return scene;
    }

    private static GameObject CreateImageTarget()
    {
        GameObject target = new GameObject("ImageTarget");
        ImageTargetBehaviour imageTarget = target.AddComponent<ImageTargetBehaviour>();
        imageTarget.SetWidth(1f);
        imageTarget.SetHeight(0.7f);
        // TODO: Assign Image Target Database in Inspector.
        return target;
    }

    private static GameObject CreateRig(Transform parent)
    {
        GameObject rig = new GameObject("ReactionRig");
        rig.transform.SetParent(parent, false);
        rig.transform.localPosition = Vector3.zero;
        rig.transform.localRotation = Quaternion.identity;
        rig.transform.localScale = Vector3.one;
        rig.AddComponent<ReactionController>();
        return rig;
    }

    private static GameObject CreateCylinder(string name, Transform parent, Vector3 localPosition, Vector3 localScale, Material material)
    {
        GameObject obj = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        obj.name = name;
        obj.transform.SetParent(parent, false);
        obj.transform.localPosition = localPosition;
        obj.transform.localScale = localScale;
        Renderer renderer = obj.GetComponent<Renderer>();
        renderer.sharedMaterial = material;
        return obj;
    }

    private static GameObject CreateTubeBetween(string name, Transform parent, Vector3 start, Vector3 end, float radius, Material material)
    {
        Vector3 direction = end - start;
        GameObject tube = CreateCylinder(name, parent, (start + end) * 0.5f, new Vector3(radius, direction.magnitude * 0.5f, radius), material);
        tube.transform.localRotation = Quaternion.FromToRotation(Vector3.up, direction.normalized);
        return tube;
    }

    private static ParticleSystem CreateParticleSystem(string name, Transform parent, Vector3 localPosition, Color color, bool looping, float rate, float lifetime, float startSize, float speed, float gravity, Material material)
    {
        GameObject obj = new GameObject(name);
        obj.transform.SetParent(parent, false);
        obj.transform.localPosition = localPosition;
        ParticleSystem particles = obj.AddComponent<ParticleSystem>();

        ParticleSystem.MainModule main = particles.main;
        main.playOnAwake = false;
        main.loop = looping;
        main.startLifetime = lifetime;
        main.startSpeed = speed;
        main.startSize = startSize;
        main.startColor = color;
        main.gravityModifier = gravity;
        main.simulationSpace = ParticleSystemSimulationSpace.Local;

        ParticleSystem.EmissionModule emission = particles.emission;
        emission.rateOverTime = rate;
        emission.enabled = true;

        ParticleSystem.ShapeModule shape = particles.shape;
        shape.shapeType = ParticleSystemShapeType.Cone;
        shape.angle = 18f;
        shape.radius = 0.05f;

        ParticleSystemRenderer renderer = particles.GetComponent<ParticleSystemRenderer>();
        renderer.sharedMaterial = material;
        renderer.renderMode = ParticleSystemRenderMode.Billboard;

        return particles;
    }

    private static void AddBurst(ParticleSystem particles, short count, float time)
    {
        ParticleSystem.EmissionModule emission = particles.emission;
        emission.rateOverTime = 0f;
        emission.SetBursts(new[] { new ParticleSystem.Burst(time, count) });
    }

    private static EquationTextReveal CreateEquationText(Transform parent, string equation)
    {
        GameObject obj = new GameObject("EquationText");
        obj.transform.SetParent(parent, false);
        obj.transform.localPosition = new Vector3(0f, -0.42f, 0f);
        obj.transform.localRotation = Quaternion.Euler(70f, 0f, 0f);
        obj.transform.localScale = Vector3.one * 0.08f;

        TextMeshPro text = obj.AddComponent<TextMeshPro>();
        text.text = equation;
        text.alignment = TextAlignmentOptions.Center;
        text.fontSize = 4.8f;
        text.color = new Color(1f, 1f, 1f, 0f);
        text.enableWordWrapping = false;
        text.rectTransform.sizeDelta = new Vector2(12f, 1.2f);

        EquationTextReveal reveal = obj.AddComponent<EquationTextReveal>();
        SerializedObject serialized = new SerializedObject(reveal);
        serialized.FindProperty("equationText").objectReferenceValue = text;
        serialized.FindProperty("fadeDuration").floatValue = 1.25f;
        serialized.ApplyModifiedPropertiesWithoutUndo();
        return reveal;
    }

    private static AnimationClip CreateCuCO3Clip(Transform rig, Transform powder)
    {
        string path = AnimationsPath + "/CuCO3_Decompose.anim";
        AnimationClip clip = new AnimationClip { frameRate = 30f };
        string powderPath = AnimationUtility.CalculateTransformPath(powder, rig);
        EditorCurveBinding binding = EditorCurveBinding.PPtrCurve(powderPath, typeof(MeshRenderer), "m_Materials.Array.data[0]");
        ObjectReferenceKeyframe[] keys =
        {
            new ObjectReferenceKeyframe { time = 0f, value = Materials["CuCO3_Green"] },
            new ObjectReferenceKeyframe { time = 2f, value = Materials["CuO_Black"] }
        };
        AnimationUtility.SetObjectReferenceCurve(clip, binding, keys);
        SaveClip(clip, path);
        return clip;
    }

    private static AnimationClip CreatePbI2Clip(Transform rig, Transform liquid, Transform pour)
    {
        string path = AnimationsPath + "/PbI2_Pour.anim";
        AnimationClip clip = new AnimationClip { frameRate = 30f };
        string pourPath = AnimationUtility.CalculateTransformPath(pour, rig);
        string liquidPath = AnimationUtility.CalculateTransformPath(liquid, rig);

        AnimationCurve tilt = AnimationCurve.EaseInOut(0f, -42f, 1.5f, -78f);
        AnimationCurve shrink = AnimationCurve.EaseInOut(0f, pour.localScale.y, 1.5f, 0.05f);
        AnimationUtility.SetEditorCurve(clip, EditorCurveBinding.FloatCurve(pourPath, typeof(Transform), "localEulerAnglesRaw.z"), tilt);
        AnimationUtility.SetEditorCurve(clip, EditorCurveBinding.FloatCurve(pourPath, typeof(Transform), "m_LocalScale.y"), shrink);

        EditorCurveBinding materialBinding = EditorCurveBinding.PPtrCurve(liquidPath, typeof(MeshRenderer), "m_Materials.Array.data[0]");
        ObjectReferenceKeyframe[] materialKeys =
        {
            new ObjectReferenceKeyframe { time = 0f, value = Materials["PbI2_Clear"] },
            new ObjectReferenceKeyframe { time = 1.5f, value = Materials["PbI2_Yellow"] }
        };
        AnimationUtility.SetObjectReferenceCurve(clip, materialBinding, materialKeys);
        SaveClip(clip, path);
        return clip;
    }

    private static void SaveClip(AnimationClip clip, string path)
    {
        AnimationClip existing = AssetDatabase.LoadAssetAtPath<AnimationClip>(path);
        if (existing == null)
        {
            AssetDatabase.CreateAsset(clip, path);
        }
        else
        {
            EditorUtility.CopySerialized(clip, existing);
            EditorUtility.SetDirty(existing);
        }
    }

    private static Animator CreateAnimator(GameObject rig, string stateName, AnimationClip clip)
    {
        Animator animator = rig.AddComponent<Animator>();
        string controllerPath = AnimationsPath + "/" + stateName + ".controller";
        AnimatorController controller = AssetDatabase.LoadAssetAtPath<AnimatorController>(controllerPath);
        if (controller == null)
        {
            controller = AnimatorController.CreateAnimatorControllerAtPath(controllerPath);
        }

        controller.parameters = new AnimatorControllerParameter[0];
        controller.AddParameter(TriggerName, AnimatorControllerParameterType.Trigger);

        AnimatorStateMachine stateMachine = controller.layers[0].stateMachine;
        foreach (ChildAnimatorState child in stateMachine.states)
        {
            stateMachine.RemoveState(child.state);
        }

        AnimatorState idle = stateMachine.AddState("Idle");
        stateMachine.defaultState = idle;

        AnimatorState reaction = stateMachine.AddState(clip == null ? "Reaction" : stateName.Replace('_', ' '));
        reaction.motion = clip;
        AnimatorStateTransition transition = idle.AddTransition(reaction);
        transition.hasExitTime = false;
        transition.duration = 0f;
        transition.AddCondition(AnimatorConditionMode.If, 0f, TriggerName);

        EditorUtility.SetDirty(controller);
        animator.runtimeAnimatorController = controller;
        return animator;
    }

    private static void ConfigureController(GameObject rig, Animator animator, ParticleSystem gas, ParticleSystem secondary, float secondaryDelay, EquationTextReveal equation, float equationDelay)
    {
        ReactionController controller = rig.GetComponent<ReactionController>();
        SerializedObject serialized = new SerializedObject(controller);
        serialized.FindProperty("reactionAnimator").objectReferenceValue = animator;
        serialized.FindProperty("animationTriggerName").stringValue = TriggerName;
        serialized.FindProperty("gasBubbles").objectReferenceValue = gas;
        serialized.FindProperty("secondaryEffect").objectReferenceValue = secondary;
        serialized.FindProperty("secondaryDelay").floatValue = secondaryDelay;
        serialized.FindProperty("equationText").objectReferenceValue = equation;
        serialized.FindProperty("equationDelay").floatValue = equationDelay;
        serialized.ApplyModifiedPropertiesWithoutUndo();
        EditorUtility.SetDirty(controller);
    }

    private static void SaveRigPrefab(GameObject rig, string name)
    {
        PrefabUtility.SaveAsPrefabAsset(rig, PrefabsPath + "/" + name + ".prefab");
    }

    private static void UpdateBuildSettings()
    {
        string[] paths =
        {
            ScenesPath + "/CuCO3_Heating.unity",
            ScenesPath + "/NH4Cl_Formation.unity",
            ScenesPath + "/PbI2_Precipitation.unity"
        };

        List<EditorBuildSettingsScene> scenes = new List<EditorBuildSettingsScene>();
        foreach (string path in paths)
        {
            scenes.Add(new EditorBuildSettingsScene(path, true));
        }

        EditorBuildSettings.scenes = scenes.ToArray();
    }

    private static Color ColorFromRgb(float r, float g, float b)
    {
        return new Color(r / 255f, g / 255f, b / 255f, 1f);
    }
}
