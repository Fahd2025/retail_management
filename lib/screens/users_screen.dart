import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await context.read<UserProvider>().loadUsers();
  }

  Future<void> showUserDialog([User? user]) async {
    await showDialog(
      context: context,
      builder: (context) => _UserDialog(user: user),
    );
  }

  Future<void> _deleteUser(
    BuildContext context,
    UserProvider provider,
    User user,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    // Prevent deleting self
    if (currentUser?.id == user.id) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot delete your own account'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteUser),
        content:
            Text(AppLocalizations.of(context)!.deleteUserConfirm(user.username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.deleteUser(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'User deleted successfully'
                : 'Failed to delete user'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No users found'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => showUserDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;

              if (isDesktop) {
                // Desktop/Tablet: DataTable layout
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Username')),
                        DataColumn(label: Text('Full Name')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Invoice Count')),
                        DataColumn(label: Text('Total Sales')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: provider.users.map((user) {
                        final stats = provider.userSalesStats[user.id] ?? {};
                        final invoiceCount = stats['invoiceCount'] ?? 0;
                        final totalSales = stats['totalSales'] ?? 0.0;

                        return DataRow(cells: [
                          DataCell(Text(user.username)),
                          DataCell(Text(user.fullName)),
                          DataCell(
                            Chip(
                              label: Text(
                                user.role == UserRole.admin
                                    ? 'Admin'
                                    : 'Cashier',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: user.role == UserRole.admin
                                  ? Colors.blue.shade100
                                  : Colors.green.shade100,
                            ),
                          ),
                          DataCell(
                            Chip(
                              label: Text(
                                user.isActive ? 'Active' : 'Inactive',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: user.isActive
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                            ),
                          ),
                          DataCell(Text(invoiceCount.toString())),
                          DataCell(
                            Text('SAR ${totalSales.toStringAsFixed(2)}'),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => showUserDialog(user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  onPressed: () =>
                                      _deleteUser(context, provider, user),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              } else {
                // Mobile: Card layout
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    final stats = provider.userSalesStats[user.id] ?? {};
                    final invoiceCount = stats['invoiceCount'] ?? 0;
                    final totalSales = stats['totalSales'] ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    user.fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => showUserDialog(user),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteUser(context, provider, user),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            _buildInfoRow('Username', user.username),
                            _buildInfoRow(
                              'Role',
                              user.role == UserRole.admin ? 'Admin' : 'Cashier',
                            ),
                            _buildInfoRow(
                              'Status',
                              user.isActive ? 'Active' : 'Inactive',
                            ),
                            _buildInfoRow(
                                'Invoice Count', invoiceCount.toString()),
                            _buildInfoRow(
                              'Total Sales',
                              'SAR ${totalSales.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

// User Dialog for Add/Edit
class _UserDialog extends StatefulWidget {
  final User? user;

  const _UserDialog({this.user});

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _fullNameController;
  late UserRole _selectedRole;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.user?.username ?? '');
    _passwordController = TextEditingController();
    _fullNameController =
        TextEditingController(text: widget.user?.fullName ?? '');
    _selectedRole = widget.user?.role ?? UserRole.cashier;
    _isActive = widget.user?.isActive ?? true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();
    bool success;

    if (widget.user == null) {
      // Create new user
      success = await provider.addUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
      );
    } else {
      // Update existing user
      final updatedUser = widget.user!.copyWith(
        username: _usernameController.text.trim(),
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : widget.user!.password,
        fullName: _fullNameController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
      );
      success = await provider.updateUser(updatedUser);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user == null
                ? 'User created successfully'
                : 'User updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage = provider.errorMessage ?? 'An error occurred';
        print(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: widget.user == null
                      ? 'Password *'
                      : 'Password (leave empty to keep current)',
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (widget.user == null && (value == null || value.isEmpty)) {
                    return 'Password is required';
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.admin,
                    child: Text('Admin'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.cashier,
                    child: Text('Cashier'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.active),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
