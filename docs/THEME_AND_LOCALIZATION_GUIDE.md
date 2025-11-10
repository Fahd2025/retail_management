# Theme and Localization Implementation Guide

## Overview

This document describes the comprehensive theme and localization support that has been implemented in the Retail Management System.

## Features Implemented

### 1. Theme Support (Light/Dark Mode)
- ✅ Light and dark theme with Material 3 design
- ✅ Persistent theme preference using SharedPreferences
- ✅ Dynamic theme switching without app restart
- ✅ WCAG AA compliant color contrast ratios
- ✅ Responsive design maintained across both themes

### 2. Localization (Arabic/English)
- ✅ Full Arabic and English language support
- ✅ RTL (Right-to-Left) support for Arabic
- ✅ Persistent language preference
- ✅ Dynamic language switching without app restart
- ✅ 200+ translated strings covering all UI elements

### 3. User Interface
- ✅ Settings screen with theme and language toggles
- ✅ Intuitive switch control for theme selection
- ✅ Dropdown selector for language choice
- ✅ Real-time preview of changes

## Installation & Setup

### Step 1: Install Dependencies

Run the following command to install all required dependencies:

```bash
flutter pub get
```

This will:
- Install `flutter_localizations` for localization support
- Update all existing dependencies
- Generate localization files automatically

### Step 2: Generate Localization Files

The localization files will be auto-generated when you run:

```bash
flutter pub get
```

Or explicitly generate them with:

```bash
flutter gen-l10n
```

This creates the necessary `AppLocalizations` class from the ARB files.

### Step 3: Build and Run

For web:
```bash
flutter run -d chrome
```

For other platforms:
```bash
flutter run
```

## File Structure

```
lib/
├── config/
│   └── app_theme.dart              # Theme configuration (light & dark)
├── providers/
│   ├── theme_provider.dart         # Theme state management
│   └── locale_provider.dart        # Localization state management
├── l10n/
│   ├── app_en.arb                  # English translations
│   └── app_ar.arb                  # Arabic translations
├── screens/
│   └── settings_screen.dart        # Updated with theme/language controls
└── main.dart                       # Updated with providers integration

l10n.yaml                           # Localization configuration
pubspec.yaml                        # Updated with dependencies
```

## Usage

### Accessing Localized Strings

In any widget:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Text(l10n.appTitle);  // Returns "Retail Management System" or "نظام إدارة البيع بالتجزئة"
}
```

### Accessing Theme Provider

```dart
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

// Read theme state
final themeProvider = context.watch<ThemeProvider>();
bool isDark = themeProvider.isDarkMode;

// Toggle theme
await context.read<ThemeProvider>().toggleTheme();
```

### Accessing Locale Provider

```dart
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

// Read locale state
final localeProvider = context.watch<LocaleProvider>();
bool isArabic = localeProvider.isArabic;

// Change language
await context.read<LocaleProvider>().setArabic();
await context.read<LocaleProvider>().setEnglish();
```

## Available Translations

The following categories of strings are available in both English and Arabic:

### General App Strings
- appTitle, appSubtitle, ok, cancel, save, delete, edit, add, search, etc.

### Login Screen
- username, password, login, logout, validation messages

### Dashboard
- dashboard, welcome, totalSales, totalProducts, totalCustomers, statistics

### Products
- products, addProduct, editProduct, productName, price, quantity, category

### Categories
- categories, addCategory, categoryName, categoryDescription

### Customers
- customers, addCustomer, customerName, phone, email, address

### Sales
- sales, newSale, invoiceNumber, subtotal, discount, tax, total, payment

### Users
- users, addUser, fullName, role, admin, cashier

### Settings
- settings, appearance, theme, language, lightMode, darkMode, english, arabic

### Messages & Validation
- saveSuccess, deleteSuccess, confirmDelete, requiredField, etc.

## Theme Colors

### Light Theme
- Primary: `#2196F3` (Blue)
- Background: `#F5F5F5` (Light Gray)
- Surface: `#FFFFFF` (White)
- High contrast ratios for accessibility

### Dark Theme
- Primary: `#90CAF9` (Light Blue)
- Background: `#121212` (Very Dark Gray)
- Surface: `#1E1E1E` (Dark Gray)
- Optimized for low-light environments

## Accessibility

Both themes meet **WCAG AA** accessibility standards:
- Minimum 4.5:1 contrast ratio for normal text
- Minimum 3:1 contrast ratio for large text
- Support for screen readers in both languages
- RTL layout support for Arabic

## Settings Screen Usage

To access theme and language settings:

1. Navigate to **Settings** from the dashboard
2. The first card shows **Appearance** settings:
   - Toggle switch for Light/Dark mode
   - Dropdown for Language selection (English/العربية)
3. Changes apply immediately without app restart
4. Preferences are saved automatically

## Best Practices

### Adding New Translations

1. Add the key-value pair to `lib/l10n/app_en.arb`:
```json
{
  "newKey": "New Value"
}
```

2. Add the corresponding Arabic translation to `lib/l10n/app_ar.arb`:
```json
{
  "newKey": "القيمة الجديدة"
}
```

3. Run `flutter pub get` to regenerate localization files

4. Use in your code:
```dart
Text(l10n.newKey)
```

### Adding Placeholders

For dynamic values in translations:

**app_en.arb:**
```json
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**Usage:**
```dart
Text(l10n.greeting('John'))  // "Hello, John!"
```

### Theme-Aware Widgets

Always use theme colors instead of hardcoded values:

```dart
// ❌ Bad
Container(color: Colors.white)

// ✅ Good
Container(color: Theme.of(context).colorScheme.surface)
```

## Testing

### Manual Testing Checklist

- [ ] Theme switches correctly between light and dark
- [ ] Theme preference persists after app restart
- [ ] Language switches correctly between English and Arabic
- [ ] Language preference persists after app restart
- [ ] Arabic text displays in RTL (Right-to-Left)
- [ ] All UI elements are properly translated
- [ ] Color contrast is sufficient in both themes
- [ ] Settings UI is accessible and intuitive

### Automated Testing

Create widget tests for theme and locale providers:

```dart
testWidgets('Theme toggle works', (WidgetTester tester) async {
  final provider = ThemeProvider();
  await provider.initialize();

  expect(provider.isDarkMode, false);
  await provider.toggleTheme();
  expect(provider.isDarkMode, true);
});
```

## Troubleshooting

### Issue: Localization files not generated

**Solution:** Run `flutter pub get` or `flutter gen-l10n`

### Issue: `AppLocalizations.of(context)` returns null

**Solution:** Ensure MaterialApp has `localizationsDelegates` configured (already done in main.dart)

### Issue: Theme not changing

**Solution:** Check that MaterialApp is wrapped in Consumer<ThemeProvider> (already done in main.dart)

### Issue: Arabic text not in RTL

**Solution:** The locale provider automatically handles RTL. Check that MaterialApp's `locale` property is set correctly (already done in main.dart)

## Performance Considerations

- Theme and locale providers are initialized once at app startup
- SharedPreferences operations are async and don't block UI
- Theme and locale changes use `notifyListeners()` for efficient rebuilds
- Only widgets that depend on theme/locale are rebuilt when changes occur

## Future Enhancements

Potential improvements for the future:

1. **Additional Languages:** Add more language support (French, Spanish, etc.)
2. **System Theme:** Add option to follow system theme preference
3. **Custom Themes:** Allow users to customize color schemes
4. **Font Scaling:** Add font size preferences for accessibility
5. **High Contrast Mode:** Additional high-contrast theme variant

## Support

For issues or questions:
- Check the implementation in `lib/providers/` and `lib/config/`
- Review ARB files in `lib/l10n/`
- Consult Flutter localization docs: https://docs.flutter.dev/accessibility-and-localization/internationalization

## Conclusion

The theme and localization implementation provides a robust, user-friendly, and accessible experience for both English and Arabic users. All code follows Flutter best practices and is well-documented for maintainability.
