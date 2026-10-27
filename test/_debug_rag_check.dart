// Throwaway live diagnostic — hits the real Supabase chemistry_knowledge
// table and the real Gemini API. Not a committed test; delete after use.
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archem/services/gemini_service.dart';
import 'package:archem/services/supabase_service.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://ysqpaxwpszyldqhevcfo.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzcXBheHdwc3p5bGRxaGV2Y2ZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyOTUxODgsImV4cCI6MjA5Njg3MTE4OH0.ZBd9c-ISlM_yz-atataMNc5MsAJyBaSwvbEMN6FazPE',
    );
  });

  test('RAG retrieval returns relevant chunks for an in-syllabus question', () async {
    const question = 'What is the mole concept and how do you calculate the number of moles?';

    final embedding = await GeminiService.instance.embedText(
      question,
      taskType: 'RETRIEVAL_QUERY',
    );
    print('Embedding length: ${embedding.length}');

    final matches = await SupabaseService.instance.matchChemistryKnowledge(
      embedding: embedding,
      matchCount: 5,
    );

    print('\n--- Retrieved chunks for: "$question" ---');
    for (final m in matches) {
      print(
        'similarity=${(m['similarity'] as num).toStringAsFixed(3)} '
        '| Ch${m['chapter_number']} ${m['topic_title']} (${m['section']})',
      );
    }

    final aboveThreshold = matches.where((m) => (m['similarity'] as num) >= 0.55).toList();
    print('${aboveThreshold.length}/${matches.length} chunks passed the 0.55 relevance threshold');

    expect(matches, isNotEmpty, reason: 'Expected at least one retrieved chunk');
    expect(aboveThreshold, isNotEmpty, reason: 'Expected at least one chunk above the relevance threshold for a clearly in-syllabus question');
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('RAG-grounded tutor reply is produced end-to-end', () async {
    const question = 'Explain the difference between exothermic and endothermic reactions.';

    final reply = await GeminiService.instance.sendRagTutorMessage(
      message: question,
      history: const [],
    );

    print('\n--- RAG tutor reply for: "$question" ---');
    print(reply);

    expect(reply, isNotEmpty);
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('Fallback still answers gracefully for an out-of-syllabus question', () async {
    const question = 'What is the capital city of France?';

    final embedding = await GeminiService.instance.embedText(
      question,
      taskType: 'RETRIEVAL_QUERY',
    );
    final matches = await SupabaseService.instance.matchChemistryKnowledge(
      embedding: embedding,
      matchCount: 5,
    );
    final aboveThreshold = matches.where((m) => (m['similarity'] as num) >= 0.55).toList();

    print('\n--- Out-of-syllabus retrieval check ---');
    print('${aboveThreshold.length}/${matches.length} chunks passed the relevance threshold (expected low/zero)');

    final reply = await GeminiService.instance.sendRagTutorMessage(
      message: question,
      history: const [],
    );
    print('Reply: $reply');

    expect(reply, isNotEmpty, reason: 'Should still reply gracefully with no relevant grounding');
  }, timeout: const Timeout(Duration(seconds: 30)));
}
