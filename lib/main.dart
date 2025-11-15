import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:retail_management/l10n/app_localizations.dart';
import 'blocs/app_config/app_config_bloc.dart';
import 'blocs/app_config/app_config_event.dart';
import 'blocs/app_config/app_config_state.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/customer/customer_bloc.dart';
import 'blocs/sale/sale_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/dashboard/dashboard_bloc.dart';
import 'config/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/currency_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize combined app config bloc
  final appConfigBloc = AppConfigBloc()..add(const InitializeAppConfigEvent());

  // Initialize currency helper with company info
  await CurrencyHelper.loadCompanyInfo();

  // Wait for initialization
  await Future.delayed(const Duration(milliseconds: 100));

  runApp(MyApp(appConfigBloc: appConfigBloc));
}

class MyApp extends StatelessWidget {
  final AppConfigBloc appConfigBloc;

  const MyApp({super.key, required this.appConfigBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: appConfigBloc),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ProductBloc()),
        BlocProvider(create: (_) => CustomerBloc()),
        BlocProvider(create: (_) => SaleBloc()),
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => DashboardBloc()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1920, 1080), // Desktop/Tablet design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<AppConfigBloc, AppConfigState>(
            builder: (context, configState) {
              return MaterialApp(
                key: ValueKey('${configState.themeMode}-${configState.colorScheme.id}'),
                title: 'Retail Management System',
                debugShowCheckedModeBanner: false,

                // Theme configuration with custom colors
                theme: AppTheme.lightTheme(configState.colorScheme),
                darkTheme: AppTheme.darkTheme(configState.colorScheme),
                themeMode: configState.themeMode,

                // Localization configuration
                locale: configState.locale,
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('ar', 'SA'),
                ],
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
            body: Center(child: CircularProgressIndicator()),
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
