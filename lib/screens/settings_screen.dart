import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/drift_database.dart';
import '../models/company_info.dart';
import '../services/sync_service.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _syncService = SyncService();
  bool _isLoading = false;
  bool _isSyncing = false;

  late TextEditingController _nameController;
  late TextEditingController _nameArabicController;
  late TextEditingController _addressController;
  late TextEditingController _addressArabicController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _vatNumberController;
  late TextEditingController _crnNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameArabicController = TextEditingController();
    _addressController = TextEditingController();
    _addressArabicController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _vatNumberController = TextEditingController();
    _crnNumberController = TextEditingController();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    setState(() => _isLoading = true);

    try {
      final db = AppDatabase();
      final info = await db.getCompanyInfo();

      if (info != null) {
        _nameController.text = info.name;
        _nameArabicController.text = info.nameArabic;
        _addressController.text = info.address;
        _addressArabicController.text = info.addressArabic;
        _phoneController.text = info.phone;
        _emailController.text = info.email ?? '';
        _vatNumberController.text = info.vatNumber;
        _crnNumberController.text = info.crnNumber;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading company info: $e')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveCompanyInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = AppDatabase();
      const uuid = Uuid();

      final companyInfo = CompanyInfo(
        id: uuid.v4(),
        name: _nameController.text,
        nameArabic: _nameArabicController.text,
        address: _addressController.text,
        addressArabic: _addressArabicController.text,
        phone: _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        vatNumber: _vatNumberController.text,
        crnNumber: _crnNumberController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.createOrUpdateCompanyInfo(companyInfo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company info saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    final result = await _syncService.manualSync();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }

    setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance & Language Preferences Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appearance,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),

                    // Theme Selection
                    ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      ),
                      title: Text(l10n.theme),
                      subtitle: Text(
                        themeProvider.isDarkMode
                          ? l10n.darkMode
                          : l10n.lightMode,
                      ),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) async {
                          await themeProvider.toggleTheme();
                        },
                      ),
                    ),

                    const Divider(),

                    // Language Selection
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(l10n.language),
                      subtitle: Text(localeProvider.currentLocaleName),
                      trailing: DropdownButton<Locale>(
                        value: localeProvider.locale,
                        underline: const SizedBox(),
                        items: LocaleProvider.supportedLocales.map((locale) {
                          return DropdownMenuItem(
                            value: locale,
                            child: Text(localeProvider.getLocaleName(locale)),
                          );
                        }).toList(),
                        onChanged: (Locale? newLocale) async {
                          if (newLocale != null) {
                            await localeProvider.setLocale(newLocale);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        localeProvider.isArabic
                          ? 'سيتم تطبيق التغييرات على الفور'
                          : 'Changes will be applied immediately',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Company Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Form(
                        key: _formKey,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWideScreen = constraints.maxWidth >= 800;

                            if (isWideScreen) {
                              // Desktop: Two-column layout
                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _nameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Company Name (English) *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? 'Required' : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _nameArabicController,
                                          decoration: const InputDecoration(
                                            labelText: 'Company Name (Arabic) *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? 'Required' : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _addressController,
                                          decoration: const InputDecoration(
                                            labelText: 'Address (English) *',
                                          ),
                                          maxLines: 2,
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? 'Required' : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _addressArabicController,
                                          decoration: const InputDecoration(
                                            labelText: 'Address (Arabic) *',
                                          ),
                                          maxLines: 2,
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? 'Required' : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _phoneController,
                                          decoration: const InputDecoration(
                                            labelText: 'Phone *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? 'Required' : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _emailController,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                          ),
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _vatNumberController,
                                          decoration: const InputDecoration(
                                            labelText: 'VAT Number *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? 'Required' : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _crnNumberController,
                                          decoration: const InputDecoration(
                                            labelText: 'CRN Number *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? 'Required' : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveCompanyInfo,
                                      child: const Text('Save Company Information'),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              // Mobile: Single column layout
                              return Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Company Name (English) *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _nameArabicController,
                                    decoration: const InputDecoration(
                                      labelText: 'Company Name (Arabic) *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _addressController,
                                    decoration: const InputDecoration(
                                      labelText: 'Address (English) *',
                                    ),
                                    maxLines: 2,
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _addressArabicController,
                                    decoration: const InputDecoration(
                                      labelText: 'Address (Arabic) *',
                                    ),
                                    maxLines: 2,
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _vatNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'VAT Number *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _crnNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'CRN Number *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveCompanyInfo,
                                      child: const Text('Save Company Information'),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sync Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Synchronization',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    const Text(
                      'Sync your local data with the cloud when internet connection is available.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSyncing ? null : _syncData,
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
                ),
              ),
            ),
            const SizedBox(height: 16),

            // About Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Version'),
                      subtitle: Text('1.0.0'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.business),
                      title: Text('Retail Management System'),
                      subtitle: Text('Point of Sale with Offline Support'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArabicController.dispose();
    _addressController.dispose();
    _addressArabicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vatNumberController.dispose();
    _crnNumberController.dispose();
    super.dispose();
  }
}
