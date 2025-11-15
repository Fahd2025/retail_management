import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../models/user.dart';
import '../widgets/form_bottom_sheet.dart';
import '../utils/currency_helper.dart';

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
    context.read<UserBloc>().add(const LoadUsersEvent());
  }

  Future<void> showUserDialog([User? user]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserDialog(user: user),
    );
  }

  Future<void> _deleteUser(
    BuildContext context,
    User user,
  ) async {
    final authState = context.read<AuthBloc>().state;
    final currentUser = authState is Authenticated ? authState.user : null;

    // Prevent deleting self
    if (currentUser?.id == user.id) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotDeleteOwnAccount),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteUser),
        content: Text(
            AppLocalizations.of(context)!.deleteUserConfirm(user.username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<UserBloc>().add(DeleteUserEvent(user.id));
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
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.green,
              ),
            );
            // Reload users after successful operation
            context.read<UserBloc>().add(const LoadUsersEvent());
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = state is UserLoaded ? state.users : <User>[];
          final userSalesStats = state is UserLoaded
              ? state.userSalesStats
              : <String, Map<String, dynamic>>{};

          if (users.isEmpty && state is! UserLoading) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(l10n.noUsersFound),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => showUserDialog(),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addUser),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;
              final l10n = AppLocalizations.of(context)!;

              if (isDesktop) {
                // Desktop/Tablet: DataTable layout that fills width
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: 24,
                        horizontalMargin: 16,
                        columns: [
                          DataColumn(label: Text(l10n.username)),
                          DataColumn(label: Text(l10n.fullName)),
                          DataColumn(label: Text(l10n.role)),
                          DataColumn(label: Text(l10n.status)),
                          DataColumn(label: Text(l10n.invoiceCount)),
                          DataColumn(label: Text(l10n.total)),
                          DataColumn(label: Text(l10n.actions)),
                        ],
                        rows: users.map((user) {
                          final stats = userSalesStats[user.id] ?? {};
                          final invoiceCount = stats['invoiceCount'] ?? 0;
                          final totalSales = stats['totalSales'] ?? 0.0;

                          return DataRow(cells: [
                            DataCell(Text(user.username)),
                            DataCell(Text(user.fullName)),
                            DataCell(
                              Chip(
                                label: Text(
                                  user.role == UserRole.admin
                                      ? l10n.admin
                                      : l10n.cashier,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: user.role == UserRole.admin
                                    ? theme.colorScheme.primaryContainer
                                    : Colors.green.shade100,
                              ),
                            ),
                            DataCell(
                              Chip(
                                label: Text(
                                  user.isActive ? l10n.active : l10n.inactive,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: user.isActive
                                    ? Colors.green.shade100
                                    : theme.colorScheme.errorContainer,
                              ),
                            ),
                            DataCell(Text(invoiceCount.toString())),
                            DataCell(
                              Text(CurrencyHelper.formatCurrencySync(
                                  totalSales)),
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
                                        size: 20,
                                        color: theme.colorScheme.error),
                                    onPressed: () => _deleteUser(context, user),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              } else {
                // Mobile: Card with ExpansionTile layout
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final stats = userSalesStats[user.id] ?? {};
                    final invoiceCount = stats['invoiceCount'] ?? 0;
                    final totalSales = stats['totalSales'] ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          child: Icon(
                            user.role == UserRole.admin
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.username + ': ' + user.username,
                              style: const TextStyle(fontSize: 13),
                            ),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    user.role == UserRole.admin
                                        ? l10n.admin
                                        : l10n.cashier,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: user.role == UserRole.admin
                                      ? theme.colorScheme.primaryContainer
                                      : Colors.green.shade100,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    user.isActive ? l10n.active : l10n.inactive,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: user.isActive
                                      ? Colors.green.shade100
                                      : theme.colorScheme.errorContainer,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color: theme.colorScheme.primary),
                              onPressed: () => showUserDialog(user),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: theme.colorScheme.error),
                              onPressed: () => _deleteUser(context, user),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                    l10n.invoiceCount, invoiceCount.toString()),
                                _buildInfoRow(
                                  l10n.total,
                                  CurrencyHelper.formatCurrencySync(totalSales),
                                ),
                              ],
                            ),
                          ),
                        ],
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

    if (widget.user == null) {
      // Create new user
      context.read<UserBloc>().add(
            AddUserEvent(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
              role: _selectedRole,
              isActive: _isActive,
            ),
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
      context.read<UserBloc>().add(UpdateUserEvent(updatedUser));
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Build the form content
    final formContent = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Username Field
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: l10n.usernameFieldLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.usernameRequired;
              }
              if (value.trim().length < 3) {
                return l10n.usernameMinLength;
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Full Name Field
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: l10n.fullNameFieldLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.fullNameRequired;
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: widget.user == null
                  ? l10n.passwordFieldLabel
                  : l10n.passwordLeaveEmpty,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outlined),
            ),
            obscureText: true,
            validator: (value) {
              if (widget.user == null && (value == null || value.isEmpty)) {
                return l10n.passwordRequired;
              }
              if (value != null && value.isNotEmpty && value.length < 6) {
                return l10n.passwordMinLength;
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Role Dropdown
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            decoration: InputDecoration(
              labelText: l10n.roleFieldLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
            ),
            items: [
              DropdownMenuItem(
                value: UserRole.admin,
                child: Text(l10n.admin),
              ),
              DropdownMenuItem(
                value: UserRole.cashier,
                child: Text(l10n.cashier),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedRole = value);
              }
            },
          ),
          const SizedBox(height: 16),

          // Active Status Switch
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SwitchListTile(
              title: Text(l10n.active),
              subtitle: Text(_isActive ? l10n.active : l10n.inactive),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
          ),
        ],
      ),
    );

    // Wrap in FormBottomSheet
    return FormBottomSheet(
      title: widget.user == null ? l10n.addUser : l10n.editUser,
      saveButtonText: l10n.save,
      cancelButtonText: l10n.cancel,
      onSave: _save,
      child: formContent,
    );
  }
}
