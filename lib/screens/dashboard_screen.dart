import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
      return const [
        CashierScreen(),
        ProductsScreen(),
        CustomersScreen(),
        SalesScreen(),
        SettingsScreen(),
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
      appBar: AppBar(
        title: Text(navItems[_selectedIndex]['label'] as String),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Row(
          //     children: [
          //       CircleAvatar(
          //         radius: 16,
          //         backgroundColor: Colors.white,
          //         child: Icon(
          //           user.role == UserRole.admin
          //               ? Icons.admin_panel_settings
          //               : Icons.person,
          //           size: 18,
          //           color: Colors.blue.shade700,
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             user.fullName,
          //             style: const TextStyle(
          //               fontSize: 14,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           Text(
          //             user.role == UserRole.admin ? 'Admin' : 'Cashier',
          //             style: const TextStyle(
          //               fontSize: 11,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
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
