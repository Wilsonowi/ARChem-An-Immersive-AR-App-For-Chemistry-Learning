using UnityEngine;

/// <summary>
/// Controls the visible fill level of the liquid in the evaporating dish.
/// This script only changes a dedicated liquid mesh; it does not modify the dish model.
/// </summary>
public sealed class SaltFormationLiquidLevel : MonoBehaviour
{
    [SerializeField] private Transform liquidTransform;
    [SerializeField, Min(0.001f)] private float meshHeightAtScaleOne = 1f;
    [SerializeField, Range(0f, 0.2f)] private float minimumVisibleScale = 0.01f;
    [SerializeField] private bool keepBottomFixed = true;

    private Vector3 initialLocalScale;
    private Vector3 initialLocalPosition;
    private bool initialized;

    private void Awake()
    {
        InitializeIfNeeded();
    }

    private void InitializeIfNeeded()
    {
        if (initialized)
        {
            return;
        }

        if (liquidTransform == null)
        {
            liquidTransform = transform;
        }

        initialLocalScale = liquidTransform.localScale;
        initialLocalPosition = liquidTransform.localPosition;
        initialized = true;
    }

    /// <summary>
    /// Sets the liquid amount from 0 (empty) to 1 (full).
    /// </summary>
    public void SetNormalizedLevel(float amount)
    {
        InitializeIfNeeded();

        amount = Mathf.Clamp01(amount);
        float visibleAmount = amount <= 0f ? minimumVisibleScale : Mathf.Max(amount, minimumVisibleScale);

        Vector3 newScale = initialLocalScale;
        newScale.y = initialLocalScale.y * visibleAmount;
        liquidTransform.localScale = newScale;

        Vector3 newPosition = initialLocalPosition;
        if (keepBottomFixed)
        {
            float removedHeight = (initialLocalScale.y - newScale.y) * meshHeightAtScaleOne;
            newPosition.y -= removedHeight * 0.5f;
        }

        liquidTransform.localPosition = newPosition;
    }

    public void SetVisible(bool visible)
    {
        InitializeIfNeeded();
        liquidTransform.gameObject.SetActive(visible);
    }

    public void ResetLevel()
    {
        InitializeIfNeeded();
        liquidTransform.localScale = initialLocalScale;
        liquidTransform.localPosition = initialLocalPosition;
    }
}
