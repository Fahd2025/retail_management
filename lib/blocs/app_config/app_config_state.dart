import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../models/print_format.dart';

class AppConfigState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isLoading;
  final PrintFormatConfig printFormatConfig;
  final double vatRate;

  const AppConfigState({
    required this.themeMode,
    required this.locale,
    required this.isLoading,
    this.printFormatConfig = PrintFormatConfig.defaultConfig,
    this.vatRate = 15.0, // Default Saudi VAT rate
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
    PrintFormatConfig? printFormatConfig,
    double? vatRate,
  }) {
    return AppConfigState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
      printFormatConfig: printFormatConfig ?? this.printFormatConfig,
      vatRate: vatRate ?? this.vatRate,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, isLoading, printFormatConfig, vatRate];
}