using System.Collections;
using UnityEngine;
using Vuforia;

public class ReactionController : MonoBehaviour
{
    [SerializeField] private Animator reactionAnimator;
    [SerializeField] private string animationTriggerName = "StartReaction";
    [SerializeField] private ParticleSystem gasBubbles;
    [SerializeField] private ParticleSystem secondaryEffect;
    [SerializeField] private float secondaryDelay = 1f;
    [SerializeField] private EquationTextReveal equationText;
    [SerializeField] private float equationDelay = 2.5f;

    private ObserverBehaviour observerBehaviour;
    private bool hasPlayed;

    private void Awake()
    {
        observerBehaviour = GetComponentInParent<ObserverBehaviour>();
    }

    private void OnEnable()
    {
        if (observerBehaviour == null)
        {
            observerBehaviour = GetComponentInParent<ObserverBehaviour>();
        }

        if (observerBehaviour != null)
        {
            observerBehaviour.OnTargetStatusChanged += HandleTargetStatusChanged;
        }
    }

    private void OnDisable()
    {
        if (observerBehaviour != null)
        {
            observerBehaviour.OnTargetStatusChanged -= HandleTargetStatusChanged;
        }
    }

    private void HandleTargetStatusChanged(ObserverBehaviour behaviour, TargetStatus status)
    {
        if (hasPlayed || !IsTracked(status.Status))
        {
            return;
        }

        hasPlayed = true;
        StartCoroutine(PlayReactionSequence());
    }

    private static bool IsTracked(Status status)
    {
        return status == Status.TRACKED || status == Status.EXTENDED_TRACKED || status == Status.LIMITED;
    }

    private IEnumerator PlayReactionSequence()
    {
        if (reactionAnimator != null && !string.IsNullOrWhiteSpace(animationTriggerName))
        {
            reactionAnimator.SetTrigger(animationTriggerName);
        }

        if (gasBubbles != null)
        {
            gasBubbles.Play(true);
        }

        if (secondaryDelay > 0f)
        {
            yield return new WaitForSeconds(secondaryDelay);
        }

        if (secondaryEffect != null)
        {
            secondaryEffect.Play(true);
        }

        float remainingEquationDelay = Mathf.Max(0f, equationDelay - secondaryDelay);
        if (remainingEquationDelay > 0f)
        {
            yield return new WaitForSeconds(remainingEquationDelay);
        }

        if (equationText != null)
        {
            equationText.Reveal();
            yield return new WaitForSeconds(equationText.FadeDuration);
        }

        FlutterBridge.NotifyFlutterComplete();
    }
}
