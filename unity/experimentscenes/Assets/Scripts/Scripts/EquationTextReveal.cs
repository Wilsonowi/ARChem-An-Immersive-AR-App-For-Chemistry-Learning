using System.Collections;
using TMPro;
using UnityEngine;

public class EquationTextReveal : MonoBehaviour
{
    [SerializeField] private TextMeshPro equationText;
    [SerializeField] private float fadeDuration = 1.25f;

    private Coroutine revealRoutine;

    public float FadeDuration => fadeDuration;

    private void Awake()
    {
        if (equationText == null)
        {
            equationText = GetComponent<TextMeshPro>();
        }

        SetAlpha(0f);
    }

    private void OnEnable()
    {
        SetAlpha(0f);
    }

    public void Reveal()
    {
        if (revealRoutine != null)
        {
            StopCoroutine(revealRoutine);
        }

        revealRoutine = StartCoroutine(FadeIn());
    }

    private IEnumerator FadeIn()
    {
        float elapsed = 0f;

        while (elapsed < fadeDuration)
        {
            elapsed += Time.deltaTime;
            SetAlpha(Mathf.Clamp01(elapsed / fadeDuration));
            yield return null;
        }

        SetAlpha(1f);
        revealRoutine = null;
    }

    private void SetAlpha(float alpha)
    {
        if (equationText == null)
        {
            return;
        }

        Color color = equationText.color;
        color.a = alpha;
        equationText.color = color;
    }
}
