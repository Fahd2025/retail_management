import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_state.dart';
import '../models/product.dart' as models;
import '../models/category.dart';
import '../database/drift_database.dart';
import '../widgets/form_bottom_sheet.dart';
import '../utils/currency_helper.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final AppDatabase _db = AppDatabase();
  Map<String, Category> _categories = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
    context.read<ProductBloc>().add(const LoadProductsEvent());
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _db.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = {
            for (var category in categories) category.id: category
          };
        });
      }
    } catch (e) {
      // Silently fail - will display IDs if categories can't be loaded
    }
  }

  String _getCategoryName(String categoryId) {
    final category = _categories[categoryId];
    if (category == null) return categoryId;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? (category.nameAr ?? category.name) : category.name;
  }

  @override
  void dispose() {
    // Don't close the singleton database instance
    super.dispose();
  }

  Future<void> showProductDialog([models.Product? product]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDialog(product: product),
    );
  }

  Future<void> _deleteProduct(
    BuildContext context,
    models.Product product,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(l10n.deleteProductConfirm(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<ProductBloc>().add(DeleteProductEvent(product.id));
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<models.Product> products = [];
          if (state is ProductLoaded) {
            products = state.products;
          } else if (state is ProductError) {
            products = state.products;
          } else if (state is ProductOperationSuccess) {
            products = state.products;
          }

          if (products.isEmpty) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(l10n.noProductsFound),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => showProductDialog(),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.add),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;
              final l10n = AppLocalizations.of(context)!;

              final configState = context.watch<AppConfigBloc>().state;
              final vatIncludedInPrice = configState.vatIncludedInPrice;
              final vatEnabled = configState.vatEnabled;

              if (isDesktop) {
                // Desktop/Tablet: DataTable layout that fills width
                return Column(
                  children: [
                    // VAT Information Note (only shown when VAT is enabled)
                    if (vatEnabled)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        color: vatIncludedInPrice
                            ? Colors.green.shade50
                            : theme.colorScheme.primary.shade50,
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: vatIncludedInPrice
                                  ? Colors.green.shade700
                                  : theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vatIncludedInPrice
                                  ? l10n.pricesIncludeVatNote
                                  : l10n.pricesExcludeVatNote,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: vatIncludedInPrice
                                    ? Colors.green.shade900
                                    : theme.colorScheme.primary.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // DataTable
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              columnSpacing: 20,
                              horizontalMargin: 16,
                              columns: [
                                DataColumn(label: Text(l10n.name)),
                                DataColumn(label: Text(l10n.barcodeRequired)),
                                DataColumn(label: Text(l10n.category)),
                                DataColumn(
                                    label: Text(vatEnabled
                                        ? (vatIncludedInPrice
                                            ? l10n.priceVatIncluded
                                            : l10n.priceVatExcluded)
                                        : l10n.price)),
                                if (vatEnabled) ...[
                                  DataColumn(label: Text(l10n.beforeVat)),
                                  DataColumn(
                                      label:
                                          Text('${l10n.vat} ${l10n.amount}')),
                                  DataColumn(label: Text(l10n.afterVat)),
                                ],
                                DataColumn(label: Text(l10n.costRequired)),
                                DataColumn(label: Text(l10n.stock)),
                                DataColumn(label: Text(l10n.actions)),
                              ],
                              rows: products.map((product) {
                                // Calculate VAT breakdown based on inclusion mode
                                final double priceBeforeVat,
                                    vatAmount,
                                    priceAfterVat;
                                if (vatIncludedInPrice) {
                                  // VAT is included in the price
                                  priceAfterVat = product.price;
                                  vatAmount = priceAfterVat -
                                      (priceAfterVat /
                                          (1 + product.vatRate / 100));
                                  priceBeforeVat = priceAfterVat - vatAmount;
                                } else {
                                  // VAT is excluded from the price
                                  priceBeforeVat = product.price;
                                  vatAmount =
                                      product.price * (product.vatRate / 100);
                                  priceAfterVat = priceBeforeVat + vatAmount;
                                }

                                return DataRow(cells: [
                                  DataCell(Text(
                                    Localizations.localeOf(context)
                                                .languageCode ==
                                            'ar'
                                        ? (product.nameAr ?? product.name)
                                        : product.name,
                                  )),
                                  DataCell(Text(product.barcode)),
                                  DataCell(
                                      Text(_getCategoryName(product.category))),
                                  DataCell(Text(
                                      CurrencyHelper.formatCurrencySync(product.price))),
                                  if (vatEnabled) ...[
                                    DataCell(Text(
                                        CurrencyHelper.formatCurrencySync(priceBeforeVat))),
                                    DataCell(Text(
                                        CurrencyHelper.formatCurrencySync(vatAmount))),
                                    DataCell(Text(
                                        CurrencyHelper.formatCurrencySync(priceAfterVat))),
                                  ],
                                  DataCell(Text(
                                      CurrencyHelper.formatCurrencySync(product.cost))),
                                  DataCell(Text(product.quantity.toString())),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 20),
                                          onPressed: () =>
                                              showProductDialog(product),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 20, color: theme.colorScheme.error),
                                          onPressed: () =>
                                              _deleteProduct(context, product),
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
                  ],
                );
              } else {
                // Mobile: Card with ExpansionTile layout
                return Column(
                  children: [
                    // VAT Information Note (only shown when VAT is enabled)
                    if (vatEnabled)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        color: vatIncludedInPrice
                            ? Colors.green.shade50
                            : theme.colorScheme.primary.shade50,
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: vatIncludedInPrice
                                  ? Colors.green.shade700
                                  : theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vatIncludedInPrice
                                    ? l10n.pricesIncludeVatNote
                                    : l10n.pricesExcludeVatNote,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: vatIncludedInPrice
                                      ? Colors.green.shade900
                                      : theme.colorScheme.primary.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Product List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          // Calculate VAT breakdown based on inclusion mode
                          final double priceBeforeVat, vatAmount, priceAfterVat;
                          if (vatIncludedInPrice) {
                            // VAT is included in the price
                            priceAfterVat = product.price;
                            vatAmount = priceAfterVat -
                                (priceAfterVat / (1 + product.vatRate / 100));
                            priceBeforeVat = priceAfterVat - vatAmount;
                          } else {
                            // VAT is excluded from the price
                            priceBeforeVat = product.price;
                            vatAmount = product.price * (product.vatRate / 100);
                            priceAfterVat = priceBeforeVat + vatAmount;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: Text(
                                Localizations.localeOf(context).languageCode ==
                                        'ar'
                                    ? (product.nameAr ?? product.name)
                                    : product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${l10n.category}: ${_getCategoryName(product.category)}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    (vatEnabled
                                            ? (vatIncludedInPrice
                                                ? l10n.priceVatIncluded
                                                : l10n.priceVatExcluded)
                                            : l10n.price) +
                                        ': ${CurrencyHelper.formatCurrencySync(product.price)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: theme.colorScheme.primary),
                                    onPressed: () => showProductDialog(product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: theme.colorScheme.error),
                                    onPressed: () =>
                                        _deleteProduct(context, product),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow(l10n.barcodeRequired,
                                          product.barcode),
                                      _buildInfoRow(l10n.costRequired,
                                          CurrencyHelper.formatCurrencySync(product.cost)),
                                      _buildInfoRow(l10n.stock,
                                          '${product.quantity} ${l10n.units}'),
                                      if (vatEnabled) ...[
                                        const SizedBox(height: 8),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.vatBreakdown,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(l10n.beforeVat,
                                            CurrencyHelper.formatCurrencySync(priceBeforeVat)),
                                        _buildInfoRow(
                                            '${l10n.vat} ${l10n.amount}',
                                            CurrencyHelper.formatCurrencySync(vatAmount)),
                                        _buildInfoRow(l10n.afterVat,
                                            CurrencyHelper.formatCurrencySync(priceAfterVat)),
                                      ],
                                      if (product.description != null &&
                                          product.description!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.description,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.description!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final models.Product? product;

  const _ProductDialog({this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final AppDatabase _db = AppDatabase();
  late TextEditingController _nameController;
  late TextEditingController _nameArController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _descriptionArController;

  List<Category> _categories = [];
  String? _selectedCategoryId;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _nameArController = TextEditingController(text: widget.product?.nameAr);
    _barcodeController = TextEditingController(text: widget.product?.barcode);
    _selectedCategoryId = widget.product?.category;
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '0',
    );
    _costController = TextEditingController(
      text: widget.product?.cost.toString() ?? '0',
    );
    _quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '0',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description,
    );
    _descriptionArController = TextEditingController(
      text: widget.product?.descriptionAr,
    );
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _db.getAllCategories(activeOnly: true);
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToLoadCategories(e.toString()))),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Get the current VAT rate from app config
    final appConfig = context.read<AppConfigBloc>().state;
    final vatRate = appConfig.vatRate;

    if (widget.product == null) {
      context.read<ProductBloc>().add(AddProductEvent(
            name: _nameController.text,
            nameAr:
                _nameArController.text.isEmpty ? null : _nameArController.text,
            barcode: _barcodeController.text,
            category: _selectedCategoryId!,
            price: double.parse(_priceController.text),
            cost: double.parse(_costController.text),
            quantity: int.parse(_quantityController.text),
            vatRate: vatRate,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            descriptionAr: _descriptionArController.text.isEmpty
                ? null
                : _descriptionArController.text,
          ));
    } else {
      context.read<ProductBloc>().add(UpdateProductEvent(
            widget.product!.copyWith(
              name: _nameController.text,
              nameAr: _nameArController.text.isEmpty
                  ? null
                  : _nameArController.text,
              barcode: _barcodeController.text,
              category: _selectedCategoryId!,
              price: double.parse(_priceController.text),
              cost: double.parse(_costController.text),
              quantity: int.parse(_quantityController.text),
              vatRate: vatRate,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              descriptionAr: _descriptionArController.text.isEmpty
                  ? null
                  : _descriptionArController.text,
            ),
          ));
    }

    // Wait for operation to complete
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Build the form content separately for cleaner code
    final formContent = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.productNameRequired,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.inventory_2_outlined),
            ),
            validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Product Name (Arabic) Field
          TextFormField(
            controller: _nameArController,
            decoration: InputDecoration(
              labelText: '${l10n.productName} (عربي)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.translate),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Barcode Field
          TextFormField(
            controller: _barcodeController,
            decoration: InputDecoration(
              labelText: l10n.barcodeRequired,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.qr_code),
            ),
            validator: (v) => v?.isEmpty ?? true ? l10n.required : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Category Dropdown with Loading State
          _isLoadingCategories
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: l10n.categoryRequired,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  hint: Text(l10n.selectACategory),
                  isExpanded: true,
                  validator: (v) => v == null ? l10n.required : null,
                      items: _categories.map((category) {
                        final isArabic =
                            Localizations.localeOf(context).languageCode == 'ar';
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(isArabic
                              ? (category.nameAr ?? category.name)
                              : category.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
          const SizedBox(height: 16),

          // Price and Cost Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: l10n.priceRequired,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      double.tryParse(v ?? '') == null ? l10n.invalid : null,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    // Trigger rebuild to update VAT amount
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _costController,
                  decoration: InputDecoration(
                    labelText: l10n.costRequired,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      double.tryParse(v ?? '') == null ? l10n.invalid : null,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quantity and VAT Rate Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: l10n.quantityRequired,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.inventory),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      int.tryParse(v ?? '') == null ? l10n.invalid : null,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BlocBuilder<AppConfigBloc, AppConfigState>(
                  builder: (context, appConfig) {
                    final price = double.tryParse(_priceController.text) ?? 0.0;
                    final vatAmount = price * (appConfig.vatRate / 100);
                    return TextFormField(
                      key: ValueKey('${price}_${appConfig.vatRate}'),
                      initialValue: vatAmount.toStringAsFixed(2),
                      decoration: InputDecoration(
                        labelText: '${l10n.vat} Amount (${CurrencyHelper.getCurrencySymbolSync()})',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.account_balance_wallet),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        suffixIcon: Tooltip(
                          message: l10n.vatAmountCalculatedAutomatically(
                              appConfig.vatRate.toStringAsFixed(1)),
                          child: Icon(Icons.info_outline,
                              size: 18, color: theme.colorScheme.primary.shade600),
                        ),
                      ),
                      readOnly: true,
                      enabled: false,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description Field
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.description,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.description_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Description (Arabic) Field
          TextFormField(
            controller: _descriptionArController,
            decoration: InputDecoration(
              labelText: '${l10n.description} (عربي)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.translate),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );

    // Wrap in FormBottomSheet for consistent modal design
    return FormBottomSheet(
      title: widget.product == null ? l10n.add : l10n.editProduct,
      saveButtonText: l10n.save,
      cancelButtonText: l10n.cancel,
      onSave: _save,
      child: formContent,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    // Don't close the singleton database instance
    super.dispose();
  }
}
