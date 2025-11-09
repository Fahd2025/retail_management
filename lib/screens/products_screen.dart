import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart' as models;
import '../models/category.dart';
import '../database/drift_database.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final AppDatabase _db = AppDatabase();
  Map<String, String> _categoryNames = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
    await context.read<ProductProvider>().loadProducts();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _db.getAllCategories();
      if (mounted) {
        setState(() {
          _categoryNames = {
            for (var category in categories) category.id: category.name
          };
        });
      }
    } catch (e) {
      // Silently fail - will display IDs if categories can't be loaded
    }
  }

  String _getCategoryName(String categoryId) {
    return _categoryNames[categoryId] ?? categoryId;
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  Future<void> showProductDialog([Product? product]) async {
  Future<void> showProductDialog([models.Product? product]) async {
    await showDialog(
      context: context,
      builder: (context) => _ProductDialog(product: product),
    );
  }

  Future<void> _deleteProduct(
    BuildContext context,
    ProductProvider provider,
    models.Product product,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await provider.deleteProduct(product.id);
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
    return Scaffold(
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No products found'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => showProductDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;

              if (isDesktop) {
                // Desktop/Tablet: DataTable layout
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Barcode')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Cost')),
                        DataColumn(label: Text('Stock')),
                        DataColumn(label: Text('VAT %')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: provider.products.map((product) {
                        return DataRow(cells: [
                          DataCell(Text(product.name)),
                          DataCell(Text(product.barcode)),
                          DataCell(Text(_getCategoryName(product.category))),
                          DataCell(
                              Text('SAR ${product.price.toStringAsFixed(2)}')),
                          DataCell(
                              Text('SAR ${product.cost.toStringAsFixed(2)}')),
                          DataCell(Text(product.quantity.toString())),
                          DataCell(
                              Text('${product.vatRate.toStringAsFixed(0)}%')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => showProductDialog(product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  onPressed: () => _deleteProduct(
                                      context, provider, product),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              } else {
                // Mobile: Card layout
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () =>
                                          showProductDialog(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteProduct(
                                          context, provider, product),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                                'Category', _getCategoryName(product.category)),
                            _buildInfoRow('Barcode', product.barcode),
                            _buildInfoRow('Price',
                                'SAR ${product.price.toStringAsFixed(2)}'),
                            _buildInfoRow('Cost',
                                'SAR ${product.cost.toStringAsFixed(2)}'),
                            _buildInfoRow('Stock', '${product.quantity} units'),
                            _buildInfoRow('VAT',
                                '${product.vatRate.toStringAsFixed(0)}%'),
                            if (product.description != null &&
                                product.description!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                product.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
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
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;
  late TextEditingController _vatRateController;
  late TextEditingController _descriptionController;

  List<Category> _categories = [];
  String? _selectedCategoryId;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
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
    _vatRateController = TextEditingController(
      text: widget.product?.vatRate.toString() ?? '15',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();
    bool success;

    if (widget.product == null) {
      success = await provider.addProduct(
        name: _nameController.text,
        barcode: _barcodeController.text,
        category: _selectedCategoryId!,
        price: double.parse(_priceController.text),
        cost: double.parse(_costController.text),
        quantity: int.parse(_quantityController.text),
        vatRate: double.parse(_vatRateController.text),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );
    } else {
      success = await provider.updateProduct(
        widget.product!.copyWith(
          name: _nameController.text,
          barcode: _barcodeController.text,
          category: _selectedCategoryId!,
          price: double.parse(_priceController.text),
          cost: double.parse(_costController.text),
          quantity: int.parse(_quantityController.text),
          vatRate: double.parse(_vatRateController.text),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
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
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Product Name *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _isLoadingCategories
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration:
                            const InputDecoration(labelText: 'Category *'),
                        hint: const Text('Select a category'),
                        isExpanded: true,
                        validator: (v) => v == null ? 'Required' : null,
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                      ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price *'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            double.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(labelText: 'Cost *'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            double.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration:
                            const InputDecoration(labelText: 'Quantity *'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            int.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _vatRateController,
                        decoration: const InputDecoration(labelText: 'VAT % *'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            double.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _vatRateController.dispose();
    _descriptionController.dispose();
    _db.close();
    super.dispose();
  }
}
