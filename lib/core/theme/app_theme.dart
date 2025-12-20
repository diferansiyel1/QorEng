import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';

/// App theme configuration with Material 3 and Dark/Light mode support.
///
/// Default: Dark mode (OLED optimized for factory environments).
abstract final class AppTheme {
  /// Dark theme - Primary for industrial use.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: _buildAppBarTheme(colorScheme, isDark: true),
      bottomNavigationBarTheme: _buildBottomNavTheme(colorScheme, isDark: true),
      cardTheme: _buildCardTheme(isDark: true),
      inputDecorationTheme: _buildInputTheme(colorScheme, isDark: true),
      elevatedButtonTheme: _buildButtonTheme(colorScheme),
    );
  }

  /// Light theme - Alternative for outdoor/bright environments.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _buildTextTheme(isDark: false),
      appBarTheme: _buildAppBarTheme(colorScheme, isDark: false),
      bottomNavigationBarTheme: _buildBottomNavTheme(colorScheme, isDark: false),
      cardTheme: _buildCardTheme(isDark: false),
      inputDecorationTheme: _buildInputTheme(colorScheme, isDark: false),
      elevatedButtonTheme: _buildButtonTheme(colorScheme),
    );
  }

  static TextTheme _buildTextTheme({required bool isDark}) {
    final baseColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(
    ColorScheme colorScheme, {
    required bool isDark,
  }) {
    return AppBarTheme(
      backgroundColor: isDark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      foregroundColor: isDark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme(
    ColorScheme colorScheme, {
    required bool isDark,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: Dimens.elevationLg,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  static CardThemeData _buildCardTheme({required bool isDark}) {
    return CardThemeData(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      elevation: Dimens.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
      ),
      margin: const EdgeInsets.all(Dimens.spacingMd),
    );
  }

  static InputDecorationTheme _buildInputTheme(
    ColorScheme colorScheme, {
    required bool isDark,
  }) {
    final borderColor = isDark
        ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
        : AppColors.textSecondaryLight.withValues(alpha: 0.3);

    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingMd,
        vertical: Dimens.spacingMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, Dimens.touchTargetMin),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingLg,
          vertical: Dimens.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
        ),
        elevation: Dimens.elevationMd,
      ),
    );
  }
}
