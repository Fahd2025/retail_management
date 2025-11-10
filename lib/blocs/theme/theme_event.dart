import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class InitializeThemeEvent extends ThemeEvent {
  const InitializeThemeEvent();
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

class SetThemeModeEvent extends ThemeEvent {
  final ThemeMode mode;

  const SetThemeModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}
