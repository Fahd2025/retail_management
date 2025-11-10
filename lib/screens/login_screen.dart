import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.initializationError(e.toString()))),
        );
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
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final username = _usernameController.text.trim();
    final success = await authProvider.login(
      username,
      _passwordController.text,
    );

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      if (success) {
        _showNotification(l10n.loginSuccess(username), false);
      } else {
        _showNotification(
          authProvider.errorMessage ?? l10n.loginFailed,
          true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
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
                                icon: Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.light_mode
                                      : Icons.dark_mode,
                                ),
                                onPressed: () async {
                                  await themeProvider.toggleTheme();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Language Switcher
                            Tooltip(
                              message: l10n.switchLanguage,
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.language),
                                onSelected: (String value) async {
                                  if (value == 'en') {
                                    await localeProvider.setEnglish();
                                  } else {
                                    await localeProvider.setArabic();
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'en',
                                    child: Row(
                                      children: [
                                        if (localeProvider.isEnglish)
                                          const Icon(Icons.check, size: 18),
                                        if (localeProvider.isEnglish)
                                          const SizedBox(width: 8),
                                        const Text('English'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'ar',
                                    child: Row(
                                      children: [
                                        if (localeProvider.isArabic)
                                          const Icon(Icons.check, size: 18),
                                        if (localeProvider.isArabic)
                                          const SizedBox(width: 8),
                                        const Text('العربية'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                    // Logo/Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.store,
                        size: 50,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      l10n.loginTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Default Credentials Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.shade200,
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
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.defaultCredentials,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseEnterUsername;
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
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
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseEnterPassword;
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _login(),
                            ),
                            const SizedBox(height: 32),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              child: Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return ElevatedButton(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: authProvider.isLoading
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
          ),
        ),
          ),

          // Notification Bar
          if (_notificationMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _isNotificationError
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    border: Border(
                      bottom: BorderSide(
                        color: _isNotificationError
                            ? Colors.red.shade200
                            : Colors.green.shade200,
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
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _notificationMessage!,
                          style: TextStyle(
                            color: _isNotificationError
                                ? Colors.red.shade900
                                : Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: _isNotificationError
                              ? Colors.red.shade700
                              : Colors.green.shade700,
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
        ],
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
