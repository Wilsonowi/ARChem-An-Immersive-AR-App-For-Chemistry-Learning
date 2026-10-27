using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using TMPro;

public class Neutralisation : MonoBehaviour
{
    [Header("3D References")]
    public Renderer flaskLiquidRenderer;
    public ParticleSystem droplets;
    public ParticleSystem bubbles;
    public GameObject labRoot;

    [Header("Liquid Colours")]
    public Color colourDeepPink = new Color(0.90f, 0.10f, 0.50f, 0.80f);
    public Color colourPink = new Color(0.95f, 0.40f, 0.70f, 0.75f);
    public Color colourLightPink = new Color(0.98f, 0.70f, 0.85f, 0.65f);
    public Color colourNearClear = new Color(0.99f, 0.90f, 0.95f, 0.40f);
    public Color colourColourless = new Color(0.95f, 0.95f, 0.98f, 0.25f);
    public Color colourExcessAcidYellow = new Color(1.00f, 0.78f, 0.08f, 0.85f);

    [Header("UI")]
    public Button startButton;       // shown on scene load
    public Button buretteButton;
    public TextMeshProUGUI buretteButtonText;
    public TextMeshProUGUI instructionText;

    [Header("Flask Movement")]
    public Animator flaskAnimator;
    public Button flaskButton;
    public GameObject flaskNamePanel;
    public string flaskMoveTrigger = "Move";


    [Header("Result Panel")]
    public GameObject resultPanel;
    public TextMeshProUGUI resultTitle;
    public TextMeshProUGUI resultEquation;
    public TextMeshProUGUI resultExplanation;
    public Button returnButton;
    public Button tryAgainButton;

    [Header("Timing")]
    public float stageDuration = 3.5f;

    [Header("Zoom Settings")]
    public float minScale = 0.5f;
    public float maxScale = 3.0f;
    public float zoomSpeed = 0.005f;

    [Header("Rotation Settings")]
    public float rotationSpeed = 0.3f;
    public bool invertVertical = false;

    // ── private state ──────────────────────────────────────────────
    private Color[] stages;
    private bool buretteOpen = false;
    private bool experimentDone = false;
    private int currentStage = 0;
    private float stageTimer = 0f;

    private bool isPinching = false;
    private float prevPinch = 0f;
    private bool isDragging = false;
    private Vector2 lastDragPos;

    private Vector3 flaskStartLocalPosition;
    private Quaternion flaskStartLocalRotation;
    private Vector3 flaskStartLocalScale;
    private bool flaskStartCaptured;


    // ── Unity lifecycle ────────────────────────────────────────────

    void Start()
    {
        CaptureFlaskStartTransform();

        stages = new Color[]
        {
            colourDeepPink, colourPink, colourLightPink,
            colourNearClear, colourColourless, colourExcessAcidYellow
        };

        if (flaskLiquidRenderer != null)
            flaskLiquidRenderer.material.color = colourDeepPink;

        if (droplets != null) droplets.gameObject.SetActive(false);
        if (bubbles != null) bubbles.gameObject.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(false);
        if (buretteButton != null) buretteButton.gameObject.SetActive(false);
        if (returnButton != null) returnButton.gameObject.SetActive(false);
        if (tryAgainButton != null) tryAgainButton.gameObject.SetActive(false);

        if (startButton != null) startButton.gameObject.SetActive(true);

        // NEW: wire buttons through code, same pattern as RateOfReactionController
        // and CuCO3ExperimentFlow, instead of relying on manual Inspector OnClick().
        if (startButton    != null) startButton.onClick.AddListener(OnStartExperiment);
        if (buretteButton  != null) buretteButton.onClick.AddListener(OnBuretteButtonPressed);
        if (flaskButton    != null) flaskButton.onClick.AddListener(OnFlaskButtonPressed);

        if (returnButton   != null) returnButton.onClick.AddListener(OnReturn);
        if (tryAgainButton != null) tryAgainButton.onClick.AddListener(ResetExperiment);

        SetInstruction("Place the model on the marker, then press Start.");
    }

    void Update()
    {
        if (buretteOpen && !experimentDone)
            HandleStageProgress();

        HandleRotation();
        HandlePinchZoom();
    }

    // ── Start button ───────────────────────────────────────────────
public void OnStartExperiment()
    {
        if (startButton != null) startButton.gameObject.SetActive(false);
        if (buretteButton != null) buretteButton.gameObject.SetActive(false);
        if (flaskButton != null) flaskButton.gameObject.SetActive(true);
        if (flaskNamePanel != null) flaskNamePanel.SetActive(true);

        SetInstruction("Press the flask button to move the conical flask beneath the burette.");
    }

    public void GobackToMenu()
    {
        SceneManager.LoadScene("MainMenu");
    }

    // ── Stage progression ──────────────────────────────────────────
    void HandleStageProgress()
    {
        stageTimer += Time.deltaTime;

        if (currentStage < stages.Length - 1)
        {
            float t = Mathf.Clamp01(stageTimer / stageDuration);
            if (flaskLiquidRenderer != null)
                flaskLiquidRenderer.material.color =
                    Color.Lerp(stages[currentStage], stages[currentStage + 1], t);

            if (stageTimer >= stageDuration)
            {
                stageTimer = 0f;
                currentStage = Mathf.Min(currentStage + 1, stages.Length - 1);

                if (currentStage == 3)
                    SetInstruction("Almost colourless — close the tap NOW!");

                if (currentStage == 4)
                    SetInstruction("Too much acid is being added — the solution is turning yellow.");

                if (currentStage >= stages.Length - 1)
                {
                    CloseBurette();
                    ShowResult();
                }
            }
        }
    }

    // ── Burette button ─────────────────────────────────────────────
    public void OnBuretteButtonPressed()
    {
        if (experimentDone) return;
        if (!buretteOpen) OpenBurette();
        else { CloseBurette(); ShowResult(); }
    }

    void OpenBurette()
    {
        buretteOpen = true;
        SetButtonText("Close Tap");
        SetInstruction("HNO<sub>3</sub> is dripping in — watch the colour change!");
        if (droplets != null) { droplets.gameObject.SetActive(true); droplets.Play(); }
        if (bubbles != null) { bubbles.gameObject.SetActive(true); bubbles.Play(); }
    }

    void CloseBurette()
    {
        buretteOpen = false;
        SetButtonText("Open Tap");
        if (droplets != null) { droplets.Stop(); droplets.gameObject.SetActive(false); }
        if (bubbles != null) { bubbles.Stop(); bubbles.gameObject.SetActive(false); }
    }

    // ── Result panel ───────────────────────────────────────────────
    void ShowResult()
    {
        experimentDone = true;
        if (buretteButton   != null) buretteButton.gameObject.SetActive(false);
        if (instructionText != null) instructionText.gameObject.SetActive(false);
        if (resultPanel     != null) resultPanel.SetActive(true);

        if (currentStage == 3) // closed exactly at Near Clear -> correct
        {
            if (flaskLiquidRenderer != null)
                flaskLiquidRenderer.material.color = colourColourless;

            if (resultTitle != null)
            {
                resultTitle.text  = "Neutralisation Complete!";
                resultTitle.color = new Color32(0, 207, 255, 255);
            }
            if (resultEquation != null)
                resultEquation.text =
                    "HNO<sub>3</sub>(aq) + KOH(aq) → KNO<sub>3</sub>(aq) + H<sub>2</sub>O(l)\n" +
                    "Salt formed: Potassium Nitrate (KNO<sub>3</sub>)";

            if (resultExplanation != null)
                resultExplanation.text =
                    "Phenolphthalein turned colourless at the equivalence " +
                    "point (pH 7). All the KOH has reacted with HNO<sub>3</sub>. " +
                    "The salt formed is potassium nitrate (KNO<sub>3</sub>), " +
                    "a soluble salt used as fertiliser.";

            if (tryAgainButton != null) tryAgainButton.gameObject.SetActive(false);
            if (returnButton   != null) returnButton.gameObject.SetActive(true);
        }
        else if (currentStage < 3) // closed too early -> still alkaline
        {
            if (resultTitle != null)
            {
                resultTitle.text  = "Stopped Too Early!";
                resultTitle.color = new Color32(250, 204, 21, 255);
            }
            if (resultEquation != null)
            {
                resultEquation.text  = "The solution is still alkaline";
                resultEquation.color = new Color32(250, 204, 21, 255);
            }
            if (resultExplanation != null)
                resultExplanation.text =
                    "The colour hasn't faded to colourless yet, which means there is " +
                    "still excess KOH in the solution. Try again and let more HNO<sub>3</sub> " +
                    "react before closing the tap.";

            if (returnButton   != null) returnButton.gameObject.SetActive(false);
            if (tryAgainButton != null) tryAgainButton.gameObject.SetActive(true);
        }
        else // currentStage >= 4 -> too much acid was added
        {
            if (flaskLiquidRenderer != null)
                flaskLiquidRenderer.material.color = colourExcessAcidYellow;

            if (resultTitle != null)
            {
                resultTitle.text  = "Too Much Acid Added!";
                resultTitle.color = new Color32(248, 113, 113, 255);
            }
            if (resultEquation != null)
            {
                resultEquation.text  = "Equivalence point was missed";
                resultEquation.color = new Color32(248, 113, 113, 255);
            }
            if (resultExplanation != null)
                resultExplanation.text =
                    "You added too much HNO<sub>3</sub>. The solution went past pH 7 " +
                    "and became acidic. Phenolphthalein is colourless in " +
                    "both neutral AND acidic solutions — stop at the very " +
                    "first sign of colourless.";

            if (returnButton   != null) returnButton.gameObject.SetActive(false);
            if (tryAgainButton != null) tryAgainButton.gameObject.SetActive(true);
        }
    }

    // ── Button handlers ────────────────────────────────────────────
    public void OnReturn() { SceneManager.LoadScene("LectureContent"); }
    public void GoBack() { SceneManager.LoadScene("MainMenu"); }

    public void ResetExperiment()
    {
        ResetFlaskToStart();

        buretteOpen = false;
        experimentDone = false;
        currentStage = 0;
        stageTimer = 0f;

        if (flaskLiquidRenderer != null)
            flaskLiquidRenderer.material.color = colourDeepPink;

        if (droplets != null) droplets.gameObject.SetActive(false);
        if (bubbles != null) bubbles.gameObject.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(false);
        if (instructionText != null) instructionText.gameObject.SetActive(true);
        if (returnButton != null) returnButton.gameObject.SetActive(false);
        if (tryAgainButton != null) tryAgainButton.gameObject.SetActive(false);
        if (buretteButton != null) buretteButton.gameObject.SetActive(false);
        if (flaskButton != null) flaskButton.gameObject.SetActive(false);
        if (flaskNamePanel != null) flaskNamePanel.SetActive(false);

        if (startButton != null) startButton.gameObject.SetActive(true);
        if (flaskButton != null) flaskButton.gameObject.SetActive(false);
        if (flaskNamePanel != null) flaskNamePanel.SetActive(false);


        SetInstruction("Place the model on the marker, then press Start.");
    }

    // ── Drag-to-rotate ─────────────────────────────────────────────
    void HandleRotation()
    {
        if (labRoot == null || experimentDone) return;

        if (Application.isEditor)
        {
            if (Input.GetMouseButtonDown(0) && !IsOverUIPosition(Input.mousePosition))
            {
                isDragging = true;
                lastDragPos = Input.mousePosition;
            }
            if (Input.GetMouseButtonUp(0)) isDragging = false;

            if (isDragging && Input.GetMouseButton(0))
            {
                Vector2 delta = (Vector2)Input.mousePosition - lastDragPos;
                lastDragPos = Input.mousePosition;
                ApplyRotation(delta);
            }
            return;
        }

        if (Input.touchCount == 1)
        {
            Touch t = Input.GetTouch(0);
            if (IsOverUI(t.fingerId)) return;

            if (t.phase == TouchPhase.Began)
            {
                isDragging = true;
                lastDragPos = t.position;
            }
            else if (t.phase == TouchPhase.Ended || t.phase == TouchPhase.Canceled)
            {
                isDragging = false;
            }
            else if (isDragging && t.phase == TouchPhase.Moved)
            {
                Vector2 delta = t.position - lastDragPos;
                lastDragPos = t.position;
                ApplyRotation(delta);
            }
        }
        else if (Input.touchCount != 1)
        {
            isDragging = false;
        }
    }

    void ApplyRotation(Vector2 delta)
    {
        float yaw = delta.x * rotationSpeed;
        float pitch = (invertVertical ? delta.y : -delta.y) * rotationSpeed;
        labRoot.transform.Rotate(Vector3.up, yaw, Space.World);
        labRoot.transform.Rotate(Vector3.right, pitch, Space.Self);
    }

    // ── Pinch-to-zoom ──────────────────────────────────────────────
    void HandlePinchZoom()
    {
        if (labRoot == null) return;

        if (Application.isEditor)
        {
            float scroll = Input.GetAxis("Mouse ScrollWheel");
            if (Mathf.Abs(scroll) > 0.001f)
            {
                float s = Mathf.Clamp(
                    labRoot.transform.localScale.x + scroll * 1.5f,
                    minScale, maxScale);
                labRoot.transform.localScale = Vector3.one * s;
            }
            return;
        }

        if (Input.touchCount == 2)
        {
            Touch t0 = Input.GetTouch(0);
            Touch t1 = Input.GetTouch(1);
            if (IsOverUI(t0.fingerId) || IsOverUI(t1.fingerId)) return;

            float dist = Vector2.Distance(t0.position, t1.position);
            if (!isPinching) { isPinching = true; prevPinch = dist; return; }

            float delta = dist - prevPinch;
            prevPinch = dist;

            float s = Mathf.Clamp(
                labRoot.transform.localScale.x + delta * zoomSpeed,
                minScale, maxScale);
            labRoot.transform.localScale = Vector3.one * s;
        }
        else
        {
            isPinching = false;
        }
    }

    // ── Helpers ────────────────────────────────────────────────────
    void SetInstruction(string text) { if (instructionText != null) instructionText.text = text; }
    void SetButtonText(string text) { if (buretteButtonText != null) buretteButtonText.text = text; }

    bool IsOverUI(int fingerId) =>
        UnityEngine.EventSystems.EventSystem.current != null &&
        UnityEngine.EventSystems.EventSystem.current.IsPointerOverGameObject(fingerId);

    bool IsOverUIPosition(Vector2 screenPos) =>
        UnityEngine.EventSystems.EventSystem.current != null &&
        UnityEngine.EventSystems.EventSystem.current.IsPointerOverGameObject();


public void NotifyFlaskMoveFinished()
    {
        if (flaskButton != null)
            flaskButton.gameObject.SetActive(false);

        if (flaskNamePanel != null)
            flaskNamePanel.SetActive(false);

        if (buretteButton != null)
            buretteButton.gameObject.SetActive(true);

        SetInstruction("Press the burette tap to begin adding acid.");
        SetButtonText("Open Tap");
    }


void CaptureFlaskStartTransform()
    {
        if (flaskAnimator == null)
            return;

        Transform flaskRig = flaskAnimator.transform;
        flaskStartLocalPosition = flaskRig.localPosition;
        flaskStartLocalRotation = flaskRig.localRotation;
        flaskStartLocalScale = flaskRig.localScale;
        flaskStartCaptured = true;
    }

    void ResetFlaskToStart()
    {
        if (flaskAnimator == null)
            return;

        flaskAnimator.ResetTrigger(flaskMoveTrigger);
        flaskAnimator.Rebind();
        flaskAnimator.Update(0f);

        if (!flaskStartCaptured)
            CaptureFlaskStartTransform();

        if (flaskStartCaptured)
        {
            Transform flaskRig = flaskAnimator.transform;
            flaskRig.localPosition = flaskStartLocalPosition;
            flaskRig.localRotation = flaskStartLocalRotation;
            flaskRig.localScale = flaskStartLocalScale;
        }
    }


public void OnFlaskButtonPressed()
    {
        if (flaskButton != null)
            flaskButton.gameObject.SetActive(false);

        if (flaskNamePanel != null)
            flaskNamePanel.SetActive(false);

        if (buretteButton != null)
            buretteButton.gameObject.SetActive(false);

        SetInstruction("Moving the conical flask beneath the burette...");

        if (flaskAnimator != null && !string.IsNullOrWhiteSpace(flaskMoveTrigger))
            flaskAnimator.SetTrigger(flaskMoveTrigger);
    }
}
