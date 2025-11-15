import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/app_config/app_config_bloc.dart';
import '../blocs/app_config/app_config_event.dart';
import '../blocs/app_config/app_config_state.dart';
import '../database/drift_database.dart' hide User;
import '../models/user.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isInitializing = false;
  String? _notificationMessage;
  bool _isNotificationError = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaultUsers();
  }

  Future<void> _initializeDefaultUsers() async {
    setState(() => _isInitializing = true);

    try {
      final db = AppDatabase();
      final users = await db.getAllUsers();

      // Create default users if none exist
      if (users.isEmpty) {
        const uuid = Uuid();

        // Create admin user
        await db.createUser(User(
          id: uuid.v4(),
          username: 'admin',
          password: 'admin123', // In production, use proper hashing
          fullName: 'System Administrator',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ));

        // Create cashier user
        await db.createUser(User(
          id: uuid.v4(),
          username: 'cashier',
          password: 'cashier123', // In production, use proper hashing
          fullName: 'Cashier User',
          role: UserRole.cashier,
          createdAt: DateTime.now(),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
        final l10n = AppLocalizations.of(context)!;
        _showNotification(l10n.initializationError(e.toString()), true);
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  void _showNotification(String message, bool isError) {
    setState(() {
      _notificationMessage = message;
      _isNotificationError = isError;
    });

    // Auto-hide notification after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _notificationMessage = null;
        });
      }
    });
  }

  Future<void> _login() async {
    // Prevent default form submission (important for web)
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    context.read<AuthBloc>().add(LoginEvent(
          username: username,
          password: password,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final username = state.user.username;
          _showNotification(l10n.loginSuccess(username), false);
        } else if (state is AuthError) {
          // Use localized error message instead of the hardcoded one from bloc
          final errorMsg = state.message.contains('Invalid')
              ? l10n.invalidCredentials
              : l10n.loginFailed;
          _showNotification(errorMsg, true);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: BlocBuilder<AppConfigBloc, AppConfigState>(
                      builder: (context, configState) {
                        return Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: configState.isDarkMode
                                ? const Color(0xFF1E1E1E).withOpacity(0.95)
                                : Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Theme and Language Switchers Row
                              BlocBuilder<AppConfigBloc, AppConfigState>(
                                builder: (context, configState) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Theme Switcher
                                      Tooltip(
                                        message: l10n.switchTheme,
                                        child: IconButton(
                                          icon: Icon(
                                            configState.isDarkMode
                                                ? Icons.light_mode
                                                : Icons.dark_mode,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<AppConfigBloc>()
                                                .add(const ToggleThemeEvent());
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Language Switcher
                                      Tooltip(
                                        message: l10n.switchLanguage,
                                        child: PopupMenuButton<String>(
                                          icon: const Icon(Icons.language),
                                          onSelected: (String value) {
                                            if (value == 'en') {
                                              context
                                                  .read<AppConfigBloc>()
                                                  .add(const SetEnglishEvent());
                                            } else {
                                              context
                                                  .read<AppConfigBloc>()
                                                  .add(const SetArabicEvent());
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            PopupMenuItem(
                                              value: 'en',
                                              child: Row(
                                                children: [
                                                  if (configState.isEnglish)
                                                    const Icon(Icons.check,
                                                        size: 18),
                                                  if (configState.isEnglish)
                                                    const SizedBox(width: 8),
                                                  Text(l10n.english),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'ar',
                                              child: Row(
                                                children: [
                                                  if (configState.isArabic)
                                                    const Icon(Icons.check,
                                                        size: 18),
                                                  if (configState.isArabic)
                                                    const SizedBox(width: 8),
                                                  Text(l10n.arabic),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              // Logo/Icon
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.store,
                                  size: 50,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                l10n.loginTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.appSubtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                              const SizedBox(height: 24),

                              // Default Credentials Display
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.primaryContainer,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.defaultCredentials,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.adminCredentials,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.cashierCredentials,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              if (_isInitializing)
                                Column(
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    Text(l10n.initializingSystem),
                                  ],
                                )
                              else
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      // Username field
                                      TextFormField(
                                        controller: _usernameController,
                                        decoration: InputDecoration(
                                          labelText: l10n.username,
                                          prefixIcon: const Icon(Icons.person),
                                        ),
                                        autofillHints: const [
                                          AutofillHints.username
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l10n.pleaseEnterUsername;
                                          }
                                          return null;
                                        },
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) {
                                          // Move focus to password field
                                          FocusScope.of(context).nextFocus();
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Password field
                                      TextFormField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                          labelText: l10n.password,
                                          prefixIcon: const Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        autofillHints: const [
                                          AutofillHints.password
                                        ],
                                        obscureText: _obscurePassword,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l10n.pleaseEnterPassword;
                                          }
                                          return null;
                                        },
                                        onFieldSubmitted: (_) {
                                          // Submit form on Enter key
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _login();
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 32),

                                      // Login button
                                      SizedBox(
                                        width: double.infinity,
                                        child: BlocBuilder<AuthBloc, AuthState>(
                                          builder: (context, state) {
                                            final isLoading =
                                                state is AuthLoading;
                                            return ElevatedButton(
                                              onPressed:
                                                  isLoading ? null : _login,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                              ),
                                              child: isLoading
                                                  ? const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Text(
                                                      l10n.login,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Notification Bar
            if (_notificationMessage != null)
              BlocBuilder<AppConfigBloc, AppConfigState>(
                builder: (context, configState) {
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Material(
                        elevation: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _isNotificationError
                                ? (configState.isDarkMode
                                    ? theme.colorScheme.error.withOpacity(0.9)
                                    : theme.colorScheme.errorContainer)
                                : (configState.isDarkMode
                                    ? Color(0xFF2E7D32).withOpacity(0.9)
                                    : Color(0xFFE8F5E9)),
                            border: Border(
                              bottom: BorderSide(
                                color: _isNotificationError
                                    ? (configState.isDarkMode
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.errorContainer)
                                    : (configState.isDarkMode
                                        ? Color(0xFF388E3C)
                                        : Color(0xFFA5D6A7)),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isNotificationError
                                    ? Icons.error_outline
                                    : Icons.check_circle_outline,
                                color: _isNotificationError
                                    ? (configState.isDarkMode
                                        ? theme.colorScheme.error.withOpacity(0.7)
                                        : theme.colorScheme.error)
                                    : (configState.isDarkMode
                                        ? Color(0xFF81C784)
                                        : Color(0xFF388E3C)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _notificationMessage!,
                                  style: TextStyle(
                                    color: _isNotificationError
                                        ? (configState.isDarkMode
                                            ? theme.colorScheme.errorContainer.withOpacity(0.5)
                                            : theme.colorScheme.error)
                                        : (configState.isDarkMode
                                            ? Color(0xFFC8E6C9)
                                            : Color(0xFF2E7D32)),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: _isNotificationError
                                      ? (configState.isDarkMode
                                          ? theme.colorScheme.error.withOpacity(0.7)
                                          : theme.colorScheme.error)
                                      : (configState.isDarkMode
                                          ? Color(0xFF81C784)
                                          : Color(0xFF388E3C)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _notificationMessage = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
