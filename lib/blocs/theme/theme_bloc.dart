import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themePreferenceKey = 'theme_mode';

  ThemeBloc()
      : super(const ThemeState(
          themeMode: ThemeMode.light,
          isLoading: true,
        )) {
    on<InitializeThemeEvent>(_onInitialize);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeModeEvent>(_onSetThemeMode);
  }

  Future<void> _onInitialize(
    InitializeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);

      final themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

      emit(state.copyWith(
        themeMode: themeMode,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      emit(state.copyWith(
        themeMode: ThemeMode.light,
        isLoading: false,
      ));
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    await _saveThemePreference(newMode);
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> _onSetThemeMode(
    SetThemeModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    if (state.themeMode != event.mode) {
      await _saveThemePreference(event.mode);
      emit(state.copyWith(themeMode: event.mode));
    }
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
}
