using UnityEngine;
using UnityEngine.Events;

// New drag-and-drop mechanic: the student drags the lit lamp across the table
// and under the tripod stand. Movement is horizontal-only (no lifting up/down),
// matching the "slide across a surface" feel. Requires a Collider on lampTransform
// so the drag can detect the student is actually touching the lamp.
public class LampDragController : MonoBehaviour
{
    [Header("References")]
    public Transform lampTransform;         // the object being dragged - needs a Collider
    public Transform startPosition;         // where the lamp sits before dragging begins
    public Transform tripodTargetPosition;  // where it needs to end up, under the tripod

    [Header("Drag Settings")]
    [Tooltip("How much world movement one pixel of screen drag produces. Tune to taste.")]
    public float dragSpeed = 0.01f;
    [Tooltip("How close to the target counts as 'placed correctly' and snaps into position.")]
    public float snapDistance = 0.3f;

    [Header("Events")]
    public UnityEvent OnPlacedCorrectly;

    private bool isDragging = false;
    private bool isPlaced = false;
    private Vector2 lastDragPos;

    void Update()
    {
        if (isPlaced) return; // stop listening once correctly placed

        if (Application.isEditor)
        {
            HandleMouseDrag();
        }
        else
        {
            HandleTouchDrag();
        }
    }

    private void HandleMouseDrag()
    {
        if (Input.GetMouseButtonDown(0) && IsPointerOverLamp(Input.mousePosition))
        {
            isDragging = true;
            lastDragPos = Input.mousePosition;
        }

        if (Input.GetMouseButtonUp(0) && isDragging)
        {
            isDragging = false;
            CheckPlacement();
        }

        if (isDragging && Input.GetMouseButton(0))
        {
            Vector2 delta = (Vector2)Input.mousePosition - lastDragPos;
            lastDragPos = Input.mousePosition;
            ApplyDrag(delta);
        }
    }

    private void HandleTouchDrag()
    {
        if (Input.touchCount != 1)
        {
            if (isDragging) { isDragging = false; CheckPlacement(); }
            return;
        }

        Touch t = Input.GetTouch(0);

        if (t.phase == TouchPhase.Began && IsPointerOverLamp(t.position))
        {
            isDragging = true;
            lastDragPos = t.position;
        }
        else if (t.phase == TouchPhase.Moved && isDragging)
        {
            Vector2 delta = t.position - lastDragPos;
            lastDragPos = t.position;
            ApplyDrag(delta);
        }
        else if ((t.phase == TouchPhase.Ended || t.phase == TouchPhase.Canceled) && isDragging)
        {
            isDragging = false;
            CheckPlacement();
        }
    }

    private bool IsPointerOverLamp(Vector2 screenPos)
    {
        if (UnityEngine.EventSystems.EventSystem.current != null &&
            UnityEngine.EventSystems.EventSystem.current.IsPointerOverGameObject())
        {
            return false; // don't start a drag if the touch is on a UI panel/button
        }

        if (Camera.main == null || lampTransform == null) return false;

        Ray ray = Camera.main.ScreenPointToRay(screenPos);
        if (Physics.Raycast(ray, out RaycastHit hit))
        {
            return hit.transform == lampTransform || hit.transform.IsChildOf(lampTransform);
        }
        return false;
    }

    private void ApplyDrag(Vector2 delta)
    {
        // Horizontal-only movement - X/Z, no vertical lift.
        Vector3 move = new Vector3(delta.x, 0f, delta.y) * dragSpeed;
        lampTransform.position += move;
    }

    private void CheckPlacement()
    {
        if (lampTransform == null || tripodTargetPosition == null) return;

        float dist = Vector3.Distance(lampTransform.position, tripodTargetPosition.position);
        if (dist <= snapDistance)
        {
            lampTransform.position = tripodTargetPosition.position;
            lampTransform.rotation = tripodTargetPosition.rotation;
            isPlaced = true;
            OnPlacedCorrectly?.Invoke();
        }
        // else: leave it wherever released - student can pick it up and try again
    }

    public void ResetPosition()
    {
        isPlaced = false;
        isDragging = false;

        if (lampTransform != null && startPosition != null)
        {
            lampTransform.position = startPosition.position;
            lampTransform.rotation = startPosition.rotation;
        }
    }
}
