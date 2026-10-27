using TMPro;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;

/// <summary>
/// Owns the complete, ordered interaction flow for the marker-based salt formation experiment.
/// Attach this component to the SaltFormation scene's ExperimentManager.
/// </summary>
public sealed class SaltFormationExperimentController : MonoBehaviour
{
    public enum ExperimentState
    {
        InitialOverview,

        WaitingForSpoon,
        SpoonPouring,
        WaitingForBeaker1,
        Filtering,
        WaitingForBeaker2,
        PouringIntoDish,
        MovingDishToHeat,
        WaitingForLighter,
        Heating,
        WaitingForCrystalTransfer,
        TransferringCrystals,
        WaitingForDrying,
        DryingAnimation,
        Complete
    }

    [Header("Buttons")]
    [SerializeField] private Button overviewContinueButton;

    [SerializeField] private Button spoonButton;
    [SerializeField] private Button beakerButton;
    [SerializeField] private Button beakerButton2;
    [SerializeField] private Button lighterButton;

    [SerializeField] private Button drySaltsButton;
    [SerializeField] private Button moveSaltCrystalsButton;
    [SerializeField] private Button retryButton;

    [Header("Optional UI")]
    [SerializeField] private TMP_Text instructionText;
    [SerializeField] private TMP_Text heatingProgressText;

    [Header("Experiment Panels")]
    [SerializeField] private GameObject initialOverviewPanel;
    [SerializeField] private GameObject modelLabels;

    [SerializeField] private GameObject spoonInstructionPanel;
    [SerializeField] private GameObject filtrationInstructionPanel;
    [SerializeField] private GameObject beaker2InstructionPanel;
    [SerializeField] private GameObject lighterInstructionPanel;
    [SerializeField] private GameObject heatingExplanationPanel;
    [SerializeField] private GameObject moveResidueInstructionPanel;
    [SerializeField] private GameObject dryingInstructionPanel;
    [FormerlySerializedAs("residuePanel")]
    [SerializeField] private GameObject finalExplanationPanel;

    [Header("Persistent Step Explanations")]
    [Tooltip("Parent of the five explanation panels. Direct children are revealed in hierarchy order.")]
    [SerializeField] private Transform extraExplanationContainer;
    [Tooltip("Optional explicit ordering. Leave empty to use the direct children of Extraexplaination.")]
    [SerializeField] private GameObject[] persistentExplanationPanels;

    [Header("Animators")]
    [SerializeField] private Animator spoonAnimator;
    [SerializeField] private Animator beaker1Animator;
    [SerializeField] private Animator beaker2Animator;
    [SerializeField] private Animator chinaDishMoveAnimator;
    [SerializeField] private Animator lighterAnimator;
    [SerializeField] private Animator crystalTransferAnimator;
    
    [Tooltip("Animator on Beaker2Rig/Beaker/Beaker liquid.")]
    [SerializeField] private Animator receivingBeakerLiquidAnimator;
[SerializeField] private Animator drySaltsAnimator;
    [Tooltip("Add every experiment Animator here so marker loss can pause it.")]
    [SerializeField] private Animator[] experimentAnimators;

    [Header("Animator Trigger Names")]
    [SerializeField] private string spoonPourTrigger = "Pour";
    [SerializeField] private string beaker1PourTrigger = "Pour";
    [SerializeField] private string beaker2PourTrigger = "Pour";
    [SerializeField] private string chinaDishMoveTrigger = "MoveToHeat";
    [SerializeField] private string lighterIgniteTrigger = "Ignite";
    [SerializeField] private string crystalTransferTrigger = "Pour";
    
    [SerializeField] private string receivingBeakerFillTrigger = "Fill";
[SerializeField] private string drySaltsTrigger = "Dry";

    [Header("Particle Systems")]
    [SerializeField] private ParticleSystem spoonPourParticles;
    [SerializeField] private ParticleSystem beakerPourParticles;
    [SerializeField] private ParticleSystem funnelDripParticles;
    [SerializeField] private ParticleSystem dishPourParticles;
    [SerializeField] private ParticleSystem flameParticles;
    [SerializeField] private ParticleSystem crystalPourParticles;
    [Tooltip("Add every experiment Particle System here so marker loss can pause it.")]
    [SerializeField] private ParticleSystem[] experimentParticles;

    [Header("Experiment Visuals")]
    [SerializeField] private GameObject powderOnSpoon;
    [Tooltip("Object such as Halite (1) that is hidden as soon as BeakerButton is pressed.")]
    [SerializeField] private GameObject haliteToHideOnBeakerPress;
    [SerializeField] private GameObject copperOxideInBeaker;
    [SerializeField] private GameObject funnelContents;
    [SerializeField] private GameObject copperOxideResidue;
    [SerializeField] private GameObject receivingBeakerLiquid;

    [FormerlySerializedAs("chinaDishContent")]
    [Tooltip("The complete initial china-dish model containing the solution.")]
    [SerializeField] private GameObject initialChinaDish;
    [Tooltip("Optional Content child of Initial China Dish; hidden until Beaker2 finishes pouring.")]
    [SerializeField] private GameObject initialChinaDishContent;
    [SerializeField] private SaltFormationLiquidLevel evaporatingDishLiquid;
    [FormerlySerializedAs("dishResidue")]
    [FormerlySerializedAs("saltCrystalsInDish")]
    [Tooltip("The complete replacement china-dish model containing the residue.")]
    [SerializeField] private GameObject residueChinaDish;
    [FormerlySerializedAs("saltCrystalsOnFilterPaper")]
    [SerializeField] private GameObject filterPaperResidue;

    [Header("Timing From Button Press")]
    [Tooltip("Time from pressing BeakerButton until Beaker1 actually starts pouring.")]
    [SerializeField, Min(0f)] private float beaker1PourStartTime = 2.3f;
    [Tooltip("Enable the disabled funnel content this many seconds after Beaker1 starts pouring.")]
    [SerializeField, Min(0f)] private float funnelContentsDelayAfterPourStart = 5f;
    [Tooltip("Time from pressing BeakerButton until the filter-funnel drip VFX begins.")]
    [SerializeField, Min(0f)] private float funnelDripStartTime = 3f;
    [Tooltip("Total filtering time measured from the BeakerButton press.")]
    [SerializeField, Min(0f)] private float filtrationCompleteTime = 5f;
    [SerializeField, Min(0.01f)] private float heatingDuration = 30f;
    [Tooltip("Delay between pressing the lighter and showing the flame VFX.")]
    [SerializeField, Min(0f)] private float lighterIgnitionDelay = 1f;


    [Header("Tracking")]
    [Tooltip("Leave enabled for Editor testing. Vuforia target events update this at runtime.")]
    [SerializeField] private bool markerTracked = true;

    public ExperimentState CurrentState { get; private set; }

    private float stateElapsed;
    private bool funnelContentsShown;
    private bool funnelDripStarted;
    private bool flameStarted;


    private void Awake()
    {
        CachePersistentExplanationPanels();
        AddButtonListeners();
    }

    private void Start()
    {
        ResetExperiment();
    }

    private void OnDestroy()
    {
        RemoveButtonListeners();
    }

private void Update()
    {
        if (!markerTracked)
        {
            return;
        }

        switch (CurrentState)
        {
            case ExperimentState.Filtering:
                UpdateFiltering();
                break;

            case ExperimentState.Heating:
                UpdateHeating();
                break;
        }
    }

private void AddButtonListeners()
    {
        if (overviewContinueButton != null) overviewContinueButton.onClick.AddListener(BeginExperiment);

        if (spoonButton != null) spoonButton.onClick.AddListener(PressSpoon);
        if (beakerButton != null) beakerButton.onClick.AddListener(PressBeaker);
        if (beakerButton2 != null) beakerButton2.onClick.AddListener(PressBeaker2);
        if (lighterButton != null) lighterButton.onClick.AddListener(PressLighter);
        if (moveSaltCrystalsButton != null) moveSaltCrystalsButton.onClick.AddListener(PressMoveSaltCrystals);
        if (drySaltsButton != null) drySaltsButton.onClick.AddListener(PressDrySalts);
        if (retryButton != null) retryButton.onClick.AddListener(ResetExperiment);
    }

private void RemoveButtonListeners()
    {
        if (overviewContinueButton != null) overviewContinueButton.onClick.RemoveListener(BeginExperiment);

        if (spoonButton != null) spoonButton.onClick.RemoveListener(PressSpoon);
        if (beakerButton != null) beakerButton.onClick.RemoveListener(PressBeaker);
        if (beakerButton2 != null) beakerButton2.onClick.RemoveListener(PressBeaker2);
        if (lighterButton != null) lighterButton.onClick.RemoveListener(PressLighter);
        if (moveSaltCrystalsButton != null) moveSaltCrystalsButton.onClick.RemoveListener(PressMoveSaltCrystals);
        if (drySaltsButton != null) drySaltsButton.onClick.RemoveListener(PressDrySalts);
        if (retryButton != null) retryButton.onClick.RemoveListener(ResetExperiment);
    }

    public void PressSpoon()
    {
        if (!CanStart(ExperimentState.WaitingForSpoon))
        {
            return;
        }

        SetState(ExperimentState.SpoonPouring);
        PlayTrigger(spoonAnimator, spoonPourTrigger);
        PlayParticle(spoonPourParticles);
    }

    public void PressBeaker()
    {
        if (!CanStart(ExperimentState.WaitingForBeaker1))
        {
            return;
        }

        SetActive(haliteToHideOnBeakerPress, false);

        stateElapsed = 0f;
        funnelContentsShown = false;
        funnelDripStarted = false;
        SetState(ExperimentState.Filtering);
        PlayTrigger(beaker1Animator, beaker1PourTrigger);
        PlayParticle(beakerPourParticles);
    }

    public void PressBeaker2()
    {
        if (!CanStart(ExperimentState.WaitingForBeaker2))
        {
            return;
        }

        SetActive(initialChinaDish, true);
        SetActive(initialChinaDishContent, false);
        SetState(ExperimentState.PouringIntoDish);
        PlayTrigger(beaker2Animator, beaker2PourTrigger);
        PlayParticle(dishPourParticles);
    }

    public void PressLighter()
    {
        if (!CanStart(ExperimentState.WaitingForLighter))
        {
            return;
        }

        // The 30-second timer begins when the lighter button is pressed.
        stateElapsed = 0f;
        SetActive(initialChinaDish, true);
        SetActive(initialChinaDishContent, true);
        SetActive(residueChinaDish, false);

        if (evaporatingDishLiquid != null)
        {
            evaporatingDishLiquid.ResetLevel();
            evaporatingDishLiquid.SetVisible(true);
            evaporatingDishLiquid.SetNormalizedLevel(1f);
        }

        flameStarted = false;
        SetState(ExperimentState.Heating);
        PlayTrigger(lighterAnimator, lighterIgniteTrigger);
    }

    public void PressMoveSaltCrystals()
    {
        if (!CanStart(ExperimentState.WaitingForCrystalTransfer))
        {
            return;
        }

        SetState(ExperimentState.TransferringCrystals);
        PlayTrigger(crystalTransferAnimator, crystalTransferTrigger);
        PlayParticle(crystalPourParticles);
    }

    public void PressDrySalts()
    {
        if (!CanStart(ExperimentState.WaitingForDrying))
        {
            return;
        }

        SetState(ExperimentState.DryingAnimation);
        PlayTrigger(drySaltsAnimator, drySaltsTrigger);
    }

    private bool CanStart(ExperimentState requiredState)
    {
        return markerTracked && CurrentState == requiredState;
    }

private void UpdateFiltering()
    {
        stateElapsed += Time.deltaTime;

        float funnelContentRevealTime = beaker1PourStartTime + funnelContentsDelayAfterPourStart;
        if (!funnelContentsShown && stateElapsed >= funnelContentRevealTime)
        {
            funnelContentsShown = true;
            SetActive(funnelContents, true);
        }

        if (!funnelDripStarted && stateElapsed >= funnelDripStartTime)
        {
            funnelDripStarted = true;
            StopParticle(beakerPourParticles);
            PlayParticle(funnelDripParticles);
            SetActive(receivingBeakerLiquid, true);
            PlayTrigger(receivingBeakerLiquidAnimator, receivingBeakerFillTrigger);
        }

        float finishTime = Mathf.Max(
            filtrationCompleteTime,
            Mathf.Max(funnelDripStartTime, funnelContentRevealTime));

        if (stateElapsed >= finishTime)
        {
            FinishFiltering();
        }
    }

    private void FinishFiltering()
    {
        StopParticle(beakerPourParticles);
        StopParticle(funnelDripParticles);
        SetActive(funnelContents, false);
        SetActive(copperOxideResidue, true);
        SetState(ExperimentState.WaitingForBeaker2);
    }

    private void UpdateHeating()
    {
        stateElapsed += Time.deltaTime;

        if (!flameStarted && stateElapsed >= lighterIgnitionDelay)
        {
            flameStarted = true;
            PlayParticle(flameParticles);
        }

        float progress = Mathf.Clamp01(stateElapsed / heatingDuration);

        if (evaporatingDishLiquid != null)
        {
            evaporatingDishLiquid.SetNormalizedLevel(1f - progress);
        }

        UpdateHeatingText(progress);

        if (stateElapsed >= heatingDuration)
        {
            FinishHeating();
        }
    }

    private void FinishHeating()
    {
        if (evaporatingDishLiquid != null)
        {
            evaporatingDishLiquid.SetNormalizedLevel(0f);
            evaporatingDishLiquid.SetVisible(false);
        }

        StopParticle(flameParticles);
        SetActive(initialChinaDish, false);
        SetActive(residueChinaDish, true);
        SetState(ExperimentState.WaitingForCrystalTransfer);
    }

    

    // Called by an Animation Event through SaltFormationAnimationRelay.
    public void NotifySpoonPourFinished()
    {
        if (CurrentState != ExperimentState.SpoonPouring)
        {
            return;
        }

        StopParticle(spoonPourParticles);
        SetActive(powderOnSpoon, false);
        SetActive(copperOxideInBeaker, true);
        SetState(ExperimentState.WaitingForBeaker1);
    }

    // Optional event near the end of the first beaker clip.
    public void NotifyBeaker1PourFinished()
    {
        if (CurrentState == ExperimentState.Filtering)
        {
            StopParticle(beakerPourParticles);
        }
    }

    // Called at the end of Beaker2_PourToDish.
    public void NotifyBeaker2PourFinished()
    {
        if (CurrentState != ExperimentState.PouringIntoDish)
        {
            return;
        }

        StopParticle(dishPourParticles);
        SetActive(receivingBeakerLiquid, false);
        SetActive(initialChinaDish, true);
        SetActive(initialChinaDishContent, true);

        if (evaporatingDishLiquid != null)
        {
            evaporatingDishLiquid.ResetLevel();
            evaporatingDishLiquid.SetVisible(true);
        }

        SetState(ExperimentState.MovingDishToHeat);
        PlayTrigger(chinaDishMoveAnimator, chinaDishMoveTrigger);
    }

    public void NotifyChinaDishMoveFinished()
    {
        if (CurrentState != ExperimentState.MovingDishToHeat)
        {
            return;
        }

        SetState(ExperimentState.WaitingForLighter);
    }

    // Optional event at the end of the lighter ignition clip.
    public void NotifyLighterIgnitionFinished()
    {
        // Heating deliberately continues because its timer started on button press.
    }

    // Called at the end of Crystals_PourToPaper.
public void NotifyCrystalTransferFinished()
    {
        if (CurrentState != ExperimentState.TransferringCrystals)
        {
            return;
        }

        StopParticle(crystalPourParticles);

        // One-object workflow: leave the animated dish residue visible at the filter paper.
        // The optional second object workflow is still supported when Filter Paper Residue is assigned.
        if (filterPaperResidue != null && filterPaperResidue != residueChinaDish)
        {
            SetActive(residueChinaDish, false);
            SetActive(filterPaperResidue, true);
        }

        SetState(ExperimentState.WaitingForDrying);
    }

    // Called at the end of DrySalts.
public void NotifyDrySaltsFinished()
    {
        if (CurrentState != ExperimentState.DryingAnimation)
        {
            return;
        }

        SetState(ExperimentState.Complete);
    }

    public void OnMarkerFound()
    {
        SetMarkerTracked(true);
    }

    public void OnMarkerLost()
    {
        SetMarkerTracked(false);
    }

    public void SetMarkerTracked(bool tracked)
    {
        if (markerTracked == tracked)
        {
            UpdateButtonAvailability();
            return;
        }

        markerTracked = tracked;
        SetAnimationsPaused(!tracked);
        SetParticlesPaused(!tracked);
        UpdateButtonAvailability();
    }

private void SetAnimationsPaused(bool paused)
    {
        SetAnimatorPaused(spoonAnimator, paused);
        SetAnimatorPaused(beaker1Animator, paused);
        SetAnimatorPaused(beaker2Animator, paused);
        SetAnimatorPaused(chinaDishMoveAnimator, paused);
        SetAnimatorPaused(lighterAnimator, paused);
        SetAnimatorPaused(crystalTransferAnimator, paused);
        
        SetAnimatorPaused(receivingBeakerLiquidAnimator, paused);
SetAnimatorPaused(drySaltsAnimator, paused);

        if (experimentAnimators == null)
        {
            return;
        }

        foreach (Animator animator in experimentAnimators)
        {
            SetAnimatorPaused(animator, paused);
        }
    }

private void SetParticlesPaused(bool paused)
    {
        SetParticlePaused(spoonPourParticles, paused);
        SetParticlePaused(beakerPourParticles, paused);
        SetParticlePaused(funnelDripParticles, paused);
        SetParticlePaused(dishPourParticles, paused);
        SetParticlePaused(flameParticles, paused);
        SetParticlePaused(crystalPourParticles, paused);

        if (experimentParticles == null)
        {
            return;
        }

        foreach (ParticleSystem particles in experimentParticles)
        {
            SetParticlePaused(particles, paused);
        }
    }

    public void ResetExperiment()
    {
        stateElapsed = 0f;
        funnelContentsShown = false;
        funnelDripStarted = false;
        // Keep the five cards ready, but hide their shared parent until the
        // learner presses Start Experiment.
        SetPersistentExplanationPanelsActive(true);
        if (extraExplanationContainer != null)
        {
            extraExplanationContainer.gameObject.SetActive(false);
        }

        ResetAnimators();
        flameStarted = false;

        StopAllParticles();

        SetActive(powderOnSpoon, true);
        SetActive(haliteToHideOnBeakerPress, true);
        SetActive(copperOxideInBeaker, false);
        SetActive(funnelContents, false);
        SetActive(copperOxideResidue, false);
        SetActive(receivingBeakerLiquid, false);
        SetActive(initialChinaDish, true);
        SetActive(initialChinaDishContent, false);
        SetActive(residueChinaDish, false);
        SetActive(filterPaperResidue, false);

        if (evaporatingDishLiquid != null)
        {
            evaporatingDishLiquid.ResetLevel();
            evaporatingDishLiquid.SetVisible(false);
        }

        SetState(ExperimentState.InitialOverview);
    }

private void CachePersistentExplanationPanels()
    {
        if (persistentExplanationPanels != null && persistentExplanationPanels.Length > 0)
        {
            return;
        }

        if (extraExplanationContainer == null)
        {
            GameObject container = GameObject.Find("Extraexplaination");
            if (container != null)
            {
                extraExplanationContainer = container.transform;
            }
        }

        if (extraExplanationContainer == null)
        {
            persistentExplanationPanels = System.Array.Empty<GameObject>();
            return;
        }

        persistentExplanationPanels = new GameObject[extraExplanationContainer.childCount];
        for (int i = 0; i < extraExplanationContainer.childCount; i++)
        {
            persistentExplanationPanels[i] = extraExplanationContainer.GetChild(i).gameObject;
        }
    }

private void SetPersistentExplanationPanelsActive(bool active)
    {
        if (persistentExplanationPanels == null)
        {
            return;
        }

        foreach (GameObject panel in persistentExplanationPanels)
        {
            SetActive(panel, active);
        }
    }

private void ResetAnimators()
    {
        ResetAnimator(spoonAnimator);
        ResetAnimator(beaker1Animator);
        ResetAnimator(beaker2Animator);
        ResetAnimator(chinaDishMoveAnimator);
        ResetAnimator(lighterAnimator);
        ResetAnimator(crystalTransferAnimator);
        
        ResetAnimator(receivingBeakerLiquidAnimator);
ResetAnimator(drySaltsAnimator);

        if (experimentAnimators != null)
        {
            foreach (Animator animator in experimentAnimators)
            {
                ResetAnimator(animator);
            }
        }

        if (!markerTracked)
        {
            SetAnimationsPaused(true);
        }
    }

private void StopAllParticles()
    {
        StopParticle(spoonPourParticles);
        StopParticle(beakerPourParticles);
        StopParticle(funnelDripParticles);
        StopParticle(dishPourParticles);
        StopParticle(flameParticles);
        StopParticle(crystalPourParticles);

        if (experimentParticles == null)
        {
            return;
        }

        foreach (ParticleSystem particles in experimentParticles)
        {
            StopParticle(particles);
        }
    }

private void SetState(ExperimentState newState)
    {
        CurrentState = newState;
        UpdateButtonAvailability();
        UpdateInstructionText();
        UpdatePanelVisibility();

        if (heatingProgressText != null && newState != ExperimentState.Heating)
        {
            heatingProgressText.gameObject.SetActive(false);
        }
    }

private void UpdatePanelVisibility()
    {
        SetActive(initialOverviewPanel, false);
        SetActive(spoonInstructionPanel, false);
        SetActive(filtrationInstructionPanel, false);
        SetActive(beaker2InstructionPanel, false);
        SetActive(lighterInstructionPanel, false);
        SetActive(heatingExplanationPanel, false);
        SetActive(moveResidueInstructionPanel, false);
        SetActive(dryingInstructionPanel, false);
        SetActive(finalExplanationPanel, false);
        SetActive(modelLabels, CurrentState == ExperimentState.InitialOverview);

        switch (CurrentState)
        {
            case ExperimentState.InitialOverview:
                SetActive(initialOverviewPanel, true);
                break;
            case ExperimentState.WaitingForSpoon:
                SetActive(spoonInstructionPanel, true);
                break;
            case ExperimentState.WaitingForBeaker1:
                SetActive(filtrationInstructionPanel, true);
                break;
            case ExperimentState.WaitingForBeaker2:
                SetActive(beaker2InstructionPanel, true);
                break;
            case ExperimentState.WaitingForLighter:
                SetActive(lighterInstructionPanel, true);
                break;
            case ExperimentState.Heating:
                SetActive(heatingExplanationPanel, true);
                break;
            case ExperimentState.WaitingForCrystalTransfer:
                SetActive(moveResidueInstructionPanel, true);
                break;
            case ExperimentState.WaitingForDrying:
                SetActive(dryingInstructionPanel, true);
                break;
            case ExperimentState.Complete:
                SetActive(finalExplanationPanel, true);
                break;
        }
    }


    private void UpdateButtonAvailability()
    {
        bool inputAllowed = markerTracked;

        SetButton(overviewContinueButton, inputAllowed && CurrentState == ExperimentState.InitialOverview);


        SetButton(spoonButton, inputAllowed && CurrentState == ExperimentState.WaitingForSpoon);
        SetButton(beakerButton, inputAllowed && CurrentState == ExperimentState.WaitingForBeaker1);
        SetButton(beakerButton2, inputAllowed && CurrentState == ExperimentState.WaitingForBeaker2);
        SetButton(lighterButton, inputAllowed && CurrentState == ExperimentState.WaitingForLighter);
        SetButton(moveSaltCrystalsButton, inputAllowed && CurrentState == ExperimentState.WaitingForCrystalTransfer);
        SetButton(drySaltsButton, inputAllowed && CurrentState == ExperimentState.WaitingForDrying);
    }

private void UpdateInstructionText()
    {
        if (instructionText == null)
        {
            return;
        }

        if (!markerTracked)
        {
            instructionText.text = "Marker lost. Point the camera at the marker to continue.";
            return;
        }

        switch (CurrentState)
        {
            case ExperimentState.InitialOverview:
                instructionText.text = "Explore the apparatus and labels, then press Start Experiment when you are ready.";
                break;
            case ExperimentState.WaitingForSpoon:
                instructionText.text = "Press the spoon button to add copper(II) oxide.";
                break;
            case ExperimentState.SpoonPouring:
                instructionText.text = "Adding copper(II) oxide...";
                break;
            case ExperimentState.WaitingForBeaker1:
                instructionText.text = "Press the beaker button to filter the mixture.";
                break;
            case ExperimentState.Filtering:
                instructionText.text = "Filtering the mixture...";
                break;
            case ExperimentState.WaitingForBeaker2:
                instructionText.text = "Press the second beaker button to pour the filtrate into the evaporating dish.";
                break;
            case ExperimentState.PouringIntoDish:
                instructionText.text = "Pouring the filtrate...";
                break;
            case ExperimentState.MovingDishToHeat:
                instructionText.text = "Moving the china dish to the heating spot...";
                break;
            case ExperimentState.WaitingForLighter:
                instructionText.text = "Press the lighter button to begin heating.";
                break;
            case ExperimentState.Heating:
                instructionText.text = "Heating the solution. Observe the liquid level.";
                break;
            case ExperimentState.WaitingForCrystalTransfer:
                instructionText.text = "Press the move salt crystals button.";
                break;
            case ExperimentState.TransferringCrystals:
                instructionText.text = "Transferring the salt crystals...";
                break;
            case ExperimentState.WaitingForDrying:
                instructionText.text = "Press the dry salts button to begin drying.";
                break;
            case ExperimentState.DryingAnimation:
                instructionText.text = "Drying the salt crystals...";
                break;
            case ExperimentState.Complete:
                instructionText.text = "Experiment complete.";
                break;
        }
    }

private void UpdateHeatingText(float progress)
    {
        if (heatingProgressText == null)
        {
            return;
        }

        heatingProgressText.gameObject.SetActive(true);
        float remaining = Mathf.Max(0f, heatingDuration - stateElapsed);
        heatingProgressText.SetText("Heating: {0:0.0} s", remaining);
    }

    private static void SetButton(Button button, bool interactable)
    {
        if (button != null)
        {
            button.interactable = interactable;
        }
    }

    private static void SetActive(GameObject target, bool active)
    {
        if (target != null)
        {
            target.SetActive(active);
        }
    }

    private static void PlayTrigger(Animator animator, string triggerName)
    {
        if (animator != null && !string.IsNullOrWhiteSpace(triggerName))
        {
            animator.SetTrigger(triggerName);
        }
    }

    private static void PlayParticle(ParticleSystem particles)
    {
        if (particles != null)
        {
            particles.Play(true);
        }
    }

    private static void StopParticle(ParticleSystem particles)
    {
        if (particles != null)
        {
            particles.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
        }
    }


private static void ResetAnimator(Animator animator)
    {
        if (animator == null || animator.runtimeAnimatorController == null)
        {
            return;
        }

        animator.speed = 1f;
        animator.Rebind();
        animator.Update(0f);
    }


private static void SetParticlePaused(ParticleSystem particles, bool paused)
    {
        if (particles == null)
        {
            return;
        }

        if (paused && particles.isPlaying)
        {
            particles.Pause(true);
        }
        else if (!paused && particles.isPaused)
        {
            particles.Play(true);
        }
    }


private static void SetAnimatorPaused(Animator animator, bool paused)
    {
        if (animator != null)
        {
            animator.speed = paused ? 0f : 1f;
        }
    }


public void BeginExperiment()
    {
        if (!CanStart(ExperimentState.InitialOverview))
        {
            return;
        }

        if (extraExplanationContainer != null)
        {
            extraExplanationContainer.gameObject.SetActive(true);
        }
        SetPersistentExplanationPanelsActive(true);
        SetState(ExperimentState.WaitingForSpoon);
    }
}
