import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/drift_database.dart';
import '../models/company_info.dart';
import '../services/sync_service.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_event.dart';
import '../blocs/app_config/app_config_state.dart';
import '../widgets/print_format_selector.dart';
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingCompanyInfo(e.toString()))),
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.companyInfoSavedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSaving(e.toString()))),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    final result = await _syncService.manualSync();

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      String message;

      switch (result.messageType) {
        case SyncMessageType.noInternet:
          message = l10n.noInternetConnection;
          break;
        case SyncMessageType.alreadySynced:
          message = l10n.allDataSynchronized;
          break;
        case SyncMessageType.success:
          message = l10n.successfullySynchronized(result.itemsSynced);
          break;
        case SyncMessageType.failed:
          message = l10n.syncFailed;
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }

    setState(() => _isSyncing = false);
  }

  List<Locale> _getSupportedLocales() {
    return const [
      Locale('en', 'US'),
      Locale('ar', 'SA'),
    ];
  }

  String _getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    BlocBuilder<AppConfigBloc, AppConfigState>(
                      builder: (context, configState) {
                        return ListTile(
                          leading: Icon(
                            configState.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          ),
                          title: Text(l10n.theme),
                          subtitle: Text(
                            configState.isDarkMode
                              ? l10n.darkMode
                              : l10n.lightMode,
                          ),
                          trailing: Switch(
                            value: configState.isDarkMode,
                            onChanged: (value) {
                              context.read<AppConfigBloc>().add(const ToggleThemeEvent());
                            },
                          ),
                        );
                      },
                    ),

                    const Divider(),

                    // Language Selection
                    BlocBuilder<AppConfigBloc, AppConfigState>(
                      builder: (context, configState) {
                        return ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(l10n.language),
                          subtitle: Text(_getLocaleName(configState.locale)),
                          trailing: DropdownButton<Locale>(
                            value: configState.locale,
                            underline: const SizedBox(),
                            items: _getSupportedLocales().map((locale) {
                              return DropdownMenuItem(
                                value: locale,
                                child: Text(_getLocaleName(locale)),
                              );
                            }).toList(),
                            onChanged: (Locale? newLocale) {
                              if (newLocale != null) {
                                if (newLocale.languageCode == 'en') {
                                  context.read<AppConfigBloc>().add(const SetEnglishEvent());
                                } else if (newLocale.languageCode == 'ar') {
                                  context.read<AppConfigBloc>().add(const SetArabicEvent());
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.changesAppliedImmediately,
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

            // Print Settings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.printSettings,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    const PrintFormatSelector(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // VAT Rate Configuration Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.vat} ${l10n.settings}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    BlocBuilder<AppConfigBloc, AppConfigState>(
                      builder: (context, configState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Default VAT Rate',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Set the default VAT rate to be applied automatically to all products',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth >= 600;
                                if (isWide) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          key: ValueKey(configState.vatRate),
                                          initialValue: configState.vatRate.toString(),
                                          decoration: InputDecoration(
                                            labelText: 'VAT Rate (%)',
                                            border: const OutlineInputBorder(),
                                            prefixIcon: const Icon(Icons.percent),
                                            hintText: '15.0',
                                          ),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (value) {
                                            final vatRate = double.tryParse(value);
                                            if (vatRate != null && vatRate >= 0 && vatRate <= 100) {
                                              context.read<AppConfigBloc>().add(UpdateVatRateEvent(vatRate));
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Current VAT Rate',
                                                style: Theme.of(context).textTheme.labelMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${configState.vatRate.toStringAsFixed(1)}%',
                                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      TextFormField(
                                        key: ValueKey(configState.vatRate),
                                        initialValue: configState.vatRate.toString(),
                                        decoration: InputDecoration(
                                          labelText: 'VAT Rate (%)',
                                          border: const OutlineInputBorder(),
                                          prefixIcon: const Icon(Icons.percent),
                                          hintText: '15.0',
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (value) {
                                          final vatRate = double.tryParse(value);
                                          if (vatRate != null && vatRate >= 0 && vatRate <= 100) {
                                            context.read<AppConfigBloc>().add(UpdateVatRateEvent(vatRate));
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Current VAT Rate',
                                              style: Theme.of(context).textTheme.labelMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${configState.vatRate.toStringAsFixed(1)}%',
                                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This VAT rate will be automatically applied to all new products. Changes apply immediately.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
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
                      l10n.companyInformation,
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
                                          decoration: InputDecoration(
                                            labelText: '${l10n.companyNameEnglish} *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? l10n.required : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _nameArabicController,
                                          decoration: InputDecoration(
                                            labelText: '${l10n.companyNameArabic} *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? l10n.required : null,
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
                                          decoration: InputDecoration(
                                            labelText: '${l10n.addressEnglish} *',
                                          ),
                                          maxLines: 2,
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? l10n.required : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _addressArabicController,
                                          decoration: InputDecoration(
                                            labelText: '${l10n.addressArabic} *',
                                          ),
                                          maxLines: 2,
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? l10n.required : null,
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
                                          decoration: InputDecoration(
                                            labelText: '${l10n.phone} *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? l10n.required : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                            labelText: l10n.email,
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
                                          decoration: InputDecoration(
                                            labelText: '${l10n.vatNumber} *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? l10n.required : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _crnNumberController,
                                          decoration: InputDecoration(
                                            labelText: '${l10n.crnNumber} *',
                                          ),
                                          validator: (v) =>
                                              v?.isEmpty ?? true ? l10n.required : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveCompanyInfo,
                                      child: Text(l10n.saveCompanyInformation),
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
                                    decoration: InputDecoration(
                                      labelText: '${l10n.companyNameEnglish} *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? l10n.required : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _nameArabicController,
                                    decoration: InputDecoration(
                                      labelText: '${l10n.companyNameArabic} *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? l10n.required : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _addressController,
                                    decoration: InputDecoration(
                                      labelText: '${l10n.addressEnglish} *',
                                    ),
                                    maxLines: 2,
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? l10n.required : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _addressArabicController,
                                    decoration: InputDecoration(
                                      labelText: '${l10n.addressArabic} *',
                                    ),
                                    maxLines: 2,
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? l10n.required : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText: '${l10n.phone} *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? l10n.required : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: l10n.email,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _vatNumberController,
                                    decoration: InputDecoration(
                                      labelText: '${l10n.vatNumber} *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? l10n.required : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _crnNumberController,
                                    decoration: InputDecoration(
                                      labelText: '${l10n.crnNumber} *',
                                    ),
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? l10n.required : null,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveCompanyInfo,
                                      child: Text(l10n.saveCompanyInformation),
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
                      l10n.dataSynchronization,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    Text(
                      l10n.syncDescription,
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
                        label: Text(_isSyncing ? l10n.syncing : l10n.syncNow),
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
                      l10n.about,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l10n.version),
                      subtitle: Text(l10n.appVersion),
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(l10n.appTitle),
                      subtitle: Text(l10n.posWithOfflineSupport),
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
