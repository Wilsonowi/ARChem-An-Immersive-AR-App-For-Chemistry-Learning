using UnityEngine;

public class CuCO3RaycastButtonController : MonoBehaviour
{
    [SerializeField] private CuCO3HeatingButtonReaction reaction;
    [SerializeField] private string buttonObjectName = "StartReactionButton3D";
    [SerializeField] private Renderer buttonRenderer;
    [SerializeField] private Color pressedColor = new Color(0.85f, 0.28f, 0.05f, 1f);

    private bool hasStarted;

    private void Update()
    {
        if (hasStarted) return;

        // Mobile / device touch
        if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began)
        {
            TryRaycastFromScreenPoint(Input.GetTouch(0).position);
        }
        // Editor testing with mouse
        else if (Input.GetMouseButtonDown(0))
        {
            TryRaycastFromScreenPoint(Input.mousePosition);
        }
    }

    private void TryRaycastFromScreenPoint(Vector2 screenPosition)
    {
        Ray ray = Camera.main.ScreenPointToRay(screenPosition);
        if (Physics.Raycast(ray, out RaycastHit hit) && hit.transform.name == buttonObjectName)
        {
            PressButton();
        }
    }

    private void PressButton()
    {
        hasStarted = true; // prevents re-triggering the reaction on a second tap

        if (buttonRenderer != null)
        {
            buttonRenderer.material.color = pressedColor;
        }

        reaction.StartReaction();
    }
}