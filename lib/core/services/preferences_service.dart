import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app preferences using shared_preferences.
class PreferencesService {
  static const String _disclaimerAcceptedKey = 'disclaimer_accepted';
  static const String _themeModeKey = 'theme_mode';

  /// Check if the user has accepted the disclaimer.
  static Future<bool> isDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerAcceptedKey) ?? false;
  }

  /// Mark the disclaimer as accepted.
  static Future<void> setDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerAcceptedKey, true);
  }

  /// Get the saved theme mode preference.
  /// Returns 'dark', 'light', or 'system'. Defaults to 'dark'.
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'dark';
  }

  /// Save the theme mode preference.
  /// Accepts 'dark', 'light', or 'system'.
  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }
}
