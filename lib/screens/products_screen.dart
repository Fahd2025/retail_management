import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await context.read<ProductProvider>().loadProducts();
  }

  Future<void> _showProductDialog([Product? product]) async {
    await showDialog(
      context: context,
      builder: (context) => _ProductDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(),
            tooltip: 'Add Product',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
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
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No products found'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showProductDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            );
          }

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
                    DataCell(Text(product.category)),
                    DataCell(Text('SAR ${product.price.toStringAsFixed(2)}')),
                    DataCell(Text('SAR ${product.cost.toStringAsFixed(2)}')),
                    DataCell(Text(product.quantity.toString())),
                    DataCell(Text('${product.vatRate.toStringAsFixed(0)}%')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showProductDialog(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () async {
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
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final Product? product;

  const _ProductDialog({this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;
  late TextEditingController _vatRateController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _barcodeController = TextEditingController(text: widget.product?.barcode);
    _categoryController = TextEditingController(text: widget.product?.category);
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
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();
    bool success;

    if (widget.product == null) {
      success = await provider.addProduct(
        name: _nameController.text,
        barcode: _barcodeController.text,
        category: _categoryController.text,
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
          category: _categoryController.text,
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
                  decoration: const InputDecoration(labelText: 'Product Name *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price *'),
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v ?? '') == null
                            ? 'Invalid'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(labelText: 'Cost *'),
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v ?? '') == null
                            ? 'Invalid'
                            : null,
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
                        decoration: const InputDecoration(labelText: 'Quantity *'),
                        keyboardType: TextInputType.number,
                        validator: (v) => int.tryParse(v ?? '') == null
                            ? 'Invalid'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _vatRateController,
                        decoration: const InputDecoration(labelText: 'VAT % *'),
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v ?? '') == null
                            ? 'Invalid'
                            : null,
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
    _categoryController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _vatRateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
