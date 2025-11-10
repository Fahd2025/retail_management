import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class InitializeLocaleEvent extends LocaleEvent {
  const InitializeLocaleEvent();
}

class SetEnglishEvent extends LocaleEvent {
  const SetEnglishEvent();
}

class SetArabicEvent extends LocaleEvent {
  const SetArabicEvent();
}

class ToggleLocaleEvent extends LocaleEvent {
  const ToggleLocaleEvent();
}

class SetLocaleEvent extends LocaleEvent {
  final Locale locale;

  const SetLocaleEvent(this.locale);

  @override
  List<Object?> get props => [locale];
}
