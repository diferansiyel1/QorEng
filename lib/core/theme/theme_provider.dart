import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:engicore/core/services/preferences_service.dart';

part 'theme_provider.g.dart';

/// Converts string to ThemeMode.
ThemeMode _stringToThemeMode(String mode) {
  return switch (mode) {
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => ThemeMode.dark,
  };
}

/// Converts ThemeMode to string.
String _themeModeToString(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.system => 'system',
    ThemeMode.dark => 'dark',
  };
}

/// Provider for managing app theme mode.
///
/// Supports dark, light, and system (auto) modes.
/// Persists user preference using SharedPreferences.
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async {
    final savedMode = await PreferencesService.getThemeMode();
    return _stringToThemeMode(savedMode);
  }

  /// Set the theme mode and persist preference.
  Future<void> setTheme(ThemeMode mode) async {
    state = const AsyncValue.loading();
    try {
      await PreferencesService.setThemeMode(_themeModeToString(mode));
      state = AsyncValue.data(mode);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
