import 'package:flutter/material.dart';

/// Industrial Minimalist color palette for EngiCore.
///
/// Primary: Teal (#00897B) for professionalism.
/// Background: Dark-Grey/Black optimized for OLED screens.
abstract final class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);

  // Background colors (OLED optimized)
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF252525);
  static const Color cardLight = Color(0xFFFAFAFA);

  // Text colors
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // Industrial accent colors
  static const Color electricalAccent = Color(0xFFFFCA28);
  static const Color mechanicalAccent = Color(0xFF78909C);
  static const Color chemicalAccent = Color(0xFF7E57C2);
  static const Color bioprocessAccent = Color(0xFF66BB6A);
}
