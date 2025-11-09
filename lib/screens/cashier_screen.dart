import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/customer_provider.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../services/invoice_service.dart';
import '../database/drift_database.dart' hide Product, Customer, Sale, SaleItem;
import '../models/company_info.dart';
import '../models/category.dart';
import 'package:uuid/uuid.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen>
    with TickerProviderStateMixin {
  final AppDatabase _db = AppDatabase();
  String? _selectedCategory;
  List<Product> _displayedProducts = [];
  Map<String, String> _categoryNames = {}; // Map category ID to name
  final _barcodeController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _cartAnimationController;
  late Animation<Offset> _cartSlideAnimation;
  Customer? _selectedCustomer;
  bool _isCartVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cartSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start off-screen to the right
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _cartAnimationController,
      curve: Curves.easeInOut,
    ));
    _loadData();
  }

  // Public method to toggle cart visibility (can be called from parent)
  void toggleCart() {
    setState(() {
      _isCartVisible = !_isCartVisible;
      if (_isCartVisible) {
        _cartAnimationController.forward();
      } else {
        _cartAnimationController.reverse();
      }
    });
  }

  Future<void> _loadData() async {
    final productProvider = context.read<ProductProvider>();
    await productProvider.loadProducts(activeOnly: true);
    await productProvider.loadCategories();
    await context.read<CustomerProvider>().loadCustomers(activeOnly: true);

    // Load category names
    try {
      final categories = await _db.getAllCategories(activeOnly: true);
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

    if (mounted && productProvider.categories.isNotEmpty) {
      setState(() {
        _selectedCategory = productProvider.categories.first;
      });
      _loadProductsByCategory();
    }
  }

  Future<void> _loadProductsByCategory() async {
    if (_selectedCategory == null) return;

    final products = await context
        .read<ProductProvider>()
        .getProductsByCategory(_selectedCategory!);

    setState(() {
      _displayedProducts = products;
    });

    _animationController.forward(from: 0);
  }

  String _getCategoryName(String categoryId) {
    return _categoryNames[categoryId] ?? categoryId;
  }

  void _addProductToCart(Product product) {
    context.read<SaleProvider>().addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    final product =
        await context.read<ProductProvider>().getProductByBarcode(barcode);

    if (product != null && mounted) {
      _addProductToCart(product);
      _barcodeController.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkout() async {
    final saleProvider = context.read<SaleProvider>();

    if (saleProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    // Show payment dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _PaymentDialog(
        total: saleProvider.cartTotal,
        customer: _selectedCustomer,
      ),
    );

    if (result != null && mounted) {
      final authProvider = context.read<AuthProvider>();
      final sale = await saleProvider.completeSale(
        cashierId: authProvider.currentUser!.id,
        customerId: result['customerId'],
        paidAmount: result['paidAmount'],
        paymentMethod: result['paymentMethod'],
      );

      if (sale != null && mounted) {
        setState(() => _selectedCustomer = null);

        // Show print dialog
        final shouldPrint = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sale Completed'),
            content: const Text('Would you like to print the invoice?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Print'),
              ),
            ],
          ),
        );

        if (shouldPrint == true && mounted) {
          await _printInvoice(sale);
        }
      }
    }
  }

  Future<void> _printInvoice(Sale sale) async {
    try {
      final db = AppDatabase();
      final companyInfo = await db.getCompanyInfo();

      if (companyInfo == null) {
        // Create default company info
        const uuid = Uuid();
        final defaultCompanyInfo = CompanyInfo(
          id: uuid.v4(),
          name: 'Retail Store',
          nameArabic: 'متجر التجزئة',
          address: '123 Main Street, City, Country',
          addressArabic: '١٢٣ الشارع الرئيسي، المدينة، الدولة',
          phone: '+966 12 345 6789',
          vatNumber: '300000000000003',
          crnNumber: '1010000000',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await db.createOrUpdateCompanyInfo(defaultCompanyInfo);
      }

      Customer? customer;
      if (sale.customerId != null) {
        customer = await db.getCustomer(sale.customerId!);
      }

      final invoiceService = InvoiceService();
      await invoiceService.printInvoice(
        sale: sale,
        companyInfo: companyInfo ?? await db.getCompanyInfo() as CompanyInfo,
        customer: customer,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _animationController.dispose();
    _cartAnimationController.dispose();
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categories;
    final saleProvider = context.watch<SaleProvider>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;

          return Row(
            children: [
              // Products section - always visible on tablet, conditional on mobile
              if (isTablet || !_isCartVisible)
                Expanded(
                  flex: isTablet && _isCartVisible ? 2 : 1,
                  child: Column(
                    children: [
                      // Barcode scanner
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: TextField(
                          controller: _barcodeController,
                          decoration: InputDecoration(
                            hintText: 'Scan or enter barcode...',
                            prefixIcon: const Icon(Icons.qr_code_scanner),
                            fillColor: Colors.grey.shade50,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onSubmitted: (_) => _scanBarcode(),
                        ),
                      ),
                      // Category tabs
                      Container(
                        height: 60,
                        color: Colors.white,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = category == _selectedCategory;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: FilterChip(
                                label: Text(_getCategoryName(category)),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => _selectedCategory = category);
                                  _loadProductsByCategory();
                                },
                                selectedColor: Colors.blue,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Products grid
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _displayedProducts.length,
                              itemBuilder: (context, index) {
                                final product = _displayedProducts[index];

                                return FadeTransition(
                                  opacity: _animationController,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.8, end: 1.0)
                                        .animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: Interval(
                                          index * 0.1,
                                          1.0,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                    ),
                                    child: _ProductCard(
                                      product: product,
                                      onTap: () => _addProductToCart(product),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // Cart section - conditionally visible based on _isCartVisible with slide animation
              if (_isCartVisible)
                SlideTransition(
                  position: _cartSlideAnimation,
                  child: Container(
                    width: isTablet ? 400 : constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                    children: [
                      // Cart header
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.blue.shade50,
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_cart),
                            const SizedBox(width: 8),
                            const Text(
                              'Cart',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${saleProvider.cartItemCount} items',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),

                      // Customer selection
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: _CustomerSelector(
                          selectedCustomer: _selectedCustomer,
                          onCustomerSelected: (customer) {
                            setState(() => _selectedCustomer = customer);
                          },
                        ),
                      ),

                      // Cart items
                      Expanded(
                        child: saleProvider.cartItems.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Cart is empty',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: saleProvider.cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = saleProvider.cartItems[index];
                                  return _CartItem(item: item);
                                },
                              ),
                      ),

                      // Cart summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Column(
                          children: [
                            _SummaryRow('Subtotal:', saleProvider.cartSubtotal),
                            const SizedBox(height: 8),
                            _SummaryRow('VAT:', saleProvider.cartVatAmount),
                            const Divider(),
                            _SummaryRow(
                              'Total:',
                              saleProvider.cartTotal,
                              isBold: true,
                              fontSize: 20,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: saleProvider.cartItems.isEmpty
                                        ? null
                                        : () => saleProvider.clearCart(),
                                    child: const Text('Clear'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: saleProvider.cartItems.isEmpty
                                        ? null
                                        : _checkout,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Checkout'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _animationController.dispose();
    _cartAnimationController.dispose();
    super.dispose();
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.blue.shade50,
                              child: Icon(
                                Icons.inventory_2,
                                size: 64,
                                color: Colors.blue.shade200,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.blue.shade50,
                          child: Icon(
                            Icons.inventory_2,
                            size: 64,
                            color: Colors.blue.shade200,
                          ),
                        ),
                  // Stock badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.quantity > 10
                            ? Colors.green
                            : product.quantity > 0
                                ? Colors.orange
                                : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${product.quantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product info
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Price with emphasis
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SAR ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final SaleItem item;

  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.read<SaleProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'SAR ${item.unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    saleProvider.updateCartItemQuantity(
                      item.id,
                      item.quantity - 1,
                    );
                  },
                  iconSize: 20,
                ),
                Text(
                  item.quantity.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    saleProvider.updateCartItemQuantity(
                      item.id,
                      item.quantity + 1,
                    );
                  },
                  iconSize: 20,
                ),
              ],
            ),
            SizedBox(
              width: 80,
              child: Text(
                'SAR ${item.total.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => saleProvider.removeFromCart(item.id),
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  final double fontSize;

  const _SummaryRow(
    this.label,
    this.amount, {
    this.isBold = false,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        Text(
          'SAR ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

class _CustomerSelector extends StatelessWidget {
  final Customer? selectedCustomer;
  final Function(Customer?) onCustomerSelected;

  const _CustomerSelector({
    required this.selectedCustomer,
    required this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(Icons.person, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<Customer?>(
                value: selectedCustomer,
                hint: const Text('Walk-in Customer'),
                isExpanded: true,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<Customer?>(
                    value: null,
                    child: Text('Walk-in Customer'),
                  ),
                  ...customers.map((customer) {
                    return DropdownMenuItem<Customer>(
                      value: customer,
                      child: Text(customer.name),
                    );
                  }).toList(),
                ],
                onChanged: onCustomerSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final double total;
  final Customer? customer;

  const _PaymentDialog({
    required this.total,
    this.customer,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _paidController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  double _change = 0;

  @override
  void initState() {
    super.initState();
    _paidController.text = widget.total.toStringAsFixed(2);
    _paidController.addListener(_calculateChange);
  }

  void _calculateChange() {
    final paid = double.tryParse(_paidController.text) ?? 0;
    setState(() {
      _change = paid - widget.total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total: SAR ${widget.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SegmentedButton<PaymentMethod>(
              segments: const [
                ButtonSegment(
                  value: PaymentMethod.cash,
                  label: Text('Cash'),
                  icon: Icon(Icons.money),
                ),
                ButtonSegment(
                  value: PaymentMethod.card,
                  label: Text('Card'),
                  icon: Icon(Icons.credit_card),
                ),
                ButtonSegment(
                  value: PaymentMethod.transfer,
                  label: Text('Transfer'),
                  icon: Icon(Icons.account_balance),
                ),
              ],
              selected: {_paymentMethod},
              onSelectionChanged: (Set<PaymentMethod> newSelection) {
                setState(() {
                  _paymentMethod = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _paidController,
              decoration: const InputDecoration(
                labelText: 'Amount Paid',
                prefixText: 'SAR ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_change >= 0)
              Text(
                'Change: SAR ${_change.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              )
            else
              Text(
                'Insufficient payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _change >= 0
              ? () {
                  Navigator.pop(context, {
                    'customerId': widget.customer?.id,
                    'paidAmount': double.parse(_paidController.text),
                    'paymentMethod': _paymentMethod,
                  });
                }
              : null,
          child: const Text('Complete'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }
}
