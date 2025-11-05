import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/sale_provider.dart';
import '../models/user.dart';
import '../models/company_info.dart';
import '../database/database_helper.dart';
import 'cashier_screen.dart';
import 'products_screen.dart';
import 'customers_screen.dart';
import 'sales_screen.dart';
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
  final GlobalKey<State<ProductsScreen>> _productsKey = GlobalKey<State<ProductsScreen>>();
  final GlobalKey<State<CustomersScreen>> _customersKey = GlobalKey<State<CustomersScreen>>();

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final db = DatabaseHelper.instance;
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
        const CashierScreen(),
        ProductsScreen(key: _productsKey),
        CustomersScreen(key: _customersKey),
        const SalesScreen(),
        const SettingsScreen(),
      ];
    } else {
      // Cashier only has access to cashier screen and sales
      return const [
        CashierScreen(),
        SalesScreen(),
      ];
    }
  }

  List<Map<String, dynamic>> _getNavigationItems(UserRole role) {
    if (role == UserRole.admin) {
      return const [
        {'icon': Icons.point_of_sale, 'label': 'Cashier'},
        {'icon': Icons.inventory, 'label': 'Products'},
        {'icon': Icons.people, 'label': 'Customers'},
        {'icon': Icons.receipt_long, 'label': 'Sales'},
        {'icon': Icons.settings, 'label': 'Settings'},
      ];
    } else {
      return const [
        {'icon': Icons.point_of_sale, 'label': 'Cashier'},
        {'icon': Icons.receipt_long, 'label': 'Sales'},
      ];
    }
  }

  PreferredSizeWidget _buildAppBar(List<Map<String, dynamic>> navItems) {
    // Build AppBar based on selected screen
    switch (_selectedIndex) {
      case 0: // Cashier Screen
        return AppBar(
          title: const Text('Point of Sale'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        );
      case 1: // Products or Sales Screen (depends on user role)
        final label = navItems[_selectedIndex]['label'] as String;
        if (label == 'Products') {
          return AppBar(
            title: const Text('Products Management'),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  (_productsKey.currentState as dynamic)?.showProductDialog();
                },
                tooltip: 'Add Product',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<ProductProvider>().loadProducts();
                },
                tooltip: 'Refresh',
              ),
            ],
          );
        } else {
          // Sales screen for cashier role
          return AppBar(
            title: const Text('Sales History'),
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
        }
      case 2: // Customers Screen (admin only)
        return AppBar(
          title: const Text('Customers Management'),
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
      case 3: // Sales Screen (admin only)
        return AppBar(
          title: const Text('Sales History'),
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
      case 4: // Settings Screen (admin only)
        return AppBar(
          title: const Text('Settings'),
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
    final navItems = _getNavigationItems(user.role);

    return Scaffold(
      appBar: _buildAppBar(navItems),
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
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Logout'),
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
