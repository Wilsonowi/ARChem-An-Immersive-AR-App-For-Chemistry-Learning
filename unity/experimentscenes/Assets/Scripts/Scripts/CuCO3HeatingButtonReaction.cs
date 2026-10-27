using System.Collections;
using UnityEngine;
using UnityEngine.Events;

// Runs the carbonate heating reaction over a fixed total duration, split into
// equal stages (default: 3 stages x 10s = 30s total). The carbonate solid
// and limewater smoothly lerp through their configured colour stages,
// smoothly lerp within each stage, so the colour change is continuous and
// clearly visible rather than a single instant snap at the end.
public class CuCO3HeatingButtonReaction : MonoBehaviour
{
    public enum CarbonateSalt
    {
        SodiumCarbonate,
        CalciumCarbonate,
        CopperIICarbonate
    }

    public CarbonateSalt SelectedCarbonate { get; private set; }
    public bool ProducesCarbonDioxide { get { return producesCarbonDioxide; } }
    public bool IsRunning { get { return reactionRoutine != null; } }
    public float ReactionProgress { get; private set; }
    public float RemainingSeconds
    {
        get
        {
            float adjustedDuration = totalReactionDuration / Mathf.Max(heatIntensity, 0.01f);
            return Mathf.Max(0f, adjustedDuration * (1f - ReactionProgress));
        }
    }


    private bool producesCarbonDioxide = true;

    [Header("Scene Objects")]
    [SerializeField] private GameObject fire;
    [SerializeField] private Renderer[] testTubeContentRenderers; // Heated carbonate solid
    [SerializeField] private Renderer[] flaskContentRenderers;    // Limewater
    [SerializeField] private ParticleSystem gasBubbles;
    [Tooltip("Bubble emitters positioned inside the heated flask and the limewater test tube.")]
    [SerializeField] private ParticleSystem[] limewaterBubbleEffects;

    [SerializeField] private ParticleSystem cloudyEffect;

    [Header("Timing")]
    [Tooltip("Total time for the whole reaction, start to finish.")]
    [SerializeField] private float totalReactionDuration = 30f;
    [Tooltip("Number of equal stages the total duration is split into (three 10-second stages across 30 seconds).")]
    [SerializeField] private int stageCount = 3;

    [Header("Heat Intensity (1 = normal speed, >1 = faster reaction)")]
    [Range(0.25f, 3f)]
    [SerializeField] private float heatIntensity = 1f;

    [Header("Florence Flask Colours (CuCO3 -> CuO), 4 stages")]
    [SerializeField] private Color[] testTubeStageColours = new Color[]
    {
        new Color(46f / 255f, 125f / 255f, 50f / 255f, 1f), // green (CuCO3)
        new Color(90f / 255f, 80f / 255f, 40f / 255f, 1f),  // transitioning
        new Color(50f / 255f, 45f / 255f, 40f / 255f, 1f),  // darkening
        new Color(20f / 255f, 20f / 255f, 20f / 255f, 1f)   // black (CuO)
    };

    [Header("Glass Test Tube Colours (clear limewater -> cloudy), 4 stages")]
    [SerializeField] private Color[] flaskStageColours = new Color[]
    {
        new Color(0.85f, 1f, 1f, 0.35f),      // clear
        new Color(0.90f, 0.95f, 0.92f, 0.50f), // slightly hazy
        new Color(0.93f, 0.93f, 0.90f, 0.65f), // more hazy
        new Color(0.95f, 0.95f, 0.90f, 0.78f)  // fully cloudy
    };

    [Header("Stage Events (for explanation UI, quizzes, audio, etc.)")]
    public UnityEvent OnReactionStarted;
    public UnityEvent OnGasStarted;         // fires at end of stage 1 (~10s)
    public UnityEvent OnBlackeningComplete; // fires at end of stage 2 (~20s)
    public UnityEvent OnCloudyComplete;     // fires at end of stage 3 (~30s) - reaction complete

    private bool hasStarted;
    private Coroutine reactionRoutine;

    private void Awake()
    {
        ResetReactionVisuals();
    }

    public void IgniteFireOnly()
    {
        SetFireActive(true);
    }

    public void SetHeatIntensity(float intensity)
    {
        heatIntensity = Mathf.Clamp(intensity, 0.25f, 3f);
    }

    public void StartReaction()
    {
        if (hasStarted) return;
        ReactionProgress = 0f;

        hasStarted = true;

        if (reactionRoutine != null)
        {
            StopCoroutine(reactionRoutine);
        }

        // Start the gas visuals immediately with the button press so the
        // learner gets instant feedback while the colour change develops.
        if (producesCarbonDioxide)
        {
            PlayParticles(gasBubbles);
            PlayParticles(limewaterBubbleEffects);
        }
        else
        {
            StopParticles(gasBubbles);
            StopParticles(limewaterBubbleEffects);
        }

        OnReactionStarted?.Invoke();
        reactionRoutine = StartCoroutine(RunReaction());
    }

    public void ResetReactionVisuals()
    {
        hasStarted = false;
        ReactionProgress = 0f;


        if (reactionRoutine != null)
        {
            StopCoroutine(reactionRoutine);
            reactionRoutine = null;
        }

        SetFireActive(false);
        StopParticles(gasBubbles);
        StopParticles(limewaterBubbleEffects);
        StopParticles(cloudyEffect);
        SetSolidRenderersColor(testTubeContentRenderers, testTubeStageColours[0]);
        SetRenderersColor(flaskContentRenderers, flaskStageColours[0]);
    }

    private IEnumerator RunReaction()
    {
        SetFireActive(true);
        float stageDuration = (totalReactionDuration / stageCount) / Mathf.Max(heatIntensity, 0.01f);

        for (int stage = 0; stage < stageCount; stage++)
        {
            float elapsed = 0f;
            Color testTubeFrom = testTubeStageColours[stage];
            Color testTubeTo = testTubeStageColours[stage + 1];
            Color flaskFrom = flaskStageColours[stage];
            Color flaskTo = flaskStageColours[stage + 1];

            while (elapsed < stageDuration)
            {
                elapsed += Time.deltaTime;
                float t = Mathf.Clamp01(elapsed / stageDuration);
                ReactionProgress = Mathf.Clamp01((stage + t) / stageCount);


                SetSolidRenderersColor(testTubeContentRenderers, Color.Lerp(testTubeFrom, testTubeTo, t));
                SetRenderersColor(flaskContentRenderers, Color.Lerp(flaskFrom, flaskTo, t));

                yield return null;
            }

            SetSolidRenderersColor(testTubeContentRenderers, testTubeTo);
            SetRenderersColor(flaskContentRenderers, flaskTo);

            if (stage == 0)
            {
                OnGasStarted?.Invoke();
            }
            else if (stage == 1)
            {
                OnBlackeningComplete?.Invoke();
            }
            else if (stage == 2)
            {
                if (producesCarbonDioxide)
                    PlayParticles(cloudyEffect);
                else
                    StopParticles(cloudyEffect);

                OnCloudyComplete?.Invoke();
            }
        }

        StopParticles(gasBubbles);
        StopParticles(limewaterBubbleEffects);
        ReactionProgress = 1f;
        reactionRoutine = null;
    }

    private void SetFireActive(bool active)
    {
        if (fire == null)
        {
            return;
        }

        fire.SetActive(active);

        ParticleSystem[] fireParticles = fire.GetComponentsInChildren<ParticleSystem>(true);
        foreach (ParticleSystem particle in fireParticles)
        {
            if (active)
            {
                particle.Play(true);
            }
            else
            {
                particle.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            }
        }

        AudioSource[] fireAudio = fire.GetComponentsInChildren<AudioSource>(true);
        foreach (AudioSource audioSource in fireAudio)
        {
            audioSource.enabled = active;
            if (active)
            {
                if (!audioSource.isPlaying) audioSource.Play();
            }
            else
            {
                audioSource.Stop();
            }
        }
    }

    private static void PlayParticles(ParticleSystem particles)
    {
        if (particles != null)
        {
            particles.gameObject.SetActive(true);
            particles.Play(true);
        }
    }

    private static void StopParticles(ParticleSystem particles)
    {
        if (particles != null)
        {
            particles.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            particles.gameObject.SetActive(false);
        }
    }

    private void SetRenderersColor(Renderer[] renderers, Color color)
    {
        if (renderers == null)
        {
            return;
        }

        foreach (Renderer renderer in renderers)
        {
            if (renderer == null)
            {
                continue;
            }

            // Use the renderer's current material instance every frame. This
            // matches the working Neutralisation experiment and avoids holding
            // a stale material reference after an Animator rebinds the model.
            Material material = renderer.material;
            material.color = color;

            if (material.HasProperty("_Color"))
                material.SetColor("_Color", color);

            if (material.HasProperty("_BaseColor"))
                material.SetColor("_BaseColor", color);

            // Liquid 4 ships with a fixed green emission colour. On Android
            // that glow remains visible even when its Albedo is changed to
            // brown or black, making every reaction stage look green. Disable
            // emission on this runtime instance so the Inspector stage colour
            // is the only colour controlling the liquid's appearance.
            if (material.HasProperty("_EmissionColor"))
            {
                material.SetColor("_EmissionColor", Color.black);
                material.DisableKeyword("_EMISSION");
            }
        }
    }

    private void SetSolidRenderersColor(Renderer[] renderers, Color color)
    {
        // Copper(II) carbonate and copper(II) oxide are solids. The original
        // Liquid 4 material was transparent and fully metallic, which reflected
        // the blue environment instead of showing the requested brown/black.
        color.a = 1f;
        SetRenderersColor(renderers, color);

        if (renderers == null)
            return;

        foreach (Renderer renderer in renderers)
        {
            if (renderer == null)
                continue;

            Material material = renderer.material;

            if (material.HasProperty("_Mode"))
                material.SetFloat("_Mode", 0f); // Standard shader: Opaque
            if (material.HasProperty("_SrcBlend"))
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
            if (material.HasProperty("_DstBlend"))
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
            if (material.HasProperty("_ZWrite"))
                material.SetInt("_ZWrite", 1);
            if (material.HasProperty("_Metallic"))
                material.SetFloat("_Metallic", 0f);
            if (material.HasProperty("_Glossiness"))
                material.SetFloat("_Glossiness", 0.12f);
            if (material.HasProperty("_SpecularHighlights"))
                material.SetFloat("_SpecularHighlights", 0f);
            if (material.HasProperty("_GlossyReflections"))
                material.SetFloat("_GlossyReflections", 0f);

            material.DisableKeyword("_ALPHATEST_ON");
            material.DisableKeyword("_ALPHABLEND_ON");
            material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
            material.renderQueue = -1;
        }
    }


    public void ConfigureCarbonate(CarbonateSalt carbonate)
    {
        // This scene now runs only the copper(II) carbonate experiment.
        // The two stage-colour arrays are intentionally left untouched so the
        // values chosen in the Inspector are the values used during heating.
        SelectedCarbonate = CarbonateSalt.CopperIICarbonate;
        producesCarbonDioxide = true;
        ResetReactionVisuals();
    }


    private static void PlayParticles(ParticleSystem[] particleEffects)
    {
        if (particleEffects == null)
            return;

        foreach (ParticleSystem particles in particleEffects)
            PlayParticles(particles);
    }

    private static void StopParticles(ParticleSystem[] particleEffects)
    {
        if (particleEffects == null)
            return;

        foreach (ParticleSystem particles in particleEffects)
            StopParticles(particles);
    }
}
