import 'package:flutter/material.dart';

/// QorEng brand color palette.
///
/// Based on the QorEng logo:
/// - Primary: Deep Navy Blue (#1E3A5F)
/// - Accent: Cyan/Teal (#00BCD4)
/// - Background: OLED-optimized dark with blue undertones
abstract final class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // Brand Primary Colors (Deep Navy Blue from logo)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2E5A8F);
  static const Color primaryDark = Color(0xFF0F2A4F);

  // ═══════════════════════════════════════════════════════════════════════════
  // Brand Accent Colors (Cyan/Teal from logo gradient)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color accent = Color(0xFF00BCD4);
  static const Color accentLight = Color(0xFF4DD0E1);
  static const Color accentDark = Color(0xFF0097A7);

  // ═══════════════════════════════════════════════════════════════════════════
  // Background Colors (OLED optimized with subtle blue undertone)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color backgroundDark = Color(0xFF0A0E14);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceDark = Color(0xFF121820);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1A2332);
  static const Color cardLight = Color(0xFFFAFBFC);

  // ═══════════════════════════════════════════════════════════════════════════
  // Text Colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textPrimaryDark = Color(0xFFE8ECF0);
  static const Color textSecondaryDark = Color(0xFF8899AA);
  static const Color textPrimaryLight = Color(0xFF1A2332);
  static const Color textSecondaryLight = Color(0xFF5A6A7A);

  // ═══════════════════════════════════════════════════════════════════════════
  // Semantic Colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF00BCD4);

  // ═══════════════════════════════════════════════════════════════════════════
  // Engineering Module Accent Colors
  // ═══════════════════════════════════════════════════════════════════════════
  /// Electrical - Electric Yellow/Gold
  static const Color electricalAccent = Color(0xFFFFD54F);

  /// Mechanical - Steel Blue/Gray
  static const Color mechanicalAccent = Color(0xFF78909C);

  /// Chemical - Purple/Violet
  static const Color chemicalAccent = Color(0xFF9575CD);

  /// Bioprocess - Green/Bio
  static const Color bioprocessAccent = Color(0xFF66BB6A);
}
