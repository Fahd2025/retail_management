# Arabic Translation Requirements

## Overview

This document outlines the mandatory requirements for Arabic translation when adding new features to the Retail Management System.

## General Requirements

### 1. **All User-Facing Text Must Be Translated**

When adding any new feature or UI element that displays text to users, you **MUST** provide both English and Arabic translations.

### 2. **Translation Files Location**

- **English**: `/lib/l10n/app_en.arb`
- **Arabic**: `/lib/l10n/app_ar.arb`

### 3. **Translation Process**

For every new text string:

1. Add the English translation to `app_en.arb`:
   ```json
   {
     "newFeatureKey": "English text here"
   }
   ```

2. Add the corresponding Arabic translation to `app_ar.arb`:
   ```json
   {
     "newFeatureKey": "النص العربي هنا"
   }
   ```

3. Run `flutter pub get` to regenerate localization files

4. Use the translation in your code:
   ```dart
   final l10n = AppLocalizations.of(context)!;
   Text(l10n.newFeatureKey)
   ```

## Recent Changes (2025-11-11)

### Mobile UI Enhancements

#### 1. Login Screen - Full Screen Mode

**File**: `lib/screens/login_screen.dart`

**Changes Made**:
- Removed Card widget with fixed margins
- Implemented full-screen layout using `SafeArea`
- Added semi-transparent container with rounded corners for modern look
- Login form now fills entire screen with gradient background

**User Experience**:
- More immersive mobile login experience
- Better use of screen real estate
- Maintains responsive design for different screen sizes

#### 2. Exit Confirmation Dialog

**File**: `lib/screens/dashboard_screen.dart`

**Changes Made**:
- Added `PopScope` widget to intercept system back button
- Implemented `_onWillPop()` method to show confirmation dialog
- Prevents accidental app exit

**Translations Added**:

| Key | English | Arabic |
|-----|---------|--------|
| `confirmExit` | "Are you sure you want to exit the application?" | "هل أنت متأكد من الخروج من التطبيق؟" |

**User Flow**:
1. User presses back button on mobile device
2. Dialog appears asking for confirmation
3. User can choose "Yes" (نعم) to exit or "No" (لا) to cancel

## Best Practices for Arabic Translation

### 1. **RTL (Right-to-Left) Support**

Arabic is an RTL language. The app automatically handles RTL layout when Arabic is selected through the `LocaleBloc`. No additional work needed for standard Flutter widgets.

### 2. **Cultural Context**

- Use formal Arabic (Modern Standard Arabic) for professional applications
- Avoid colloquialisms or regional dialects
- Maintain consistency in terminology across the application

### 3. **Translation Quality**

- Ensure translations are grammatically correct
- Use appropriate Arabic technical terms
- Don't use Google Translate blindly - review and refine translations
- Consider context when translating (e.g., "Save" could be حفظ or إنشاء depending on context)

### 4. **Placeholder Text**

For dynamic content with placeholders:

**English (app_en.arb)**:
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

**Arabic (app_ar.arb)**:
```json
{
  "greeting": "مرحباً، {name}!"
}
```

### 5. **Numbers and Dates**

- The app handles number localization automatically
- For dates, use `intl` package formatting which respects locale

## Checklist for New Features

Before committing any new feature, ensure:

- [ ] All user-facing strings are added to both `app_en.arb` and `app_ar.arb`
- [ ] Translations are contextually appropriate
- [ ] Arabic translations are grammatically correct
- [ ] UI layout works correctly in both LTR (English) and RTL (Arabic) modes
- [ ] Tested the feature in both languages
- [ ] Documentation updated to reflect new translations

## Translation Guidelines by Category

### Action Buttons
- Use imperative verb forms
- Keep translations concise
- Examples:
  - Save → حفظ
  - Delete → حذف
  - Edit → تعديل
  - Add → إضافة

### Confirmation Dialogs
- Use polite, formal question structure
- Include proper question marks (؟ in Arabic)
- Examples:
  - "Are you sure?" → "هل أنت متأكد؟"
  - "Confirm action?" → "تأكيد الإجراء؟"

### Error Messages
- Be clear and specific
- Suggest solutions when possible
- Examples:
  - "Field is required" → "هذا الحقل مطلوب"
  - "Invalid email" → "البريد الإلكتروني غير صحيح"

### Status Messages
- Use complete sentences
- Include context
- Examples:
  - "Saved successfully" → "تم الحفظ بنجاح"
  - "Loading..." → "جاري التحميل..."

## Tools and Resources

### Recommended Translation Tools

1. **DeepL** - Often more accurate than Google Translate for Arabic
2. **Reverso Context** - Shows translations in context
3. **Native Arabic Speakers** - Always best to have a native speaker review

### Arabic Keyboard Layouts

For developers needing to test Arabic input:
- Windows: Alt + Shift to switch keyboards
- macOS: Control + Space
- Linux: Super + Space (depends on DE)

### Testing Arabic Display

Common issues to test:
- Text alignment (should be right-aligned for Arabic)
- Icon positions (should mirror in RTL)
- Text truncation (ellipsis should appear on left side)
- Mixed content (Arabic text with English numbers/names)

## Common Translation Patterns

| English Pattern | Arabic Pattern | Notes |
|----------------|----------------|-------|
| "Welcome {name}" | "مرحباً {name}" | Name stays in English/original |
| "Total: {amount}" | "الإجمالي: {amount}" | Numbers use localized format |
| "Save Changes" | "حفظ التغييرات" | Add definite article (ال) |
| "Are you sure?" | "هل أنت متأكد؟" | Use Arabic question mark |
| "{count} items" | "{count} عناصر" | Number comes first |

## Contact and Support

If you need help with Arabic translations:
1. Consult this document first
2. Review existing translations in `app_ar.arb` for consistency
3. Check Flutter localization documentation
4. Seek help from Arabic-speaking team members

## Conclusion

Maintaining high-quality Arabic translations is essential for providing a professional, accessible experience to Arabic-speaking users. By following these requirements and guidelines, we ensure consistency and quality across the application.

---

**Last Updated**: 2025-11-11
**Document Version**: 1.0
**Maintained By**: Development Team
