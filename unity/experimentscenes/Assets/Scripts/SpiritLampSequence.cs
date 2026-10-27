using UnityEngine;
using System.Collections;

// Attach to any manager object. Owns the full sequence:
// 1) lighter moves up to the lamp's wick
// 2) flame ignites the instant it arrives
// 3) lighter retracts back to its resting spot
// 4) the now-lit lamp travels under the test tubes
// 5) hand off to the existing CuCO3HeatingButtonReaction for gas/blackening/cloudy timers
public class SpiritLampSequence : MonoBehaviour
{
    [Header("Existing Reaction Script")]
    public CuCO3HeatingButtonReaction reactionScript;

    [Header("Lighter Prop")]
    public Transform lighterTransform;     // the lighter model that moves
    public Transform lighterRestPosition;  // where the lighter starts/ends (e.g. resting on the table)
    public Transform lampWickPosition;     // where the lighter's tip needs to be to "touch" the wick

    [Header("Lighter Timing")]
    [Tooltip("Time for the lighter to travel from its resting spot up to the wick.")]
    public float lighterMoveInDuration = 1f;
    [Tooltip("How long the lighter stays at the wick while the flame catches.")]
    public float lighterHoldDuration = 0.5f;
    [Tooltip("Time for the lighter to travel back to its resting spot.")]
    public float lighterMoveOutDuration = 1f;

    [Header("Lamp Movement")]
    public Transform lampTransform;   // the lamp object that actually moves
    public Transform restPosition;    // empty GameObject marking the lamp's starting spot
    public Transform heatingPosition; // empty GameObject marking the under-the-tubes spot
    [Tooltip("Time for the lit lamp to travel from its resting spot to under the test tubes.")]
    public float lampMoveDuration = 1.5f;

    private bool sequenceStarted = false;

    public void PlayFullSequence()
    {
        if (sequenceStarted) return; // guard against double-clicks mid-sequence
        sequenceStarted = true;
        StartCoroutine(SequenceRoutine());
    }

    public void ResetSequence()
    {
        sequenceStarted = false;
        StopAllCoroutines();

        if (lighterTransform != null && lighterRestPosition != null)
        {
            lighterTransform.position = lighterRestPosition.position;
            lighterTransform.rotation = lighterRestPosition.rotation;
        }
        if (lampTransform != null && restPosition != null)
        {
            lampTransform.position = restPosition.position;
            lampTransform.rotation = restPosition.rotation;
        }
    }

    private IEnumerator SequenceRoutine()
    {
        // 1: lighter travels up to the wick
        yield return MoveTransform(lighterTransform, lampWickPosition, lighterMoveInDuration);

        // 2: the instant it arrives, the flame ignites (same GameObject your
        // CuCO3HeatingButtonReaction already uses for gas/blackening timing)
        if (reactionScript != null)
        {
            reactionScript.IgniteFireOnly();
        }

        yield return new WaitForSeconds(lighterHoldDuration);

        // 3: lighter retracts
        yield return MoveTransform(lighterTransform, lighterRestPosition, lighterMoveOutDuration);

        // 4: move the now-lit lamp under the test tubes
        yield return MoveTransform(lampTransform, heatingPosition, lampMoveDuration);

        // 5: hand off to the existing script - gas/blackening/cloudy timers
        // start counting from THIS moment, not from the button press.
        if (reactionScript != null)
        {
            reactionScript.StartReaction();
        }
    }

    // Shared mover used for both the lighter and the lamp - avoids duplicating
    // the same lerp/easing logic twice.
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
            t = t * t * (3f - 2f * t); // smoothstep easing, feels less robotic than linear

            obj.position = Vector3.Lerp(startPos, target.position, t);
            obj.rotation = Quaternion.Slerp(startRot, target.rotation, t);

            yield return null;
        }

        obj.position = target.position;
        obj.rotation = target.rotation;
    }
}
