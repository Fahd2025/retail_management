import 'package:flutter/material.dart';

/// Comprehensive typography system for the retail management application
///
/// This typography system follows Material Design 3 guidelines with:
/// - Clear hierarchy for different content types
/// - Optimized readability on both light and dark backgrounds
/// - Responsive sizing support
/// - Consistent spacing and line heights
class AppTypography {
  // Font family - can be customized for branding
  static const String fontFamily = 'Roboto';

  // ==================== DISPLAY STYLES ====================
  // Used for large, impactful text (hero sections, splash screens)

  /// Display Large - 57sp
  /// Used for: Hero text, major feature announcements
  static TextStyle displayLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: color,
      );

  /// Display Medium - 45sp
  /// Used for: Section headers, dashboard titles
  static TextStyle displayMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
        color: color,
      );

  /// Display Small - 36sp
  /// Used for: Page titles, modal headers
  static TextStyle displaySmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
        color: color,
      );

  // ==================== HEADLINE STYLES ====================
  // Used for important text that needs to stand out

  /// Headline Large - 32sp
  /// Used for: Main screen titles
  static TextStyle headlineLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
        color: color,
      );

  /// Headline Medium - 28sp
  /// Used for: Card titles, section headers
  static TextStyle headlineMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.29,
        color: color,
      );

  /// Headline Small - 24sp
  /// Used for: Dialog titles, form section headers
  static TextStyle headlineSmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: color,
      );

  // ==================== TITLE STYLES ====================
  // Used for medium-emphasis text

  /// Title Large - 22sp
  /// Used for: AppBar titles, prominent list items
  static TextStyle titleLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: color,
      );

  /// Title Medium - 16sp
  /// Used for: Subheadings, emphasized labels
  static TextStyle titleMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.50,
        color: color,
      );

  /// Title Small - 14sp
  /// Used for: List item titles, form field labels
  static TextStyle titleSmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  // ==================== BODY STYLES ====================
  // Used for main content text

  /// Body Large - 16sp
  /// Used for: Main body text, descriptions
  static TextStyle bodyLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: color,
      );

  /// Body Medium - 14sp
  /// Used for: Default body text, form inputs
  static TextStyle bodyMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: color,
      );

  /// Body Small - 12sp
  /// Used for: Secondary information, captions
  static TextStyle bodySmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: color,
      );

  // ==================== LABEL STYLES ====================
  // Used for buttons, tabs, and labels

  /// Label Large - 14sp
  /// Used for: Button text, prominent labels
  static TextStyle labelLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  /// Label Medium - 12sp
  /// Used for: Secondary button text, menu items
  static TextStyle labelMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
        color: color,
      );

  /// Label Small - 11sp
  /// Used for: Small labels, badges, tags
  static TextStyle labelSmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.45,
        color: color,
      );

  // ==================== SPECIAL PURPOSE STYLES ====================

  /// Currency - 24sp Bold
  /// Used for: Price displays, financial values
  static TextStyle currency(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.33,
        color: color,
      );

  /// Currency Small - 16sp Bold
  /// Used for: Smaller price displays
  static TextStyle currencySmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.50,
        color: color,
      );

  /// Numeric Display - 32sp
  /// Used for: Statistics, metrics, counters
  static TextStyle numericDisplay(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Barcode/Code - Monospace
  /// Used for: Barcodes, SKUs, reference numbers
  static TextStyle code(Color color) => TextStyle(
        fontFamily: 'Courier',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.43,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Button Text - 14sp Semi-Bold
  /// Used for: Primary button labels
  static TextStyle button(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.75,
        height: 1.43,
        color: color,
      );

  /// Overline - 10sp
  /// Used for: Overlines, tags, metadata
  static TextStyle overline(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        height: 1.60,
        color: color,
      );

  // ==================== HELPER METHODS ====================

  /// Creates a complete TextTheme for light mode
  static TextTheme lightTextTheme() {
    const textColor = Color(0xFF1A1C1E);
    const textColorMedium = Color(0xFF424242);
    const textColorLight = Color(0xFF757575);

    return TextTheme(
      displayLarge: displayLarge(textColor),
      displayMedium: displayMedium(textColor),
      displaySmall: displaySmall(textColor),
      headlineLarge: headlineLarge(textColor),
      headlineMedium: headlineMedium(textColor),
      headlineSmall: headlineSmall(textColor),
      titleLarge: titleLarge(textColor),
      titleMedium: titleMedium(textColorMedium),
      titleSmall: titleSmall(textColorMedium),
      bodyLarge: bodyLarge(textColor),
      bodyMedium: bodyMedium(textColorMedium),
      bodySmall: bodySmall(textColorLight),
      labelLarge: labelLarge(textColor),
      labelMedium: labelMedium(textColorMedium),
      labelSmall: labelSmall(textColorLight),
    );
  }

  /// Creates a complete TextTheme for dark mode
  static TextTheme darkTextTheme() {
    const textColor = Color(0xFFE1E6ED);
    const textColorMedium = Color(0xFFB8C1CC);
    const textColorLight = Color(0xFF8791A0);

    return TextTheme(
      displayLarge: displayLarge(textColor),
      displayMedium: displayMedium(textColor),
      displaySmall: displaySmall(textColor),
      headlineLarge: headlineLarge(textColor),
      headlineMedium: headlineMedium(textColor),
      headlineSmall: headlineSmall(textColor),
      titleLarge: titleLarge(textColor),
      titleMedium: titleMedium(textColorMedium),
      titleSmall: titleSmall(textColorMedium),
      bodyLarge: bodyLarge(textColor),
      bodyMedium: bodyMedium(textColorMedium),
      bodySmall: bodySmall(textColorLight),
      labelLarge: labelLarge(textColor),
      labelMedium: labelMedium(textColorMedium),
      labelSmall: labelSmall(textColorLight),
    );
  }
}
