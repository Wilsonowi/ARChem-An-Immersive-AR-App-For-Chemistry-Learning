import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_plan_stage.dart';
import '../models/user_model.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ── AUTH ──────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isLoggedIn => currentUser != null;
  String? get accessToken => currentSession?.accessToken;
  String? get userId => currentUser?.id;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password.
  /// Passes username and full_name as metadata for the trigger.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username, 'full_name': fullName},
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── PROFILE ───────────────────────────────────────────

  /// Fetch current user profile from Supabase.
  Future<UserModel?> fetchProfile() async {
    final uid = userId;
    if (uid == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// Update profile fields.
  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
    bool? hasCompletedDiagnostic,
  }) async {
    final uid = userId;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (hasCompletedDiagnostic != null)
      updates['has_completed_diagnostic'] = hasCompletedDiagnostic;

    if (updates.isEmpty) return;

    await _client.from('profiles').update(updates).eq('id', uid);
  }

  // ── PROGRESS ──────────────────────────────────────────

  /// Fetch all progress rows for current user.
  Future<List<Map<String, dynamic>>> fetchProgress() async {
    final uid = userId;
    if (uid == null) return [];

    final response = await _client
        .from('progress')
        .select()
        .eq('user_id', uid)
        .order('chapter_number');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Save or update progress for a chapter.
  Future<void> saveProgress({
    required String chapter,
    required int chapterNumber,
    String? subtopic,
    int? quizScore,
    int? maxScore,
    bool? experimentDone,
  }) async {
    final uid = userId;
    if (uid == null) return;

    // Check if record exists
    final existing = await _client
        .from('progress')
        .select('id')
        .eq('user_id', uid)
        .eq('chapter', chapter)
        .maybeSingle();

    final data = <String, dynamic>{
      'user_id': uid,
      'chapter': chapter,
      'chapter_number': chapterNumber,
      if (subtopic != null) 'subtopic': subtopic,
      if (quizScore != null) 'quiz_score': quizScore,
      if (maxScore != null) 'max_score': maxScore,
      if (experimentDone != null) 'experiment_done': experimentDone,
    };

    if (existing == null) {
      await _client.from('progress').insert(data);
    } else {
      data.remove('user_id');
      data.remove('chapter');
      data.remove('chapter_number');
      await _client
          .from('progress')
          .update(data)
          .eq('user_id', uid)
          .eq('chapter', chapter);
    }
  }

  // ── QUIZ HISTORY ──────────────────────────────────────

  /// Save a single quiz question result.
  Future<void> saveQuizQuestion({
    required String chapter,
    required int chapterNumber,
    String? subtopic,
    required String questionText,
    String? selectedAnswer,
    required String correctAnswer,
    required bool isCorrect,
    String? explanation,
  }) async {
    final uid = userId;
    if (uid == null) return;

    await _client.from('quiz_history').insert({
      'user_id': uid,
      'chapter': chapter,
      'chapter_number': chapterNumber,
      'subtopic': subtopic,
      'question_text': questionText,
      'selected_answer': selectedAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'explanation': explanation,
    });
  }

  /// Save multiple quiz question results in a single request, instead of
  /// one round trip per question.
  Future<void> saveQuizQuestions(List<Map<String, dynamic>> results) async {
    final uid = userId;
    if (uid == null || results.isEmpty) return;

    final rows = results
        .map(
          (r) => {
            'user_id': uid,
            'chapter': r['chapter'],
            'chapter_number': r['chapter_number'],
            'subtopic': r['subtopic'],
            'question_text': r['question_text'],
            'selected_answer': r['selected_answer'],
            'correct_answer': r['correct_answer'],
            'is_correct': r['is_correct'],
            'explanation': r['explanation'],
          },
        )
        .toList();

    await _client.from('quiz_history').insert(rows);
  }

  // ── CHAT HISTORY ──────────────────────────────────────

  /// Save one question/answer turn from the AI tutor chat.
  Future<void> saveChatTurn({
    required String question,
    required String answer,
  }) async {
    final uid = userId;
    if (uid == null) return;

    await _client.from('chat_history').insert({
      'user_id': uid,
      'question': question,
      'answer': answer,
    });
  }

  /// Fetch the most recent [limit] question/answer turns, oldest first (so
  /// callers can append them directly to a chat transcript in reading
  /// order).
  Future<List<Map<String, dynamic>>> fetchRecentChatHistory({
    int limit = 10,
  }) async {
    final uid = userId;
    if (uid == null) return [];

    final response = await _client
        .from('chat_history')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response).reversed.toList();
  }

  // ── DIAGNOSTIC ────────────────────────────────────────

  /// Save diagnostic results for all chapters.
  Future<void> saveDiagnosticResults(List<Map<String, dynamic>> results) async {
    final uid = userId;
    if (uid == null) return;

    final rows = results
        .map(
          (r) => {
            'user_id': uid,
            'chapter': r['chapter'],
            'chapter_number': r['chapter_number'],
            'subtopic': r['subtopic'],
            'score': r['score'],
            'max_score': r['max_score'],
          },
        )
        .toList();

    await _client.from('diagnostic_results').insert(rows);
  }

  // ── STUDY PLAN ────────────────────────────────────────

  /// Fetch latest study plan.
  Future<Map<String, dynamic>?> fetchStudyPlan() async {
    final uid = userId;
    if (uid == null) return null;

    final response = await _client
        .from('study_plans')
        .select()
        .eq('user_id', uid)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response;
  }

  /// Save or update study plan.
  Future<void> saveStudyPlan({
    required Map<String, dynamic> plan,
    required List<String> weakChapters,
    required List<String> strongChapters,
    required int examReadinessPercent,
  }) async {
    final uid = userId;
    if (uid == null) return;

    // Check if plan exists
    final existing = await _client
        .from('study_plans')
        .select('id')
        .eq('user_id', uid)
        .maybeSingle();

    final data = {
      'user_id': uid,
      'plan': StudyPlanStage.normalizePlan(plan),
      'weak_chapters': weakChapters,
      'strong_chapters': strongChapters,
      'exam_readiness_percent': examReadinessPercent,
    };

    if (existing == null) {
      await _client.from('study_plans').insert(data);
    } else {
      await _client.from('study_plans').update(data).eq('user_id', uid);
    }
  }

  // ── AR EXPERIMENT RESULTS ─────────────────────────────

  /// Update only the JSON plan payload for the current user's study plan.
  Future<void> updateStudyPlanPayload(Map<String, dynamic> plan) async {
    final uid = userId;
    if (uid == null) return;

    await _client
        .from('study_plans')
        .update({'plan': StudyPlanStage.normalizePlan(plan)})
        .eq('user_id', uid);
  }

  Future<Map<String, dynamic>?> fetchNormalizedStudyPlanPayload() async {
    final raw = await fetchStudyPlan();
    if (raw == null) return null;

    final plan = Map<String, dynamic>.from(raw['plan'] as Map? ?? {});
    final normalized = StudyPlanStage.normalizePlan(plan);
    if (normalized.toString() != plan.toString()) {
      await updateStudyPlanPayload(normalized);
    }
    return normalized;
  }

  Future<void> markStudyPlanStageProgress({
    required int chapterNumber,
    bool lectureCompleted = false,
    bool quizCompleted = false,
  }) async {
    final raw = await fetchStudyPlan();
    if (raw == null) return;

    final plan = Map<String, dynamic>.from(raw['plan'] as Map? ?? {});
    final updated = StudyPlanStage.markProgress(
      plan: plan,
      chapterNumber: chapterNumber,
      lectureCompleted: lectureCompleted,
      quizCompleted: quizCompleted,
    );
    await updateStudyPlanPayload(updated);
  }

  /// Save AR experiment result sent back from Unity.
  Future<void> saveARResult({
    required String experimentName,
    required String chapter,
    required int chapterNumber,
    String? subtopic,
    int? score,
    int? maxScore,
    Map<String, dynamic>? payload,
  }) async {
    final uid = userId;
    if (uid == null) return;

    await _client.from('ar_experiment_results').insert({
      'user_id': uid,
      'experiment_name': experimentName,
      'chapter': chapter,
      'chapter_number': chapterNumber,
      'subtopic': subtopic,
      'score': score,
      'max_score': maxScore,
      'result_payload': payload ?? {},
    });
  }

  // ── RAG KNOWLEDGE BASE ─────────────────────────────────

  /// Retrieve the top matching chemistry knowledge chunks for a query
  /// embedding, via the `match_chemistry_knowledge` Postgres function.
  Future<List<Map<String, dynamic>>> matchChemistryKnowledge({
    required List<double> embedding,
    int matchCount = 5,
  }) async {
    final response = await _client.rpc(
      'match_chemistry_knowledge',
      params: {'query_embedding': embedding, 'match_count': matchCount},
    );
    return List<Map<String, dynamic>>.from(response as List);
  }
}
