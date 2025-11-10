import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleState extends Equatable {
  // Supported locales
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale arabicLocale = Locale('ar', 'SA');

  static const List<Locale> supportedLocales = [
    englishLocale,
    arabicLocale,
  ];

  final Locale locale;
  final bool isLoading;

  const LocaleState({
    required this.locale,
    required this.isLoading,
  });

  bool get isArabic => locale.languageCode == 'ar';
  bool get isEnglish => locale.languageCode == 'en';

  TextDirection get textDirection =>
      locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

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

  String get currentLocaleName => getLocaleName(locale);

  LocaleState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [locale, isLoading];
}
