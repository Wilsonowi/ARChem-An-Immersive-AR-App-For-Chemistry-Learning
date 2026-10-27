/// Picks follow-up quick-prompt suggestions based on keywords in the
/// tutor's last reply, so the chip row feels contextual without needing an
/// extra Gemini call. Falls back to a general default set when nothing
/// matches.
class ChatSuggestions {
  ChatSuggestions._();

  static const List<String> defaultPrompts = [
    'What is neutralisation?',
    'Explain mole concept',
    'Compare acid and alkaline',
  ];

  static const Map<String, List<String>> _keywordPrompts = {
    'mole': [
      'Explain molar mass',
      'Give a mole calculation example',
      "What is Avogadro's number?",
    ],
    'acid': [
      'Difference between strong and weak acids',
      'What is pH?',
      'Explain neutralisation',
    ],
    'alkali': [
      'What is pH?',
      'Explain neutralisation',
      'Give an example of an alkali',
    ],
    'bond': [
      'Ionic vs covalent bond',
      'What is a dative bond?',
      'Explain metallic bonding',
    ],
    'equation': [
      'How do I balance this equation?',
      'What are state symbols?',
      'Explain limiting reagent',
    ],
    'rate of reaction': [
      'Factors affecting rate of reaction',
      'Explain collision theory',
      'What is activation energy?',
    ],
    'periodic table': [
      'Explain group trends',
      'What is atomic radius?',
      'Explain Group 18 elements',
    ],
    'atom': [
      'Explain electron arrangement',
      'What are isotopes?',
      'Describe the atomic model',
    ],
    'salt': [
      'How do I prepare a soluble salt?',
      'Explain the precipitation method',
      'What is crystallisation?',
    ],
    'titration': [
      'Explain a titration experiment',
      'What indicator should I use?',
      'How do I calculate concentration?',
    ],
  };

  /// Returns 3 follow-up prompts relevant to [botReply], or [defaultPrompts]
  /// if nothing matched.
  static List<String> forReply(String botReply) {
    final lower = botReply.toLowerCase();
    for (final entry in _keywordPrompts.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return defaultPrompts;
  }
}
