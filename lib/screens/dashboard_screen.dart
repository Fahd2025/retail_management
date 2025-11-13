import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  CompanyInfo? _companyInfo;

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
    // Build AppBar based on selected screen
    switch (_selectedIndex) {
      case 0: // Cashier Screen
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
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                actions: [
                  // Cart icon with badge
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Badge(
                      label: Text('$cartItemCount'),
                      isLabelVisible: cartItemCount > 0,
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          (_cashierKey.currentState as dynamic)?.toggleCart();
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      case 1: // Products or Sales Screen (depends on user role)
        final label = navItems[_selectedIndex]['label'] as String;
        if (label == l10n.products) {
          return AppBar(
            title: Text(l10n.productsManagement),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  (_productsKey.currentState as dynamic)?.showProductDialog();
                },
                tooltip: l10n.addProduct,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<ProductBloc>().add(const LoadProductsEvent());
                },
                tooltip: l10n.refresh,
              ),
            ],
          );
        } else {
          // Sales screen for cashier role
          return AppBar(
            title: Text(l10n.salesList),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<SaleBloc>().add(const LoadSalesEvent());
                },
                tooltip: l10n.refresh,
              ),
            ],
          );
        }
      case 2: // Categories Screen (admin only)
        return AppBar(
          title: Text(l10n.categories),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                (_categoriesKey.currentState as dynamic)?.showCategoryDialog();
              },
              tooltip: l10n.addCategory,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                (_categoriesKey.currentState as dynamic)?.loadCategories();
              },
              tooltip: l10n.refresh,
            ),
          ],
        );
      case 3: // Customers Screen (admin only)
        return AppBar(
          title: Text(l10n.customersManagement),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                (_customersKey.currentState as dynamic)?.showCustomerDialog();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<CustomerBloc>().add(const LoadCustomersEvent());
              },
            ),
          ],
        );
      case 4: // Sales Screen (admin only)
        return AppBar(
          title: Text(l10n.salesList),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SaleBloc>().add(const LoadSalesEvent());
              },
            ),
          ],
        );
      case 5: // Users Screen (admin only)
        return AppBar(
          title: Text(l10n.usersManagement),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                (_usersKey.currentState as dynamic)?.showUserDialog();
              },
              tooltip: l10n.addUser,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<UserBloc>().add(const LoadUsersEvent());
              },
              tooltip: l10n.refresh,
            ),
          ],
        );
      case 6: // Settings Screen (admin only)
        return AppBar(
          title: Text(l10n.settings),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        );
      default:
        return AppBar(
          title: Text(navItems[_selectedIndex]['label'] as String),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        );
    }
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          if (_companyInfo?.logoPath != null &&
              _companyInfo!.logoPath!.isNotEmpty)
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder(
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
                            color: Colors.blue.shade700,
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Icon(
                        Icons.store,
                        size: 40,
                        color: Colors.blue.shade700,
                      );
                    } else {
                      return Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade700,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            )
          else
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.store,
                size: 40,
                color: Colors.blue.shade700,
              ),
            ),
          const SizedBox(height: 12),
          // Branch/Company Name
          Text(
            _companyInfo?.name ?? 'Retail Management',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirm),
        content: Text(l10n.confirmExit),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const SizedBox();
        }

        final user = authState.user;
        final screens = _getScreens(user.role);
        final navItems = _getNavigationItems(user.role, context);

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
            child: Column(
              children: [
                _buildDrawerHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: navItems.length,
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      final isSelected = _selectedIndex == index;

                      return ListTile(
                        leading: Icon(
                          item['icon'] as IconData,
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.grey.shade700,
                        ),
                        title: Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Colors.blue.shade50,
                        onTap: () {
                          setState(() => _selectedIndex = index);
                          Navigator.pop(context); // Close drawer
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    AppLocalizations.of(context)!.logout,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    final l10n = AppLocalizations.of(context)!;
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.logout),
                        content: Text(l10n.confirmLogout),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(l10n.logout),
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
                const SizedBox(height: 8),
              ],
            ),
          ),
            body: screens[_selectedIndex],
          ),
        );
      },
    );
  }
}
