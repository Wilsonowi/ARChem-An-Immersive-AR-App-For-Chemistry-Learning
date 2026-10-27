import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../splash_screen.dart';
import '../onboarding_screen.dart';
import '../login_screen.dart';
import '../register_screen.dart';
import '../auth/auth_controller.dart';

import '../home/home_screen.dart';
import '../chapters/chapters_list_screen.dart';
import '../profiles/profiles.dart';

import '../diagnostic/diagnostic_screen.dart';
import '../weekly_plan/weekly_plan_screen.dart';
import '../quiz/quiz_menu_screen.dart';
import '../quiz/quiz_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../experiments/experiment_menu_screen.dart';
import '../experiments/unity_experiment_screen.dart';
import '../widgets/chemistry_background.dart';
import '../subjective_quiz/quiz_type_selection_screen.dart';
import '../quiz_history/quiz_history_screen.dart';
import '../subjective_quiz/subjective_chapter_menu_screen.dart';
import '../subjective_quiz/subjective_question_screen.dart';

// â”€â”€ LECTURE SCREENS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
import '../lecture_screen/c1.dart';
import '../lecture_screen/c2.dart';
import '../lecture_screen/c3.dart';
import '../lecture_screen/c4.dart';
import '../lecture_screen/c5.dart';
import '../lecture_screen/c6.dart';
import '../lecture_screen/c7.dart';
import '../lecture_screen/c8.dart';

// â”€â”€ PLACEHOLDER â€” replace with real screens on later days â”€â”€
import '../widgets/placeholder_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoading = authState.isLoading;
      final path = state.matchedLocation;

      // Let splash screen handle its own navigation
      if (path == '/splash') return null;

      // Session still resolving â€” hold current route
      if (isLoading) return null;

      const unauthPaths = ['/onboarding', '/login', '/register'];
      final onUnauthPage = unauthPaths.contains(path);

      if (!isLoggedIn && !onUnauthPage) return '/login';
      if (isLoggedIn && onUnauthPage) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),

      // â”€â”€ Authenticated routes (placeholder until Day 2+) â”€â”€
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),

      GoRoute(path: '/chapters', builder: (c, s) => const ChapterListScreen()),

      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(path: '/diagnostic', builder: (c, s) => const DiagnosticScreen()),
      GoRoute(path: '/study-plan', builder: (c, s) => const WeeklyPlanScreen()),
      GoRoute(path: '/quiz', builder: (c, s) => const QuizMenuScreen()),
      GoRoute(
        path: '/chat',
        builder: (c, s) => ChatbotScreen(
          autoAttachMarking: s.uri.queryParameters['attach'] == 'marking',
        ),
      ),
      GoRoute(
        path: '/quiz-type',
        builder: (c, s) => const QuizTypeSelectionScreen(),
      ),
      GoRoute(
        path: '/quiz-history',
        builder: (c, s) => const QuizHistoryScreen(),
      ),
      GoRoute(
        path: '/quiz-subjective',
        builder: (c, s) => const SubjectiveChapterMenuScreen(),
      ),
      GoRoute(
        path: '/quiz-subjective/:chapterId',
        builder: (c, s) {
          final id = int.tryParse(s.pathParameters['chapterId'] ?? '') ?? 1;
          return SubjectiveQuestionScreen(chapterNumber: id);
        },
      ),

      GoRoute(
        path: '/lecture/:chapterId',
        builder: (c, s) {
          final id = s.pathParameters['chapterId'];
          switch (id) {
            case '1':
              return const LectureChapter1Screen();
            case '2':
              return const LectureChapter2Screen();
            case '3':
              return const LectureChapter3Screen();
            case '4':
              return const LectureChapter4Screen();
            case '5':
              return const LectureChapter5Screen();
            case '6':
              return const LectureChapter6Screen();
            case '7':
              return const LectureChapter7Screen();
            case '8':
              return const LectureChapter8Screen();
            default:
              return PlaceholderScreen(title: 'Lecture $id â€” Coming Soon');
          }
        },
      ),
      GoRoute(
        path: '/quiz/:chapterId',
        builder: (c, s) {
          final id = int.tryParse(s.pathParameters['chapterId'] ?? '') ?? 1;
          return QuizScreen(chapterNumber: id);
        },
      ),
      GoRoute(
        path: '/experiments',
        builder: (c, s) => const ExperimentMenuScreen(),
      ),
      GoRoute(
        path: '/ar/:experiment',
        builder: (c, s) {
          final experiment = s.pathParameters['experiment'] ?? 'CuCO3_Heating';
          return UnityExperimentScreen(experimentName: experiment);
        },
      ),
      GoRoute(
        path: '/progress',
        builder: (c, s) => const PlaceholderScreen(title: 'Progress'),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.transparent,
      body: ChemistryBackground(
        child: Center(
          child: Text(
            'Page not found: ${state.error}',
            style: const TextStyle(color: Color(0xFF1E293B)),
          ),
        ),
      ),
    ),
  );
});
