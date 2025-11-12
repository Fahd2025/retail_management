import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:retail_management/generated/l10n/app_localizations.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/customer/customer_bloc.dart';
import 'blocs/sale/sale_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/theme/theme_bloc.dart';
import 'blocs/theme/theme_event.dart';
import 'blocs/theme/theme_state.dart';
import 'blocs/locale/locale_bloc.dart';
import 'blocs/locale/locale_event.dart';
import 'blocs/locale/locale_state.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/customer/customer_bloc.dart';
import 'blocs/sale/sale_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'config/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme and locale blocs
  final themeBloc = ThemeBloc()..add(const InitializeThemeEvent());
  final localeBloc = LocaleBloc()..add(const InitializeLocaleEvent());

  // Wait for initialization
  await Future.delayed(const Duration(milliseconds: 100));

  runApp(MyApp(
    themeBloc: themeBloc,
    localeBloc: localeBloc,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeBloc themeBloc;
  final LocaleBloc localeBloc;

  const MyApp({
    super.key,
    required this.themeBloc,
    required this.localeBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeBloc),
        BlocProvider.value(value: localeBloc),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ProductBloc()),
        BlocProvider(create: (_) => CustomerBloc()),
        BlocProvider(create: (_) => SaleBloc()),
        BlocProvider(create: (_) => UserBloc()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1920, 1080), // Desktop/Tablet design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<LocaleBloc, LocaleState>(
                builder: (context, localeState) {
                  return MaterialApp(
                    title: 'Retail Management System',
                    debugShowCheckedModeBanner: false,

                    // Theme configuration
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.themeMode,

                    // Localization configuration
                    locale: localeState.locale,
                    supportedLocales: LocaleState.supportedLocales,
                    localizationsDelegates: [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],

                    // Properly handle text direction for RTL languages
                    builder: (context, child) {
                      return Directionality(
                        textDirection: localeState.textDirection,
                        child: child!,
                      );
                    },

                    home: const AuthWrapper(),
                  );
                },
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
  // Use a GlobalKey to preserve LoginScreen state across rebuilds
  final GlobalKey<State<LoginScreen>> _loginScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authState is Authenticated) {
          return const DashboardScreen();
        }

        // Use key to preserve LoginScreen state when BlocBuilder rebuilds
        return LoginScreen(key: _loginScreenKey);
      },
    );
  }
}
