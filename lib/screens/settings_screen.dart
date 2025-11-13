import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/drift_database.dart';
import '../models/company_info.dart';
import '../services/sync_service.dart';
import '../services/image_service.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_event.dart';
import '../blocs/app_config/app_config_state.dart';
import '../widgets/print_format_selector.dart';
import '../widgets/settings_section.dart';
import '../widgets/company_logo_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:retail_management/l10n/app_localizations.dart';

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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.createOrUpdateCompanyInfo(companyInfo);

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
      ],
    );
  }

  /// Build Print Settings Section (High Priority)
  Widget _buildPrintSettingsSection() {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSection(
      title: l10n.printSettings,
      icon: Icons.print,
      subtitle: 'Configure invoice printing options',
      children: const [
        PrintFormatSelector(),
      ],
    );
  }

  /// Build Company Information Section (Medium Priority)
  Widget _buildCompanyInfoSection() {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSection(
      title: l10n.companyInformation,
      icon: Icons.business,
      subtitle: 'Business details and contact information',
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
