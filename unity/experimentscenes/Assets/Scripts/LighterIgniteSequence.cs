using UnityEngine;
using System.Collections;

// Replaces the lamp-moving part of the old SpiritLampSequence. This script
// ONLY handles the lighter prop: move to wick, ignite fire, retract.
// The lamp's move into heating position is now a manual drag (see LampDragController).
public class LighterIgniteSequence : MonoBehaviour
{
    [Header("Existing Reaction Script")]
    public CuCO3HeatingButtonReaction reactionScript;

    [Header("Lighter Prop")]
    public Transform lighterTransform;
    public Transform lighterRestPosition;
    public Transform lampWickPosition;

    [Header("Timing")]
    [Tooltip("How long the lighter's move-to-wick animation takes visually.")]
    public float lighterMoveInDuration = 2f;
    [Tooltip("Fixed delay from button press until the flame ignites, per the experiment spec.")]
    public float fireIgniteDelay = 2f;
    [Tooltip("How long the lighter lingers at the wick after ignition before retracting.")]
    public float lighterHoldDuration = 0.5f;
    [Tooltip("Time for the lighter to travel back to its resting spot.")]
    public float lighterMoveOutDuration = 1f;

    private bool isPlaying = false;

    public void PlayIgniteSequence(System.Action onComplete)
    {
        if (isPlaying) return;
        isPlaying = true;
        StartCoroutine(Routine(onComplete));
    }

    public void ResetSequence()
    {
        isPlaying = false;
        StopAllCoroutines();

        if (lighterTransform != null && lighterRestPosition != null)
        {
            lighterTransform.position = lighterRestPosition.position;
            lighterTransform.rotation = lighterRestPosition.rotation;
        }
    }

    private IEnumerator Routine(System.Action onComplete)
    {
        // Lighter starts travelling toward the wick...
        StartCoroutine(MoveTransform(lighterTransform, lampWickPosition, lighterMoveInDuration));

        // ...independently, ignite fires at a fixed delay from button press.
        yield return new WaitForSeconds(fireIgniteDelay);
        if (reactionScript != null)
        {
            reactionScript.IgniteFireOnly();
        }

        yield return new WaitForSeconds(lighterHoldDuration);
        yield return MoveTransform(lighterTransform, lighterRestPosition, lighterMoveOutDuration);

        isPlaying = false;
        onComplete?.Invoke();
    }

    private IEnumerator MoveTransform(Transform obj, Transform target, float duration)
    {
        if (obj == null || target == null) yield break;

        Vector3 startPos = obj.position;
        Quaternion startRot = obj.rotation;
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / duration);
            t = t * t * (3f - 2f * t); // smoothstep easing

            obj.position = Vector3.Lerp(startPos, target.position, t);
            obj.rotation = Quaternion.Slerp(startRot, target.rotation, t);

            yield return null;
        }

        obj.position = target.position;
        obj.rotation = target.rotation;
    }
}
