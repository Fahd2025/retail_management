import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../database/drift_database.dart';
import '../models/company_info.dart';
import '../services/sync_service.dart';
import '../services/image_service.dart';
import '../services/data_import_export_service.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_event.dart';
import '../blocs/app_config/app_config_state.dart';
import '../blocs/data_import_export/data_import_export_bloc.dart';
import '../blocs/data_import_export/data_import_export_event.dart';
import '../blocs/data_import_export/data_import_export_state.dart';
import '../widgets/print_format_selector.dart';
import '../widgets/settings_section.dart';
import '../widgets/company_logo_picker.dart';
import '../widgets/theme_color_selector.dart';
import '../widgets/data_type_selector_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../utils/currency_helper.dart';

/// Improved Settings Screen with responsive design and reusable components
///
/// Features:
/// - Responsive layout adapting to screen size (mobile, tablet, desktop)
/// - Reusable SettingsSection, SettingsGrid, and SettingsItem components
/// - Priority-based section organization
/// - Consistent spacing and visual hierarchy
/// - Accessibility considerations
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

  // Company logo path
  String? _logoPath;
  String? _oldLogoPath;

  // Currency selection
  String _selectedCurrency = 'SAR';

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
        _logoPath = info.logoPath;
        _oldLogoPath = info.logoPath;
        _selectedCurrency = info.currency;
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.errorLoadingCompanyInfo(e.toString()));
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
        logoPath: _logoPath,
        currency: _selectedCurrency,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.createOrUpdateCompanyInfo(companyInfo);

      // Refresh currency helper cache with updated company info
      await CurrencyHelper.refreshCache();

      // Clean up old logo if it was changed
      if (_oldLogoPath != null && _oldLogoPath != _logoPath) {
        await ImageService.cleanupOldLogo(_oldLogoPath);
      }

      // Update old logo path reference
      _oldLogoPath = _logoPath;

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showSuccessSnackBar(l10n.companyInfoSavedSuccess);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.errorSaving(e.toString()));
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

      if (result.success) {
        _showSuccessSnackBar(message);
      } else {
        _showErrorSnackBar(message);
      }
    }

    setState(() => _isSyncing = false);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show export success dialog with options to share or open file
  void _showExportSuccessDialog(BuildContext context, String filePath) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Check if this is a web download (filePath starts with "Downloaded: ")
    final isWebDownload = filePath.startsWith('Downloaded: ');
    final isDirectory = !isWebDownload && !kIsWeb && FileSystemEntity.isDirectorySync(filePath);

    // Extract filename for web downloads
    String displayMessage;
    if (isWebDownload) {
      final filename = filePath.replaceFirst('Downloaded: ', '');
      displayMessage = 'File downloaded: $filename';
    } else {
      displayMessage = l10n.exportSuccessMessage(filePath);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.exportSuccess,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayMessage,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isWebDownload
                          ? 'Check your browser\'s downloads folder'
                          : isDirectory
                              ? 'Multiple files exported to folder'
                              : 'File saved successfully',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Open File button (only for non-web platforms)
          if (!isWebDownload && !kIsWeb)
            TextButton.icon(
              onPressed: () async {
                try {
                  if (isDirectory) {
                    // For directories, try to open the first file or the directory itself
                    final dir = Directory(filePath);
                    final files = await dir.list().toList();
                    if (files.isNotEmpty && files.first is File) {
                      await OpenFile.open(files.first.path);
                    } else {
                      // Try to open the directory
                      await OpenFile.open(filePath);
                    }
                  } else {
                    await OpenFile.open(filePath);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showErrorSnackBar('Could not open file: $e');
                  }
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.openFile ?? 'Open File'),
            ),

          // Share button (only for non-web single files)
          if (!isWebDownload && !kIsWeb && !isDirectory)
            TextButton.icon(
              onPressed: () async {
                try {
                  final file = XFile(filePath);
                  await Share.shareXFiles(
                    [file],
                    subject: 'Data Export - ${DateTime.now().toString()}',
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showErrorSnackBar('Could not share file: $e');
                  }
                }
              },
              icon: const Icon(Icons.share),
              label: Text(l10n.share ?? 'Share'),
            ),

          // Close button
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  List<Locale> _getSupportedLocales() {
    return const [
      Locale('en', 'US'),
      Locale('ar', 'SA'),
    ];
  }

  String _getLocaleName(Locale locale) {
    final l10n = AppLocalizations.of(context)!;
    switch (locale.languageCode) {
      case 'en':
        return l10n.english;
      case 'ar':
        return l10n.arabic;
      default:
        return l10n.english;
    }
  }

  Map<String, String> _getCurrencyOptions() {
    final l10n = AppLocalizations.of(context)!;
    return {
      'SAR': l10n.currencySAR,
      'USD': l10n.currencyUSD,
      'EUR': l10n.currencyEUR,
      'GBP': l10n.currencyGBP,
      'AED': l10n.currencyAED,
      'KWD': l10n.currencyKWD,
      'BHD': l10n.currencyBHD,
      'QAR': l10n.currencyQAR,
      'OMR': l10n.currencyOMR,
      'JOD': l10n.currencyJOD,
      'EGP': l10n.currencyEGP,
    };
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'SAR':
        return 'ر.س';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'AED':
        return 'د.إ';
      case 'KWD':
        return 'د.ك';
      case 'BHD':
        return 'د.ب';
      case 'QAR':
        return 'ر.ق';
      case 'OMR':
        return 'ر.ع';
      case 'JOD':
        return 'د.أ';
      case 'EGP':
        return 'ج.م';
      default:
        return currencyCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isMobile = width < 600;
          final isTablet = width >= 600 && width < 1200;
          final isDesktop = width >= 1200;

          // Build all sections
          final sections = [
            _buildAppearanceSection(),
            _buildPrintSettingsSection(),
            _buildCompanyInfoSection(),
            _builVATSection(),
            _buildDataImportExportSection(),
            _buildSyncSection(),
            _buildAboutSection(),
          ];

          // Apply responsive layout
          Widget content;

          if (isDesktop) {
            // Desktop: Two-column grid with max width
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

  /// Build Appearance & Language Section (High Priority)
  Widget _buildAppearanceSection() {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSection(
      title: l10n.appearance,
      icon: Icons.palette,
      subtitle: l10n.changesAppliedImmediately,
      children: [
        // Theme Selection
        BlocBuilder<AppConfigBloc, AppConfigState>(
          builder: (context, configState) {
            return SwitchListTile(
              secondary: Icon(
                configState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: Text(l10n.theme),
              subtitle: Text(
                configState.isDarkMode ? l10n.darkMode : l10n.lightMode,
              ),
              value: configState.isDarkMode,
              onChanged: (value) {
                context.read<AppConfigBloc>().add(const ToggleThemeEvent());
              },
              contentPadding: EdgeInsets.zero,
            );
          },
        ),

        const SizedBox(height: 8),

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
                      context
                          .read<AppConfigBloc>()
                          .add(const SetEnglishEvent());
                    } else if (newLocale.languageCode == 'ar') {
                      context.read<AppConfigBloc>().add(const SetArabicEvent());
                    }
                  }
                },
              ),
              contentPadding: EdgeInsets.zero,
            );
          },
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Theme Color Selection
        const ThemeColorSelector(),
      ],
    );
  }

  /// Build Print Settings Section (High Priority)
  Widget _buildPrintSettingsSection() {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSection(
      title: l10n.printSettings,
      icon: Icons.print,
      subtitle: l10n.configureInvoicePrintingOptions,
      children: const [
        PrintFormatSelector(),
      ],
    );
  }

  /// Build Company Information Section (Medium Priority)
  Widget _buildCompanyInfoSection() {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSection(
      title: l10n.companyNameEnglish,
      icon: Icons.business,
      subtitle: l10n.businessDetailsAndContactInformation,
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Form(
            key: _formKey,
            child: _buildCompanyInfoForm(),
          ),
      ],
    );
  }

  /// Build Company Information Form with Responsive Layout
  Widget _buildCompanyInfoForm() {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 800;

        if (isWideScreen) {
          // Desktop: Two-column layout
          return Column(
            children: [
              // Company Logo
              Center(
                child: CompanyLogoPicker(
                  currentLogoPath: _logoPath,
                  onLogoSelected: (logoPath) {
                    setState(() {
                      _logoPath = logoPath;
                    });
                  },
                  onLogoRemoved: () {
                    setState(() {
                      _logoPath = null;
                    });
                  },
                  size: 150,
                ),
              ),
              const SizedBox(height: 24),
              _buildFormRow([
                _buildTextField(
                  controller: _nameController,
                  label: '${l10n.companyNameEnglish} *',
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                _buildTextField(
                  controller: _nameArabicController,
                  label: '${l10n.companyNameArabic} *',
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
              ]),
              const SizedBox(height: 16),
              _buildFormRow([
                _buildTextField(
                  controller: _addressController,
                  label: '${l10n.addressEnglish} *',
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                _buildTextField(
                  controller: _addressArabicController,
                  label: '${l10n.addressArabic} *',
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
              ]),
              const SizedBox(height: 16),
              _buildFormRow([
                _buildTextField(
                  controller: _phoneController,
                  label: '${l10n.phone} *',
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                _buildTextField(
                  controller: _emailController,
                  label: l10n.email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ]),
              const SizedBox(height: 16),
              _buildFormRow([
                _buildTextField(
                  controller: _vatNumberController,
                  label: '${l10n.vatNumber} *',
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                _buildTextField(
                  controller: _crnNumberController,
                  label: '${l10n.crnNumber} *',
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
              ]),
              const SizedBox(height: 16),
              _buildFormRow([
                _buildCurrencyDropdown(),
                const SizedBox(), // Empty space for alignment
              ]),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          );
        } else {
          // Mobile: Single column layout
          return Column(
            children: [
              // Company Logo
              Center(
                child: CompanyLogoPicker(
                  currentLogoPath: _logoPath,
                  onLogoSelected: (logoPath) {
                    setState(() {
                      _logoPath = logoPath;
                    });
                  },
                  onLogoRemoved: () {
                    setState(() {
                      _logoPath = null;
                    });
                  },
                  size: 150,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: '${l10n.companyNameEnglish} *',
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameArabicController,
                label: '${l10n.companyNameArabic} *',
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: '${l10n.addressEnglish} *',
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressArabicController,
                label: '${l10n.addressArabic} *',
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: '${l10n.phone} *',
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: l10n.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _vatNumberController,
                label: '${l10n.vatNumber} *',
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _crnNumberController,
                label: '${l10n.crnNumber} *',
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              _buildCurrencyDropdown(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          );
        }
      },
    );
  }

  /// Build a row of form fields for two-column layout
  Widget _buildFormRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .expand((child) => [
                Expanded(child: child),
                if (child != children.last) const SizedBox(width: 16),
              ])
          .toList(),
    );
  }

  /// Build a text form field with consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  /// Build save button with loading state
  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveCompanyInfo,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(l10n.saveCompanyInformation),
      ),
    );
  }

  /// Build currency dropdown selector
  Widget _buildCurrencyDropdown() {
    final l10n = AppLocalizations.of(context)!;
    final currencyOptions = _getCurrencyOptions();

    return DropdownButtonFormField<String>(
      initialValue: _selectedCurrency,
      decoration: InputDecoration(
        labelText: '${l10n.currency} *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIcon: const Icon(Icons.attach_money),
      ),
      items: currencyOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCurrency = newValue;
          });
        }
      },
      validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
    );
  }

  /// Build VAT Rate Configuration Section (Low Priority)
  Widget _builVATSection() {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSection(
      title: l10n.defaultVatRate,
      icon: Icons.sync,
      subtitle: l10n.setDefaultVatRateDescription,
      children: [
        const Divider(),
        BlocBuilder<AppConfigBloc, AppConfigState>(
          builder: (context, configState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // VAT Enable/Disable Toggle
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: configState.vatEnabled
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: configState.vatEnabled
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      configState.vatEnabled
                          ? l10n.vatEnabled
                          : l10n.vatDisabled,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      configState.vatEnabled
                          ? l10n.vatEnabledDescription
                          : l10n.vatDisabledDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: configState.vatEnabled,
                    onChanged: (value) {
                      context
                          .read<AppConfigBloc>()
                          .add(UpdateVatEnabledEvent(value));
                    },
                    activeThumbColor: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 24),

                // Show VAT Rate and Inclusion settings only if VAT is enabled
                if (configState.vatEnabled) ...[
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (value) {
                                  final vatRate = double.tryParse(value);
                                  if (vatRate != null &&
                                      vatRate >= 0 &&
                                      vatRate <= 100) {
                                    context
                                        .read<AppConfigBloc>()
                                        .add(UpdateVatRateEvent(vatRate));
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
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.currentVatRate,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${configState.vatRate.toStringAsFixed(1)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
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
                                labelText: l10n.vatRateLabel,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.percent),
                                hintText: l10n.vatRateHint,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (value) {
                                final vatRate = double.tryParse(value);
                                if (vatRate != null &&
                                    vatRate >= 0 &&
                                    vatRate <= 100) {
                                  context
                                      .read<AppConfigBloc>()
                                      .add(UpdateVatRateEvent(vatRate));
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
                                    l10n.currentVatRate,
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${configState.vatRate.toStringAsFixed(1)}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
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
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    l10n.vatCalculationMethod,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.chooseVatCalculationMethod,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: configState.vatIncludedInPrice
                        ? Colors.green.shade50
                        : Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: configState.vatIncludedInPrice
                            ? Colors.green.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        configState.vatIncludedInPrice
                            ? l10n.vatIncludedInPrice
                            : l10n.vatExcludedFromPrice,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      subtitle: Text(
                        configState.vatIncludedInPrice
                            ? l10n.vatIncludedInPriceDescription
                            : l10n.vatExcludedFromPriceDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      value: configState.vatIncludedInPrice,
                      onChanged: (value) {
                        context
                            .read<AppConfigBloc>()
                            .add(UpdateVatInclusionEvent(value));
                      },
                      activeThumbColor: Colors.green.shade700,
                    ),
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
                        Icon(Icons.info_outline,
                            color: Colors.amber.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.vatRateAppliedToNewProducts,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.amber.shade900,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ], // End of if (configState.vatEnabled)
              ],
            );
          },
        ),
      ],
    );
  }

  /// Build Data Import/Export Section
  Widget _buildDataImportExportSection() {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => DataImportExportBloc(
        service: DataImportExportService(database: AppDatabase()),
      ),
      child: BlocConsumer<DataImportExportBloc, DataImportExportState>(
        listener: (context, state) {
          if (state is DataExported) {
            _showExportSuccessDialog(context, state.filePath);
          } else if (state is DataImported) {
            _showSuccessSnackBar(
                l10n.importSuccessMessage(state.itemsImported));
          } else if (state is DataImportExportError) {
            _showErrorSnackBar('${state.message}\n${state.errorDetails ?? ''}');
          }
        },
        builder: (context, state) {
          final isLoading =
              state is DataExporting || state is DataImporting;

          return SettingsSection(
            title: l10n.dataImportExport,
            icon: Icons.import_export,
            subtitle: l10n.dataImportExportDescription,
            children: [
              // Warning card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.importWarning,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Progress indicator if loading
              if (isLoading)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: state is DataExporting
                          ? state.progress
                          : state is DataImporting
                              ? state.progress
                              : 0.0,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state is DataExporting
                          ? l10n.exportInProgress
                          : l10n.importInProgress,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Export button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _handleExport(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.upload),
                  label: Text(l10n.exportData),
                ),
              ),

              const SizedBox(height: 12),

              // Import button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _handleImport(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.download),
                  label: Text(l10n.importData),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Handle export data
  void _handleExport(BuildContext context) {
    showDataTypeSelectorBottomSheet(
      context: context,
      isExport: true,
      onConfirm: (dataTypes, format) {
        context.read<DataImportExportBloc>().add(
              ExportDataRequested(
                dataTypes: dataTypes,
                format: format ?? ExportFormat.json,
              ),
            );
      },
    );
  }

  /// Handle import data
  Future<void> _handleImport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // First, pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
    );

    if (result != null) {
      final file = result.files.single;

      // On web, use bytes; on mobile, use path
      if (kIsWeb) {
        // Web platform - use bytes
        if (file.bytes != null && file.name.isNotEmpty) {
          final fileContent = utf8.decode(file.bytes!);
          final fileName = file.name;

          // Show data type selector
          if (context.mounted) {
            showDataTypeSelectorBottomSheet(
              context: context,
              isExport: false,
              onConfirm: (dataTypes, _) {
                context.read<DataImportExportBloc>().add(
                      ImportDataRequested(
                        fileContent: fileContent,
                        fileName: fileName,
                        dataTypes: dataTypes,
                      ),
                    );
              },
            );
          }
        } else {
          // No bytes available
          if (context.mounted) {
            _showErrorSnackBar(l10n.selectFileToImport);
          }
        }
      } else {
        // Mobile platform - use path
        if (file.path != null) {
          final filePath = file.path!;

          // Show data type selector
          if (context.mounted) {
            showDataTypeSelectorBottomSheet(
              context: context,
              isExport: false,
              onConfirm: (dataTypes, _) {
                context.read<DataImportExportBloc>().add(
                      ImportDataRequested(
                        filePath: filePath,
                        dataTypes: dataTypes,
                      ),
                    );
              },
            );
          }
        } else {
          // No path available
          if (context.mounted) {
            _showErrorSnackBar(l10n.selectFileToImport);
          }
        }
      }
    } else {
      // User canceled the picker
      if (context.mounted) {
        _showErrorSnackBar(l10n.selectFileToImport);
      }
    }
  }

  /// Build Data Synchronization Section (Low Priority)
  Widget _buildSyncSection() {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSection(
      title: l10n.dataSynchronization,
      icon: Icons.sync,
      subtitle: l10n.syncDescription,
      children: [
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSyncing ? null : _syncData,
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
            label: Text(_isSyncing ? l10n.syncing : l10n.syncNow),
          ),
        ),
      ],
    );
  }

  /// Build About Section (Low Priority)
  Widget _buildAboutSection() {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSection(
      title: l10n.about,
      icon: Icons.info_outline,
      children: [
        SettingsItem(
          icon: Icons.info_outline,
          title: l10n.version,
          subtitle: l10n.appVersion,
        ),
        const SizedBox(height: 8),
        SettingsItem(
          icon: Icons.business,
          title: l10n.appTitle,
          subtitle: l10n.posWithOfflineSupport,
        ),
      ],
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
