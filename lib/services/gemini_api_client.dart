import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class GeminiApiClient {
  GeminiApiClient._();
  static final GeminiApiClient instance = GeminiApiClient._();

  static const String textModel = 'gemini-flash-lite-latest';
  static const String embeddingModel = 'gemini-embedding-001';
  static const String _functionName = 'gemini-proxy';

  Future<String> generateText({
    required String prompt,
    required Duration timeout,
    Map<String, dynamic>? generationConfig,
  }) async {
    final data = await _invokeProxy(
      model: textModel,
      endpoint: 'generateContent',
      geminiBody: {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        if (generationConfig != null) 'generationConfig': generationConfig,
      },
      timeout: timeout,
    );
    return data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String? ??
        '';
  }

  Future<Map<String, dynamic>> generateJson({
    required String prompt,
    required Duration timeout,
    Map<String, dynamic>? generationConfig,
    String Function(String text)? cleanJsonText,
  }) async {
    final text = await generateText(
      prompt: prompt,
      timeout: timeout,
      generationConfig: generationConfig,
    );
    return parseJsonText(text, cleanJsonText: cleanJsonText);
  }

  Future<Map<String, dynamic>> generateVisionJson({
    required String prompt,
    required Uint8List imageBytes,
    required String mimeType,
    required Duration timeout,
    Map<String, dynamic>? generationConfig,
  }) async {
    final data = await _invokeProxy(
      model: textModel,
      endpoint: 'generateContent',
      geminiBody: {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inlineData': {
                  'mimeType': mimeType,
                  'data': base64Encode(imageBytes),
                },
              },
            ],
          },
        ],
        if (generationConfig != null) 'generationConfig': generationConfig,
      },
      timeout: timeout,
    );
    final text =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ??
        '';
    return parseJsonText(text);
  }

  Future<List<double>> embedText({
    required String text,
    String taskType = 'RETRIEVAL_QUERY',
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final data = await _invokeProxy(
      model: embeddingModel,
      endpoint: 'embedContent',
      geminiBody: {
        'model': 'models/$embeddingModel',
        'content': {
          'parts': [
            {'text': text},
          ],
        },
        'taskType': taskType,
        'outputDimensionality': 768,
      },
      timeout: timeout,
    );
    final values = (data['embedding']?['values'] as List?)?.cast<num>();
    if (values == null) {
      throw const FormatException('Missing embedding values');
    }
    return values.map((v) => v.toDouble()).toList();
  }

  Map<String, dynamic> parseJsonText(
    String text, {
    String Function(String text)? cleanJsonText,
  }) {
    final cleaned = cleanJsonText?.call(text) ?? cleanMarkdownJson(text);
    final decoded = jsonDecode(cleaned);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('Gemini returned non-object JSON');
  }

  String cleanMarkdownJson(String text) {
    return text.replaceAll('```json', '').replaceAll('```', '').trim();
  }

  Future<Map<String, dynamic>> _invokeProxy({
    required String model,
    required String endpoint,
    required Map<String, dynamic> geminiBody,
    required Duration timeout,
  }) async {
    final response = await Supabase.instance.client.functions
        .invoke(
          _functionName,
          body: {
            'model': model,
            'endpoint': endpoint,
            'body': geminiBody,
          },
        )
        .timeout(timeout);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    throw const FormatException('Gemini proxy returned invalid JSON');
  }
}
