using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections;

// Master controller tying the guided flow together:
// Step 1 (press button -> ignite, fire lights at 1s inside the animation)
// -> Step 2 (press button -> lamp starts moving under tripod)
// -> Step 3's panel appears 1.5s after the move button was pressed, and now
//    STAYS VISIBLE for the whole reaction (about 90s), with its explanation
//    text rotating every ~30s as the reaction script fires its stage events.
// -> Explanation panel replaces Step 3 once OnCloudyComplete fires (reaction done)
public class CuCO3ExperimentFlow : MonoBehaviour
{
    [Header("Panels")]
    public GameObject step1Panel;
    public GameObject step2Panel;
    public GameObject step3Panel;
    public GameObject explanationPanel;

    [Header("Opening Flow")]
    public Button introEnterButton;
    public GameObject overviewPanel;
    public Button overviewContinueButton;
    public GameObject modelLabels;
    public TMP_Text overviewSelectionText;
    public TMP_Text carbonateSampleLabel;
    public TMP_Text limewaterLabel;

    [Header("Dynamic Final Explanation")]
    public TMP_Text finalTitleText;
    public TMP_Text finalEquationText;
    public TMP_Text finalExplanationText;

    [Header("Reaction Progress")]
    public Image reactionProgressFill;
    public TMP_Text reactionProgressText;

    [Header("Step 1 - Ignite")]
    public Button igniteButton;
    public LighterAnimationController lighterSequence;

    [Header("Step 2 - Move Lamp")]
    public Button moveButton;
    public LampAnimationController lampSequence;
    [Tooltip("Delay after pressing the move button before Step 3's panel appears.")]
    public float delayBeforeStep3 = 1.5f;

    [Header("Step 3 - Observe (stays visible, text rotates every ~30s)")]
    public Button observeButton;
    public TMP_Text step3ExplanationText;
    public CuCO3HeatingButtonReaction reactionScript;
    // Wire reactionScript's OnCloudyComplete (UnityEvent, in the Inspector)
    // to call this script's ShowExplanationPanel() method.

    [Header("Retry")]
    public Button retryButton;

void Start()
    {
        if (introEnterButton != null) introEnterButton.onClick.AddListener(OnIntroEntered);
        if (overviewContinueButton != null) overviewContinueButton.onClick.AddListener(BeginGuidedExperiment);

        if (igniteButton != null) igniteButton.onClick.AddListener(OnIgniteButtonPressed);
        else Debug.LogWarning("CuCO3ExperimentFlow: igniteButton is not assigned in the Inspector.", this);

        if (moveButton != null) moveButton.onClick.AddListener(OnMoveButtonPressed);
        else Debug.LogWarning("CuCO3ExperimentFlow: moveButton is not assigned in the Inspector.", this);

        if (observeButton != null) observeButton.onClick.AddListener(OnObserveButtonPressed);
        else Debug.LogWarning("CuCO3ExperimentFlow: observeButton is not assigned in the Inspector.", this);

        if (retryButton != null) retryButton.onClick.AddListener(OnRetry);

        if (reactionScript != null)
        {
            reactionScript.ConfigureCarbonate(
                CuCO3HeatingButtonReaction.CarbonateSalt.CopperIICarbonate);
            reactionScript.OnGasStarted.AddListener(OnStage1Explanation);
            reactionScript.OnBlackeningComplete.AddListener(OnStage2Explanation);
            reactionScript.OnCloudyComplete.AddListener(OnStage3Explanation);
        }
        else
        {
            Debug.LogWarning("CuCO3ExperimentFlow: reactionScript is not assigned - stage explanations won't fire.", this);
        }

        ShowOpeningState();
    }

private void Update()
    {
        if (reactionScript == null)
            return;

        if (reactionProgressFill != null)
            reactionProgressFill.fillAmount = reactionScript.ReactionProgress;

        if (reactionProgressText != null)
        {
            reactionProgressText.text = reactionScript.IsRunning
                ? "Heating: " + Mathf.CeilToInt(reactionScript.RemainingSeconds) + " s remaining"
                : (reactionScript.ReactionProgress >= 1f ? "Observation complete" : "Ready to observe");
        }
    }


    private void OnIntroEntered()
    {
        ShowOpeningState();
        UpdateSelectionLabels();
        if (overviewPanel != null) overviewPanel.SetActive(true);
        if (modelLabels != null) modelLabels.SetActive(true);
    }

    private void BeginGuidedExperiment()
    {
        if (overviewPanel != null) overviewPanel.SetActive(false);
        if (modelLabels != null) modelLabels.SetActive(false);
        ShowOnlyStep1();
    }

    private void UpdateSelectionLabels()
    {
        string selection;
        string sample;
        string limewater;

        selection = "Copper(II) carbonate\nCuCO<sub>3</sub>";
        sample = "<b>HEATED SAMPLE</b>\nCopper(II) carbonate — CuCO<sub>3</sub>\nGreen solid";
        limewater = "<b>LIMEWATER</b>\nExpected result: turns cloudy";

        if (overviewSelectionText != null) overviewSelectionText.text = selection;
        if (carbonateSampleLabel != null) carbonateSampleLabel.text = sample;
        if (limewaterLabel != null) limewaterLabel.text = limewater;
    }


    private void OnIgniteButtonPressed()
    {
        SetButtonAvailable(igniteButton, false);
        SetButtonAvailable(moveButton, false);
        if (step1Panel != null) step1Panel.SetActive(false);
        if (lighterSequence != null) lighterSequence.PlayIgniteSequence(OnIgniteSequenceComplete);
        else Debug.LogWarning("CuCO3ExperimentFlow: lighterSequence is not assigned.", this);
    }

    private void OnIgniteSequenceComplete()
    {
        if (step2Panel != null) step2Panel.SetActive(true);
        SetButtonAvailable(moveButton, true);
    }

    private void OnMoveButtonPressed()
    {
        SetButtonAvailable(moveButton, false);
        SetButtonAvailable(observeButton, false);
        if (step2Panel != null) step2Panel.SetActive(false);

        if (lampSequence != null) lampSequence.PlayMoveSequence(null);
        else Debug.LogWarning("CuCO3ExperimentFlow: lampSequence is not assigned.", this);

        StartCoroutine(ShowStep3AfterDelay());
    }

    private IEnumerator ShowStep3AfterDelay()
    {
        yield return new WaitForSeconds(delayBeforeStep3);
        if (step3Panel != null) step3Panel.SetActive(true);
        SetButtonAvailable(observeButton, true);
    }

private void OnObserveButtonPressed()
    {
        string saltName = GetSelectedSaltName();
        SetStep3Text("Heating " + saltName + ". Observe the solid and limewater during the 30-second test.");

        SetButtonAvailable(observeButton, false);

        if (reactionScript != null) reactionScript.StartReaction();
        else Debug.LogWarning("CuCO3ExperimentFlow: reactionScript is not assigned.", this);
    }

private void OnStage1Explanation()
    {
        SetStep3Text("Carbon dioxide is being released and passes through the delivery tube into the limewater.");
    }

private void OnStage2Explanation()
    {
        SetStep3Text("The green copper(II) carbonate changes through brown, then becomes black as copper(II) oxide forms.");
    }

private void OnStage3Explanation()
    {
        SetStep3Text("The limewater turns cloudy because carbon dioxide forms a white calcium carbonate precipitate.");
    }

    private void SetStep3Text(string message)
    {
        if (step3ExplanationText != null) step3ExplanationText.text = message;
    }

    // Called via CuCO3HeatingButtonReaction's OnCloudyComplete UnityEvent (wire in Inspector)
public void ShowExplanationPanel()
    {
        UpdateFinalExplanation();

        SetButtonAvailable(igniteButton, false);
        SetButtonAvailable(moveButton, false);
        SetButtonAvailable(observeButton, false);
        if (step3Panel != null) step3Panel.SetActive(false);
        if (explanationPanel != null) explanationPanel.SetActive(true);
        SetButtonAvailable(retryButton, true);
    }

private void OnRetry()
    {
        if (explanationPanel != null) explanationPanel.SetActive(false);
        if (reactionScript != null)
        {
            reactionScript.ConfigureCarbonate(
                CuCO3HeatingButtonReaction.CarbonateSalt.CopperIICarbonate);
            reactionScript.ResetReactionVisuals();
        }
        if (lighterSequence != null) lighterSequence.ResetSequence();
        if (lampSequence != null) lampSequence.ResetSequence();
        ShowOnlyStep1();
    }

private void ShowOnlyStep1()
    {
        if (overviewPanel != null) overviewPanel.SetActive(false);
        if (modelLabels != null) modelLabels.SetActive(false);
        if (step1Panel != null) step1Panel.SetActive(true);
        if (step2Panel != null) step2Panel.SetActive(false);
        if (step3Panel != null) step3Panel.SetActive(false);
        if (explanationPanel != null) explanationPanel.SetActive(false);
        SetButtonAvailable(igniteButton, true);
        SetButtonAvailable(moveButton, false);
        SetButtonAvailable(observeButton, false);
        SetButtonAvailable(retryButton, false);
    }


    private void ShowOpeningState()
    {
        if (overviewPanel != null) overviewPanel.SetActive(false);
        if (modelLabels != null) modelLabels.SetActive(false);
        if (step1Panel != null) step1Panel.SetActive(false);
        if (step2Panel != null) step2Panel.SetActive(false);
        if (step3Panel != null) step3Panel.SetActive(false);
        if (explanationPanel != null) explanationPanel.SetActive(false);
        SetButtonAvailable(igniteButton, false);
        SetButtonAvailable(moveButton, false);
        SetButtonAvailable(observeButton, false);
        SetButtonAvailable(retryButton, false);
    }

    private static void SetButtonAvailable(Button button, bool available)
    {
        if (button == null)
            return;

        button.interactable = available;
        button.gameObject.SetActive(available);
    }

    private string GetSelectedSaltName()
    {
        return "copper(II) carbonate";
    }

    private void UpdateFinalExplanation()
    {
        string title;
        string equation;
        string explanation;

        title = "Thermal Decomposition Complete";
        equation = "CuCO<sub>3</sub>(s) → CuO(s) + CO<sub>2</sub>(g)\nCO<sub>2</sub>(g) + Ca(OH)<sub>2</sub>(aq) → CaCO<sub>3</sub>(s) + H<sub>2</sub>O(l)";
        explanation = "Green copper(II) carbonate decomposed into black copper(II) oxide and carbon dioxide. The carbon dioxide turned limewater cloudy by forming a white calcium carbonate precipitate.";

        if (finalTitleText != null) finalTitleText.text = title;
        if (finalEquationText != null) finalEquationText.text = equation;
        if (finalExplanationText != null) finalExplanationText.text = explanation;
    }
}
