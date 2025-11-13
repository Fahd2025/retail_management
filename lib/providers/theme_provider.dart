import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing application theme (light/dark mode)
///
/// This provider handles:
/// - Theme mode switching between light and dark modes
/// - Persistence of user's theme preference using SharedPreferences
/// - Automatic theme restoration on app startup
/// - Notification to listeners when theme changes
class ThemeProvider with ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Initializes the theme provider by loading saved theme preference
  /// Should be called when the app starts
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await loadThemePreference();

    _isLoading = false;
    notifyListeners();
  }

  /// Loads the saved theme preference from SharedPreferences
  /// Defaults to light mode if no preference is saved
  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);

      if (savedTheme != null) {
        _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      } else {
        _themeMode = ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      _themeMode = ThemeMode.light;
    }
  }

  /// Toggles between light and dark theme modes
  /// Persists the selection to SharedPreferences
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemePreference();
    notifyListeners();
  }

  /// Sets a specific theme mode
  ///
  /// @param mode The theme mode to set (light or dark)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemePreference();
      notifyListeners();
    }
  }

  /// Saves the current theme preference to SharedPreferences
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themePreferenceKey,
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }
}
