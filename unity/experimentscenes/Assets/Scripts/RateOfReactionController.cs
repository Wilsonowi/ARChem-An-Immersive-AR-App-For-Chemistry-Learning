using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections;

// Main controller for the "Effect of Concentration on Rate of Reaction" experiment
// (Na2S2O3 + H2SO4, disappearing 'X' mark). New, standalone scene/script - does not
// modify any existing CuCO3 files.
public class RateOfReactionController : MonoBehaviour
{
    [Header("UI - Input")]
    public TMP_InputField thioVolumeInput;   // Volume of Na2S2O3 (cm3)
    public TMP_InputField waterVolumeInput;  // Volume of distilled water (cm3)
    public Button startButton;
    public GameObject startButtonObject;
    public Button retryButton;
    public GameObject retryButtonObject;
    public TMP_Text validationText;

    [Header("UI - Runtime Display")]
    public TMP_Text timerText;
    public TMP_Text concentrationText;
    public TMP_Text resultsLogText;          // appends each trial, mimics Table 7.5

    [Header("UI - Explanation")]
    public GameObject explanationPanel;
    public TMP_Text explanationTitleText;
    public TMP_Text explanationEquationText;
    public TMP_Text explanationText;

    [Header("Experiment Refs")]
    public TurbidityEffect turbidityEffect;

    [Header("Pour Animation")]
    public Animator pourAnimator;
    public GameObject beakerWaterObject;
    public GameObject secondPourBeakerObject;
    public GameObject observeCanvas;
    public string pourStateName = "Pour";
    public float pourDuration = 10f;

    [Header("Fixed Constants (per Table 7.5)")]
    public float acidVolume = 5f;             // H2SO4, fixed
    public float totalVolume = 50f;           // fixed total mixture volume
    public float stockConcentration = 0.2f;   // mol/dm3, stock Na2S2O3
    public float timeConstantK = 3.6f;        // calibrated: V=45cm3 -> ~20s, V=10cm3 -> ~90s

    private enum State { Idle, Pouring, Reacting, Complete }
    private State currentState = State.Idle;
    private float reactionTimer = 0f;
    private float targetReactionTime = 0f;
    private float _lastConcentration;
    private Coroutine pourRoutine;

    void Start()
    {
        if (startButton != null)
            startButton.onClick.AddListener(OnStartClicked);

        if (retryButton != null)
            retryButton.onClick.AddListener(OnRetryClicked);

        SetStartButtonVisible(true);
        SetRetryButtonVisible(false);
        SetPourVisual(false);
        SetObserveCanvasVisible(false);

        if (explanationPanel != null)
            explanationPanel.SetActive(false);

        if (validationText != null)
            validationText.text = "";
    }

    void Update()
    {
        if (currentState != State.Reacting) return;

        reactionTimer += Time.deltaTime;
        timerText.text = $"Time: {reactionTimer:F1} s";

        if (reactionTimer >= targetReactionTime)
        {
            currentState = State.Complete;
            timerText.text = $"'X' disappeared at {targetReactionTime:F1} s";
            LogResult();
            ShowExplanation();
            SetRetryButtonVisible(true);
        }
    }

    void OnStartClicked()
    {
        if (currentState == State.Reacting) return; // ignore double-clicks mid-run

        if (!float.TryParse(thioVolumeInput.text, out float thioVol) ||
            !float.TryParse(waterVolumeInput.text, out float waterVol))
        {
            validationText.text = "Please enter valid numbers.";
            return;
        }

        if (thioVol < 0 || waterVol < 0)
        {
            validationText.text = "Volumes cannot be negative.";
            return;
        }

        float requiredSum = totalVolume - acidVolume; // 45 cm3
        if (Mathf.Abs((thioVol + waterVol) - requiredSum) > 0.01f)
        {
            validationText.text =
                $"Na2S2O3 + water must total {requiredSum} cm3 (H2SO4 is fixed at {acidVolume} cm3).";
            return;
        }

        validationText.text = "";
        StartExperiment(thioVol, waterVol);
    }

    void StartExperiment(float thioVol, float waterVol)
    {
        float concentration = stockConcentration * (thioVol / totalVolume);
        concentrationText.text = $"[Na2S2O3] in mixture = {concentration:F3} mol/dm3";

        targetReactionTime = timeConstantK / Mathf.Max(concentration, 0.001f);
        reactionTimer = 0f;
        currentState = State.Pouring;
        _lastConcentration = concentration;
        SetStartButtonVisible(false);
        SetRetryButtonVisible(false);
        SetObserveCanvasVisible(true);

        turbidityEffect.ResetEffect();

        _lastThioVol = thioVol;
        _lastWaterVol = waterVol;

        if (timerText != null)
            timerText.text = "0.0 s";

        ShowPouringState();
        PlayPourAnimation();

        if (pourRoutine != null)
            StopCoroutine(pourRoutine);

        pourRoutine = StartCoroutine(BeginReactionAfterPour());
    }

    private float _lastThioVol, _lastWaterVol;

    void OnRetryClicked()
    {
        if (pourRoutine != null)
        {
            StopCoroutine(pourRoutine);
            pourRoutine = null;
        }

        currentState = State.Idle;
        reactionTimer = 0f;
        targetReactionTime = 0f;

        if (timerText != null)
            timerText.text = "0.0 s";

        if (validationText != null)
            validationText.text = "";

        if (explanationPanel != null)
            explanationPanel.SetActive(false);

        if (turbidityEffect != null)
            turbidityEffect.ResetEffect();

        SetPourVisual(false);
        SetObserveCanvasVisible(false);

        SetRetryButtonVisible(false);
        SetStartButtonVisible(true);
    }

    IEnumerator BeginReactionAfterPour()
    {
        yield return new WaitForSeconds(pourDuration);

        pourRoutine = null;
        SetPourVisual(false);
        reactionTimer = 0f;
        currentState = State.Reacting;

        ShowReactionEquation();

        if (turbidityEffect != null)
            turbidityEffect.StartReaction(targetReactionTime, null);
    }

    void PlayPourAnimation()
    {
        SetPourVisual(true);

        if (pourAnimator == null) return;

        pourAnimator.enabled = true;
        pourAnimator.Play(pourStateName, 0, 0f);
        pourAnimator.Update(0f);
    }

    void SetPourVisual(bool visible)
    {
        if (beakerWaterObject != null)
            beakerWaterObject.SetActive(visible);

        if (secondPourBeakerObject != null)
            secondPourBeakerObject.SetActive(visible);
    }

    void SetObserveCanvasVisible(bool visible)
    {
        if (observeCanvas != null)
            observeCanvas.SetActive(visible);
    }

    void SetStartButtonVisible(bool visible)
    {
        if (startButtonObject != null)
            startButtonObject.SetActive(visible);
        else if (startButton != null)
            startButton.gameObject.SetActive(visible);
    }

    void SetRetryButtonVisible(bool visible)
    {
        if (retryButtonObject != null)
            retryButtonObject.SetActive(visible);
        else if (retryButton != null)
            retryButton.gameObject.SetActive(visible);
    }

    void LogResult()
    {
        if (resultsLogText == null) return;
        resultsLogText.text +=
            $"\nNa2S2O3: {_lastThioVol}cm3 | Water: {_lastWaterVol}cm3 -> Time: {targetReactionTime:F1}s";
    }

    void ShowReactionEquation()
    {
        if (explanationPanel == null) return;

        explanationPanel.SetActive(true);
        if (explanationTitleText != null)
        {
            explanationTitleText.text = "REACTION IN PROGRESS";
            explanationTitleText.color = new Color32(86, 204, 242, 255);
        }

        if (explanationEquationText != null)
        {
            explanationEquationText.text =
                "S<sub>2</sub>O<sub>3</sub><sup>2−</sup>(aq) + 2H<sup>+</sup>(aq)\n" +
                "→ S(s) + SO<sub>2</sub>(g) + H<sub>2</sub>O(l)";
        }

        if (explanationText != null)
        {
            explanationText.text =
                $"Mixture concentration: <b>{_lastConcentration:F3} mol/dm<sup>3</sup></b>\n" +
                "Yellow sulfur is forming. Watch the X mark become harder to see.";
        }
    }

    void ShowPouringState()
    {
        if (explanationPanel == null) return;

        explanationPanel.SetActive(true);

        if (explanationTitleText != null)
        {
            explanationTitleText.text = "ADDING REACTANT";
            explanationTitleText.color = new Color32(242, 201, 76, 255);
        }

        if (explanationEquationText != null)
        {
            explanationEquationText.text =
                "Na<sub>2</sub>S<sub>2</sub>O<sub>3</sub>(aq) + H<sub>2</sub>SO<sub>4</sub>(aq)";
        }

        if (explanationText != null)
        {
            explanationText.text =
                "Pouring the measured distilled water and sodium thiosulfate into the flask. The " +
                "reaction timer will begin when both pours are complete.";
        }
    }

    void ShowExplanation()
    {
        if (explanationPanel == null) return;

        explanationPanel.SetActive(true);

        string speedLabel;
        string reason;
        Color32 resultColor;

        if (targetReactionTime <= 35f)
        {
            speedLabel = "FAST REACTION";
            resultColor = new Color32(39, 174, 96, 255);
            reason =
                "A high concentration places more reactant particles in the same volume. Effective " +
                "collisions with H<sup>+</sup> occur more often, so sulfur forms quickly and hides " +
                "the X sooner.";
        }
        else if (targetReactionTime <= 65f)
        {
            speedLabel = "MODERATE REACTION";
            resultColor = new Color32(242, 201, 76, 255);
            reason =
                "Moderate dilution gives an intermediate number of reactant particles per unit " +
                "volume. Effective collisions occur at a moderate frequency, so sulfur forms at an " +
                "intermediate rate.";
        }
        else
        {
            speedLabel = "SLOW REACTION";
            resultColor = new Color32(242, 153, 74, 255);
            reason =
                "More water produces a low concentration, with fewer reactant particles per unit " +
                "volume. Effective collisions with H<sup>+</sup> occur less often, so sulfur forms " +
                "slowly and the X remains visible longer.";
        }

        if (explanationTitleText != null)
        {
            explanationTitleText.text = speedLabel;
            explanationTitleText.color = resultColor;
        }

        if (explanationEquationText != null)
        {
            explanationEquationText.text =
                $"<b>X disappeared in {targetReactionTime:F1} s</b>\n" +
                $"[Na<sub>2</sub>S<sub>2</sub>O<sub>3</sub>] = {_lastConcentration:F3} mol/dm<sup>3</sup>";
        }

        if (explanationText == null) return;
        explanationText.text =
            $"Na<sub>2</sub>S<sub>2</sub>O<sub>3</sub>: <b>{_lastThioVol:F1} cm<sup>3</sup></b>   " +
            $"Water: <b>{_lastWaterVol:F1} cm<sup>3</sup></b>\n\n" +
            reason;
    }
}
