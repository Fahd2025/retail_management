import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui.dart';
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
      return LiquidAppBar(
        title: l10n.appTitle,
        elevation: 4,
        blur: 20,
        actions: [
          LiquidTooltip(
            message: l10n.refreshDashboard,
            child: LiquidButton(
              onTap: () {
                context
                    .read<DashboardBloc>()
                    .add(const RefreshDashboardEvent());
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.refresh, color: Colors.white),
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

            return LiquidAppBar(
              title: l10n.pointOfSale,
              elevation: 4,
              blur: 20,
              actions: [
                // Cart icon with badge
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Badge(
                    label: Text('$cartItemCount'),
                    isLabelVisible: cartItemCount > 0,
                    child: LiquidButton(
                      onTap: () {
                        (_cashierKey.currentState as dynamic)?.toggleCart();
                      },
                      type: LiquidButtonType.icon,
                      size: LiquidButtonSize.medium,
                      child:
                          const Icon(Icons.shopping_cart, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else if (label == l10n.products) {
      return LiquidAppBar(
        title: l10n.productsManagement,
        elevation: 4,
        blur: 20,
        actions: [
          LiquidTooltip(
            message: l10n.add,
            child: LiquidButton(
              onTap: () {
                (_productsKey.currentState as dynamic)?.showProductDialog();
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          LiquidTooltip(
            message: l10n.refresh,
            child: LiquidButton(
              onTap: () {
                context.read<ProductBloc>().add(const LoadProductsEvent());
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      );
    } else if (label == l10n.categories) {
      return LiquidAppBar(
        title: l10n.categories,
        elevation: 4,
        blur: 20,
        actions: [
          LiquidTooltip(
            message: l10n.add,
            child: LiquidButton(
              onTap: () {
                (_categoriesKey.currentState as dynamic)?.showCategoryDialog();
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          LiquidTooltip(
            message: l10n.refresh,
            child: LiquidButton(
              onTap: () {
                (_categoriesKey.currentState as dynamic)?.loadCategories();
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      );
    } else if (label == l10n.customers) {
      return LiquidAppBar(
        title: l10n.customersManagement,
        elevation: 4,
        blur: 20,
        actions: [
          LiquidTooltip(
            message: l10n.add,
            child: LiquidButton(
              onTap: () {
                (_customersKey.currentState as dynamic)?.showCustomerDialog();
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          LiquidTooltip(
            message: l10n.refresh,
            child: LiquidButton(
              onTap: () {
                context.read<CustomerBloc>().add(const LoadCustomersEvent());
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      );
    } else if (label == l10n.sales) {
      return LiquidAppBar(
        title: l10n.salesList,
        elevation: 4,
        blur: 20,
        actions: [
          LiquidTooltip(
            message: l10n.refresh,
            child: LiquidButton(
              onTap: () {
                context.read<SaleBloc>().add(const LoadSalesEvent());
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      );
    } else if (label == l10n.users) {
      return LiquidAppBar(
        title: l10n.usersManagement,
        elevation: 4,
        blur: 20,
        actions: [
          LiquidTooltip(
            message: l10n.addUser,
            child: LiquidButton(
              onTap: () {
                (_usersKey.currentState as dynamic)?.showUserDialog();
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          LiquidTooltip(
            message: l10n.refresh,
            child: LiquidButton(
              onTap: () {
                context.read<UserBloc>().add(const LoadUsersEvent());
              },
              type: LiquidButtonType.icon,
              size: LiquidButtonSize.medium,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      );
    } else if (label == l10n.settings) {
      return LiquidAppBar(
        title: l10n.settings,
        elevation: 4,
        blur: 20,
      );
    } else {
      return LiquidAppBar(
        title: label,
        elevation: 4,
        blur: 20,
      );
    }
  }

  Widget _buildDrawerHeader() {
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

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
            LiquidContainer(
              width: 60,
              height: 60,
              borderRadius: 12,
              blur: 10,
              opacity: 0.3,
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
                          return Icon(
                            Icons.store,
                            size: 40,
                            color: Colors.white,
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Icon(
                        Icons.store,
                        size: 40,
                        color: Colors.white,
                      );
                    } else {
                      return Center(
                        child: LiquidLoader(size: 24),
                      );
                    }
                  },
                ),
              ),
            )
          else
            LiquidContainer(
              width: 60,
              height: 60,
              borderRadius: 12,
              blur: 10,
              opacity: 0.3,
              child: Icon(
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
    final liquidTheme = LiquidTheme.of(context);

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
                            : liquidTheme.textColor.withValues(alpha: 0.7)),
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
                                : liquidTheme.textColor.withValues(alpha: 0.8)),
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
      builder: (context) => LiquidDialog(
        title: l10n.confirm,
        content: Text(l10n.confirmExit),
        actions: [
          LiquidButton(
            onTap: () => Navigator.pop(context, false),
            type: LiquidButtonType.outlined,
            child: Text(l10n.no),
          ),
          LiquidButton(
            onTap: () => Navigator.pop(context, true),
            type: LiquidButtonType.filled,
            backgroundColor: theme.colorScheme.error,
            child: Text(l10n.yes, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

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
          child: LiquidScaffold(
            appBar: _buildAppBar(navItems, context),
            onDrawerChanged: (isOpened) {
              // Reload company info when drawer is opened (to show latest changes from settings)
              if (isOpened) {
                _loadCompanyInfo();
              }
            },
            drawer: LiquidDrawer(
              key: ValueKey(_companyInfo?.updatedAt.toString() ?? ''),
              width: 280,
              elevation: 8,
              blur: 30,
              child: Column(
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
                          builder: (context) => LiquidDialog(
                            title: l10n.logout,
                            content: Text(l10n.confirmLogout),
                            actions: [
                              LiquidButton(
                                onTap: () => Navigator.pop(context, false),
                                type: LiquidButtonType.outlined,
                                child: Text(l10n.cancel),
                              ),
                              LiquidButton(
                                onTap: () => Navigator.pop(context, true),
                                type: LiquidButtonType.filled,
                                backgroundColor: theme.colorScheme.error,
                                child: Text(l10n.logout,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ],
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
