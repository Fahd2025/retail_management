import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';

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
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(customer.name[0].toUpperCase()),
                  ),
                  title: Text(customer.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (customer.phone != null) Text('Phone: ${customer.phone}'),
                      if (customer.email != null) Text('Email: ${customer.email}'),
                      if (customer.vatNumber != null)
                        Text('VAT: ${customer.vatNumber}'),
                      if (customer.saudiAddress != null)
                        Text('Address: ${customer.saudiAddress!.formattedAddress}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                  isThreeLine: true,
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
    return AlertDialog(
      title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer'),
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
                  decoration: const InputDecoration(labelText: 'Customer Name *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vatNumberController,
                  decoration: const InputDecoration(labelText: 'VAT Number'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _crnNumberController,
                  decoration: const InputDecoration(labelText: 'CRN Number'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Saudi National Address',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _buildingController,
                        decoration: const InputDecoration(labelText: 'Building Number'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(labelText: 'Street Name'),
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
                        decoration: const InputDecoration(labelText: 'District'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City'),
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
                        decoration: const InputDecoration(labelText: 'Postal Code'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _additionalNumberController,
                        decoration: const InputDecoration(labelText: 'Additional Number'),
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
