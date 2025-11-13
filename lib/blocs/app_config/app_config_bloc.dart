import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/print_format.dart';
import 'app_config_event.dart';
import 'app_config_state.dart';

class AppConfigBloc extends Bloc<AppConfigEvent, AppConfigState> {
  static const String _themePreferenceKey = 'theme_mode';
  static const String _localePreferenceKey = 'app_locale';
  static const String _printFormatPreferenceKey = 'print_format_config';
  static const String _vatRatePreferenceKey = 'vat_rate';
  static const String _vatIncludedInPricePreferenceKey = 'vat_included_in_price';

  static const Locale englishLocale = Locale('en', 'US');
  static const Locale arabicLocale = Locale('ar', 'SA');

  AppConfigBloc()
      : super(const AppConfigState(
          themeMode: ThemeMode.light,
          locale: englishLocale,
          isLoading: true,
          printFormatConfig: PrintFormatConfig.defaultConfig,
          vatRate: 15.0,
          vatIncludedInPrice: false,
        )) {
    on<InitializeAppConfigEvent>(_onInitialize);
    on<UpdateThemeEvent>(_onUpdateTheme);
    on<UpdateLocaleEvent>(_onUpdateLocale);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetEnglishEvent>(_onSetEnglish);
    on<SetArabicEvent>(_onSetArabic);
    on<UpdatePrintFormatEvent>(_onUpdatePrintFormat);
    on<UpdateVatRateEvent>(_onUpdateVatRate);
    on<UpdateVatInclusionEvent>(_onUpdateVatInclusion);
  }

  Future<void> _onInitialize(
    InitializeAppConfigEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);
      final savedLocale = prefs.getString(_localePreferenceKey);
      final savedPrintFormat = prefs.getString(_printFormatPreferenceKey);
      final savedVatRate = prefs.getDouble(_vatRatePreferenceKey);
      final savedVatIncludedInPrice = prefs.getBool(_vatIncludedInPricePreferenceKey);

      final themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      final locale = savedLocale == 'ar' ? arabicLocale : englishLocale;
      final vatRate = savedVatRate ?? 15.0; // Default Saudi VAT rate
      final vatIncludedInPrice = savedVatIncludedInPrice ?? false; // Default: VAT not included

      PrintFormatConfig printFormatConfig = PrintFormatConfig.defaultConfig;
      if (savedPrintFormat != null) {
        try {
          final json = jsonDecode(savedPrintFormat) as Map<String, dynamic>;
          printFormatConfig = PrintFormatConfig.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing print format config: $e');
        }
      }

      emit(state.copyWith(
        themeMode: themeMode,
        locale: locale,
        printFormatConfig: printFormatConfig,
        vatRate: vatRate,
        vatIncludedInPrice: vatIncludedInPrice,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Error loading app config preferences: $e');
      emit(state.copyWith(
        themeMode: ThemeMode.light,
        locale: englishLocale,
        printFormatConfig: PrintFormatConfig.defaultConfig,
        vatRate: 15.0,
        vatIncludedInPrice: false,
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateTheme(
    UpdateThemeEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    if (state.themeMode != event.themeMode) {
      await _saveThemePreference(event.themeMode);
      emit(state.copyWith(themeMode: event.themeMode));
    }
  }

  Future<void> _onUpdateLocale(
    UpdateLocaleEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    if (state.locale != event.locale) {
      await _saveLocalePreference(event.locale);
      emit(state.copyWith(locale: event.locale));
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await _saveThemePreference(newMode);
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> _onSetEnglish(
    SetEnglishEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    await _saveLocalePreference(englishLocale);
    emit(state.copyWith(locale: englishLocale));
  }

  Future<void> _onSetArabic(
    SetArabicEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    await _saveLocalePreference(arabicLocale);
    emit(state.copyWith(locale: arabicLocale));
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themePreferenceKey,
        mode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  Future<void> _saveLocalePreference(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePreferenceKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale preference: $e');
    }
  }

  Future<void> _onUpdatePrintFormat(
    UpdatePrintFormatEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    if (state.printFormatConfig != event.config) {
      await _savePrintFormatPreference(event.config);
      emit(state.copyWith(printFormatConfig: event.config));
    }
  }

  Future<void> _savePrintFormatPreference(PrintFormatConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(config.toJson());
      await prefs.setString(_printFormatPreferenceKey, json);
    } catch (e) {
      debugPrint('Error saving print format preference: $e');
    }
  }

  Future<void> _onUpdateVatRate(
    UpdateVatRateEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    if (state.vatRate != event.vatRate) {
      await _saveVatRatePreference(event.vatRate);
      emit(state.copyWith(vatRate: event.vatRate));
    }
  }

  Future<void> _saveVatRatePreference(double vatRate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_vatRatePreferenceKey, vatRate);
    } catch (e) {
      debugPrint('Error saving VAT rate preference: $e');
    }
  }

  Future<void> _onUpdateVatInclusion(
    UpdateVatInclusionEvent event,
    Emitter<AppConfigState> emit,
  ) async {
    if (state.vatIncludedInPrice != event.vatIncludedInPrice) {
      await _saveVatInclusionPreference(event.vatIncludedInPrice);
      emit(state.copyWith(vatIncludedInPrice: event.vatIncludedInPrice));
    }
  }

  Future<void> _saveVatInclusionPreference(bool vatIncludedInPrice) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_vatIncludedInPricePreferenceKey, vatIncludedInPrice);
    } catch (e) {
      debugPrint('Error saving VAT inclusion preference: $e');
    }
  }
}