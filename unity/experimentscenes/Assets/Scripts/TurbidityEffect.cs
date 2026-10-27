using UnityEngine;
using System.Collections;

// Attach this to the conical flask (or a manager object) and assign the liquid
// and X-mark renderers in the Inspector. Independent of CuCO3 scripts.
public class TurbidityEffect : MonoBehaviour
{
    [Header("Visual References")]
    public Renderer liquidRenderer;   // liquid mesh inside the flask (Transparent shader)
    public Renderer xMarkRenderer;    // the 'X' mark quad/sprite viewed through the liquid

    [Header("Colors")]
    public Color clearLiquidColor = new Color32(216, 247, 255, 55);
    public Color turbidLiquidColor = new Color32(255, 211, 64, 245); // strong sulfur-yellow cloudiness

    private Coroutine activeCoroutine;

    public void StartReaction(float duration, System.Action onComplete)
    {
        if (activeCoroutine != null) StopCoroutine(activeCoroutine);
        activeCoroutine = StartCoroutine(TurbidityRoutine(duration, onComplete));
    }

    public void ResetEffect()
    {
        if (activeCoroutine != null) StopCoroutine(activeCoroutine);
        SetLiquidColor(clearLiquidColor);

        xMarkRenderer.enabled = true;
        Color c = xMarkRenderer.material.color;
        c.a = 1f;
        xMarkRenderer.material.color = c;
    }

    private IEnumerator TurbidityRoutine(float duration, System.Action onComplete)
    {
        float elapsed = 0f;
        xMarkRenderer.enabled = true;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / duration);
            // Develop the visible yellow earlier while retaining a smooth change.
            float colourProgress = Mathf.Pow(t, 0.65f);

            // Liquid gets progressively more yellow/cloudy
            SetLiquidColor(Color.Lerp(clearLiquidColor, turbidLiquidColor, colourProgress));

            // X mark fades out as if being obscured by the forming sulfur precipitate
            Color xColor = xMarkRenderer.material.color;
            xColor.a = 1f - t;
            xMarkRenderer.material.color = xColor;

            if (t >= 1f) xMarkRenderer.enabled = false;

            yield return null;
        }

        onComplete?.Invoke();
    }

    private void SetLiquidColor(Color color)
    {
        if (liquidRenderer == null) return;

        Material material = liquidRenderer.material;
        material.color = color;

        if (material.HasProperty("_BaseColor"))
            material.SetColor("_BaseColor", color);

        if (material.HasProperty("_Color"))
            material.SetColor("_Color", color);
    }
}
