import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'config/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme and locale providers
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();

  await Future.wait([
    themeProvider.initialize(),
    localeProvider.initialize(),
  ]);

  runApp(MyApp(
    themeProvider: themeProvider,
    localeProvider: localeProvider,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;

  const MyApp({
    super.key,
    required this.themeProvider,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(1920, 1080), // Desktop/Tablet design size
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'Retail Management System',
                debugShowCheckedModeBanner: false,

                // Theme configuration
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,

                // Localization configuration
                locale: localeProvider.locale,
                supportedLocales: LocaleProvider.supportedLocales,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                home: const AuthWrapper(),
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isLoggedIn) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
