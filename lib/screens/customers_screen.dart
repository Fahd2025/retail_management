import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../blocs/customer/customer_bloc.dart';
import '../blocs/customer/customer_event.dart';
import '../blocs/customer/customer_state.dart';
import '../models/customer.dart' as models;
import '../database/drift_database.dart';
import '../services/customer_invoice_export_service.dart';
import '../widgets/form_bottom_sheet.dart';

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
    return Scaffold(
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
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
                  Icon(Icons.people, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(l10n.noCustomersFound),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => showCustomerDialog(),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addCustomer),
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
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 16,
                        columns: [
                          DataColumn(label: Text(l10n.nameFieldLabel)),
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
                                    .getCustomerSalesStatistics(customer.id),
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
                                    .getCustomerSalesStatistics(customer.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final stats = snapshot.data!;
                                    final totalAmount =
                                        stats['totalAmount'] as double;
                                    return Text(
                                        'SAR ${totalAmount.toStringAsFixed(2)}');
                                  }
                                  return const Text('...');
                                },
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.picture_as_pdf,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    tooltip: l10n.exportInvoicesToPdf,
                                    onPressed: () =>
                                        _showExportDialog(context, customer),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () =>
                                        showCustomerDialog(customer),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(l10n.deleteCustomer),
                                          content:
                                              Text(l10n.deleteCustomerConfirm),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text(l10n.cancel),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: Text(l10n.delete),
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
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          child: Text(customer.name[0].toUpperCase()),
                        ),
                        title: Text(customer.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (customer.phone != null)
                              Text(
                                l10n.phoneLabel(customer.phone!),
                              ),
                            if (customer.email != null)
                              Text(
                                l10n.emailLabel(customer.email!),
                              ),
                            if (customer.vatNumber != null)
                              Text(
                                l10n.vatLabel2(customer.vatNumber!),
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
                                  final currencyFormat = NumberFormat.currency(
                                    symbol: 'SAR ',
                                    decimalDigits: 2,
                                  );
                                  return Text(
                                    l10n.invoicesTotal(
                                      invoiceCount,
                                      currencyFormat.format(totalAmount),
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  );
                                }
                                return Text(l10n.loadingStatistics);
                              },
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.blue,
                              ),
                              tooltip: l10n.exportInvoicesToPdf,
                              onPressed: () =>
                                  _showExportDialog(context, customer),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showCustomerDialog(customer),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(l10n.deleteCustomer),
                                    content: Text(l10n.deleteCustomerConfirm),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(l10n.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text(l10n.delete),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer.saudiAddress!.formattedAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
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
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.customerNameRequired,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outlined),
            ),
            validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.emailFieldLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Phone Field
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: l10n.phoneFieldLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // VAT Number Field
          TextFormField(
            controller: _vatNumberController,
            decoration: InputDecoration(
              labelText: l10n.vatNumberFieldLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.receipt_outlined),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // CRN Number Field
          TextFormField(
            controller: _crnNumberController,
            decoration: InputDecoration(
              labelText: l10n.crnNumberFieldLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.business_outlined),
            ),
            textInputAction: TextInputAction.next,
          ),

          // Saudi National Address Section
          const SizedBox(height: 32),
          Divider(color: theme.dividerColor),
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
                child: TextFormField(
                  controller: _buildingController,
                  decoration: InputDecoration(
                    labelText: l10n.buildingNumber,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.home_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(
                    labelText: l10n.streetName,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.streetview_outlined),
                  ),
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
                child: TextFormField(
                  controller: _districtController,
                  decoration: InputDecoration(
                    labelText: l10n.district,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_city_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: l10n.city,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
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
                child: TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: l10n.postalCode,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.mail_outline),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _additionalNumberController,
                  decoration: InputDecoration(
                    labelText: l10n.additionalNumber,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.tag_outlined),
                  ),
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

    // Build the export configuration content
    final exportContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Information
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.customer,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      widget.customer.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
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
          ),
        ),
        const SizedBox(height: 12),

        // Period Dropdown
        DropdownButtonFormField<String>(
          initialValue: _filterOption,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            prefixIcon: const Icon(Icons.date_range),
          ),
          items: [
            DropdownMenuItem(value: 'all', child: Text(l10n.allTime)),
            DropdownMenuItem(
              value: 'last_month',
              child: Text(l10n.lastMonth),
            ),
            DropdownMenuItem(
              value: 'last_3_months',
              child: Text(l10n.lastThreeMonths),
            ),
            DropdownMenuItem(
              value: 'last_year',
              child: Text(l10n.lastYear),
            ),
            DropdownMenuItem(
              value: 'custom',
              child: Text(l10n.customDateRange),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _filterOption = value!;
              _setDateRangeFromFilter();
            });
          },
        ),

        // Custom Date Range Pickers (conditionally shown)
        if (_filterOption == 'custom') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectStartDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _startDate == null
                        ? l10n.startDate
                        : dateFormat.format(_startDate!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectEndDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _endDate == null
                        ? l10n.endDate
                        : dateFormat.format(_endDate!),
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
              final currencyFormat = NumberFormat.currency(
                symbol: 'SAR ',
                decimalDigits: 2,
              );

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.preview,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
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
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            Text(
                              '${sales.length}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
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
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            Text(
                              currencyFormat.format(totalAmount),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
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
