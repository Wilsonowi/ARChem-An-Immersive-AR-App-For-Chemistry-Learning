using UnityEngine;

// Replaces LampDragController.cs. Instead of manual dragging, this triggers
// YOUR hand-made Animator clip for the lamp moving under the tripod, and
// listens for one Animation Event you place inside that clip:
//   - OnMoveAnimationComplete() -> place on the clip's very last frame
public class LampAnimationController : MonoBehaviour
{
    [Header("Animator")]
    public Animator lampAnimator;
    public string moveTriggerName = "MoveToTripod";

    private System.Action onMoveComplete;

    // Called by CuCO3ExperimentFlow when the Step 2 button is pressed.
    public void PlayMoveSequence(System.Action onComplete)
    {
        onMoveComplete = onComplete;

        if (lampAnimator != null)
        {
            lampAnimator.SetTrigger(moveTriggerName);
        }
    }

    // Add an Animation Event on the clip's LAST frame that calls this
    // method by name.
    public void OnMoveAnimationComplete()
    {
        onMoveComplete?.Invoke();
        onMoveComplete = null;
    }

    // Called by CuCO3ExperimentFlow on Retry.
    public void ResetSequence()
    {
        onMoveComplete = null;

        if (lampAnimator != null)
        {
            lampAnimator.Rebind();
            lampAnimator.Update(0f);
        }
    }
}
