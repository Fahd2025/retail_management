import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppConfigState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isLoading;

  const AppConfigState({
    required this.themeMode,
    required this.locale,
    required this.isLoading,
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isArabic => locale.languageCode == 'ar';
  bool get isEnglish => locale.languageCode == 'en';

  TextDirection get textDirection =>
      locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  AppConfigState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isLoading,
  }) {
    return AppConfigState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, isLoading];
}