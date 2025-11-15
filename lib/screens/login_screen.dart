import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui_design.dart';
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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isInitializing = false;
  String? _notificationMessage;
  bool _isNotificationError = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeDefaultUsers();

    // Initialize animations for smooth entrance
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
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
    final liquidTheme = LiquidTheme.of(context);

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
      child: LiquidScaffold(
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
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: BlocBuilder<AppConfigBloc, AppConfigState>(
                        builder: (context, configState) {
                          return LiquidCard(
                            elevation: 8,
                            blur: 25,
                            opacity: 0.18,
                            borderRadius: 32,
                            padding: const EdgeInsets.all(40),
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Theme and Language Switchers Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Theme Switcher
                                    LiquidTooltip(
                                      message: l10n.switchTheme,
                                      child: LiquidButton(
                                        onPressed: () {
                                          context.read<AppConfigBloc>().add(const ToggleThemeEvent());
                                        },
                                        type: LiquidButtonType.icon,
                                        size: LiquidButtonSize.small,
                                        child: Icon(
                                          configState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                          color: liquidTheme.textColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Language Switcher
                                    LiquidTooltip(
                                      message: l10n.switchLanguage,
                                      child: LiquidPopupMenu<String>(
                                        icon: Icon(Icons.language, color: liquidTheme.textColor),
                                        items: [
                                          LiquidPopupMenuItem(
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
                                          LiquidPopupMenuItem(
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
                                        onSelected: (String value) {
                                          if (value == 'en') {
                                            context.read<AppConfigBloc>().add(const SetEnglishEvent());
                                          } else {
                                            context.read<AppConfigBloc>().add(const SetArabicEvent());
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Logo/Icon with glass effect
                                LiquidContainer(
                                  width: 120,
                                  height: 120,
                                  borderRadius: 60,
                                  blur: 15,
                                  opacity: 0.2,
                                  child: Center(
                                    child: Icon(
                                      Icons.store,
                                      size: 60,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Title
                                Text(
                                  l10n.loginTitle,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: liquidTheme.textColor,
                                    fontSize: 28,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.appSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: liquidTheme.textColor.withValues(alpha: 0.7),
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),

                                // Default Credentials Display with glass effect
                                LiquidBanner(
                                  type: LiquidBannerType.info,
                                  title: l10n.defaultCredentials,
                                  icon: Icons.info_outline,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.adminCredentials,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: liquidTheme.textColor.withValues(alpha: 0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.cashierCredentials,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: liquidTheme.textColor.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                if (_isInitializing)
                                  Column(
                                    children: [
                                      LiquidLoader(size: 40),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.initializingSystem,
                                        style: TextStyle(color: liquidTheme.textColor),
                                      ),
                                    ],
                                  )
                                else
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        // Username field with Liquid Glass design
                                        LiquidTextField(
                                          controller: _usernameController,
                                          label: l10n.username,
                                          prefixIcon: const Icon(Icons.person),
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

                                        // Password field with Liquid Glass design
                                        LiquidTextField(
                                          controller: _passwordController,
                                          label: l10n.password,
                                          prefixIcon: const Icon(Icons.lock),
                                          obscureText: _obscurePassword,
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

                                        // Login button with Liquid Glass design
                                        SizedBox(
                                          width: double.infinity,
                                          child: BlocBuilder<AuthBloc, AuthState>(
                                            builder: (context, state) {
                                              final isLoading = state is AuthLoading;
                                              return LiquidButton(
                                                onPressed: isLoading ? null : _login,
                                                type: LiquidButtonType.filled,
                                                size: LiquidButtonSize.large,
                                                width: double.infinity,
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
                                                          color: Colors.white,
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
            ),

            // Notification Bar with Liquid Glass design
            if (_notificationMessage != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LiquidAlert(
                      type: _isNotificationError
                          ? LiquidAlertType.error
                          : LiquidAlertType.success,
                      message: _notificationMessage!,
                      onDismiss: () {
                        setState(() {
                          _notificationMessage = null;
                        });
                      },
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
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
