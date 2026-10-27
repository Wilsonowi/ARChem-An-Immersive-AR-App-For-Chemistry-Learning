using UnityEngine;

public sealed class NeutralisationAnimationRelay : MonoBehaviour
{
    [SerializeField] private Neutralisation controller;

    public void FlaskMoveFinished()
    {
        if (controller != null)
        {
            controller.NotifyFlaskMoveFinished();
        }
    }
}
