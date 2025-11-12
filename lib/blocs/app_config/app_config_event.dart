import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AppConfigEvent extends Equatable {
  const AppConfigEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAppConfigEvent extends AppConfigEvent {
  const InitializeAppConfigEvent();

  @override
  List<Object?> get props => [];
}

class UpdateThemeEvent extends AppConfigEvent {
  final ThemeMode themeMode;

  const UpdateThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateLocaleEvent extends AppConfigEvent {
  final Locale locale;

  const UpdateLocaleEvent(this.locale);

  @override
  List<Object?> get props => [locale];
}

class ToggleThemeEvent extends AppConfigEvent {
  const ToggleThemeEvent();

  @override
  List<Object?> get props => [];
}

class SetEnglishEvent extends AppConfigEvent {
  const SetEnglishEvent();

  @override
  List<Object?> get props => [];
}

class SetArabicEvent extends AppConfigEvent {
  const SetArabicEvent();

  @override
  List<Object?> get props => [];
}