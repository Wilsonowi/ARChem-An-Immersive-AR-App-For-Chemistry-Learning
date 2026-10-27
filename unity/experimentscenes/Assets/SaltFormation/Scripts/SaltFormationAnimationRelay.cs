using UnityEngine;

/// <summary>
/// Receives Animation Events and forwards them to the SaltFormation experiment controller.
/// Add this component to each animated apparatus, then select the matching public method
/// in an Animation Event placed at the end of its clip.
/// </summary>
public sealed class SaltFormationAnimationRelay : MonoBehaviour
{
    [SerializeField] private SaltFormationExperimentController controller;

    public void SpoonPourFinished()
    {
        if (controller != null)
        {
            controller.NotifySpoonPourFinished();
        }
    }

    public void Beaker1PourFinished()
    {
        if (controller != null)
        {
            controller.NotifyBeaker1PourFinished();
        }
    }

    public void Beaker2PourFinished()
    {
        if (controller != null)
        {
            controller.NotifyBeaker2PourFinished();
        }
    }

public void ChinaDishMoveFinished()
    {
        if (controller != null)
        {
            controller.NotifyChinaDishMoveFinished();
        }
    }


    public void LighterIgnitionFinished()
    {
        if (controller != null)
        {
            controller.NotifyLighterIgnitionFinished();
        }
    }

    public void CrystalTransferFinished()
    {
        if (controller != null)
        {
            controller.NotifyCrystalTransferFinished();
        }
    }

    public void DrySaltsFinished()
    {
        if (controller != null)
        {
            controller.NotifyDrySaltsFinished();
        }
    }
}
