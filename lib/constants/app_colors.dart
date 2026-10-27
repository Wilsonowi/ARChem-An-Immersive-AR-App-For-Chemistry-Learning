import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── BACKGROUND ────────────────────────────────────────
  static const Color background = Color(0xFFEAF7FF);
  static const Color surface = Color(0xFFF7FCFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFC8E4F4);

  // ── ACCENT ────────────────────────────────────────────
  static const Color cyan = Color(0xFF0284C7);
  static const Color cyanDim = Color(0x1A0284C7);
  static const Color cyanGlow = Color(0x330284C7);

  // ── INDIGO ACCENT (onboarding) ─────────────────────────
  static const Color indigo = Color(0xFF4F46E5);
  static const Color indigoDim = Color(0x1A4F46E5);
  static const Color indigoDark = Color(0xFF581C87); // dark purple (CTA slider)
  static const Color lilacGlow = Color(0xFFE7DEFB);

  // ── STATUS ────────────────────────────────────────────
  static const Color green = Color(0xFF059669);
  static const Color greenDim = Color(0x1A059669);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDim = Color(0x16F59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color redDim = Color(0x16EF4444);

  // ── TEXT ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F2942);
  static const Color textSecondary = Color(0xFF4D6B84);
  static const Color textMuted = Color(0xFF7894AA);

  // ── CHAPTER COLOURS ───────────────────────────────────
  static const Color chapter1 = Color(0xFF6366F1); // purple
  static const Color chapter2 = Color(0xFF3B82F6); // blue
  static const Color chapter3 = Color(0xFF06B6D4); // cyan
  static const Color chapter4 = Color(0xFF10B981); // green
  static const Color chapter5 = Color(0xFFF59E0B); // amber
  static const Color chapter6 = Color(0xFFEF4444); // red
  static const Color chapter7 = Color(0xFFEC4899); // pink
  static const Color chapter8 = Color(0xFF8B5CF6); // violet

  static Color chapterColor(int number) {
    switch (number) {
      case 1:
        return chapter1;
      case 2:
        return chapter2;
      case 3:
        return chapter3;
      case 4:
        return chapter4;
      case 5:
        return chapter5;
      case 6:
        return chapter6;
      case 7:
        return chapter7;
      case 8:
        return chapter8;
      default:
        return cyan;
    }
  }
}
