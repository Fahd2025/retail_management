# Settings Page UI/UX Design Guide

## Overview

This guide explains the design principles, component architecture, and implementation patterns for creating an optimal settings page experience across all screen sizes in the retail management Flutter application.

## Table of Contents

1. [Design Principles](#design-principles)
2. [Responsive Design Strategy](#responsive-design-strategy)
3. [Component Architecture](#component-architecture)
4. [Section Organization](#section-organization)
5. [UI/UX Best Practices](#uiux-best-practices)
6. [Implementation Examples](#implementation-examples)
7. [Visual Design Specifications](#visual-design-specifications)
8. [Accessibility Considerations](#accessibility-considerations)

---

## Design Principles

### 1. Progressive Disclosure
- Show the most important settings first
- Use collapsible sections for advanced or less frequently used options
- Maintain clear visual hierarchy

### 2. Consistency
- Reusable components ensure consistent look and feel
- Standard spacing, typography, and color schemes throughout
- Predictable interaction patterns

### 3. Responsive by Default
- Layouts adapt seamlessly from mobile to desktop
- Content reflows intelligently based on available space
- No horizontal scrolling on any device

### 4. Clarity and Simplicity
- Clear labels and descriptions for all settings
- Visual feedback for all interactions
- Minimal cognitive load through good organization

---

## Responsive Design Strategy

### Screen Size Breakpoints

```dart
const double mobileBreakpoint = 600.0;    // phones
const double tabletBreakpoint = 900.0;    // tablets
const double desktopBreakpoint = 1200.0;  // desktop/wide screens
```

### Layout Strategies by Screen Size

#### Mobile (< 600px)
- **Single column layout**
- **Stack all sections vertically**
- **Full-width cards with no margins**
- **Touch-friendly target sizes (minimum 48px)**
- **Simplified forms with single-column fields**

```dart
// Mobile layout example
return Column(
  children: sections.map((section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: section,
    );
  }).toList(),
);
```

#### Tablet (600px - 1200px)
- **Single column layout with increased padding**
- **Wider cards with breathing room**
- **Two-column form fields where appropriate**
- **Moderate spacing between elements**

```dart
// Tablet layout example
return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 32),
  child: Column(
    children: sections.map((section) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: section,
      );
    }).toList(),
  ),
);
```

#### Desktop (> 1200px)
- **Two-column grid for sections**
- **Side-by-side related settings**
- **Maximum content width (1400px) with centered alignment**
- **Generous spacing and padding**

```dart
// Desktop layout example
return Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1400),
    child: SettingsGrid(
      spacing: 24,
      children: sections,
    ),
  ),
);
```

### Responsive Implementation Pattern

```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;

      if (width < 600) {
        return _buildMobileLayout();
      } else if (width < 1200) {
        return _buildTabletLayout();
      } else {
        return _buildDesktopLayout();
      }
    },
  );
}
```

---

## Component Architecture

### 1. SettingsSection

A reusable card-based container for grouped settings.

**Features:**
- Optional icon and subtitle
- Collapsible mode with ExpansionTile
- Consistent styling and spacing
- Divider between header and content

**Use Cases:**
- Grouping related settings
- Creating visual separation between different areas
- Collapsing less frequently used options

**Example:**
```dart
SettingsSection(
  title: 'Appearance',
  icon: Icons.palette,
  subtitle: 'Customize the look and feel',
  isCollapsible: false,
  children: [
    // Settings items
  ],
)
```

### 2. SettingsGrid

A responsive grid that adapts layout based on screen size.

**Features:**
- Automatic column count adjustment
- Configurable spacing
- Alternating item distribution for balance

**Breakpoint Behavior:**
- **< 600px**: 1 column (mobile)
- **600-1200px**: 1 column (tablet)
- **> 1200px**: 2 columns (desktop)

**Example:**
```dart
SettingsGrid(
  spacing: 24,
  children: [
    appearanceSection,
    printSettingsSection,
    companyInfoSection,
    syncSection,
  ],
)
```

### 3. SettingsItem

A consistent list item for individual settings.

**Features:**
- Icon, title, subtitle support
- Trailing widget for controls
- Optional tap handler
- Zero content padding for alignment

**Example:**
```dart
SettingsItem(
  icon: Icons.print,
  title: 'Print Format',
  subtitle: 'A4 (210×297mm)',
  trailing: Icon(Icons.chevron_right),
  onTap: () => showFormatDialog(),
)
```

---

## Section Organization

### Priority-Based Hierarchy

#### High Priority (Always Visible, Top Position)
1. **Appearance & Language**
   - Theme selection
   - Language preferences
   - Most frequently accessed

2. **Print Settings**
   - Print format selection
   - Display options
   - Critical for daily operations

#### Medium Priority (Visible, Middle Position)
3. **Company Information**
   - Business details
   - Contact information
   - Important but infrequently changed

#### Low Priority (Visible, Bottom Position)
4. **Data Synchronization**
   - Sync controls
   - Status information
   - Occasional use

5. **About**
   - Version information
   - App details
   - Reference only

### Grouping Strategies

#### Functional Grouping
Group settings by function or feature area:
- **Appearance**: Theme, language, display preferences
- **Business**: Company info, tax settings, currency
- **Operations**: Printing, invoicing, receipts
- **System**: Sync, backup, updates

#### Frequency-Based Grouping
Group by how often settings are accessed:
- **Daily**: Print settings, language
- **Weekly**: Sync, appearance
- **Monthly**: Company info
- **Rarely**: About, advanced settings

---

## UI/UX Best Practices

### 1. Visual Hierarchy

#### Typography Scale
```dart
// Section titles
TextStyle titleLarge = Theme.of(context).textTheme.titleLarge;
// fontSize: 22, fontWeight: FontWeight.w500

// Setting labels
TextStyle titleMedium = Theme.of(context).textTheme.titleMedium;
// fontSize: 16, fontWeight: FontWeight.w500

// Descriptions
TextStyle bodyMedium = Theme.of(context).textTheme.bodyMedium;
// fontSize: 14, fontWeight: FontWeight.w400

// Helper text
TextStyle bodySmall = Theme.of(context).textTheme.bodySmall;
// fontSize: 12, fontWeight: FontWeight.w400
```

#### Visual Weight Distribution
```
Section Header (Heavy)
  ↓
Divider (Light separator)
  ↓
Primary Settings (Medium-Heavy)
  ↓
Secondary Settings (Medium)
  ↓
Helper Text (Light)
```

### 2. Spacing and Rhythm

#### Spacing Scale
```dart
const double space4 = 4.0;    // Minimal (between related items)
const double space8 = 8.0;    // Small (within groups)
const double space12 = 12.0;  // Medium (between items)
const double space16 = 16.0;  // Standard (between elements)
const double space24 = 24.0;  // Large (between sections)
const double space32 = 32.0;  // XLarge (page margins)
```

#### Application
- **Internal padding**: 16px (cards, sections)
- **Item spacing**: 8-12px (within sections)
- **Section spacing**: 16-24px (between sections)
- **Page margins**: 16px (mobile), 32px (tablet), auto-centered (desktop)

### 3. Color and Contrast

#### Semantic Colors
```dart
// Primary actions
Theme.of(context).primaryColor

// Destructive actions
Theme.of(context).colorScheme.error

// Success states
Colors.green[600]

// Disabled states
Theme.of(context).disabledColor

// Backgrounds
Theme.of(context).cardColor
Theme.of(context).scaffoldBackgroundColor
```

#### Text Colors
```dart
// Primary text (high emphasis)
Theme.of(context).textTheme.bodyLarge?.color

// Secondary text (medium emphasis)
Colors.grey[600] // Light mode
Colors.grey[400] // Dark mode

// Disabled text (low emphasis)
Theme.of(context).disabledColor
```

### 4. Touch Targets

#### Minimum Sizes
- **Buttons**: 48px height minimum
- **List items**: 56px height minimum
- **Switches**: 48px x 48px tap target
- **Icons**: 24px with 48px tap target

#### Implementation
```dart
ListTile(
  contentPadding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,  // Ensures minimum height
  ),
  // ...
)
```

### 5. Loading States

#### Inline Loading
```dart
if (_isLoading)
  const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: CircularProgressIndicator(),
    ),
  )
else
  // Content
```

#### Button Loading
```dart
ElevatedButton(
  onPressed: _isSaving ? null : _save,
  child: _isSaving
    ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : const Text('Save'),
)
```

### 6. Error Handling

#### Form Validation
```dart
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  },
)
```

#### User Feedback
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(message),
    backgroundColor: isSuccess ? Colors.green : Colors.red,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
  ),
);
```

---

## Implementation Examples

### Example 1: Basic Settings Section

```dart
SettingsSection(
  title: 'Appearance',
  icon: Icons.palette,
  children: [
    BlocBuilder<AppConfigBloc, AppConfigState>(
      builder: (context, state) {
        return SwitchListTile(
          secondary: Icon(
            state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          ),
          title: const Text('Dark Mode'),
          subtitle: Text(
            state.isDarkMode ? 'Enabled' : 'Disabled',
          ),
          value: state.isDarkMode,
          onChanged: (value) {
            context.read<AppConfigBloc>().add(
              const ToggleThemeEvent(),
            );
          },
        );
      },
    ),
  ],
)
```

### Example 2: Collapsible Advanced Settings

```dart
SettingsSection(
  title: 'Advanced',
  icon: Icons.tune,
  subtitle: 'Advanced configuration options',
  isCollapsible: true,
  initiallyExpanded: false,
  children: [
    SettingsItem(
      icon: Icons.cache,
      title: 'Clear Cache',
      subtitle: 'Free up storage space',
      trailing: const Icon(Icons.chevron_right),
      onTap: _clearCache,
    ),
    SettingsItem(
      icon: Icons.restore,
      title: 'Reset to Defaults',
      subtitle: 'Restore all settings',
      trailing: const Icon(Icons.chevron_right),
      onTap: _resetSettings,
    ),
  ],
)
```

### Example 3: Responsive Form Layout

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isWideScreen = constraints.maxWidth >= 800;

    if (isWideScreen) {
      // Two-column layout
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Single-column layout
      return Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
        ],
      );
    }
  },
)
```

### Example 4: Complete Responsive Settings Page

```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Determine layout mode
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1200;
        final isDesktop = width >= 1200;

        // Build section list
        final sections = [
          _buildAppearanceSection(),
          _buildPrintSettingsSection(),
          _buildCompanyInfoSection(),
          _buildSyncSection(),
          _buildAboutSection(),
        ];

        // Apply responsive layout
        Widget content;

        if (isDesktop) {
          // Two-column grid
          content = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: SettingsGrid(
                spacing: 24,
                children: sections,
              ),
            ),
          );
        } else {
          // Single column
          content = Column(
            children: sections
                .map((section) => Padding(
                      padding: EdgeInsets.only(
                        bottom: isTablet ? 24 : 16,
                      ),
                      child: section,
                    ))
                .toList(),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: content,
        );
      },
    ),
  );
}
```

---

## Visual Design Specifications

### Card Styling

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  margin: EdgeInsets.zero,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: content,
  ),
)
```

### Section Header Styling

```dart
Row(
  children: [
    if (icon != null) ...[
      Icon(icon, size: 28, color: Theme.of(context).primaryColor),
      const SizedBox(width: 12),
    ],
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    ),
  ],
)
```

### Divider Styling

```dart
Divider(
  height: 24,
  thickness: 1,
  color: Theme.of(context).dividerColor,
)
```

### Button Styling

```dart
// Primary action button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: onPressed,
  child: Text(label),
)

// Secondary action button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: onPressed,
  child: Text(label),
)
```

### Input Field Styling

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  ),
)
```

---

## Accessibility Considerations

### 1. Screen Reader Support

```dart
// Semantic labels for icons
Semantics(
  label: 'Dark mode toggle',
  child: Icon(Icons.dark_mode),
)

// Exclude decorative elements
ExcludeSemantics(
  child: DecorativeIcon(),
)
```

### 2. Focus Management

```dart
// Focus order
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      Focus(
        child: firstField,
      ),
      Focus(
        child: secondField,
      ),
    ],
  ),
)
```

### 3. Color Contrast

- Ensure minimum 4.5:1 contrast ratio for normal text
- Ensure minimum 3:1 contrast ratio for large text
- Don't rely solely on color to convey information

### 4. Touch Targets

- Minimum 48x48 logical pixels for all interactive elements
- Adequate spacing between adjacent touch targets
- Visual feedback on interaction

### 5. Text Scaling

```dart
// Support dynamic text scaling
Text(
  content,
  style: Theme.of(context).textTheme.bodyMedium,
  // Text will scale with system settings
)
```

---

## Best Practices Checklist

### Layout
- [ ] Responsive breakpoints implemented
- [ ] No horizontal scrolling on any device
- [ ] Content reflows appropriately
- [ ] Maximum width constraints on desktop
- [ ] Consistent spacing throughout

### Interactions
- [ ] Touch targets ≥ 48px
- [ ] Visual feedback on all interactions
- [ ] Loading states for async operations
- [ ] Error messages are clear and actionable
- [ ] Confirmation for destructive actions

### Accessibility
- [ ] Semantic labels for icons
- [ ] Proper focus management
- [ ] Sufficient color contrast
- [ ] Support for text scaling
- [ ] Screen reader tested

### Performance
- [ ] Efficient rebuilds with BlocBuilder
- [ ] Lazy loading where appropriate
- [ ] Optimized image assets
- [ ] Smooth animations (60 FPS)
- [ ] Minimal memory footprint

### UX
- [ ] Clear visual hierarchy
- [ ] Consistent terminology
- [ ] Helpful placeholder text
- [ ] Immediate feedback
- [ ] Graceful degradation

---

## Conclusion

This guide provides a comprehensive framework for creating well-organized, responsive, and accessible settings pages in Flutter applications. By following these principles and using the provided reusable components, you can create settings interfaces that work seamlessly across all device sizes while maintaining consistency and usability.

### Key Takeaways

1. **Use reusable components** (SettingsSection, SettingsGrid, SettingsItem) for consistency
2. **Implement responsive breakpoints** (mobile < 600px, tablet 600-1200px, desktop > 1200px)
3. **Organize by priority** (most important settings first)
4. **Follow spacing guidelines** (4px, 8px, 16px, 24px, 32px)
5. **Ensure accessibility** (touch targets, contrast, semantic labels)
6. **Provide feedback** (loading states, validation, confirmations)
7. **Test across devices** (mobile, tablet, desktop, different orientations)

### Further Resources

- [Flutter Layout Documentation](https://docs.flutter.dev/development/ui/layout)
- [Material Design Guidelines](https://material.io/design)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Responsive Design in Flutter](https://docs.flutter.dev/development/ui/layout/responsive)
