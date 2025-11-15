import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui.dart';
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
    final liquidTheme = LiquidTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => LiquidDialog(
        title: l10n.deleteUser,
        content: Text(
          l10n.deleteUserConfirm(user.username),
          style: TextStyle(color: liquidTheme.textColor),
        ),
        actions: [
          LiquidButton(
            onTap: () => Navigator.pop(context, false),
            type: LiquidButtonType.text,
            child: Text(l10n.cancel),
          ),
          LiquidButton(
            onTap: () => Navigator.pop(context, true),
            type: LiquidButtonType.filled,
            backgroundColor: theme.colorScheme.error,
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<UserBloc>().add(DeleteUserEvent(user.id));
    }
  }

  Widget _buildInfoRow(
      String label, String value, LiquidThemeData liquidTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: liquidTheme.textColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: liquidTheme.textColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liquidTheme = LiquidTheme.of(context);

    return LiquidScaffold(
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
            return Center(
              child: LiquidLoader(size: 60),
            );
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
                  LiquidContainer(
                    width: 120,
                    height: 120,
                    borderRadius: 60,
                    blur: 15,
                    opacity: 0.2,
                    child: Icon(
                      Icons.people,
                      size: 64,
                      color: liquidTheme.textColor.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noUsersFound,
                    style: TextStyle(color: liquidTheme.textColor),
                  ),
                  const SizedBox(height: 16),
                  LiquidButton(
                    onTap: () => showUserDialog(),
                    type: LiquidButtonType.filled,
                    icon: const Icon(Icons.add, color: Colors.white),
                    child: Text(
                      l10n.addUser,
                      style: const TextStyle(color: Colors.white),
                    ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: LiquidCard(
                          elevation: 4,
                          blur: 20,
                          opacity: 0.15,
                          padding: EdgeInsets.zero,
                          child: DataTable(
                            columnSpacing: 24,
                            horizontalMargin: 16,
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: liquidTheme.textColor,
                            ),
                            dataTextStyle: TextStyle(
                              color: liquidTheme.textColor,
                            ),
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
                                DataCell(Text(
                                  user.username,
                                  style:
                                      TextStyle(color: liquidTheme.textColor),
                                )),
                                DataCell(Text(
                                  user.fullName,
                                  style:
                                      TextStyle(color: liquidTheme.textColor),
                                )),
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
                                      user.isActive
                                          ? l10n.active
                                          : l10n.inactive,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: user.isActive
                                        ? Colors.green.shade100
                                        : theme.colorScheme.errorContainer,
                                  ),
                                ),
                                DataCell(Text(
                                  invoiceCount.toString(),
                                  style:
                                      TextStyle(color: liquidTheme.textColor),
                                )),
                                DataCell(
                                  Text(
                                    CurrencyHelper.formatCurrencySync(
                                        totalSales),
                                    style:
                                        TextStyle(color: liquidTheme.textColor),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        onPressed: () => showUserDialog(user),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: theme.colorScheme.error,
                                        ),
                                        onPressed: () =>
                                            _deleteUser(context, user),
                                      ),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
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

                    return LiquidCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      blur: 18,
                      opacity: 0.15,
                      borderRadius: 16,
                      padding: EdgeInsets.zero,
                      child: ExpansionTile(
                        leading: LiquidContainer(
                          width: 40,
                          height: 40,
                          borderRadius: 20,
                          blur: 10,
                          opacity: 0.15,
                          child: Center(
                            child: Icon(
                              user.role == UserRole.admin
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: liquidTheme.textColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.username + ': ' + user.username,
                              style: TextStyle(
                                fontSize: 13,
                                color: liquidTheme.textColor
                                    .withValues(alpha: 0.7),
                              ),
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
                              icon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () => showUserDialog(user),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: theme.colorScheme.error,
                              ),
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
                                  l10n.invoiceCount,
                                  invoiceCount.toString(),
                                  liquidTheme,
                                ),
                                _buildInfoRow(
                                  l10n.total,
                                  CurrencyHelper.formatCurrencySync(totalSales),
                                  liquidTheme,
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

  Widget _buildGlassSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
          border: Border.all(
            color: value
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  value ? theme.colorScheme.primary : theme.colorScheme.outline,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final liquidTheme = LiquidTheme.of(context);

    // Build the form content
    final formContent = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Username Field
          LiquidTextField(
            controller: _usernameController,
            label: l10n.usernameFieldLabel,
            prefixIcon: const Icon(Icons.person_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.usernameRequired;
              }
              if (value.trim().length < 3) {
                return l10n.usernameMinLength;
              }
              return null;
            },
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Full Name Field
          LiquidTextField(
            controller: _fullNameController,
            label: l10n.fullNameFieldLabel,
            prefixIcon: const Icon(Icons.badge_outlined),
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
          LiquidTextField(
            controller: _passwordController,
            label: widget.user == null
                ? l10n.passwordFieldLabel
                : l10n.passwordLeaveEmpty,
            prefixIcon: const Icon(Icons.lock_outlined),
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
              labelStyle: TextStyle(color: liquidTheme.textColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: liquidTheme.textColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.admin_panel_settings_outlined,
                color: liquidTheme.textColor.withValues(alpha: 0.7),
              ),
            ),
            dropdownColor: Theme.of(context).colorScheme.surface,
            style: TextStyle(color: liquidTheme.textColor),
            items: [
              DropdownMenuItem(
                value: UserRole.admin,
                child: Text(
                  l10n.admin,
                  style: TextStyle(color: liquidTheme.textColor),
                ),
              ),
              DropdownMenuItem(
                value: UserRole.cashier,
                child: Text(
                  l10n.cashier,
                  style: TextStyle(color: liquidTheme.textColor),
                ),
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
          LiquidCard(
            elevation: 2,
            blur: 10,
            opacity: 0.1,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.active,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: liquidTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isActive ? l10n.active : l10n.inactive,
                      style: TextStyle(
                        fontSize: 14,
                        color: liquidTheme.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                _buildGlassSwitch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() => _isActive = value);
                  },
                ),
              ],
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
