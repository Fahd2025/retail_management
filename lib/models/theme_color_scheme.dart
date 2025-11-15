import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Theme color scheme model for customizable app colors
///
/// Supports both predefined color schemes and custom colors
/// for primary and secondary colors in light and dark modes
class ThemeColorScheme extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final Color lightPrimary;
  final Color lightSecondary;
  final Color darkPrimary;
  final Color darkSecondary;
  final bool isCustom;

  const ThemeColorScheme({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.lightPrimary,
    required this.lightSecondary,
    required this.darkPrimary,
    required this.darkSecondary,
    this.isCustom = false,
  });

  /// Predefined color schemes
  static const ThemeColorScheme defaultBlue = ThemeColorScheme(
    id: 'default_blue',
    name: 'Default Blue',
    nameAr: 'الأزرق الافتراضي',
    lightPrimary: Color(0xFF2196F3),
    lightSecondary: Color(0xFF009688),
    darkPrimary: Color(0xFF64B5F6),
    darkSecondary: Color(0xFF4DD0E1),
  );

  static const ThemeColorScheme deepPurple = ThemeColorScheme(
    id: 'deep_purple',
    name: 'Deep Purple',
    nameAr: 'الأرجواني الداكن',
    lightPrimary: Color(0xFF673AB7),
    lightSecondary: Color(0xFF512DA8),
    darkPrimary: Color(0xFF9575CD),
    darkSecondary: Color(0xFF7E57C2),
  );

  static const ThemeColorScheme teal = ThemeColorScheme(
    id: 'teal',
    name: 'Teal',
    nameAr: 'الأزرق المخضر',
    lightPrimary: Color(0xFF009688),
    lightSecondary: Color(0xFF00796B),
    darkPrimary: Color(0xFF4DB6AC),
    darkSecondary: Color(0xFF26A69A),
  );

  static const ThemeColorScheme indigo = ThemeColorScheme(
    id: 'indigo',
    name: 'Indigo',
    nameAr: 'النيلي',
    lightPrimary: Color(0xFF3F51B5),
    lightSecondary: Color(0xFF303F9F),
    darkPrimary: Color(0xFF7986CB),
    darkSecondary: Color(0xFF5C6BC0),
  );

  static const ThemeColorScheme amber = ThemeColorScheme(
    id: 'amber',
    name: 'Amber',
    nameAr: 'الكهرماني',
    lightPrimary: Color(0xFFFFC107),
    lightSecondary: Color(0xFFFF6F00),
    darkPrimary: Color(0xFFFFD54F),
    darkSecondary: Color(0xFFFF8F00),
  );

  static const ThemeColorScheme green = ThemeColorScheme(
    id: 'green',
    name: 'Green',
    nameAr: 'الأخضر',
    lightPrimary: Color(0xFF4CAF50),
    lightSecondary: Color(0xFF388E3C),
    darkPrimary: Color(0xFF81C784),
    darkSecondary: Color(0xFF66BB6A),
  );

  static const ThemeColorScheme red = ThemeColorScheme(
    id: 'red',
    name: 'Red',
    nameAr: 'الأحمر',
    lightPrimary: Color(0xFFF44336),
    lightSecondary: Color(0xFFD32F2F),
    darkPrimary: Color(0xFFEF5350),
    darkSecondary: Color(0xFFE57373),
  );

  static const ThemeColorScheme orange = ThemeColorScheme(
    id: 'orange',
    name: 'Orange',
    nameAr: 'البرتقالي',
    lightPrimary: Color(0xFFFF9800),
    lightSecondary: Color(0xFFF57C00),
    darkPrimary: Color(0xFFFFB74D),
    darkSecondary: Color(0xFFFF9800),
  );

  static const ThemeColorScheme pink = ThemeColorScheme(
    id: 'pink',
    name: 'Pink',
    nameAr: 'الوردي',
    lightPrimary: Color(0xFFE91E63),
    lightSecondary: Color(0xFFC2185B),
    darkPrimary: Color(0xFFF06292),
    darkSecondary: Color(0xFFEC407A),
  );

  static const ThemeColorScheme cyan = ThemeColorScheme(
    id: 'cyan',
    name: 'Cyan',
    nameAr: 'السماوي',
    lightPrimary: Color(0xFF00BCD4),
    lightSecondary: Color(0xFF0097A7),
    darkPrimary: Color(0xFF4DD0E1),
    darkSecondary: Color(0xFF26C6DA),
  );

  /// List of all predefined color schemes
  static const List<ThemeColorScheme> predefinedSchemes = [
    defaultBlue,
    deepPurple,
    teal,
    indigo,
    amber,
    green,
    red,
    orange,
    pink,
    cyan,
  ];

  /// Get a scheme by ID
  static ThemeColorScheme? getSchemeById(String id) {
    try {
      return predefinedSchemes.firstWhere((scheme) => scheme.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a custom color scheme
  factory ThemeColorScheme.custom({
    required Color lightPrimary,
    required Color lightSecondary,
    required Color darkPrimary,
    required Color darkSecondary,
  }) {
    return ThemeColorScheme(
      id: 'custom',
      name: 'Custom',
      nameAr: 'مخصص',
      lightPrimary: lightPrimary,
      lightSecondary: lightSecondary,
      darkPrimary: darkPrimary,
      darkSecondary: darkSecondary,
      isCustom: true,
    );
  }

  /// Get localized name based on locale
  String getLocalizedName(Locale locale) {
    return locale.languageCode == 'ar' ? nameAr : name;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'lightPrimary': lightPrimary.value,
      'lightSecondary': lightSecondary.value,
      'darkPrimary': darkPrimary.value,
      'darkSecondary': darkSecondary.value,
      'isCustom': isCustom,
    };
  }

  /// Create from JSON
  factory ThemeColorScheme.fromJson(Map<String, dynamic> json) {
    return ThemeColorScheme(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      lightPrimary: Color(json['lightPrimary'] as int),
      lightSecondary: Color(json['lightSecondary'] as int),
      darkPrimary: Color(json['darkPrimary'] as int),
      darkSecondary: Color(json['darkSecondary'] as int),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  /// Create a copy with different values
  ThemeColorScheme copyWith({
    String? id,
    String? name,
    String? nameAr,
    Color? lightPrimary,
    Color? lightSecondary,
    Color? darkPrimary,
    Color? darkSecondary,
    bool? isCustom,
  }) {
    return ThemeColorScheme(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      lightPrimary: lightPrimary ?? this.lightPrimary,
      lightSecondary: lightSecondary ?? this.lightSecondary,
      darkPrimary: darkPrimary ?? this.darkPrimary,
      darkSecondary: darkSecondary ?? this.darkSecondary,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        lightPrimary,
        lightSecondary,
        darkPrimary,
        darkSecondary,
        isCustom,
      ];
}
