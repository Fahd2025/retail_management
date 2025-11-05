import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
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

  List<NavigationRailDestination> _getNavigationItems(UserRole role) {
    if (role == UserRole.admin) {
      return const [
        NavigationRailDestination(
          icon: Icon(Icons.point_of_sale),
          label: Text('Cashier'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory),
          label: Text('Products'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('Customers'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.receipt_long),
          label: Text('Sales'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ];
    } else {
      return const [
        NavigationRailDestination(
          icon: Icon(Icons.point_of_sale),
          label: Text('Cashier'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.receipt_long),
          label: Text('Sales'),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox();

    final screens = _getScreens(user.role);
    final navItems = _getNavigationItems(user.role);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.blue.shade700,
            indicatorColor: Colors.white.withOpacity(0.3),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            selectedLabelTextStyle: const TextStyle(color: Colors.white),
            unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.7)),
            unselectedLabelTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            leading: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    user.role == UserRole.admin
                        ? Icons.admin_panel_settings
                        : Icons.person,
                    size: 30,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  user.role == UserRole.admin ? 'Admin' : 'Cashier',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
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
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        await authProvider.logout();
                      }
                    },
                    tooltip: 'Logout',
                  ),
                ),
              ),
            ),
            destinations: navItems,
          ),

          // Main content
          Expanded(
            child: screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
