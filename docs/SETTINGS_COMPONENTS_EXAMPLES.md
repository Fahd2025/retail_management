# Settings Components - Quick Start Examples

## Overview

This guide provides quick, copy-paste examples for using the reusable settings components.

---

## SettingsSection Examples

### Basic Section

```dart
SettingsSection(
  title: 'General',
  children: [
    SwitchListTile(
      title: const Text('Enable notifications'),
      value: _notificationsEnabled,
      onChanged: (value) {
        setState(() => _notificationsEnabled = value);
      },
    ),
  ],
)
```

### Section with Icon

```dart
SettingsSection(
  title: 'Appearance',
  icon: Icons.palette,
  children: [
    // Your settings items
  ],
)
```

### Section with Icon and Subtitle

```dart
SettingsSection(
  title: 'Print Settings',
  icon: Icons.print,
  subtitle: 'Configure how invoices are printed',
  children: [
    // Your settings items
  ],
)
```

### Collapsible Section (Advanced Settings)

```dart
SettingsSection(
  title: 'Advanced',
  icon: Icons.tune,
  subtitle: 'Expert configuration options',
  isCollapsible: true,
  initiallyExpanded: false,
  children: [
    SettingsItem(
      icon: Icons.developer_mode,
      title: 'Developer Mode',
      subtitle: 'Enable debug features',
      trailing: Switch(
        value: _devMode,
        onChanged: (value) => setState(() => _devMode = value),
      ),
    ),
  ],
)
```

### Section with Custom Padding

```dart
SettingsSection(
  title: 'Custom Spacing',
  icon: Icons.space_bar,
  padding: const EdgeInsets.all(24),
  children: [
    // Your content with custom padding
  ],
)
```

---

## SettingsGrid Examples

### Basic Two-Column Grid (Desktop)

```dart
SettingsGrid(
  children: [
    _buildAppearanceSection(),
    _buildPrintSection(),
    _buildCompanySection(),
    _buildSyncSection(),
  ],
)
```

### Grid with Custom Spacing

```dart
SettingsGrid(
  spacing: 32,  // Larger spacing between sections
  children: [
    section1,
    section2,
    section3,
  ],
)
```

### Responsive Page Layout

```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;

        final sections = [
          _buildSection1(),
          _buildSection2(),
          _buildSection3(),
        ];

        Widget content;
        if (isDesktop) {
          // Desktop: Two-column grid
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
          // Mobile/Tablet: Single column
          content = Column(
            children: sections
                .map((section) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: section,
                    ))
                .toList(),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16 : 32),
          child: content,
        );
      },
    ),
  );
}
```

---

## SettingsItem Examples

### Basic Item

```dart
SettingsItem(
  icon: Icons.info,
  title: 'Version',
  subtitle: '1.0.0',
)
```

### Item with Trailing Widget

```dart
SettingsItem(
  icon: Icons.language,
  title: 'Language',
  subtitle: 'English',
  trailing: const Icon(Icons.chevron_right),
)
```

### Tappable Item

```dart
SettingsItem(
  icon: Icons.color_lens,
  title: 'Theme',
  subtitle: 'Choose your theme',
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    // Navigate to theme selection
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ThemeSettingsScreen()),
    );
  },
)
```

### Item with Switch

```dart
SettingsItem(
  icon: Icons.notifications,
  title: 'Notifications',
  subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
  trailing: Switch(
    value: _notificationsEnabled,
    onChanged: (value) {
      setState(() => _notificationsEnabled = value);
    },
  ),
)
```

### Item with Dropdown

```dart
SettingsItem(
  icon: Icons.print,
  title: 'Print Format',
  subtitle: _selectedFormat,
  trailing: DropdownButton<String>(
    value: _selectedFormat,
    underline: const SizedBox(),
    items: ['A4', '80mm', '58mm'].map((format) {
      return DropdownMenuItem(
        value: format,
        child: Text(format),
      );
    }).toList(),
    onChanged: (value) {
      setState(() => _selectedFormat = value!);
    },
  ),
)
```

---

## Complete Example: Custom Settings Page

```dart
import 'package:flutter/material.dart';
import '../widgets/settings_section.dart';

class MySettingsScreen extends StatefulWidget {
  const MySettingsScreen({super.key});

  @override
  State<MySettingsScreen> createState() => _MySettingsScreenState();
}

class _MySettingsScreenState extends State<MySettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1200;

          final sections = [
            _buildGeneralSection(),
            _buildNotificationsSection(),
            _buildAboutSection(),
          ];

          Widget content;
          if (isDesktop) {
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
            content = Column(
              children: sections
                  .map((section) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: section,
                      ))
                  .toList(),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16 : 32),
            child: content,
          );
        },
      ),
    );
  }

  Widget _buildGeneralSection() {
    return SettingsSection(
      title: 'General',
      icon: Icons.settings,
      subtitle: 'Basic application settings',
      children: [
        SwitchListTile(
          secondary: Icon(_darkMode ? Icons.dark_mode : Icons.light_mode),
          title: const Text('Dark Mode'),
          subtitle: Text(_darkMode ? 'Enabled' : 'Disabled'),
          value: _darkMode,
          onChanged: (value) {
            setState(() => _darkMode = value);
          },
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        SettingsItem(
          icon: Icons.language,
          title: 'Language',
          subtitle: _language,
          trailing: DropdownButton<String>(
            value: _language,
            underline: const SizedBox(),
            items: ['English', 'العربية'].map((lang) {
              return DropdownMenuItem(
                value: lang,
                child: Text(lang),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _language = value!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return SettingsSection(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active),
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive alerts and updates'),
          value: _notifications,
          onChanged: (value) {
            setState(() => _notifications = value);
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return SettingsSection(
      title: 'About',
      icon: Icons.info_outline,
      children: [
        SettingsItem(
          icon: Icons.info,
          title: 'Version',
          subtitle: '1.0.0',
        ),
        const SizedBox(height: 8),
        SettingsItem(
          icon: Icons.article,
          title: 'Terms of Service',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to terms
          },
        ),
      ],
    );
  }
}
```

---

## Pattern: BLoC Integration

```dart
Widget _buildAppearanceSection() {
  return SettingsSection(
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
            contentPadding: EdgeInsets.zero,
          );
        },
      ),
    ],
  );
}
```

---

## Pattern: Form Section

```dart
Widget _buildProfileSection() {
  return SettingsSection(
    title: 'Profile',
    icon: Icons.person,
    subtitle: 'Update your personal information',
    children: [
      Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
```

---

## Pattern: Loading State

```dart
Widget _buildDataSection() {
  return SettingsSection(
    title: 'Data',
    icon: Icons.storage,
    children: [
      if (_isLoading)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      else ...[
        SettingsItem(
          icon: Icons.cloud_upload,
          title: 'Backup',
          subtitle: _lastBackup ?? 'Never',
          trailing: const Icon(Icons.chevron_right),
          onTap: _performBackup,
        ),
        const SizedBox(height: 8),
        SettingsItem(
          icon: Icons.delete_forever,
          title: 'Clear Cache',
          subtitle: '${_cacheSize} MB',
          trailing: const Icon(Icons.chevron_right),
          onTap: _clearCache,
        ),
      ],
    ],
  );
}
```

---

## Pattern: Action Button

```dart
Widget _buildSyncSection() {
  return SettingsSection(
    title: 'Synchronization',
    icon: Icons.sync,
    subtitle: 'Keep your data up to date',
    children: [
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isSyncing ? null : _performSync,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: _isSyncing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.sync),
          label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
        ),
      ),
    ],
  );
}
```

---

## Quick Tips

### 1. Consistent Spacing
Always use the standard spacing scale:
```dart
const SizedBox(height: 8)   // Between related items
const SizedBox(height: 16)  // Between sections
const SizedBox(height: 24)  // Before major actions
```

### 2. Zero Padding for List Tiles
When using ListTile inside SettingsSection, set `contentPadding: EdgeInsets.zero`:
```dart
SwitchListTile(
  contentPadding: EdgeInsets.zero,  // Important!
  // ...
)
```

### 3. Full-Width Buttons
For action buttons, always use full width:
```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton(/* ... */),
)
```

### 4. Icons Size
For section icons, use default size (28px). For list item icons, use default (24px):
```dart
SettingsSection(
  icon: Icons.settings,  // 28px by default
  // ...
)

SettingsItem(
  icon: Icons.info,  // 24px by default
  // ...
)
```

### 5. Responsive Breakpoints
Use consistent breakpoints:
```dart
final isMobile = width < 600;
final isTablet = width >= 600 && width < 1200;
final isDesktop = width >= 1200;
```

---

## Common Patterns Summary

| Pattern | Use SettingsSection | Use SettingsItem | Use SettingsGrid |
|---------|---------------------|------------------|------------------|
| Group related settings | ✅ | ❌ | ❌ |
| Single setting item | ❌ | ✅ | ❌ |
| Responsive layout | ❌ | ❌ | ✅ |
| Form container | ✅ | ❌ | ❌ |
| Navigation item | ❌ | ✅ | ❌ |
| Action button container | ✅ | ❌ | ❌ |
| Read-only info | ❌ | ✅ | ❌ |

---

## Next Steps

1. **Copy examples** that match your use case
2. **Customize** titles, icons, and content
3. **Test** on different screen sizes
4. **Adjust** spacing and styling as needed
5. **Refer** to SETTINGS_UI_GUIDE.md for detailed guidelines

Happy coding! 🚀
