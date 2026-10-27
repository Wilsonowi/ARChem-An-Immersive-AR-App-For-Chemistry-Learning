import 'package:archem/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Quiz screen loads fallback questions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: QuizScreen(chapterNumber: 3)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CHAPTER QUIZ'), findsOneWidget);
    expect(find.text('Ch 3 - Mole Concept'), findsOneWidget);
  });
}
