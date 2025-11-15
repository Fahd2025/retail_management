import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui.dart';
import 'package:retail_management/blocs/app_config/app_config_state.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../blocs/sale/sale_bloc.dart';
import '../blocs/sale/sale_event.dart';
import '../blocs/sale/sale_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/customer/customer_bloc.dart';
import '../blocs/customer/customer_event.dart';
import '../blocs/customer/customer_state.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../models/product.dart';
import '../widgets/form_bottom_sheet.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../services/invoice_service.dart';
import '../database/drift_database.dart' hide Product, Customer, Sale, SaleItem;
import '../models/company_info.dart';
import '../utils/currency_helper.dart';
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
    context.read<ProductBloc>().add(const LoadProductsEvent(activeOnly: true));
    context.read<ProductBloc>().add(const LoadCategoriesEvent());
    context
        .read<CustomerBloc>()
        .add(const LoadCustomersEvent(activeOnly: true));

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

    // Wait for bloc state and set selected category
    final productBloc = context.read<ProductBloc>();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted && productBloc.state is ProductLoaded) {
      final state = productBloc.state as ProductLoaded;
      if (state.categories.isNotEmpty) {
        setState(() {
          _selectedCategory = state.categories.first;
        });
        _loadProductsByCategory();
      }
    }
  }

  Future<void> _loadProductsByCategory() async {
    if (_selectedCategory == null) return;

    context
        .read<ProductBloc>()
        .add(GetProductsByCategoryEvent(_selectedCategory!));

    // Wait for state update and get products
    await Future.delayed(const Duration(milliseconds: 50));
    final productBloc = context.read<ProductBloc>();
    if (productBloc.state is ProductLoaded) {
      final state = productBloc.state as ProductLoaded;
      final products =
          state.products.where((p) => p.category == _selectedCategory).toList();

      if (mounted) {
        setState(() {
          _displayedProducts = products;
        });
        _animationController.forward(from: 0);
      }
    }
  }

  String _getCategoryName(String categoryId) {
    return _categoryNames[categoryId] ?? categoryId;
  }

  void _addProductToCart(Product product) {
    final vatIncludedInPrice =
        context.read<AppConfigBloc>().state.vatIncludedInPrice;

    // Determine product name based on locale
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final productName =
        isArabic ? (product.nameAr ?? product.name) : product.name;

    context.read<SaleBloc>().add(AddToCartEvent(
          product,
          vatIncludedInPrice: vatIncludedInPrice,
          productName: productName,
        ));

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.productAddedToCart(productName)),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    context.read<ProductBloc>().add(GetProductByBarcodeEvent(barcode));

    // Wait for state update
    await Future.delayed(const Duration(milliseconds: 50));
    final productBloc = context.read<ProductBloc>();

    if (productBloc.state is ProductLoaded) {
      final state = productBloc.state as ProductLoaded;
      final product = state.products.firstWhere(
        (p) => p.barcode == barcode,
        orElse: () => throw Exception('Product not found'),
      );

      if (mounted) {
        _addProductToCart(product);
        _barcodeController.clear();
      }
    } else if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productNotFound),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkout() async {
    final saleBloc = context.read<SaleBloc>();
    final saleState = saleBloc.state;

    List<SaleItem> cartItems = [];
    double cartTotal = 0;

    if (saleState is SaleLoaded) {
      cartItems = saleState.cartItems;
      cartTotal = saleState.cartTotal;
    } else if (saleState is SaleError) {
      cartItems = saleState.cartItems;
      cartTotal = saleState.cartTotal;
    } else if (saleState is SaleOperationSuccess) {
      cartItems = saleState.cartItems;
      cartTotal = saleState.cartTotal;
    }

    if (cartItems.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cartIsEmpty)),
      );
      return;
    }

    // Show payment dialog
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentDialog(
        total: cartTotal,
        customer: _selectedCustomer,
      ),
    );

    if (result != null && mounted) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;

      if (authState is Authenticated) {
        context.read<SaleBloc>().add(CompleteSaleEvent(
              cashierId: authState.user.id,
              customerId: result['customerId'],
              paidAmount: result['paidAmount'],
              paymentMethod: result['paymentMethod'],
            ));

        // Wait for sale completion
        await Future.delayed(const Duration(milliseconds: 200));
        final newSaleState = saleBloc.state;

        Sale? sale;
        if (newSaleState is SaleCompleted) {
          sale = newSaleState.completedSale;
        }

        if (sale != null && mounted) {
          setState(() => _selectedCustomer = null);

          // Show print dialog
          final shouldPrint = await showDialog<bool>(
            context: context,
            builder: (context) {
              final liquidTheme = LiquidTheme.of(context);
              return LiquidDialog(
                title: AppLocalizations.of(context)!.saleCompleted,
                content: Text(
                  AppLocalizations.of(context)!.printInvoiceQuestion,
                  style: TextStyle(color: liquidTheme.textColor),
                ),
                actions: [
                  LiquidButton(
                    onTap: () => Navigator.pop(context, false),
                    type: LiquidButtonType.text,
                    child: Text(AppLocalizations.of(context)!.no),
                  ),
                  LiquidButton(
                    onTap: () => Navigator.pop(context, true),
                    type: LiquidButtonType.filled,
                    child: Text(
                      AppLocalizations.of(context)!.printInvoice,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );

          if (shouldPrint == true && mounted) {
            await _printInvoice(sale);
          }

          toggleCart();
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

      // Get current print format configuration from AppConfig
      final appConfigState = context.read<AppConfigBloc>().state;
      final printConfig = appConfigState.printFormatConfig;

      // Print directly using the configured settings from settings page
      final invoiceService = InvoiceService();
      await invoiceService.printInvoice(
        sale: sale,
        companyInfo: companyInfo ?? await db.getCompanyInfo() as CompanyInfo,
        customer: customer,
        config: printConfig,
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.printError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final liquidTheme = LiquidTheme.of(context);

    return BlocBuilder<ProductBloc, ProductState>(
        builder: (context, productState) {
      List<String> categories = [];
      if (productState is ProductLoaded) {
        categories = productState.categories;
      } else if (productState is ProductError) {
        categories = productState.categories;
      } else if (productState is ProductOperationSuccess) {
        categories = productState.categories;
      }

      return BlocBuilder<SaleBloc, SaleState>(
        builder: (context, saleState) {
          List<SaleItem> cartItems = [];
          double cartSubtotal = 0;
          double cartVatAmount = 0;
          double cartTotal = 0;
          int cartItemCount = 0;

          if (saleState is SaleLoaded) {
            cartItems = saleState.cartItems;
            cartSubtotal = saleState.cartSubtotal;
            cartVatAmount = saleState.cartVatAmount;
            cartTotal = saleState.cartTotal;
            cartItemCount = saleState.cartItemCount;
          } else if (saleState is SaleError) {
            cartItems = saleState.cartItems;
            cartSubtotal = saleState.cartSubtotal;
            cartVatAmount = saleState.cartVatAmount;
            cartTotal = saleState.cartTotal;
            cartItemCount = saleState.cartItemCount;
          } else if (saleState is SaleOperationSuccess) {
            cartItems = saleState.cartItems;
            cartSubtotal = saleState.cartSubtotal;
            cartVatAmount = saleState.cartVatAmount;
            cartTotal = saleState.cartTotal;
            cartItemCount = saleState.cartItemCount;
          }

          final theme = Theme.of(context);
          return LiquidScaffold(
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
                            LiquidContainer(
                              padding: const EdgeInsets.all(16),
                              blur: 15,
                              opacity: 0.1,
                              child: LiquidTextField(
                                controller: _barcodeController,
                                hintText: l10n.scanOrEnterBarcode,
                                prefixIcon: const Icon(Icons.qr_code_scanner),
                                onSubmitted: (_) => _scanBarcode(),
                              ),
                            ),

                            // VAT Information Note (only shown when VAT is enabled)
                            BlocBuilder<AppConfigBloc, AppConfigState>(
                              builder: (context, configState) {
                                if (!configState.vatEnabled) {
                                  return const SizedBox.shrink();
                                }

                                return LiquidBanner(
                                  type: configState.vatIncludedInPrice
                                      ? LiquidBannerType.success
                                      : LiquidBannerType.info,
                                  icon: Icons.info_outline,
                                  title: configState.vatIncludedInPrice
                                      ? l10n.vatIncludedInPriceNote(configState
                                          .vatRate
                                          .toStringAsFixed(1))
                                      : l10n.vatExcludedFromPriceNote(
                                          configState.vatRate
                                              .toStringAsFixed(1)),
                                );
                              },
                            ),

                            // Category tabs
                            LiquidContainer(
                              height: 60,
                              blur: 10,
                              opacity: 0.08,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(8),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  final isSelected =
                                      category == _selectedCategory;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: LiquidButton(
                                      onTap: () {
                                        setState(
                                            () => _selectedCategory = category);
                                        _loadProductsByCategory();
                                      },
                                      type: isSelected
                                          ? LiquidButtonType.filled
                                          : LiquidButtonType.outlined,
                                      backgroundColor: isSelected
                                          ? theme.colorScheme.primary
                                          : null,
                                      child: Text(
                                        _getCategoryName(category),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : liquidTheme.textColor,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
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
                                          scale: Tween<double>(
                                                  begin: 0.8, end: 1.0)
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
                                            onTap: () =>
                                                _addProductToCart(product),
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
                        child: LiquidContainer(
                          width: isTablet ? 400 : constraints.maxWidth,
                          blur: 20,
                          opacity: 0.15,
                          borderRadius: 0,
                          child: Column(
                            children: [
                              // Cart header
                              LiquidContainer(
                                padding: const EdgeInsets.all(16),
                                blur: 15,
                                opacity: 0.2,
                                borderRadius: 0,
                                child: Row(
                                  children: [
                                    Icon(Icons.shopping_cart,
                                        color: liquidTheme.textColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.cart,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: liquidTheme.textColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      l10n.cartItems(cartItemCount),
                                      style: TextStyle(
                                        color: liquidTheme.textColor
                                            .withValues(alpha: 0.6),
                                      ),
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
                                    setState(
                                        () => _selectedCustomer = customer);
                                  },
                                ),
                              ),

                              // Cart items
                              Expanded(
                                child: cartItems.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            LiquidContainer(
                                              width: 100,
                                              height: 100,
                                              borderRadius: 50,
                                              blur: 15,
                                              opacity: 0.15,
                                              child: Icon(
                                                Icons.shopping_cart_outlined,
                                                size: 64,
                                                color: liquidTheme.textColor
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              l10n.cartIsEmpty,
                                              style: TextStyle(
                                                color: liquidTheme.textColor
                                                    .withValues(alpha: 0.6),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: cartItems.length,
                                        itemBuilder: (context, index) {
                                          final item = cartItems[index];
                                          return _CartItem(item: item);
                                        },
                                      ),
                              ),

                              // Cart summary
                              LiquidContainer(
                                padding: const EdgeInsets.all(16),
                                blur: 15,
                                opacity: 0.2,
                                borderRadius: 0,
                                child:
                                    BlocBuilder<AppConfigBloc, AppConfigState>(
                                  builder: (context, configState) {
                                    return Column(
                                      children: [
                                        if (configState.vatEnabled) ...[
                                          _SummaryRow(
                                              l10n.subtotalLabel, cartSubtotal),
                                          const SizedBox(height: 8),
                                          _SummaryRow(
                                              l10n.vatLabel, cartVatAmount),
                                          Divider(
                                              color: liquidTheme.textColor
                                                  .withValues(alpha: 0.3)),
                                        ],
                                        _SummaryRow(
                                          l10n.totalLabelColon,
                                          cartTotal,
                                          isBold: true,
                                          fontSize: 20,
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: LiquidButton(
                                                onTap: cartItems.isEmpty
                                                    ? null
                                                    : () => context
                                                        .read<SaleBloc>()
                                                        .add(
                                                            const ClearCartEvent()),
                                                type: LiquidButtonType.outlined,
                                                child: Text(l10n.clear),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 2,
                                              child: LiquidButton(
                                                onTap: cartItems.isEmpty
                                                    ? null
                                                    : _checkout,
                                                type: LiquidButtonType.filled,
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                                child: Text(
                                                  l10n.checkout,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
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
        },
      );
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _animationController.dispose();
    _cartAnimationController.dispose();
    // Don't close the singleton database instance
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
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    return LiquidCard(
      elevation: 4,
      blur: 15,
      opacity: 0.15,
      borderRadius: 16,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: product.imageUrl != null &&
                          product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return LiquidContainer(
                              blur: 10,
                              opacity: 0.1,
                              borderRadius: 0,
                              child: Icon(
                                Icons.inventory_2,
                                size: 64,
                                color: liquidTheme.textColor
                                    .withValues(alpha: 0.3),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: LiquidLoader(size: 40),
                            );
                          },
                        )
                      : LiquidContainer(
                          blur: 10,
                          opacity: 0.1,
                          borderRadius: 0,
                          child: Icon(
                            Icons.inventory_2,
                            size: 64,
                            color: liquidTheme.textColor.withValues(alpha: 0.3),
                          ),
                        ),
                ),
                // Stock badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: LiquidContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    blur: 10,
                    opacity: 0.9,
                    borderRadius: 12,
                    color: product.quantity > 10
                        ? Colors.green
                        : product.quantity > 0
                            ? Colors.orange
                            : Colors.red,
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? (product.nameAr ?? product.name)
                      : product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: liquidTheme.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Price with emphasis
                LiquidContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  blur: 10,
                  opacity: 0.15,
                  borderRadius: 6,
                  child: Text(
                    CurrencyHelper.formatCurrencySync(product.price),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
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
    );
  }
}

class _CartItem extends StatelessWidget {
  final SaleItem item;

  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final liquidTheme = LiquidTheme.of(context);

    return LiquidCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      blur: 12,
      opacity: 0.12,
      borderRadius: 12,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: liquidTheme.textColor,
                  ),
                ),
                Text(
                  CurrencyHelper.formatCurrencySync(item.unitPrice),
                  style: TextStyle(
                    color: liquidTheme.textColor.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              LiquidButton(
                type: LiquidButtonType.icon,
                size: LiquidButtonSize.small,
                onTap: () {
                  final vatIncludedInPrice =
                      context.read<AppConfigBloc>().state.vatIncludedInPrice;
                  context.read<SaleBloc>().add(
                        UpdateCartItemQuantityEvent(item.id, item.quantity - 1,
                            vatIncludedInPrice: vatIncludedInPrice),
                      );
                },
                child: const Icon(Icons.remove, size: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  item.quantity.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: liquidTheme.textColor,
                  ),
                ),
              ),
              LiquidButton(
                type: LiquidButtonType.icon,
                size: LiquidButtonSize.small,
                onTap: () {
                  final vatIncludedInPrice =
                      context.read<AppConfigBloc>().state.vatIncludedInPrice;
                  context.read<SaleBloc>().add(
                        UpdateCartItemQuantityEvent(item.id, item.quantity + 1,
                            vatIncludedInPrice: vatIncludedInPrice),
                      );
                },
                child: const Icon(Icons.add, size: 20),
              ),
            ],
          ),
          SizedBox(
            width: 80,
            child: Text(
              CurrencyHelper.formatCurrencySync(item.total),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: liquidTheme.textColor,
              ),
            ),
          ),
          LiquidButton(
            type: LiquidButtonType.icon,
            size: LiquidButtonSize.small,
            onTap: () =>
                context.read<SaleBloc>().add(RemoveFromCartEvent(item.id)),
            child: const Icon(Icons.delete, color: Colors.red, size: 20),
          ),
        ],
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
    final liquidTheme = LiquidTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: liquidTheme.textColor,
          ),
        ),
        Text(
          CurrencyHelper.formatCurrencySync(amount),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: liquidTheme.textColor,
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
    final liquidTheme = LiquidTheme.of(context);

    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, customerState) {
        List<Customer> customers = [];
        if (customerState is CustomerLoaded) {
          customers = customerState.customers;
        } else if (customerState is CustomerError) {
          customers = customerState.customers;
        } else if (customerState is CustomerOperationSuccess) {
          customers = customerState.customers;
        }

        return LiquidCard(
          elevation: 2,
          blur: 12,
          opacity: 0.12,
          borderRadius: 12,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.person, size: 20, color: liquidTheme.textColor),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<Customer?>(
                  value: selectedCustomer,
                  hint: Text(
                    AppLocalizations.of(context)!.walkInCustomer,
                    style: TextStyle(color: liquidTheme.textColor),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: liquidTheme.surfaceColor,
                  style: TextStyle(color: liquidTheme.textColor),
                  items: [
                    DropdownMenuItem<Customer?>(
                      value: null,
                      child: Text(
                        AppLocalizations.of(context)!.walkInCustomer,
                        style: TextStyle(color: liquidTheme.textColor),
                      ),
                    ),
                    ...customers.map((customer) {
                      return DropdownMenuItem<Customer>(
                        value: customer,
                        child: Text(
                          customer.name,
                          style: TextStyle(color: liquidTheme.textColor),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: onCustomerSelected,
                ),
              ),
            ],
          ),
        );
      },
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    // Build the payment content
    final paymentContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Total Amount Display - Prominent
        LiquidContainer(
          padding: const EdgeInsets.all(20),
          blur: 15,
          opacity: 0.2,
          borderRadius: 12,
          child: Column(
            children: [
              Text(
                l10n.total,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: liquidTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyHelper.formatCurrencySync(widget.total),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Payment Method Selection
        Text(
          l10n.paymentMethod,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: liquidTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<PaymentMethod>(
          segments: [
            ButtonSegment(
              value: PaymentMethod.cash,
              label: Text(l10n.cashPayment),
              icon: const Icon(Icons.money),
            ),
            ButtonSegment(
              value: PaymentMethod.card,
              label: Text(l10n.cardPayment),
              icon: const Icon(Icons.credit_card),
            ),
            ButtonSegment(
              value: PaymentMethod.transfer,
              label: Text(l10n.transferPayment),
              icon: const Icon(Icons.account_balance),
            ),
          ],
          selected: {_paymentMethod},
          onSelectionChanged: (Set<PaymentMethod> newSelection) {
            setState(() {
              _paymentMethod = newSelection.first;
            });
          },
        ),
        const SizedBox(height: 24),

        // Amount Paid Input
        LiquidTextField(
          controller: _paidController,
          labelText: l10n.amountPaid,
          prefixText: '${CurrencyHelper.getCurrencySymbolSync()} ',
          prefixIcon: const Icon(Icons.payments_outlined),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        const SizedBox(height: 24),

        // Change Display - Dynamic
        LiquidContainer(
          padding: const EdgeInsets.all(16),
          blur: 15,
          opacity: 0.2,
          borderRadius: 8,
          color: _change >= 0
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.errorContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _change >= 0 ? l10n.change : l10n.insufficientPayment,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _change >= 0
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onErrorContainer,
                ),
              ),
              if (_change >= 0)
                Text(
                  CurrencyHelper.formatCurrencySync(_change),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    // Wrap in FormBottomSheet with conditional save button
    return FormBottomSheet(
      title: l10n.payment,
      saveButtonText: l10n.complete,
      cancelButtonText: l10n.cancel,
      isSaveDisabled: _change < 0, // Disable if insufficient payment
      onSave: () {
        Navigator.pop(context, {
          'customerId': widget.customer?.id,
          'paidAmount': double.parse(_paidController.text),
          'paymentMethod': _paymentMethod,
        });
      },
      maxHeightFraction: 0.85,
      child: paymentContent,
    );
  }

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }
}
