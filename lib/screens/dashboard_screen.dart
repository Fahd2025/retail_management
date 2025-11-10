import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../models/company_info.dart';
import '../database/drift_database.dart';
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
  final GlobalKey<State<CashierScreen>> _cashierKey = GlobalKey<State<CashierScreen>>();
  final GlobalKey<State<ProductsScreen>> _productsKey = GlobalKey<State<ProductsScreen>>();
  final GlobalKey<State<CategoriesScreen>> _categoriesKey = GlobalKey<State<CategoriesScreen>>();
  final GlobalKey<State<CustomersScreen>> _customersKey = GlobalKey<State<CustomersScreen>>();
  final GlobalKey<State<UsersScreen>> _usersKey = GlobalKey<State<UsersScreen>>();

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

  List<Map<String, dynamic>> _getNavigationItems(UserRole role, BuildContext context) {
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

  PreferredSizeWidget _buildAppBar(List<Map<String, dynamic>> navItems, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Build AppBar based on selected screen
    switch (_selectedIndex) {
      case 0: // Cashier Screen
        final saleProvider = context.watch<SaleProvider>();
        return AppBar(
          title: Text(l10n.pointOfSale),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            // Cart icon with badge
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Badge(
                label: Text('${saleProvider.cartItemCount}'),
                isLabelVisible: saleProvider.cartItemCount > 0,
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
                  context.read<ProductProvider>().loadProducts();
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
                  context.read<SaleProvider>().loadSales();
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
                context.read<CustomerProvider>().loadCustomers();
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
                context.read<SaleProvider>().loadSales();
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
                context.read<UserProvider>().loadUsers();
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
                child: Image.file(
                  File(_companyInfo!.logoPath!),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.store,
                      size: 40,
                      color: Colors.blue.shade700,
                    );
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox();

    final screens = _getScreens(user.role);
    final navItems = _getNavigationItems(user.role, context);

    return Scaffold(
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
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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
                  await authProvider.logout();
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      body: screens[_selectedIndex],
    );
  }
}
