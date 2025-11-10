import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _localePreferenceKey = 'app_locale';

  LocaleBloc()
      : super(const LocaleState(
          locale: LocaleState.englishLocale,
          isLoading: true,
        )) {
    on<InitializeLocaleEvent>(_onInitialize);
    on<SetEnglishEvent>(_onSetEnglish);
    on<SetArabicEvent>(_onSetArabic);
    on<ToggleLocaleEvent>(_onToggleLocale);
    on<SetLocaleEvent>(_onSetLocale);
  }

  Future<void> _onInitialize(
    InitializeLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localePreferenceKey);

      final locale = savedLocaleCode == 'ar'
          ? LocaleState.arabicLocale
          : LocaleState.englishLocale;

      emit(state.copyWith(
        locale: locale,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Error loading locale preference: $e');
      emit(state.copyWith(
        locale: LocaleState.englishLocale,
        isLoading: false,
      ));
    }
  }

  Future<void> _onSetEnglish(
    SetEnglishEvent event,
    Emitter<LocaleState> emit,
  ) async {
    await _setLocale(LocaleState.englishLocale, emit);
  }

  Future<void> _onSetArabic(
    SetArabicEvent event,
    Emitter<LocaleState> emit,
  ) async {
    await _setLocale(LocaleState.arabicLocale, emit);
  }

  Future<void> _onToggleLocale(
    ToggleLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    final newLocale = state.locale.languageCode == 'en'
        ? LocaleState.arabicLocale
        : LocaleState.englishLocale;
    await _setLocale(newLocale, emit);
  }

  Future<void> _onSetLocale(
    SetLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    if (!LocaleState.supportedLocales.contains(event.locale)) {
      debugPrint('Unsupported locale: ${event.locale}');
      return;
    }
    await _setLocale(event.locale, emit);
  }

  Future<void> _setLocale(Locale locale, Emitter<LocaleState> emit) async {
    if (state.locale != locale) {
      await _saveLocalePreference(locale);
      emit(state.copyWith(locale: locale));
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
}
