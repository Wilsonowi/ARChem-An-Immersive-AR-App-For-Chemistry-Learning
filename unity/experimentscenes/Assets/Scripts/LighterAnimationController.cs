using UnityEngine;

// Replaces LighterIgniteSequence.cs. Instead of scripting the movement,
// this just triggers YOUR hand-made Animator clip and listens for two
// Animation Events you place inside that clip:
//   - OnLighterTouchedWick()   -> place at the exact frame the flame touches the wick
//   - OnIgniteAnimationComplete() -> place on the clip's very last frame
public class LighterAnimationController : MonoBehaviour
{
    [Header("Existing Reaction Script")]
    public CuCO3HeatingButtonReaction reactionScript;

    [Header("Animator")]
    public Animator lighterAnimator;
    public string igniteTriggerName = "Ignite";

    private System.Action onSequenceComplete;

    // Called by CuCO3ExperimentFlow when the Step 1 button is pressed.
    public void PlayIgniteSequence(System.Action onComplete)
    {
        onSequenceComplete = onComplete;

        if (lighterAnimator != null)
        {
            lighterAnimator.SetTrigger(igniteTriggerName);
        }
    }

    // Add an Animation Event in your clip, at the frame the lighter touches
    // the wick, that calls this method by name.
    public void OnLighterTouchedWick()
    {
        if (reactionScript != null)
        {
            reactionScript.IgniteFireOnly();
        }
    }

    // Add an Animation Event on the clip's LAST frame that calls this
    // method by name - this is what tells the flow controller to move on.
    public void OnIgniteAnimationComplete()
    {
        onSequenceComplete?.Invoke();
        onSequenceComplete = null;
    }

    // Called by CuCO3ExperimentFlow on Retry.
    public void ResetSequence()
    {
        onSequenceComplete = null;

        if (lighterAnimator != null)
        {
            lighterAnimator.Rebind(); // snaps back to the Animator's default state instantly
            lighterAnimator.Update(0f);
        }
    }
}
