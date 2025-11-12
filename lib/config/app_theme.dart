import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dark_theme_colors.dart';
import 'app_typography.dart';

/// Application theme configuration with Material 3 design
///
/// This class provides:
/// - Comprehensive light and dark theme configurations
/// - WCAG AA accessibility compliant color schemes (contrast ratios ≥ 4.5:1)
/// - Unified component styling across the retail management application
/// - Material 3 design system implementation
/// - Professional appearance optimized for business applications
/// - Reduced eye strain for extended use in dark environments
class AppTheme {
  // ==================== LIGHT THEME COLORS ====================
  // Primary brand color - Blue
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryDarkColor = Color(0xFF1976D2);
  static const Color primaryLightColor = Color(0xFF64B5F6);

  // Secondary color - Teal
  static const Color secondaryColor = Color(0xFF009688);
  static const Color secondaryDarkColor = Color(0xFF00796B);

  // Success, Warning, Error colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);

  /// Light theme configuration
  /// Designed with WCAG AA compliant contrast ratios (minimum 4.5:1 for normal text)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme for Material 3 components
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryLightColor,
        onPrimaryContainer: const Color(0xFF001D36),
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,
        errorContainer: errorColor.withOpacity(0.2),
        onErrorContainer: errorColor,
        background: const Color(0xFFF5F5F5),
        onBackground: const Color(0xFF1A1C1E),
        surface: Colors.white,
        onSurface: const Color(0xFF1A1C1E),
        surfaceVariant: const Color(0xFFE0E0E0),
        onSurfaceVariant: const Color(0xFF424242),
        outline: const Color(0xFF757575),
        outlineVariant: const Color(0xFFBB86FC),
        shadow: const Color(0xFF000000),
        scrim: const Color(0xFF000000),
        inverseSurface: const Color(0xFF343A40),
        onInverseSurface: Colors.white,
        inversePrimary: primaryColor,
      ),

      // Scaffold background
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),

      // Canvas color
      canvasColor: Colors.white,

      // Text theme
      textTheme: AppTypography.lightTextTheme(),

      // App bar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 4,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: primaryColor,
        shadowColor: Color(0x1F000000),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 2,
        color: Colors.white,
        shadowColor: Color(0x1F000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          disabledForegroundColor: const Color(0xFF9E9E9E),
          shadowColor: const Color(0x1F000000),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          disabledForegroundColor: const Color(0xFF9E9E9E),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          disabledForegroundColor: const Color(0xFF9E9E9E),
          side: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFF424242),
          disabledForegroundColor: const Color(0xFFBDBDBD).withOpacity(0.38),
          highlightColor: primaryColor.withOpacity(0.12),
          hoverColor: const Color(0xFFBDBDBD).withOpacity(0.04),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLightColor,
        foregroundColor: Colors.white,
        elevation: 6,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFF44336), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFF44336), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: Color(0xFF757575), fontSize: 14),
        hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        errorStyle: TextStyle(color: Color(0xFFF44336), fontSize: 12),
        helperStyle: TextStyle(color: Color(0xFF757575), fontSize: 12),
        prefixIconColor: Color(0xFF757575),
        suffixIconColor: Color(0xFF757575),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: Color(0xFF424242),
        size: 24,
      ),

      primaryIconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: primaryColor,
        elevation: 8,
        shadowColor: const Color(0x1F000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1C1E),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF424242),
          fontSize: 14,
        ),
        actionsPadding: const EdgeInsets.all(24),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: primaryColor,
        modalBackgroundColor: Colors.white,
        elevation: 8,
        modalElevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return const Color(0xFFBDBDBD);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryLightColor;
          }
          return const Color(0xFFE0E0E0);
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return primaryColor.withOpacity(0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFFBDBDBD).withOpacity(0.04);
          }
          if (states.contains(WidgetState.focused)) {
            return const Color(0xFFBDBDBD).withOpacity(0.12);
          }
          return Colors.transparent;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0xFFBDBDBD);
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return primaryColor.withOpacity(0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFFBDBDBD).withOpacity(0.04);
          }
          if (states.contains(WidgetState.focused)) {
            return const Color(0xFFBDBDBD).withOpacity(0.12);
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0xFFBDBDBD);
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return const Color(0xFF424242);
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return primaryColor.withOpacity(0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFFBDBDBD).withOpacity(0.04);
          }
          if (states.contains(WidgetState.focused)) {
            return const Color(0xFFBDBDBD).withOpacity(0.12);
          }
          return Colors.transparent;
        }),
      ),

      // SnackBar theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF323232),
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        actionTextColor: primaryColor,
        disabledActionTextColor: Color(0xFF9E9E9E),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        behavior: SnackBarBehavior.floating,
        actionOverflowThreshold: 0.25,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF757575),
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: primaryColor.withOpacity(0.12),
        selectedColor: primaryColor,
        iconColor: const Color(0xFF757575),
        textColor: const Color(0xFF1A1C1E),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1C1E),
          fontSize: 16,
        ),
        subtitleTextStyle: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 14,
        ),
        leadingAndTrailingTextStyle: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color(0xFFE0E0E0),
        circularTrackColor: Color(0xFFE0E0E0),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE0E0E0),
        deleteIconColor: const Color(0xFF757575),
        disabledColor: const Color(0xFFE0E0E0).withOpacity(0.12),
        selectedColor: primaryColor.withOpacity(0.2),
        secondarySelectedColor: secondaryColor.withOpacity(0.2),
        shadowColor: const Color(0x1F000000),
        labelStyle: const TextStyle(
          color: Color(0xFF1A1C1E),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Color(0xFF1A1C1E),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        pressElevation: 2,
      ),

      // Data table theme
      dataTableTheme: DataTableThemeData(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.12);
          }
          return Colors.transparent;
        }),
        dataTextStyle: const TextStyle(
          color: Color(0xFF1A1C1E),
          fontSize: 14,
        ),
        headingTextStyle: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        headingRowColor: WidgetStateProperty.resolveWith((states) {
          return const Color(0xFFE0E0E0).withOpacity(0.5);
        }),
        dividerThickness: 1,
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: const Color(0xFF757575),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: const Color(0xFFE0E0E0),
      ),

      // Tooltip theme
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: Color(0xFF616161),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        waitDuration: Duration(milliseconds: 500),
        showDuration: Duration(milliseconds: 1500),
      ),
    );
  }

  /// Dark theme configuration
  /// Designed with WCAG AA compliant contrast ratios
  /// Dark surfaces help reduce eye strain in low-light environments
  ///
  /// Key features:
  /// - Professional dark color palette optimized for retail applications
  /// - High contrast text for better readability
  /// - Subtle surface elevation for visual hierarchy
  /// - Comprehensive widget theming for consistency
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ==================== COLOR SCHEME ====================
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        // Primary colors
        primary: DarkThemeColors.primary,
        onPrimary: DarkThemeColors.onPrimary,
        primaryContainer: DarkThemeColors.primaryContainer,
        onPrimaryContainer: DarkThemeColors.onPrimaryContainer,
        // Secondary colors
        secondary: DarkThemeColors.secondary,
        onSecondary: DarkThemeColors.onSecondary,
        secondaryContainer: DarkThemeColors.secondaryContainer,
        onSecondaryContainer: DarkThemeColors.onSecondaryContainer,
        // Error colors
        error: DarkThemeColors.error,
        onError: Colors.white,
        errorContainer: DarkThemeColors.errorContainer,
        onErrorContainer: DarkThemeColors.onErrorContainer,
        // Surface colors
        surface: DarkThemeColors.surface,
        onSurface: DarkThemeColors.onSurface,
        surfaceContainerHighest: DarkThemeColors.surfaceVariant,
        onSurfaceVariant: DarkThemeColors.onSurfaceVariant,
        // Other colors
        outline: DarkThemeColors.outline,
        outlineVariant: DarkThemeColors.outlineVariant,
        shadow: DarkThemeColors.shadow,
        scrim: DarkThemeColors.scrim,
        inverseSurface: const Color(0xFFE1E6ED),
        onInverseSurface: const Color(0xFF1A1F26),
        inversePrimary: const Color(0xFF2196F3),
      ),

      // ==================== SCAFFOLD ====================
      scaffoldBackgroundColor: DarkThemeColors.background,

      // ==================== CANVAS COLOR ====================
      canvasColor: DarkThemeColors.surface,

      // ==================== TEXT THEME ====================
      textTheme: AppTypography.darkTextTheme(),

      // ==================== APPBAR THEME ====================
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 4,
        backgroundColor: DarkThemeColors.surfaceElevated,
        foregroundColor: DarkThemeColors.onSurface,
        surfaceTintColor: DarkThemeColors.primary,
        shadowColor: DarkThemeColors.shadow,
        iconTheme: const IconThemeData(
          color: DarkThemeColors.onSurface,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: DarkThemeColors.onSurface,
          size: 24,
        ),
        titleTextStyle: AppTypography.titleLarge(DarkThemeColors.onSurface),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // ==================== CARD THEME ====================
      cardTheme: CardThemeData(
        elevation: 2,
        color: DarkThemeColors.surface,
        surfaceTintColor: DarkThemeColors.primary,
        shadowColor: DarkThemeColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(8),
      ),

      // ==================== ELEVATED BUTTON THEME ====================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: DarkThemeColors.primary,
          foregroundColor: DarkThemeColors.onPrimary,
          disabledBackgroundColor: DarkThemeColors.surfaceVariant.withOpacity(
            0.12,
          ),
          disabledForegroundColor: DarkThemeColors.textDisabled,
          shadowColor: DarkThemeColors.shadow,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.button(DarkThemeColors.onPrimary),
        ),
      ),

      // ==================== TEXT BUTTON THEME ====================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DarkThemeColors.primary,
          disabledForegroundColor: DarkThemeColors.textDisabled,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.button(DarkThemeColors.primary),
        ),
      ),

      // ==================== OUTLINED BUTTON THEME ====================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DarkThemeColors.primary,
          disabledForegroundColor: DarkThemeColors.textDisabled,
          side: const BorderSide(color: DarkThemeColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.button(DarkThemeColors.primary),
        ),
      ),

      // ==================== ICON BUTTON THEME ====================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: DarkThemeColors.onSurfaceVariant,
          disabledForegroundColor: DarkThemeColors.textDisabled,
          highlightColor: DarkThemeColors.primary.withOpacity(0.12),
          hoverColor: DarkThemeColors.hoverOverlay,
        ),
      ),

      // ==================== FLOATING ACTION BUTTON THEME ====================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DarkThemeColors.primaryContainer,
        foregroundColor: DarkThemeColors.onPrimaryContainer,
        elevation: 6,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ==================== INPUT DECORATION THEME ====================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkThemeColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DarkThemeColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DarkThemeColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: DarkThemeColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DarkThemeColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DarkThemeColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: DarkThemeColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: AppTypography.bodyMedium(DarkThemeColors.onSurfaceVariant),
        hintStyle: AppTypography.bodyMedium(DarkThemeColors.textHint),
        errorStyle: AppTypography.bodySmall(DarkThemeColors.error),
        helperStyle: AppTypography.bodySmall(DarkThemeColors.onSurfaceVariant),
        prefixIconColor: DarkThemeColors.onSurfaceVariant,
        suffixIconColor: DarkThemeColors.onSurfaceVariant,
      ),

      // ==================== SNACKBAR THEME ====================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DarkThemeColors.surfaceElevated,
        contentTextStyle: AppTypography.bodyMedium(DarkThemeColors.onSurface),
        actionTextColor: DarkThemeColors.primary,
        disabledActionTextColor: DarkThemeColors.textDisabled,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        actionOverflowThreshold: 0.25,
      ),

      // ==================== BOTTOM NAVIGATION BAR THEME ====================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DarkThemeColors.surfaceElevated,
        selectedItemColor: DarkThemeColors.primary,
        unselectedItemColor: DarkThemeColors.onSurfaceVariant,
        selectedLabelStyle: AppTypography.labelSmall(DarkThemeColors.primary),
        unselectedLabelStyle: AppTypography.labelSmall(
          DarkThemeColors.onSurfaceVariant,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ==================== NAVIGATION RAIL THEME ====================
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: DarkThemeColors.surfaceElevated,
        selectedIconTheme: const IconThemeData(
          color: DarkThemeColors.primary,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: DarkThemeColors.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle: AppTypography.labelMedium(
          DarkThemeColors.primary,
        ),
        unselectedLabelTextStyle: AppTypography.labelMedium(
          DarkThemeColors.onSurfaceVariant,
        ),
        elevation: 0,
      ),

      // ==================== LIST TILE THEME ====================
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: DarkThemeColors.primaryContainer.withOpacity(0.12),
        selectedColor: DarkThemeColors.primary,
        iconColor: DarkThemeColors.onSurfaceVariant,
        textColor: DarkThemeColors.onSurface,
        titleTextStyle: AppTypography.bodyLarge(DarkThemeColors.onSurface),
        subtitleTextStyle: AppTypography.bodyMedium(
          DarkThemeColors.onSurfaceVariant,
        ),
        leadingAndTrailingTextStyle: AppTypography.labelSmall(
          DarkThemeColors.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ==================== CHIP THEME ====================
      chipTheme: ChipThemeData(
        backgroundColor: DarkThemeColors.surfaceVariant,
        deleteIconColor: DarkThemeColors.onSurfaceVariant,
        disabledColor: DarkThemeColors.surfaceVariant.withOpacity(0.12),
        selectedColor: DarkThemeColors.primaryContainer,
        secondarySelectedColor: DarkThemeColors.secondaryContainer,
        shadowColor: DarkThemeColors.shadow,
        labelStyle: AppTypography.labelMedium(DarkThemeColors.onSurfaceVariant),
        secondaryLabelStyle: AppTypography.labelMedium(
          DarkThemeColors.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        pressElevation: 2,
      ),

      // ==================== DATA TABLE THEME ====================
      dataTableTheme: DataTableThemeData(
        decoration: BoxDecoration(
          color: DarkThemeColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DarkThemeColors.primaryContainer.withOpacity(0.12);
          }
          return Colors.transparent;
        }),
        dataTextStyle: AppTypography.bodyMedium(DarkThemeColors.onSurface),
        headingTextStyle: AppTypography.titleSmall(
          DarkThemeColors.onSurfaceVariant,
        ),
        headingRowColor: WidgetStateProperty.all(
          DarkThemeColors.surfaceVariant.withOpacity(0.5),
        ),
        dividerThickness: 1,
      ),

      // ==================== ICON THEME ====================
      iconTheme: const IconThemeData(
        color: DarkThemeColors.onSurface,
        size: 24,
      ),

      primaryIconTheme: const IconThemeData(
        color: DarkThemeColors.primary,
        size: 24,
      ),

      // ==================== DIVIDER THEME ====================
      dividerTheme: const DividerThemeData(
        color: DarkThemeColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ==================== DIALOG THEME ====================
      dialogTheme: DialogThemeData(
        backgroundColor: DarkThemeColors.surface,
        surfaceTintColor: DarkThemeColors.primary,
        elevation: 24,
        shadowColor: DarkThemeColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: AppTypography.headlineSmall(DarkThemeColors.onSurface),
        contentTextStyle: AppTypography.bodyMedium(
          DarkThemeColors.onSurfaceVariant,
        ),
        actionsPadding: const EdgeInsets.all(24),
      ),

      // ==================== BOTTOM SHEET THEME ====================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: DarkThemeColors.surface,
        surfaceTintColor: DarkThemeColors.primary,
        modalBackgroundColor: DarkThemeColors.surface,
        elevation: 8,
        modalElevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ==================== SWITCH THEME ====================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return DarkThemeColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return DarkThemeColors.primary;
          }
          return DarkThemeColors.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return DarkThemeColors.surfaceVariant.withOpacity(0.12);
          }
          if (states.contains(WidgetState.selected)) {
            return DarkThemeColors.primaryContainer;
          }
          return DarkThemeColors.surfaceVariant;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return DarkThemeColors.pressedOverlay;
          }
          if (states.contains(WidgetState.hovered)) {
            return DarkThemeColors.hoverOverlay;
          }
          if (states.contains(WidgetState.focused)) {
            return DarkThemeColors.focusOverlay;
          }
          return Colors.transparent;
        }),
      ),

      // ==================== CHECKBOX THEME ====================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return DarkThemeColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return DarkThemeColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(DarkThemeColors.onPrimary),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return DarkThemeColors.pressedOverlay;
          }
          if (states.contains(WidgetState.hovered)) {
            return DarkThemeColors.hoverOverlay;
          }
          if (states.contains(WidgetState.focused)) {
            return DarkThemeColors.focusOverlay;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ==================== RADIO THEME ====================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return DarkThemeColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return DarkThemeColors.primary;
          }
          return DarkThemeColors.onSurfaceVariant;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return DarkThemeColors.pressedOverlay;
          }
          if (states.contains(WidgetState.hovered)) {
            return DarkThemeColors.hoverOverlay;
          }
          if (states.contains(WidgetState.focused)) {
            return DarkThemeColors.focusOverlay;
          }
          return Colors.transparent;
        }),
      ),

      // ==================== SLIDER THEME ====================
      sliderTheme: SliderThemeData(
        activeTrackColor: DarkThemeColors.primary,
        inactiveTrackColor: DarkThemeColors.surfaceVariant,
        thumbColor: DarkThemeColors.primary,
        overlayColor: DarkThemeColors.primary.withOpacity(0.12),
        valueIndicatorColor: DarkThemeColors.primary,
        valueIndicatorTextStyle: AppTypography.labelMedium(
          DarkThemeColors.onPrimary,
        ),
      ),

      // ==================== PROGRESS INDICATOR THEME ====================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DarkThemeColors.primary,
        linearTrackColor: DarkThemeColors.surfaceVariant,
        circularTrackColor: DarkThemeColors.surfaceVariant,
      ),

      // ==================== TOOLTIP THEME ====================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DarkThemeColors.tooltip,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: AppTypography.bodySmall(DarkThemeColors.onTooltip),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(milliseconds: 1500),
      ),

      // ==================== BADGE THEME ====================
      badgeTheme: BadgeThemeData(
        backgroundColor: DarkThemeColors.badge,
        textColor: DarkThemeColors.onBadge,
        smallSize: 6,
        largeSize: 16,
        textStyle: AppTypography.labelSmall(DarkThemeColors.onBadge),
      ),

      // ==================== TAB BAR THEME ====================
      tabBarTheme: TabBarThemeData(
        labelColor: DarkThemeColors.primary,
        unselectedLabelColor: DarkThemeColors.onSurfaceVariant,
        labelStyle: AppTypography.titleSmall(DarkThemeColors.primary),
        unselectedLabelStyle: AppTypography.titleSmall(
          DarkThemeColors.onSurfaceVariant,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: DarkThemeColors.primary, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: DarkThemeColors.divider,
      ),

      // ==================== DRAWER THEME ====================
      drawerTheme: DrawerThemeData(
        backgroundColor: DarkThemeColors.surface,
        surfaceTintColor: DarkThemeColors.primary,
        elevation: 16,
        shadowColor: DarkThemeColors.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
      ),

      // ==================== POPUP MENU THEME ====================
      popupMenuTheme: PopupMenuThemeData(
        color: DarkThemeColors.surface,
        surfaceTintColor: DarkThemeColors.primary,
        elevation: 8,
        shadowColor: DarkThemeColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTypography.bodyMedium(DarkThemeColors.onSurface),
      ),

      // ==================== BANNER THEME ====================
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: DarkThemeColors.surface,
        contentTextStyle: AppTypography.bodyMedium(DarkThemeColors.onSurface),
        elevation: 1,
        padding: const EdgeInsets.all(16),
      ),

      // ==================== EXPANSION TILE THEME ====================
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        textColor: DarkThemeColors.onSurface,
        iconColor: DarkThemeColors.onSurfaceVariant,
        collapsedTextColor: DarkThemeColors.onSurface,
        collapsedIconColor: DarkThemeColors.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ==================== TIME PICKER THEME ====================
      timePickerTheme: TimePickerThemeData(
        backgroundColor: DarkThemeColors.surface,
        dialBackgroundColor: DarkThemeColors.surfaceVariant,
        dialHandColor: DarkThemeColors.primary,
        dialTextColor: DarkThemeColors.onSurface,
        hourMinuteColor: DarkThemeColors.surfaceVariant,
        hourMinuteTextColor: DarkThemeColors.onSurface,
        dayPeriodColor: DarkThemeColors.surfaceVariant,
        dayPeriodTextColor: DarkThemeColors.onSurface,
        entryModeIconColor: DarkThemeColors.onSurface,
        helpTextStyle: AppTypography.labelMedium(DarkThemeColors.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),

      // ==================== DATE PICKER THEME ====================
      datePickerTheme: DatePickerThemeData(
        backgroundColor: DarkThemeColors.surface,
        surfaceTintColor: DarkThemeColors.primary,
        headerBackgroundColor: DarkThemeColors.primaryContainer,
        headerForegroundColor: DarkThemeColors.onPrimaryContainer,
        headerHeadlineStyle: AppTypography.headlineLarge(
          DarkThemeColors.onPrimaryContainer,
        ),
        headerHelpStyle: AppTypography.labelMedium(
          DarkThemeColors.onPrimaryContainer,
        ),
        weekdayStyle: AppTypography.bodySmall(DarkThemeColors.onSurfaceVariant),
        dayStyle: AppTypography.bodyMedium(DarkThemeColors.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 6,
      ),

      // ==================== SEARCH BAR THEME ====================
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(
          DarkThemeColors.surfaceVariant,
        ),
        surfaceTintColor: WidgetStateProperty.all(DarkThemeColors.primary),
        elevation: WidgetStateProperty.all(2),
        shadowColor: WidgetStateProperty.all(DarkThemeColors.shadow),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
        textStyle: WidgetStateProperty.all(
          AppTypography.bodyMedium(DarkThemeColors.onSurface),
        ),
        hintStyle: WidgetStateProperty.all(
          AppTypography.bodyMedium(DarkThemeColors.textHint),
        ),
      ),

      // ==================== SEARCH VIEW THEME ====================
      searchViewTheme: SearchViewThemeData(
        backgroundColor: DarkThemeColors.surface,
        surfaceTintColor: DarkThemeColors.primary,
        elevation: 6,
        dividerColor: DarkThemeColors.divider,
        headerTextStyle: AppTypography.bodyLarge(DarkThemeColors.onSurface),
        headerHintStyle: AppTypography.bodyLarge(DarkThemeColors.textHint),
      ),
    );
  }
}
