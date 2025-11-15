import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../blocs/customer/customer_bloc.dart';
import '../blocs/customer/customer_event.dart';
import '../blocs/customer/customer_state.dart';
import '../models/customer.dart' as models;
import '../database/drift_database.dart';
import '../services/customer_invoice_export_service.dart';
import '../widgets/form_bottom_sheet.dart';
import '../utils/currency_helper.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    context.read<CustomerBloc>().add(const LoadCustomersEvent());
  }

  Future<void> showCustomerDialog([models.Customer? customer]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomerDialog(customer: customer),
    );
  }

  Future<void> _showExportDialog(
    BuildContext context,
    models.Customer customer,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExportInvoicesDialog(customer: customer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    return LiquidScaffold(
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return Center(
              child: LiquidLoader(size: 60),
            );
          }

          List<models.Customer> customers = [];
          if (state is CustomerLoaded) {
            customers = state.customers;
          } else if (state is CustomerError) {
            customers = state.customers;
          } else if (state is CustomerOperationSuccess) {
            customers = state.customers;
          }

          if (customers.isEmpty) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LiquidContainer(
                    width: 120,
                    height: 120,
                    borderRadius: 60,
                    blur: 15,
                    opacity: 0.2,
                    child: Icon(
                      Icons.people,
                      size: 64,
                      color: liquidTheme.textColor.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noCustomersFound,
                    style: TextStyle(color: liquidTheme.textColor),
                  ),
                  const SizedBox(height: 16),
                  LiquidButton(
                    onTap: () => showCustomerDialog(),
                    type: LiquidButtonType.filled,
                    icon: const Icon(Icons.add, color: Colors.white),
                    child: Text(
                      l10n.addCustomer,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;
              final l10n = AppLocalizations.of(context)!;

              if (isDesktop) {
                // Desktop/Tablet: DataTable layout that fills width
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: LiquidCard(
                          elevation: 4,
                          blur: 20,
                          opacity: 0.15,
                          borderRadius: 16,
                          padding: EdgeInsets.zero,
                          child: DataTable(
                            columnSpacing: 24,
                            horizontalMargin: 16,
                            headingTextStyle: TextStyle(
                              color: liquidTheme.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                            dataTextStyle: TextStyle(
                              color: liquidTheme.textColor,
                            ),
                            columns: [
                              DataColumn(label: Text(l10n.name)),
                              DataColumn(label: Text(l10n.phoneFieldLabel)),
                              DataColumn(label: Text(l10n.emailFieldLabel)),
                              DataColumn(label: Text(l10n.vatNumberFieldLabel)),
                              DataColumn(label: Text(l10n.invoiceCount)),
                              DataColumn(label: Text(l10n.totalAmount(''))),
                              DataColumn(label: Text(l10n.actions)),
                            ],
                            rows: customers.map((customer) {
                              return DataRow(cells: [
                                DataCell(Text(customer.name)),
                                DataCell(Text(customer.phone ?? '-')),
                                DataCell(Text(customer.email ?? '-')),
                                DataCell(Text(customer.vatNumber ?? '-')),
                                DataCell(
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: AppDatabase()
                                        .getCustomerSalesStatistics(
                                            customer.id),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final stats = snapshot.data!;
                                        final invoiceCount =
                                            stats['invoiceCount'] as int;
                                        return Text(invoiceCount.toString());
                                      }
                                      return const Text('...');
                                    },
                                  ),
                                ),
                                DataCell(
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: AppDatabase()
                                        .getCustomerSalesStatistics(
                                            customer.id),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final stats = snapshot.data!;
                                        final totalAmount =
                                            stats['totalAmount'] as double;
                                        return Text(
                                            CurrencyHelper.formatCurrencySync(
                                                totalAmount));
                                      }
                                      return const Text('...');
                                    },
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LiquidButton(
                                        type: LiquidButtonType.icon,
                                        size: LiquidButtonSize.small,
                                        onTap: () => _showExportDialog(
                                            context, customer),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      LiquidButton(
                                        type: LiquidButtonType.icon,
                                        size: LiquidButtonSize.small,
                                        onTap: () =>
                                            showCustomerDialog(customer),
                                        child: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      LiquidButton(
                                        type: LiquidButtonType.icon,
                                        size: LiquidButtonSize.small,
                                        onTap: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => LiquidDialog(
                                              title: l10n.deleteCustomer,
                                              content: Text(
                                                l10n.deleteCustomerConfirm,
                                                style: TextStyle(
                                                    color:
                                                        liquidTheme.textColor),
                                              ),
                                              actions: [
                                                LiquidButton(
                                                  onTap: () => Navigator.pop(
                                                      context, false),
                                                  type: LiquidButtonType.text,
                                                  child: Text(l10n.cancel),
                                                ),
                                                LiquidButton(
                                                  onTap: () => Navigator.pop(
                                                      context, true),
                                                  type: LiquidButtonType.filled,
                                                  backgroundColor:
                                                      theme.colorScheme.error,
                                                  child: Text(
                                                    l10n.delete,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true && mounted) {
                                            context.read<CustomerBloc>().add(
                                                  DeleteCustomerEvent(
                                                      customer.id),
                                                );
                                          }
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // Mobile: Card with ExpansionTile layout
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return LiquidCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      blur: 18,
                      opacity: 0.15,
                      borderRadius: 16,
                      padding: EdgeInsets.zero,
                      child: ExpansionTile(
                        leading: LiquidContainer(
                          width: 40,
                          height: 40,
                          borderRadius: 20,
                          blur: 10,
                          opacity: 0.15,
                          child: Center(
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: liquidTheme.textColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (customer.phone != null)
                              Text(
                                l10n.phoneLabel(customer.phone!),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: liquidTheme.textColor
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            if (customer.email != null)
                              Text(
                                l10n.emailLabel(customer.email!),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: liquidTheme.textColor
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            if (customer.vatNumber != null)
                              Text(
                                l10n.vatLabel2(customer.vatNumber!),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: liquidTheme.textColor
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            const SizedBox(height: 4),
                            FutureBuilder<Map<String, dynamic>>(
                              future: AppDatabase().getCustomerSalesStatistics(
                                customer.id,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final stats = snapshot.data!;
                                  final invoiceCount =
                                      stats['invoiceCount'] as int;
                                  final totalAmount =
                                      stats['totalAmount'] as double;
                                  final currencyFormat =
                                      CurrencyHelper.getCurrencyFormatterSync();
                                  return Text(
                                    l10n.invoicesTotal(
                                      invoiceCount,
                                      currencyFormat.format(totalAmount),
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  );
                                }
                                return Text(
                                  l10n.loadingStatistics,
                                  style: TextStyle(
                                    color: liquidTheme.textColor
                                        .withValues(alpha: 0.6),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LiquidButton(
                              type: LiquidButtonType.icon,
                              size: LiquidButtonSize.small,
                              onTap: () => _showExportDialog(context, customer),
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            LiquidButton(
                              type: LiquidButtonType.icon,
                              size: LiquidButtonSize.small,
                              onTap: () => showCustomerDialog(customer),
                              child: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            LiquidButton(
                              type: LiquidButtonType.icon,
                              size: LiquidButtonSize.small,
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => LiquidDialog(
                                    title: l10n.deleteCustomer,
                                    content: Text(
                                      l10n.deleteCustomerConfirm,
                                      style: TextStyle(
                                          color: liquidTheme.textColor),
                                    ),
                                    actions: [
                                      LiquidButton(
                                        onTap: () =>
                                            Navigator.pop(context, false),
                                        type: LiquidButtonType.text,
                                        child: Text(l10n.cancel),
                                      ),
                                      LiquidButton(
                                        onTap: () =>
                                            Navigator.pop(context, true),
                                        type: LiquidButtonType.filled,
                                        backgroundColor:
                                            theme.colorScheme.error,
                                        child: Text(
                                          l10n.delete,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && mounted) {
                                  context.read<CustomerBloc>().add(
                                        DeleteCustomerEvent(customer.id),
                                      );
                                }
                              },
                              child: Icon(
                                Icons.delete,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          if (customer.saudiAddress != null)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.saudiNationalAddress,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: liquidTheme.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer.saudiAddress!.formattedAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: liquidTheme.textColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _CustomerDialog extends StatefulWidget {
  final models.Customer? customer;

  const _CustomerDialog({this.customer});

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _vatNumberController;
  late TextEditingController _crnNumberController;

  // Saudi Address fields
  late TextEditingController _buildingController;
  late TextEditingController _streetController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _additionalNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name);
    _emailController = TextEditingController(text: widget.customer?.email);
    _phoneController = TextEditingController(text: widget.customer?.phone);
    _vatNumberController = TextEditingController(
      text: widget.customer?.vatNumber,
    );
    _crnNumberController = TextEditingController(
      text: widget.customer?.crnNumber,
    );

    final address = widget.customer?.saudiAddress;
    _buildingController = TextEditingController(text: address?.buildingNumber);
    _streetController = TextEditingController(text: address?.streetName);
    _districtController = TextEditingController(text: address?.district);
    _cityController = TextEditingController(text: address?.city);
    _postalCodeController = TextEditingController(text: address?.postalCode);
    _additionalNumberController = TextEditingController(
      text: address?.additionalNumber,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<CustomerBloc>();

    final saudiAddress = models.SaudiAddress(
      buildingNumber:
          _buildingController.text.isEmpty ? null : _buildingController.text,
      streetName:
          _streetController.text.isEmpty ? null : _streetController.text,
      district:
          _districtController.text.isEmpty ? null : _districtController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      postalCode: _postalCodeController.text.isEmpty
          ? null
          : _postalCodeController.text,
      additionalNumber: _additionalNumberController.text.isEmpty
          ? null
          : _additionalNumberController.text,
    );

    if (widget.customer == null) {
      bloc.add(
        AddCustomerEvent(
          name: _nameController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          vatNumber: _vatNumberController.text.isEmpty
              ? null
              : _vatNumberController.text,
          crnNumber: _crnNumberController.text.isEmpty
              ? null
              : _crnNumberController.text,
          saudiAddress: saudiAddress,
        ),
      );
    } else {
      bloc.add(
        UpdateCustomerEvent(
          widget.customer!.copyWith(
            name: _nameController.text,
            email: _emailController.text.isEmpty ? null : _emailController.text,
            phone: _phoneController.text.isEmpty ? null : _phoneController.text,
            vatNumber: _vatNumberController.text.isEmpty
                ? null
                : _vatNumberController.text,
            crnNumber: _crnNumberController.text.isEmpty
                ? null
                : _crnNumberController.text,
            saudiAddress: saudiAddress,
          ),
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    // Build the form content
    final formContent = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Customer Information Section
          Text(
            l10n.customerInformation,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Customer Name Field
          LiquidTextField(
            controller: _nameController,
            label: l10n.customerNameRequired,
            prefixIcon: const Icon(Icons.person_outlined),
            validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Email Field
          LiquidTextField(
            controller: _emailController,
            label: l10n.emailFieldLabel,
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Phone Field
          LiquidTextField(
            controller: _phoneController,
            label: l10n.phoneFieldLabel,
            prefixIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // VAT Number Field
          LiquidTextField(
            controller: _vatNumberController,
            label: l10n.vatNumberFieldLabel,
            prefixIcon: const Icon(Icons.receipt_outlined),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // CRN Number Field
          LiquidTextField(
            controller: _crnNumberController,
            label: l10n.crnNumberFieldLabel,
            prefixIcon: const Icon(Icons.business_outlined),
            textInputAction: TextInputAction.next,
          ),

          // Saudi National Address Section
          const SizedBox(height: 32),
          Divider(color: liquidTheme.textColor.withValues(alpha: 0.2)),
          const SizedBox(height: 16),

          Text(
            l10n.saudiNationalAddress,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Building Number and Street Name Row
          Row(
            children: [
              Expanded(
                child: LiquidTextField(
                  controller: _buildingController,
                  label: l10n.buildingNumber,
                  prefixIcon: const Icon(Icons.home_outlined),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LiquidTextField(
                  controller: _streetController,
                  label: l10n.streetName,
                  prefixIcon: const Icon(Icons.streetview_outlined),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // District and City Row
          Row(
            children: [
              Expanded(
                child: LiquidTextField(
                  controller: _districtController,
                  label: l10n.district,
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LiquidTextField(
                  controller: _cityController,
                  label: l10n.city,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Postal Code and Additional Number Row
          Row(
            children: [
              Expanded(
                child: LiquidTextField(
                  controller: _postalCodeController,
                  label: l10n.postalCode,
                  prefixIcon: const Icon(Icons.mail_outline),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LiquidTextField(
                  controller: _additionalNumberController,
                  label: l10n.additionalNumber,
                  prefixIcon: const Icon(Icons.tag_outlined),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Wrap in FormBottomSheet
    return FormBottomSheet(
      title: widget.customer == null ? l10n.addCustomer : l10n.editCustomer,
      saveButtonText: l10n.save,
      cancelButtonText: l10n.cancel,
      onSave: _save,
      maxHeightFraction: 0.95, // Use more height for this complex form
      child: formContent,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _vatNumberController.dispose();
    _crnNumberController.dispose();
    _buildingController.dispose();
    _streetController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _additionalNumberController.dispose();
    super.dispose();
  }
}

class _ExportInvoicesDialog extends StatefulWidget {
  final models.Customer customer;

  const _ExportInvoicesDialog({required this.customer});

  @override
  State<_ExportInvoicesDialog> createState() => _ExportInvoicesDialogState();
}

class _ExportInvoicesDialogState extends State<_ExportInvoicesDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;
  String _filterOption =
      'all'; // 'all', 'custom', 'last_month', 'last_3_months', 'last_year'

  @override
  void initState() {
    super.initState();
    _setDateRangeFromFilter();
  }

  void _setDateRangeFromFilter() {
    final now = DateTime.now();
    switch (_filterOption) {
      case 'last_month':
        _startDate = DateTime(now.year, now.month - 1, now.day);
        _endDate = now;
        break;
      case 'last_3_months':
        _startDate = DateTime(now.year, now.month - 3, now.day);
        _endDate = now;
        break;
      case 'last_year':
        _startDate = DateTime(now.year - 1, now.month, now.day);
        _endDate = now;
        break;
      case 'all':
        _startDate = null;
        _endDate = null;
        break;
      case 'custom':
        // Keep existing dates or set to null
        break;
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _filterOption = 'custom';
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _filterOption = 'custom';
      });
    }
  }

  Future<void> _exportInvoices() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final db = AppDatabase();
      final exportService = CustomerInvoiceExportService();
      final l10n = AppLocalizations.of(context)!;

      // Get company info
      final companyInfo = await db.getCompanyInfo();
      if (companyInfo == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.companyInfoNotFound)));
        }
        return;
      }

      // Get sales for customer with date filter
      final sales = await db.getSalesByCustomer(
        widget.customer.id,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (sales.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.noInvoicesFound)));
        }
        return;
      }

      // Export to PDF
      await exportService.exportCustomerInvoices(
        customer: widget.customer,
        sales: sales,
        companyInfo: companyInfo,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportedInvoicesSuccess(sales.length))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorExportingInvoices(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    // Build the export configuration content
    final exportContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Information
        LiquidCard(
          elevation: 2,
          blur: 15,
          opacity: 0.15,
          borderRadius: 12,
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.customer,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: liquidTheme.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      widget.customer.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: liquidTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Period Selection Section
        Text(
          l10n.selectPeriod,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: liquidTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),

        // Period Dropdown wrapped in LiquidContainer
        LiquidContainer(
          blur: 15,
          opacity: 0.1,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonFormField<String>(
            value: _filterOption,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 8,
              ),
              prefixIcon: Icon(
                Icons.date_range,
                color: theme.colorScheme.primary,
              ),
            ),
            dropdownColor: theme.scaffoldBackgroundColor,
            style: TextStyle(color: liquidTheme.textColor),
            items: [
              DropdownMenuItem(value: 'all', child: Text(l10n.allTime)),
              DropdownMenuItem(
                value: 'last_month',
                child: Text(l10n.monthly),
              ),
              DropdownMenuItem(
                value: 'last_3_months',
                child: Text(l10n.lastThreeMonths),
              ),
              DropdownMenuItem(
                value: 'last_year',
                child: Text(l10n.yearly),
              ),
              DropdownMenuItem(
                value: 'custom',
                child: Text(l10n.custom),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _filterOption = value!;
                _setDateRangeFromFilter();
              });
            },
          ),
        ),

        // Custom Date Range Pickers (conditionally shown)
        if (_filterOption == 'custom') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LiquidButton(
                  onTap: _selectStartDate,
                  type: LiquidButtonType.outlined,
                  icon: const Icon(Icons.calendar_today),
                  child: Text(
                    _startDate == null
                        ? l10n.from
                        : dateFormat.format(_startDate!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LiquidButton(
                  onTap: _selectEndDate,
                  type: LiquidButtonType.outlined,
                  icon: const Icon(Icons.calendar_today),
                  child: Text(
                    _endDate == null ? l10n.to : dateFormat.format(_endDate!),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),

        // Preview Statistics
        FutureBuilder<List<dynamic>>(
          future: Future.wait([
            AppDatabase().getSalesByCustomer(
              widget.customer.id,
              startDate: _startDate,
              endDate: _endDate,
            ),
            AppDatabase().getCustomerSalesStatistics(widget.customer.id),
          ]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final sales = snapshot.data![0] as List;
              final stats = snapshot.data![1] as Map<String, dynamic>;
              final totalAmount = stats['totalAmount'] as double;
              final currencyFormat = CurrencyHelper.getCurrencyFormatterSync();

              return LiquidCard(
                elevation: 3,
                blur: 18,
                opacity: 0.15,
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.preview,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: liquidTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.invoiceCount,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: liquidTheme.textColor
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '${sales.length}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: liquidTheme.textColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.totalAmount(''),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: liquidTheme.textColor
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              currencyFormat.format(totalAmount),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: liquidTheme.textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LiquidLoader(size: 40),
              ),
            );
          },
        ),
      ],
    );

    // Wrap in FormBottomSheet
    return FormBottomSheet(
      title: l10n.exportCustomerInvoices,
      saveButtonText: _isExporting ? l10n.exporting : l10n.exportToPdf,
      cancelButtonText: l10n.cancel,
      isLoading: _isExporting,
      onSave: _exportInvoices,
      maxHeightFraction: 0.9,
      child: exportContent,
    );
  }
}
