/// Piping Master - Blueprint Theme
///
/// Technical drawing-inspired theme with dark blue background
/// and monospaced typography for CAD-like appearance.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Blueprint color palette for Piping Master module.
abstract final class PipingColors {
  /// Primary background - dark blueprint blue.
  static const Color background = Color(0xFF263238);

  /// Secondary background for cards.
  static const Color surface = Color(0xFF37474F);

  /// Blueprint line color.
  static const Color line = Color(0xFFB0BEC5);

  /// Dimension text color.
  static const Color dimension = Color(0xFFFFFFFF);

  /// Accent for highlights.
  static const Color accent = Color(0xFF00E5FF);

  /// Success/good fit indicator.
  static const Color success = Color(0xFF4CAF50);

  /// Warning indicator.
  static const Color warning = Color(0xFFFF9800);

  /// Danger/collision indicator.
  static const Color danger = Color(0xFFF44336);

  /// Grid lines on blueprint.
  static const Color grid = Color(0xFF455A64);

  /// Bolt hole fill color.
  static const Color boltHole = Color(0xFF1E272C);
}

/// Text styles for technical/CAD appearance.
abstract final class PipingTypography {
  /// Monospaced style for dimension labels.
  static TextStyle dimension({
    double fontSize = 14,
    Color color = PipingColors.dimension,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Monospaced style for large measurements.
  static TextStyle measurement({
    double fontSize = 24,
    Color color = PipingColors.accent,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Label style for dropdown headers.
  static TextStyle label({
    double fontSize = 12,
    Color color = PipingColors.line,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  /// Title style for section headers.
  static TextStyle sectionTitle({
    double fontSize = 16,
    Color color = PipingColors.dimension,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.2,
    );
  }
}

/// Decoration styles for blueprint cards.
abstract final class PipingDecorations {
  /// Card decoration with blueprint styling.
  static BoxDecoration card({bool isHighlighted = false}) {
    return BoxDecoration(
      color: PipingColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isHighlighted ? PipingColors.accent : PipingColors.grid,
        width: isHighlighted ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Input decoration for dropdowns.
  static InputDecoration dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: PipingTypography.label(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: PipingColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PipingColors.grid),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PipingColors.grid),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PipingColors.accent, width: 2),
      ),
    );
  }
}
