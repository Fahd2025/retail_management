import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';
import '../providers/customer_provider.dart';
import '../providers/sale_provider.dart';
import '../models/customer.dart';
import '../models/company_info.dart';
import '../database/drift_database.dart';
import '../services/customer_invoice_export_service.dart';

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
    await context.read<CustomerProvider>().loadCustomers();
  }

  Future<void> showCustomerDialog([Customer? customer]) async {
    await showDialog(
      context: context,
      builder: (context) => _CustomerDialog(customer: customer),
    );
  }

  Future<void> _showExportDialog(BuildContext context, Customer customer) async {
    await showDialog(
      context: context,
      builder: (context) => _ExportInvoicesDialog(customer: customer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.customers.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.customers.length,
            itemBuilder: (context, index) {
              final customer = provider.customers[index];
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
                      if (customer.phone != null) Text(AppLocalizations.of(context)!.phoneLabel(customer.phone!)),
                      if (customer.email != null) Text(AppLocalizations.of(context)!.emailLabel(customer.email!)),
                      if (customer.vatNumber != null)
                        Text(AppLocalizations.of(context)!.vatLabel2(customer.vatNumber!)),
                      const SizedBox(height: 4),
                      FutureBuilder<Map<String, dynamic>>(
                        future: context.read<SaleProvider>().getCustomerStatistics(customer.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final stats = snapshot.data!;
                            final invoiceCount = stats['invoiceCount'] as int;
                            final totalAmount = stats['totalAmount'] as double;
                            final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);
                            return Text(
                              'Invoices: $invoiceCount | Total: ${currencyFormat.format(totalAmount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            );
                          }
                          return const Text('Loading statistics...');
                        },
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                        tooltip: 'Export Invoices to PDF',
                        onPressed: () => _showExportDialog(context, customer),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => showCustomerDialog(customer),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final l10n = AppLocalizations.of(context)!;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.deleteCustomer),
                              content: Text(l10n.deleteCustomerConfirm),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            await provider.deleteCustomer(customer.id);
                          }
                        },
                      ),
                    ],
                  ),
                  children: [
                    if (customer.saudiAddress != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(AppLocalizations.of(context)!.addressLabel(customer.saudiAddress!.formattedAddress)),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CustomerDialog extends StatefulWidget {
  final Customer? customer;

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
    _vatNumberController = TextEditingController(text: widget.customer?.vatNumber);
    _crnNumberController = TextEditingController(text: widget.customer?.crnNumber);

    final address = widget.customer?.saudiAddress;
    _buildingController = TextEditingController(text: address?.buildingNumber);
    _streetController = TextEditingController(text: address?.streetName);
    _districtController = TextEditingController(text: address?.district);
    _cityController = TextEditingController(text: address?.city);
    _postalCodeController = TextEditingController(text: address?.postalCode);
    _additionalNumberController = TextEditingController(text: address?.additionalNumber);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerProvider>();

    final saudiAddress = SaudiAddress(
      buildingNumber: _buildingController.text.isEmpty ? null : _buildingController.text,
      streetName: _streetController.text.isEmpty ? null : _streetController.text,
      district: _districtController.text.isEmpty ? null : _districtController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      postalCode: _postalCodeController.text.isEmpty ? null : _postalCodeController.text,
      additionalNumber: _additionalNumberController.text.isEmpty
          ? null
          : _additionalNumberController.text,
    );

    bool success;
    if (widget.customer == null) {
      success = await provider.addCustomer(
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        vatNumber: _vatNumberController.text.isEmpty ? null : _vatNumberController.text,
        crnNumber: _crnNumberController.text.isEmpty ? null : _crnNumberController.text,
        saudiAddress: saudiAddress,
      );
    } else {
      success = await provider.updateCustomer(
        widget.customer!.copyWith(
          name: _nameController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          vatNumber: _vatNumberController.text.isEmpty ? null : _vatNumberController.text,
          crnNumber: _crnNumberController.text.isEmpty ? null : _crnNumberController.text,
          saudiAddress: saudiAddress,
        ),
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.customer == null ? l10n.addCustomer : l10n.editCustomer),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.customerNameRequired),
                  validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.emailFieldLabel),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: l10n.phoneFieldLabel),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vatNumberController,
                  decoration: InputDecoration(labelText: l10n.vatNumberFieldLabel),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _crnNumberController,
                  decoration: InputDecoration(labelText: l10n.crnNumberFieldLabel),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.saudiNationalAddress,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _buildingController,
                        decoration: InputDecoration(labelText: l10n.buildingNumber),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _streetController,
                        decoration: InputDecoration(labelText: l10n.streetName),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _districtController,
                        decoration: InputDecoration(labelText: l10n.district),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(labelText: l10n.city),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _postalCodeController,
                        decoration: InputDecoration(labelText: l10n.postalCode),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _additionalNumberController,
                        decoration: InputDecoration(labelText: l10n.additionalNumber),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
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
  final Customer customer;

  const _ExportInvoicesDialog({required this.customer});

  @override
  State<_ExportInvoicesDialog> createState() => _ExportInvoicesDialogState();
}

class _ExportInvoicesDialogState extends State<_ExportInvoicesDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;
  String _filterOption = 'all'; // 'all', 'custom', 'last_month', 'last_3_months', 'last_year'

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
      final saleProvider = context.read<SaleProvider>();
      final exportService = CustomerInvoiceExportService();

      // Get company info
      final companyInfo = await db.getCompanyInfo();
      if (companyInfo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Company information not found. Please set up company info first.')),
          );
        }
        return;
      }

      // Get sales for customer with date filter
      final sales = await saleProvider.getCustomerSales(
        widget.customer.id,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (sales.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No invoices found for the selected period.')),
          );
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
          SnackBar(content: Text('Successfully exported ${sales.length} invoices to PDF')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting invoices: $e')),
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

    return AlertDialog(
      title: const Text('Export Customer Invoices to PDF'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer: ${widget.customer.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Select Period:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _filterOption,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Time')),
                DropdownMenuItem(value: 'last_month', child: Text('Last Month')),
                DropdownMenuItem(value: 'last_3_months', child: Text('Last 3 Months')),
                DropdownMenuItem(value: 'last_year', child: Text('Last Year')),
                DropdownMenuItem(value: 'custom', child: Text('Custom Date Range')),
              ],
              onChanged: (value) {
                setState(() {
                  _filterOption = value!;
                  _setDateRangeFromFilter();
                });
              },
            ),
            if (_filterOption == 'custom') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectStartDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_startDate == null ? 'Start Date' : dateFormat.format(_startDate!)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectEndDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_endDate == null ? 'End Date' : dateFormat.format(_endDate!)),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: Future.wait([
                context.read<SaleProvider>().getCustomerSales(
                  widget.customer.id,
                  startDate: _startDate,
                  endDate: _endDate,
                ),
                context.read<SaleProvider>().getCustomerStatistics(widget.customer.id),
              ]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sales = snapshot.data![0] as List;
                  final stats = snapshot.data![1] as Map<String, dynamic>;
                  final totalAmount = stats['totalAmount'] as double;
                  final currencyFormat = NumberFormat.currency(symbol: 'SAR ', decimalDigits: 2);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Total Invoices: ${sales.length}'),
                        Text('Total Amount: ${currencyFormat.format(totalAmount)}'),
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportInvoices,
          icon: _isExporting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.picture_as_pdf),
          label: Text(_isExporting ? 'Exporting...' : 'Export to PDF'),
        ),
      ],
    );
  }
}
