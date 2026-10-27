using UnityEngine;
using UnityEngine.UI;

// New, standalone script. Attach to your ExperimentManager (or any object)
// in the Rate of Reaction scene.
public class IntroPanelController : MonoBehaviour
{
    [Header("Intro Panel")]
    public GameObject introPanel;
    public Button startButton;

    [Header("Panels to reveal only after dismissal (optional)")]
    public GameObject[] panelsToRevealAfterIntro; // e.g. SetupTrial, LiveReadout

    void Start()
    {
        if (introPanel != null)
        {
            introPanel.SetActive(true);
        }

        SetOtherPanelsActive(false);

        if (startButton != null)
        {
            startButton.onClick.AddListener(DismissIntro);
        }
    }

    private void DismissIntro()
    {
        if (introPanel != null)
        {
            introPanel.SetActive(false);
        }

        SetOtherPanelsActive(true);
    }

    private void SetOtherPanelsActive(bool active)
    {
        if (panelsToRevealAfterIntro == null) return;

        foreach (GameObject panel in panelsToRevealAfterIntro)
        {
            if (panel != null)
            {
                panel.SetActive(active);
            }
        }
    }
}
