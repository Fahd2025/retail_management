import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/customer/customer_bloc.dart';
import '../blocs/customer/customer_event.dart';
import '../blocs/sale/sale_bloc.dart';
import '../blocs/sale/sale_event.dart';
import '../blocs/sale/sale_state.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/dashboard/dashboard_event.dart';
import '../models/user.dart';
import '../models/company_info.dart';
import '../database/drift_database.dart';
import '../services/image_service.dart';
import 'cashier_screen.dart';
import 'products_screen.dart';
import 'categories_screen.dart';
import 'customers_screen.dart';
import 'sales_screen.dart';
import 'users_screen.dart';
import 'settings_screen.dart';
import 'analytics_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  CompanyInfo? _companyInfo;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // GlobalKeys for screen access
  final GlobalKey<State<CashierScreen>> _cashierKey =
      GlobalKey<State<CashierScreen>>();
  final GlobalKey<State<ProductsScreen>> _productsKey =
      GlobalKey<State<ProductsScreen>>();
  final GlobalKey<State<CategoriesScreen>> _categoriesKey =
      GlobalKey<State<CategoriesScreen>>();
  final GlobalKey<State<CustomersScreen>> _customersKey =
      GlobalKey<State<CustomersScreen>>();
  final GlobalKey<State<UsersScreen>> _usersKey =
      GlobalKey<State<UsersScreen>>();

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();

    // Initialize animations for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final db = AppDatabase();
      final info = await db.getCompanyInfo();
      if (mounted) {
        setState(() => _companyInfo = info);
      }
    } catch (e) {
      // Handle error silently or show a snackbar if needed
    }
  }

  List<Widget> _getScreens(UserRole role) {
    if (role == UserRole.admin) {
      return [
        const AnalyticsDashboardScreen(),
        CashierScreen(key: _cashierKey),
        ProductsScreen(key: _productsKey),
        CategoriesScreen(key: _categoriesKey),
        CustomersScreen(key: _customersKey),
        const SalesScreen(),
        UsersScreen(key: _usersKey),
        const SettingsScreen(),
      ];
    } else {
      // Cashier only has access to cashier screen and sales
      return [
        CashierScreen(key: _cashierKey),
        const SalesScreen(),
      ];
    }
  }

  List<Map<String, dynamic>> _getNavigationItems(
      UserRole role, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (role == UserRole.admin) {
      return [
        {'icon': Icons.dashboard, 'label': l10n.dashboard},
        {'icon': Icons.point_of_sale, 'label': l10n.cashier},
        {'icon': Icons.inventory, 'label': l10n.products},
        {'icon': Icons.category, 'label': l10n.categories},
        {'icon': Icons.people, 'label': l10n.customers},
        {'icon': Icons.receipt_long, 'label': l10n.sales},
        {'icon': Icons.person, 'label': l10n.users},
        {'icon': Icons.settings, 'label': l10n.settings},
      ];
    } else {
      return [
        {'icon': Icons.point_of_sale, 'label': l10n.cashier},
        {'icon': Icons.receipt_long, 'label': l10n.sales},
      ];
    }
  }

  PreferredSizeWidget _buildAppBar(
      List<Map<String, dynamic>> navItems, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final label = navItems[_selectedIndex]['label'] as String;

    // Check if it's the Analytics Dashboard
    if (label == l10n.dashboard) {
      return AppBar(
        title: Text(l10n.appTitle),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
        actions: [
          Tooltip(
            message: l10n.refreshDashboard,
            child: IconButton(
              onPressed: () {
                context
                    .read<DashboardBloc>()
                    .add(const RefreshDashboardEvent());
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    }

    // Build AppBar based on selected screen label
    if (label == l10n.pointOfSale || label == l10n.cashier) {
      // Cashier Screen
      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<SaleBloc, SaleState>(
          builder: (context, saleState) {
            int cartItemCount = 0;
            if (saleState is SaleLoaded) {
              cartItemCount = saleState.cartItemCount;
            } else if (saleState is SaleError) {
              cartItemCount = saleState.cartItemCount;
            } else if (saleState is SaleOperationSuccess) {
              cartItemCount = saleState.cartItemCount;
            }

            return AppBar(
              title: Text(l10n.pointOfSale),
              elevation: 4,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
              actions: [
                // Cart icon with badge
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Badge(
                    label: Text('$cartItemCount'),
                    isLabelVisible: cartItemCount > 0,
                    child: IconButton(
                      onPressed: () {
                        (_cashierKey.currentState as dynamic)?.toggleCart();
                      },
                      icon: const Icon(Icons.shopping_cart),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else if (label == l10n.products) {
      return AppBar(
        title: Text(l10n.productsManagement),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
        actions: [
          Tooltip(
            message: l10n.add,
            child: IconButton(
              onPressed: () {
                (_productsKey.currentState as dynamic)?.showProductDialog();
              },
              icon: const Icon(Icons.add),
            ),
          ),
          Tooltip(
            message: l10n.refresh,
            child: IconButton(
              onPressed: () {
                context.read<ProductBloc>().add(const LoadProductsEvent());
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    } else if (label == l10n.categories) {
      return AppBar(
        title: Text(l10n.categories),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
        actions: [
          Tooltip(
            message: l10n.add,
            child: IconButton(
              onPressed: () {
                (_categoriesKey.currentState as dynamic)?.showCategoryDialog();
              },
              icon: const Icon(Icons.add),
            ),
          ),
          Tooltip(
            message: l10n.refresh,
            child: IconButton(
              onPressed: () {
                (_categoriesKey.currentState as dynamic)?.loadCategories();
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    } else if (label == l10n.customers) {
      return AppBar(
        title: Text(l10n.customersManagement),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
        actions: [
          Tooltip(
            message: l10n.add,
            child: IconButton(
              onPressed: () {
                (_customersKey.currentState as dynamic)?.showCustomerDialog();
              },
              icon: const Icon(Icons.add),
            ),
          ),
          Tooltip(
            message: l10n.refresh,
            child: IconButton(
              onPressed: () {
                context.read<CustomerBloc>().add(const LoadCustomersEvent());
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    } else if (label == l10n.sales) {
      return AppBar(
        title: Text(l10n.salesList),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
        actions: [
          Tooltip(
            message: l10n.refresh,
            child: IconButton(
              onPressed: () {
                context.read<SaleBloc>().add(const LoadSalesEvent());
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    } else if (label == l10n.users) {
      return AppBar(
        title: Text(l10n.usersManagement),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
        actions: [
          Tooltip(
            message: l10n.addUser,
            child: IconButton(
              onPressed: () {
                (_usersKey.currentState as dynamic)?.showUserDialog();
              },
              icon: const Icon(Icons.add),
            ),
          ),
          Tooltip(
            message: l10n.refresh,
            child: IconButton(
              onPressed: () {
                context.read<UserBloc>().add(const LoadUsersEvent());
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    } else if (label == l10n.settings) {
      return AppBar(
        title: Text(l10n.settings),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
      );
    } else {
      return AppBar(
        title: Text(label),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
      );
    }
  }

  Widget _buildDrawerHeader() {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo with glass effect
          if (_companyInfo?.logoPath != null &&
              _companyInfo!.logoPath!.isNotEmpty)
            GlassmorphicContainer(
              width: 60,
              height: 60,
              borderRadius: 12,
              blur: 15,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.2),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FutureBuilder(
                  key: ValueKey(_companyInfo!.logoPath),
                  future: ImageService.getImageBytes(_companyInfo!.logoPath),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData &&
                        snapshot.data != null) {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.store,
                            size: 40,
                            color: Colors.white,
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Icon(
                        Icons.store,
                        size: 40,
                        color: Colors.white,
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      );
                    }
                  },
                ),
              ),
            )
          else
            GlassmorphicContainer(
              width: 60,
              height: 60,
              borderRadius: 12,
              blur: 15,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.2),
                ],
              ),
              child: const Icon(
                Icons.store,
                size: 40,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 16),
          // Company Name (localized - English or Arabic based on app language)
          Builder(
            builder: (context) {
              final locale = Localizations.localeOf(context);
              final isArabic = locale.languageCode == 'ar';
              final companyName = isArabic
                  ? (_companyInfo?.nameArabic ??
                      _companyInfo?.name ??
                      'إدارة التجزئة')
                  : (_companyInfo?.name ?? 'Retail Management');

              return Text(
                companyName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          const SizedBox(height: 8),
          // VAT Number
          if (_companyInfo?.vatNumber != null)
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  '${l10n.vatNumber}: ${_companyInfo!.vatNumber}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: iconColor ??
                        (isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.7)),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: textColor ??
                            (isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.8)),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphicContainer(
          width: 400,
          height: 200,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.9),
              theme.colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.5),
              theme.colorScheme.primary.withValues(alpha: 0.2),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.confirm,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.confirmExit,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.no),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.yes),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return shouldExit ?? false;
  }

  Widget _buildGlassDrawer({
    required Widget child,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return GlassmorphicContainer(
      width: 280,
      height: double.infinity,
      borderRadius: 0,
      blur: 20,
      alignment: Alignment.centerLeft,
      border: 0,
      linearGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.surface.withValues(alpha: 0.95),
          theme.colorScheme.surface.withValues(alpha: 0.9),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.3),
          theme.colorScheme.primary.withValues(alpha: 0.1),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const SizedBox();
        }

        final user = authState.user;
        final screens = _getScreens(user.role);
        final navItems = _getNavigationItems(user.role, context);
        final l10n = AppLocalizations.of(context)!;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) async {
            if (didPop) {
              return;
            }
            final shouldPop = await _onWillPop(context);
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: _buildAppBar(navItems, context),
            drawer: Drawer(
              width: 280,
              backgroundColor: Colors.transparent,
              child: _buildGlassDrawer(
                context: context,
                child: Column(
                  key: ValueKey(_companyInfo?.updatedAt.toString() ?? ''),
                  children: [
                    _buildDrawerHeader(),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            ...navItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isSelected = _selectedIndex == index;

                              return _buildDrawerItem(
                                icon: item['icon'] as IconData,
                                label: item['label'] as String,
                                isSelected: isSelected,
                                onTap: () async {
                                  // Animate screen transition
                                  _animationController.reset();
                                  _animationController.forward();

                                  // Check if we're navigating away from settings (index 7 for admin)
                                  final isLeavingSettings =
                                      (_previousIndex == 7 &&
                                          user.role == UserRole.admin);

                                  setState(() {
                                    _previousIndex = _selectedIndex;
                                    _selectedIndex = index;
                                  });

                                  // Reload company info if leaving settings
                                  if (isLeavingSettings) {
                                    await _loadCompanyInfo();
                                  }

                                  if (context.mounted) {
                                    Navigator.pop(context); // Close drawer
                                  }
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: _buildDrawerItem(
                        icon: Icons.logout,
                        label: l10n.logout,
                        isSelected: false,
                        iconColor: theme.colorScheme.error,
                        textColor: theme.colorScheme.error,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: GlassmorphicContainer(
                                width: 400,
                                height: 200,
                                borderRadius: 20,
                                blur: 20,
                                alignment: Alignment.center,
                                border: 2,
                                linearGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.surface
                                        .withValues(alpha: 0.9),
                                    theme.colorScheme.surface
                                        .withValues(alpha: 0.8),
                                  ],
                                ),
                                borderGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary
                                        .withValues(alpha: 0.5),
                                    theme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l10n.logout,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.confirmLogout,
                                        style: theme.textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(l10n.cancel),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  theme.colorScheme.error,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text(l10n.logout),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (confirm == true && mounted) {
                            Navigator.pop(context); // Close drawer
                            context.read<AuthBloc>().add(const LogoutEvent());
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: screens[_selectedIndex],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
