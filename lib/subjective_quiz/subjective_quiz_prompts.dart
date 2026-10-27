import 'models/subjective_question_model.dart';

/// All Gemini prompt strings for the subjective quiz feature, kept in one
/// place for easy tuning. Edit `fewShotExamples` with real SPM-style
/// questions to anchor phrasing, command words, and mark-allocation style.
class SubjectiveQuizPrompts {
  SubjectiveQuizPrompts._();

  static const int questionCount = 3;
  static const int marksPerQuestion = 5;

  // TODO: paste your own SPM-style few-shot examples here (5-10 questions),
  // covering the command words and mark-allocation style you want Gemini to
  // imitate. Keep the format loose - Gemini just needs to see the pattern.
  static const String fewShotExamples = '''
(No few-shot examples provided yet - add SPM Form 4 Chemistry subjective
question examples here, e.g.:
"State one observation when magnesium ribbon is burned in air. [1 mark]"
"Explain why the rate of reaction increases when the concentration of acid
is increased. [3 marks]"
etc.)
''';

  static String generationPrompt({
    required String chapter,
    required String referenceContext,
  }) {
    return 'You are writing $questionCount SPM-style (Malaysian Form 4 '
        'Chemistry) subjective/structured-response exam questions for '
        'Chapter: $chapter. Each question is worth exactly '
        '$marksPerQuestion marks. Ground every question in the reference '
        'notes below when they are relevant and cover the topic. If the '
        'notes say none matched, or they don\'t cover enough to write '
        '$questionCount full questions, write the remaining questions using '
        'well-established Malaysian SPM Form 4 Chemistry syllabus knowledge '
        'for this chapter instead - never write a question about the '
        'reference notes themselves being missing or unavailable.\n\n'
        'Few-shot examples of SPM subjective question phrasing, command '
        'words, and mark-allocation style to imitate:\n$fewShotExamples\n\n'
        'Reference notes:\n$referenceContext\n\n'
        'Do not use LaTeX or any backslash-based math notation anywhere '
        '(no \\text{}, \\frac{}, \\times, \$ signs, etc.) - these questions '
        'are shown to the student as plain text with no math renderer. '
        'Write units, powers, and chemical formulas in plain characters '
        'instead, e.g. "cm^3" or "cm3" (not "\\text{cm}^3"), "25 degC" '
        '(not "25^\\circ C"), and "H2SO4" (not "H_2SO_4").\n\n'
        'For each question, also write a mark scheme: a list of distinct '
        'markable points and how many marks each is worth (or, for '
        'calculation questions, an accuracy/method mark breakdown). The '
        'marks in the mark scheme for a question must sum to exactly '
        '$marksPerQuestion. The mark scheme is never shown to the student - '
        'it is only used later to mark their answer, so it should be '
        'precise enough to mark against directly.\n\n'
        'Return only valid JSON, no markdown fences, no commentary, with '
        'exactly this schema: '
        '{"questions":[{"question":"...","marks":$marksPerQuestion,'
        '"mark_scheme":[{"point":"...","marks":0}]}]} '
        'with exactly $questionCount items in "questions".';
  }

  static String markingPrompt({
    required List<SubjectiveQuestion> questions,
    required List<String> answers,
  }) {
    final items = <String>[];
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final answer = i < answers.length ? answers[i] : '';
      final scheme = q.markScheme
          .map((p) => '- ${p.point} (${p.marks} marks)')
          .join('\n');
      items.add(
        '[${i + 1}] Question (${q.marks} marks): ${q.questionText}\n'
        'Mark scheme:\n$scheme\n\n'
        'Student\'s answer:\n$answer',
      );
    }

    return 'You are marking $questionCount SPM-style Malaysian Form 4 '
        'Chemistry subjective answers against their mark schemes. For each '
        'question, award marks only for points the student\'s answer '
        'actually demonstrates - do not award marks for points not covered '
        'in their answer, and do not penalise wording differences if the '
        'chemistry meaning is the same as a mark scheme point. '
        'marks_awarded must never exceed marks_possible. Give a short '
        'explanation (1-3 sentences) of what was correct and what was '
        'missing or wrong, referencing the mark scheme. Do not use LaTeX '
        'or any backslash-based math notation in the explanation (no '
        '\\text{}, \\frac{}, etc.) - it is shown as plain text with no math '
        'renderer, so write units and formulas in plain characters instead '
        '(e.g. "cm^3", "H2SO4").\n\n'
        '${items.join('\n\n---\n\n')}\n\n'
        'Return only valid JSON, no markdown fences, no commentary, with '
        'exactly this schema: {"results":['
        '{"marks_awarded":0,"marks_possible":${questions.isNotEmpty ? questions.first.marks : marksPerQuestion},"explanation":"..."}'
        ']} with exactly ${questions.length} items in "results", in the '
        'same order as the questions above. Use each question\'s own '
        '"marks" value (shown above) as that item\'s marks_possible.';
  }
}
