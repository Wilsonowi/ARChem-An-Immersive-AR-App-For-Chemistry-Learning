// ARChem Gemini proxy.
//
// The Flutter app sends the Gemini request body here. This function adds the
// server-only API key and forwards the request to an allowlisted Gemini model.
// Keep JWT verification enabled when deploying this function.

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
const GEMINI_BASE_URL =
  "https://generativelanguage.googleapis.com/v1beta/models";

const TEXT_MODEL = "gemini-flash-lite-latest";
const EMBEDDING_MODEL = "gemini-embedding-001";
const MAX_REQUEST_BYTES = 12 * 1024 * 1024;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type GeminiEndpoint = "generateContent" | "embedContent";

type ProxyRequest = {
  model?: unknown;
  endpoint?: unknown;
  body?: unknown;
};

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store",
    },
  });
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isAllowedCombination(model: string, endpoint: GeminiEndpoint): boolean {
  return (
    (model === TEXT_MODEL && endpoint === "generateContent") ||
    (model === EMBEDDING_MODEL && endpoint === "embedContent")
  );
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed. Use POST." }, 405);
  }

  if (!GEMINI_API_KEY) {
    console.error("GEMINI_API_KEY is missing from Edge Function secrets.");
    return jsonResponse({ error: "AI service is not configured." }, 500);
  }

  const contentLength = Number(req.headers.get("content-length") ?? 0);
  if (contentLength > MAX_REQUEST_BYTES) {
    return jsonResponse({ error: "Request is too large." }, 413);
  }

  let payload: ProxyRequest;
  try {
    payload = await req.json();
  } catch {
    return jsonResponse({ error: "Request body must be valid JSON." }, 400);
  }

  if (!isRecord(payload)) {
    return jsonResponse({ error: "Request body must be a JSON object." }, 400);
  }

  const { model, endpoint, body } = payload;
  if (
    typeof model !== "string" ||
    (endpoint !== "generateContent" && endpoint !== "embedContent") ||
    !isRecord(body)
  ) {
    return jsonResponse(
      { error: 'Request must contain valid "model", "endpoint", and "body".' },
      400,
    );
  }

  if (!isAllowedCombination(model, endpoint)) {
    return jsonResponse(
      { error: "The requested Gemini model and endpoint are not allowed." },
      400,
    );
  }

  try {
    const geminiResponse = await fetch(
      `${GEMINI_BASE_URL}/${model}:${endpoint}?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(55_000),
      },
    );

    const responseBody = await geminiResponse.text();

    if (!geminiResponse.ok) {
      console.error(
        `Gemini ${endpoint} failed with status ${geminiResponse.status}: ${responseBody}`,
      );

      let upstreamError: unknown;
      try {
        upstreamError = JSON.parse(responseBody);
      } catch {
        upstreamError = { message: "Gemini returned a non-JSON error." };
      }

      return jsonResponse(
        {
          error: "Gemini request failed.",
          upstreamStatus: geminiResponse.status,
          details: upstreamError,
        },
        geminiResponse.status,
      );
    }

    return new Response(responseBody, {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json; charset=utf-8",
        "Cache-Control": "no-store",
      },
    });
  } catch (error) {
    const timedOut = error instanceof DOMException && error.name === "TimeoutError";
    console.error("Gemini proxy request failed:", error);
    return jsonResponse(
      { error: timedOut ? "Gemini request timed out." : "AI service unavailable." },
      timedOut ? 504 : 502,
    );
  }
});
