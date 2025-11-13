import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing application localization (language)
///
/// This provider handles:
/// - Language switching between Arabic and English
/// - Persistence of user's language preference using SharedPreferences
/// - Automatic locale restoration on app startup
/// - Notification to listeners when locale changes
/// - RTL (Right-to-Left) support for Arabic language
class LocaleProvider with ChangeNotifier {
  static const String _localePreferenceKey = 'app_locale';

  // Supported locales
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale arabicLocale = Locale('ar', 'SA');

  static const List<Locale> supportedLocales = [
    englishLocale,
    arabicLocale,
  ];

  Locale _locale = englishLocale;
  bool _isLoading = true;

  Locale get locale => _locale;
  bool get isLoading => _isLoading;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  /// Returns the text direction based on the current locale
  /// Arabic uses RTL (Right-to-Left), English uses LTR (Left-to-Right)
  TextDirection get textDirection =>
      _locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  /// Initializes the locale provider by loading saved language preference
  /// Should be called when the app starts
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await loadLocalePreference();

    _isLoading = false;
    notifyListeners();
  }

  /// Loads the saved locale preference from SharedPreferences
  /// Defaults to English if no preference is saved
  Future<void> loadLocalePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localePreferenceKey);

      if (savedLocaleCode != null) {
        _locale = savedLocaleCode == 'ar' ? arabicLocale : englishLocale;
      } else {
        _locale = englishLocale;
      }
    } catch (e) {
      debugPrint('Error loading locale preference: $e');
      _locale = englishLocale;
    }
  }

  /// Sets the locale to English
  Future<void> setEnglish() async {
    await setLocale(englishLocale);
  }

  /// Sets the locale to Arabic
  Future<void> setArabic() async {
    await setLocale(arabicLocale);
  }

  /// Toggles between English and Arabic
  Future<void> toggleLocale() async {
    final newLocale =
        _locale.languageCode == 'en' ? arabicLocale : englishLocale;
    await setLocale(newLocale);
  }

  /// Sets a specific locale
  ///
  /// @param locale The locale to set (must be in supportedLocales)
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      debugPrint('Unsupported locale: $locale');
      return;
    }

    if (_locale != locale) {
      _locale = locale;
      await _saveLocalePreference();
      notifyListeners();
    }
  }

  /// Saves the current locale preference to SharedPreferences
  Future<void> _saveLocalePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePreferenceKey, _locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale preference: $e');
    }
  }

  /// Gets the locale name for display purposes
  String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode;
    }
  }

  /// Gets the current locale name
  String get currentLocaleName => getLocaleName(_locale);
}
