import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui_design.dart';
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
import '../widgets/company_logo_picker.dart';
import '../widgets/theme_color_selector.dart';
import '../widgets/data_type_selector_bottom_sheet.dart';
import '../widgets/data_type_detection_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../utils/currency_helper.dart';

/// Settings Screen with Liquid Glass UI Design
///
/// Features:
/// - Beautiful glass morphism design
/// - Responsive layout adapting to screen size (mobile, tablet, desktop)
/// - Smooth animations and transitions
/// - Priority-based section organization
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
        _showErrorNotification(l10n.errorLoadingCompanyInfo(e.toString()));
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
        _showSuccessNotification(l10n.companyInfoSavedSuccess);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorNotification(l10n.errorSaving(e.toString()));
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
        _showSuccessNotification(message);
      } else {
        _showErrorNotification(message);
      }
    }

    setState(() => _isSyncing = false);
  }

  void _showSuccessNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorNotification(String message) {
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LiquidCard(
          elevation: 8,
          blur: 25,
          opacity: 0.18,
          borderRadius: 24,
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              LiquidContainer(
                width: 80,
                height: 80,
                borderRadius: 40,
                blur: 15,
                opacity: 0.2,
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                l10n.exportSuccess,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                displayMessage,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Info banner
              LiquidBanner(
                type: LiquidBannerType.info,
                icon: Icons.info_outline,
                child: Text(
                  isWebDownload
                      ? 'Check your browser\'s downloads folder'
                      : isDirectory
                          ? 'Multiple files exported to folder'
                          : 'File saved successfully',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Open File button (only for non-web platforms)
                  if (!isWebDownload && !kIsWeb) ...[
                    LiquidButton(
                      onPressed: () async {
                        try {
                          if (isDirectory) {
                            final dir = Directory(filePath);
                            final files = await dir.list().toList();
                            if (files.isNotEmpty && files.first is File) {
                              await OpenFile.open(files.first.path);
                            } else {
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
                            _showErrorNotification('Could not open file: $e');
                          }
                        }
                      },
                      type: LiquidButtonType.outlined,
                      size: LiquidButtonSize.medium,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_new, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.openFile ?? 'Open File'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Share button (only for non-web single files)
                  if (!isWebDownload && !kIsWeb && !isDirectory) ...[
                    LiquidButton(
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
                            _showErrorNotification('Could not share file: $e');
                          }
                        }
                      },
                      type: LiquidButtonType.outlined,
                      size: LiquidButtonSize.medium,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.share, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.share ?? 'Share'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Close button
                  LiquidButton(
                    onPressed: () => Navigator.pop(context),
                    type: LiquidButtonType.filled,
                    size: LiquidButtonSize.medium,
                    child: Text(l10n.close),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

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
            _buildVATSection(),
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
                child: _buildSettingsGrid(
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

  /// Build responsive settings grid for desktop layout
  Widget _buildSettingsGrid({
    required double spacing,
    required List<Widget> children,
  }) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: children.map((child) {
        return SizedBox(
          width: (1400 - spacing) / 2,
          child: child,
        );
      }).toList(),
    );
  }

  /// Build Appearance & Language Section (High Priority)
  Widget _buildAppearanceSection() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    return _buildLiquidSection(
      title: l10n.appearance,
      icon: Icons.palette,
      subtitle: l10n.changesAppliedImmediately,
      child: Column(
        children: [
          // Theme Selection
          BlocBuilder<AppConfigBloc, AppConfigState>(
            builder: (context, configState) {
              return _buildGlassTile(
                leading: Icon(
                  configState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: liquidTheme.textColor,
                ),
                title: l10n.theme,
                subtitle: configState.isDarkMode ? l10n.darkMode : l10n.lightMode,
                trailing: _buildGlassSwitch(
                  value: configState.isDarkMode,
                  onChanged: (value) {
                    context.read<AppConfigBloc>().add(const ToggleThemeEvent());
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Language Selection
          BlocBuilder<AppConfigBloc, AppConfigState>(
            builder: (context, configState) {
              return _buildGlassTile(
                leading: Icon(
                  Icons.language,
                  color: liquidTheme.textColor,
                ),
                title: l10n.language,
                subtitle: _getLocaleName(configState.locale),
                trailing: LiquidPopupMenu<Locale>(
                  icon: Icon(Icons.arrow_drop_down, color: liquidTheme.textColor),
                  items: _getSupportedLocales().map((locale) {
                    return LiquidPopupMenuItem(
                      value: locale,
                      child: Row(
                        children: [
                          if (configState.locale == locale)
                            const Icon(Icons.check, size: 18),
                          if (configState.locale == locale)
                            const SizedBox(width: 8),
                          Text(_getLocaleName(locale)),
                        ],
                      ),
                    );
                  }).toList(),
                  onSelected: (Locale? newLocale) {
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

          const SizedBox(height: 24),
          Divider(color: liquidTheme.textColor.withValues(alpha: 0.1)),
          const SizedBox(height: 24),

          // Theme Color Selection
          const ThemeColorSelector(),
        ],
      ),
    );
  }

  /// Build Print Settings Section (High Priority)
  Widget _buildPrintSettingsSection() {
    final l10n = AppLocalizations.of(context)!;

    return _buildLiquidSection(
      title: l10n.printSettings,
      icon: Icons.print,
      subtitle: l10n.configureInvoicePrintingOptions,
      child: const PrintFormatSelector(),
    );
  }

  /// Build Company Information Section (Medium Priority)
  Widget _buildCompanyInfoSection() {
    final l10n = AppLocalizations.of(context)!;

    return _buildLiquidSection(
      title: l10n.companyNameEnglish,
      icon: Icons.business,
      subtitle: l10n.businessDetailsAndContactInformation,
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: LiquidLoader(size: 40)),
            )
          : Form(
              key: _formKey,
              child: _buildCompanyInfoForm(),
            ),
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
                LiquidTextField(
                  controller: _nameController,
                  label: '${l10n.companyNameEnglish} *',
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                LiquidTextField(
                  controller: _nameArabicController,
                  label: '${l10n.companyNameArabic} *',
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
              ]),
              const SizedBox(height: 16),
              _buildFormRow([
                LiquidTextField(
                  controller: _addressController,
                  label: '${l10n.addressEnglish} *',
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                LiquidTextField(
                  controller: _addressArabicController,
                  label: '${l10n.addressArabic} *',
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
              ]),
              const SizedBox(height: 16),
              _buildFormRow([
                LiquidTextField(
                  controller: _phoneController,
                  label: '${l10n.phone} *',
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                LiquidTextField(
                  controller: _emailController,
                  label: l10n.email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ]),
              const SizedBox(height: 16),
              _buildFormRow([
                LiquidTextField(
                  controller: _vatNumberController,
                  label: '${l10n.vatNumber} *',
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                LiquidTextField(
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
              LiquidTextField(
                controller: _nameController,
                label: '${l10n.companyNameEnglish} *',
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              LiquidTextField(
                controller: _nameArabicController,
                label: '${l10n.companyNameArabic} *',
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              LiquidTextField(
                controller: _addressController,
                label: '${l10n.addressEnglish} *',
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              LiquidTextField(
                controller: _addressArabicController,
                label: '${l10n.addressArabic} *',
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              LiquidTextField(
                controller: _phoneController,
                label: '${l10n.phone} *',
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              LiquidTextField(
                controller: _emailController,
                label: l10n.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              LiquidTextField(
                controller: _vatNumberController,
                label: '${l10n.vatNumber} *',
                validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
              ),
              const SizedBox(height: 16),
              LiquidTextField(
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

  /// Build save button with loading state
  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: LiquidButton(
        onPressed: _isLoading ? null : _saveCompanyInfo,
        type: LiquidButtonType.filled,
        size: LiquidButtonSize.large,
        width: double.infinity,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                l10n.saveCompanyInformation,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Build currency dropdown selector with liquid glass design
  Widget _buildCurrencyDropdown() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);
    final currencyOptions = _getCurrencyOptions();

    return LiquidContainer(
      blur: 15,
      opacity: 0.15,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: _selectedCurrency,
        decoration: InputDecoration(
          labelText: '${l10n.currency} *',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.attach_money, color: liquidTheme.textColor),
          labelStyle: TextStyle(color: liquidTheme.textColor),
        ),
        style: TextStyle(color: liquidTheme.textColor),
        dropdownColor: theme.colorScheme.surface,
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
      ),
    );
  }

  /// Build VAT Rate Configuration Section
  Widget _buildVATSection() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    return _buildLiquidSection(
      title: l10n.defaultVatRate,
      icon: Icons.receipt_long,
      subtitle: l10n.setDefaultVatRateDescription,
      child: BlocBuilder<AppConfigBloc, AppConfigState>(
        builder: (context, configState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VAT Enable/Disable Toggle
              LiquidCard(
                elevation: 0,
                blur: 20,
                opacity: 0.15,
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            configState.vatEnabled
                                ? l10n.vatEnabled
                                : l10n.vatDisabled,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            configState.vatEnabled
                                ? l10n.vatEnabledDescription
                                : l10n.vatDisabledDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: liquidTheme.textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildGlassSwitch(
                      value: configState.vatEnabled,
                      onChanged: (value) {
                        context.read<AppConfigBloc>().add(UpdateVatEnabledEvent(value));
                      },
                    ),
                  ],
                ),
              ),

              // Show VAT Rate and Inclusion settings only if VAT is enabled
              if (configState.vatEnabled) ...[
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(
                            child: LiquidTextField(
                              key: ValueKey(configState.vatRate),
                              initialValue: configState.vatRate.toString(),
                              label: l10n.vatRateLabel,
                              prefixIcon: const Icon(Icons.percent),
                              hint: l10n.vatRateHint,
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
                            child: LiquidContainer(
                              padding: const EdgeInsets.all(16),
                              blur: 15,
                              opacity: 0.15,
                              borderRadius: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.currentVatRate,
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${configState.vatRate.toStringAsFixed(1)}%',
                                    style: theme.textTheme.headlineMedium?.copyWith(
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
                          LiquidTextField(
                            key: ValueKey(configState.vatRate),
                            initialValue: configState.vatRate.toString(),
                            label: l10n.vatRateLabel,
                            prefixIcon: const Icon(Icons.percent),
                            hint: l10n.vatRateHint,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) {
                              final vatRate = double.tryParse(value);
                              if (vatRate != null && vatRate >= 0 && vatRate <= 100) {
                                context.read<AppConfigBloc>().add(UpdateVatRateEvent(vatRate));
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          LiquidContainer(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            blur: 15,
                            opacity: 0.15,
                            borderRadius: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.currentVatRate,
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${configState.vatRate.toStringAsFixed(1)}%',
                                  style: theme.textTheme.headlineMedium?.copyWith(
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
                Divider(color: liquidTheme.textColor.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                Text(
                  l10n.vatCalculationMethod,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chooseVatCalculationMethod,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: liquidTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                LiquidCard(
                  elevation: 0,
                  blur: 20,
                  opacity: 0.15,
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              configState.vatIncludedInPrice
                                  ? l10n.vatIncludedInPrice
                                  : l10n.vatExcludedFromPrice,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              configState.vatIncludedInPrice
                                  ? l10n.vatIncludedInPriceDescription
                                  : l10n.vatExcludedFromPriceDescription,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: liquidTheme.textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildGlassSwitch(
                        value: configState.vatIncludedInPrice,
                        onChanged: (value) {
                          context.read<AppConfigBloc>().add(UpdateVatInclusionEvent(value));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LiquidBanner(
                  type: LiquidBannerType.warning,
                  icon: Icons.info_outline,
                  child: Text(
                    l10n.vatRateAppliedToNewProducts,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Build Data Import/Export Section
  Widget _buildDataImportExportSection() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => DataImportExportBloc(
        service: DataImportExportService(database: AppDatabase()),
      ),
      child: BlocConsumer<DataImportExportBloc, DataImportExportState>(
        listener: (context, state) {
          if (state is DataExported) {
            _showExportSuccessDialog(context, state.filePath);
          } else if (state is DataImported) {
            context.read<AppConfigBloc>().add(const InitializeAppConfigEvent());
            CurrencyHelper.refreshCache();
            _loadCompanyInfo();
            _showSuccessNotification(l10n.importSuccessMessage(state.itemsImported));
          } else if (state is DataImportExportError) {
            _showErrorNotification('${state.message}\n${state.errorDetails ?? ''}');
          }
        },
        builder: (context, state) {
          final isLoading = state is DataExporting || state is DataImporting;

          return _buildLiquidSection(
            title: l10n.dataImportExport,
            icon: Icons.import_export,
            subtitle: l10n.dataImportExportDescription,
            child: Column(
              children: [
                // Warning banner
                LiquidBanner(
                  type: LiquidBannerType.warning,
                  icon: Icons.info_outline,
                  child: Text(
                    l10n.importWarning,
                    style: theme.textTheme.bodySmall,
                  ),
                ),

                const SizedBox(height: 24),

                // Progress indicator if loading
                if (isLoading) ...[
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
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                ],

                // Export button
                SizedBox(
                  width: double.infinity,
                  child: LiquidButton(
                    onPressed: isLoading ? null : () => _handleExport(context),
                    type: LiquidButtonType.filled,
                    size: LiquidButtonSize.large,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.exportData),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Import button
                SizedBox(
                  width: double.infinity,
                  child: LiquidButton(
                    onPressed: isLoading ? null : () => _handleImport(context),
                    type: LiquidButtonType.outlined,
                    size: LiquidButtonSize.large,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.importData),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  /// Handle import data with automatic detection
  Future<void> _handleImport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // First, pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
    );

    if (result != null) {
      final file = result.files.single;
      String? filePath;
      String? fileContent;
      String? fileName;

      // On web, use bytes; on mobile, use path
      if (kIsWeb) {
        if (file.bytes != null && file.name.isNotEmpty) {
          fileContent = utf8.decode(file.bytes!);
          fileName = file.name;
        } else {
          if (context.mounted) {
            _showErrorNotification(l10n.selectFileToImport);
          }
          return;
        }
      } else {
        if (file.path != null) {
          filePath = file.path!;
          fileName = file.path!.split('/').last;
        } else {
          if (context.mounted) {
            _showErrorNotification(l10n.selectFileToImport);
          }
          return;
        }
      }

      if (!context.mounted) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: LiquidLoader(size: 40),
        ),
      );

      try {
        final db = AppDatabase();
        final service = DataImportExportService(database: db);

        final detectionResult = await service.detectDataTypes(
          filePath: filePath,
          fileContent: fileContent,
          fileName: fileName,
        );

        if (!context.mounted) return;

        Navigator.of(context).pop();

        if (detectionResult.isValid && detectionResult.detectedTypes.isNotEmpty) {
          final selectedTypes = await showDataTypeDetectionDialog(
            context: context,
            detectionResult: detectionResult,
          );

          if (selectedTypes != null && selectedTypes.isNotEmpty && context.mounted) {
            context.read<DataImportExportBloc>().add(
                  ImportDataRequested(
                    filePath: filePath,
                    fileContent: fileContent,
                    fileName: fileName,
                    dataTypes: selectedTypes,
                  ),
                );
          }
        } else {
          if (context.mounted) {
            if (detectionResult.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(detectionResult.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }

            showDataTypeSelectorBottomSheet(
              context: context,
              isExport: false,
              onConfirm: (dataTypes, _) {
                context.read<DataImportExportBloc>().add(
                      ImportDataRequested(
                        filePath: filePath,
                        fileContent: fileContent,
                        fileName: fileName,
                        dataTypes: dataTypes,
                      ),
                    );
              },
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
          _showErrorNotification('Error detecting data types: ${e.toString()}');

          showDataTypeSelectorBottomSheet(
            context: context,
            isExport: false,
            onConfirm: (dataTypes, _) {
              context.read<DataImportExportBloc>().add(
                    ImportDataRequested(
                      filePath: filePath,
                      fileContent: fileContent,
                      fileName: fileName,
                      dataTypes: dataTypes,
                    ),
                  );
            },
          );
        }
      }
    } else {
      if (context.mounted) {
        _showErrorNotification(l10n.selectFileToImport);
      }
    }
  }

  /// Build Data Synchronization Section
  Widget _buildSyncSection() {
    final l10n = AppLocalizations.of(context)!;

    return _buildLiquidSection(
      title: l10n.dataSynchronization,
      icon: Icons.sync,
      subtitle: l10n.syncDescription,
      child: SizedBox(
        width: double.infinity,
        child: LiquidButton(
          onPressed: _isSyncing ? null : _syncData,
          type: LiquidButtonType.filled,
          size: LiquidButtonSize.large,
          width: double.infinity,
          child: _isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sync, size: 20),
                    const SizedBox(width: 8),
                    Text(_isSyncing ? l10n.syncing : l10n.syncNow),
                  ],
                ),
        ),
      ),
    );
  }

  /// Build About Section
  Widget _buildAboutSection() {
    final l10n = AppLocalizations.of(context)!;
    final liquidTheme = LiquidTheme.of(context);

    return _buildLiquidSection(
      title: l10n.about,
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildGlassTile(
            leading: Icon(Icons.info_outline, color: liquidTheme.textColor),
            title: l10n.version,
            subtitle: l10n.appVersion,
          ),
          const SizedBox(height: 16),
          _buildGlassTile(
            leading: Icon(Icons.business, color: liquidTheme.textColor),
            title: l10n.appTitle,
            subtitle: l10n.posWithOfflineSupport,
          ),
        ],
      ),
    );
  }

  /// Build a liquid glass section wrapper
  Widget _buildLiquidSection({
    required String title,
    required IconData icon,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    return LiquidCard(
      elevation: 4,
      blur: 25,
      opacity: 0.18,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              LiquidContainer(
                width: 48,
                height: 48,
                borderRadius: 24,
                blur: 15,
                opacity: 0.2,
                child: Center(
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: liquidTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  /// Build a glass morphism tile (similar to ListTile)
  Widget _buildGlassTile({
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    return LiquidContainer(
      blur: 15,
      opacity: 0.15,
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: liquidTheme.textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing,
          ],
        ],
      ),
    );
  }

  /// Build a glass morphism switch
  Widget _buildGlassSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: Border.all(
            color: value
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
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
