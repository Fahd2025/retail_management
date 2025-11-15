import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glassmorphism/glassmorphism.dart';
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
    final isDark = theme.brightness == Brightness.dark;

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
            // Animated gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                    theme.colorScheme.secondary.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),

            // Decorative blurred circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.secondary.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: BlocBuilder<AppConfigBloc, AppConfigState>(
                    builder: (context, configState) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return IntrinsicHeight(
                                child: GlassmorphicContainer(
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight > 0 ? constraints.maxHeight : 650,
                                  borderRadius: 32,
                            blur: 20,
                            alignment: Alignment.center,
                            border: 2,
                            linearGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.2),
                                isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.white.withValues(alpha: 0.1),
                              ],
                            ),
                            borderGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.5),
                                Colors.white.withValues(alpha: 0.2),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Theme and Language Switchers Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Theme Switcher
                                      Tooltip(
                                        message: l10n.switchTheme,
                                        child: IconButton(
                                          onPressed: () {
                                            context.read<AppConfigBloc>().add(const ToggleThemeEvent());
                                          },
                                          icon: Icon(
                                            configState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Language Switcher
                                      Tooltip(
                                        message: l10n.switchLanguage,
                                        child: PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.language,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                          onSelected: (String value) {
                                            if (value == 'en') {
                                              context.read<AppConfigBloc>().add(const SetEnglishEvent());
                                            } else {
                                              context.read<AppConfigBloc>().add(const SetArabicEvent());
                                            }
                                          },
                                          itemBuilder: (BuildContext context) => [
                                            PopupMenuItem<String>(
                                              value: 'en',
                                              child: Row(
                                                children: [
                                                  if (configState.isEnglish)
                                                    const Icon(Icons.check, size: 18),
                                                  if (configState.isEnglish)
                                                    const SizedBox(width: 8),
                                                  Text(l10n.english),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'ar',
                                              child: Row(
                                                children: [
                                                  if (configState.isArabic)
                                                    const Icon(Icons.check, size: 18),
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
                                  ),
                                  const SizedBox(height: 16),

                                  // Logo/Icon with glass effect
                                  GlassmorphicContainer(
                                    width: 120,
                                    height: 120,
                                    borderRadius: 60,
                                    blur: 15,
                                    alignment: Alignment.center,
                                    border: 2,
                                    linearGradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        isDark
                                            ? Colors.white.withValues(alpha: 0.1)
                                            : Colors.white.withValues(alpha: 0.3),
                                        isDark
                                            ? Colors.white.withValues(alpha: 0.05)
                                            : Colors.white.withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderGradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.6),
                                        Colors.white.withValues(alpha: 0.2),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.store,
                                      size: 60,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Title
                                  Text(
                                    l10n.loginTitle,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 28,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.appSubtitle,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.black87.withValues(alpha: 0.7),
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),

                                  // Default Credentials Display with glass effect
                                  IntrinsicHeight(
                                    child: GlassmorphicContainer(
                                      width: double.infinity,
                                      height: 200,
                                      borderRadius: 16,
                                    blur: 15,
                                    alignment: Alignment.center,
                                    border: 2,
                                    linearGradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.withValues(alpha: 0.1),
                                        Colors.blue.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderGradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.withValues(alpha: 0.5),
                                        Colors.blue.withValues(alpha: 0.2),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                l10n.defaultCredentials,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            l10n.adminCredentials,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark
                                                  ? Colors.white.withValues(alpha: 0.8)
                                                  : Colors.black87.withValues(alpha: 0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            l10n.cashierCredentials,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark
                                                  ? Colors.white.withValues(alpha: 0.8)
                                                  : Colors.black87.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  if (_isInitializing)
                                    Column(
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.initializingSystem,
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
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
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: isDark
                                                  ? Colors.white.withValues(alpha: 0.1)
                                                  : Colors.white.withValues(alpha: 0.5),
                                            ),
                                            textInputAction: TextInputAction.next,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return l10n.pleaseEnterUsername;
                                              }
                                              return null;
                                            },
                                            onFieldSubmitted: (_) {
                                              FocusScope.of(context).nextFocus();
                                            },
                                          ),
                                          const SizedBox(height: 20),

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
                                                    _obscurePassword = !_obscurePassword;
                                                  });
                                                },
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: isDark
                                                  ? Colors.white.withValues(alpha: 0.1)
                                                  : Colors.white.withValues(alpha: 0.5),
                                            ),
                                            obscureText: _obscurePassword,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return l10n.pleaseEnterPassword;
                                              }
                                              return null;
                                            },
                                            onFieldSubmitted: (_) {
                                              if (_formKey.currentState!.validate()) {
                                                _login();
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 40),

                                          // Login button
                                          SizedBox(
                                            width: double.infinity,
                                            child: BlocBuilder<AuthBloc, AuthState>(
                                              builder: (context, state) {
                                                final isLoading = state is AuthLoading;
                                                return ElevatedButton(
                                                  onPressed: isLoading ? null : _login,
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    backgroundColor: theme.colorScheme.primary,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  child: isLoading
                                                      ? const SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      : Text(
                                                          l10n.login,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
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
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
                    },
                  ),
                ),
              ),
            ),

            // Notification Bar with glass effect
            if (_notificationMessage != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 70,
                      borderRadius: 12,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isNotificationError
                            ? [
                                Colors.red.withValues(alpha: 0.3),
                                Colors.red.withValues(alpha: 0.2),
                              ]
                            : [
                                Colors.green.withValues(alpha: 0.3),
                                Colors.green.withValues(alpha: 0.2),
                              ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isNotificationError
                            ? [
                                Colors.red.withValues(alpha: 0.6),
                                Colors.red.withValues(alpha: 0.3),
                              ]
                            : [
                                Colors.green.withValues(alpha: 0.6),
                                Colors.green.withValues(alpha: 0.3),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              _isNotificationError ? Icons.error_outline : Icons.check_circle_outline,
                              color: _isNotificationError ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _notificationMessage!,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: isDark ? Colors.white : Colors.black87,
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
                ),
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
