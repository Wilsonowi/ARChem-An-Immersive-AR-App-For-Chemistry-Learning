import 'package:flutter/material.dart';

class ChapterModel {
  final int number;
  final String title;
  final String shortTitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> subtopics;

  const ChapterModel({
    required this.number,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.subtopics,
  });
}

class ChapterProgress {
  final String chapter;
  final int chapterNumber;
  final int quizScore;
  final int maxScore;
  final bool experimentDone;

  const ChapterProgress({
    required this.chapter,
    required this.chapterNumber,
    this.quizScore = 0,
    this.maxScore = 5,
    this.experimentDone = false,
  });

  factory ChapterProgress.fromJson(Map<String, dynamic> json) {
    return ChapterProgress(
      chapter: json['chapter'] as String,
      chapterNumber: json['chapter_number'] as int,
      quizScore: json['quiz_score'] as int? ?? 0,
      maxScore: json['max_score'] as int? ?? 5,
      experimentDone: json['experiment_done'] as bool? ?? false,
    );
  }

  double get percentage => maxScore > 0 ? quizScore / maxScore : 0.0;
}
