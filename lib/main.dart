import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/api/api_client.dart';
import 'core/services/local_notification_service.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/splash/splash_screen.dart';
import 'state/auth_provider.dart';
import 'state/chat_provider.dart';
import 'state/notification_provider.dart';
import 'state/order_provider.dart';
import 'state/payment_provider.dart';
import 'state/product_provider.dart';
import 'state/rental_provider.dart';
import 'state/report_provider.dart';
import 'widgets/auth/auth_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('id_ID', null);
  await LocalNotificationService.initialize();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage: tokenStorage);

  runApp(VieguardApp(apiClient: apiClient, tokenStorage: tokenStorage));
}

class VieguardApp extends StatelessWidget {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  const VieguardApp({super.key, required this.apiClient, required this.tokenStorage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient: apiClient, tokenStorage: tokenStorage)..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => OrderProvider(apiClient: apiClient)..initFromCache()),
        ChangeNotifierProvider(create: (_) => RentalProvider(apiClient: apiClient)..initFromCache()),
        ChangeNotifierProvider(create: (_) => PaymentProvider(apiClient: apiClient)..initFromCache()),
        ChangeNotifierProvider(create: (_) => ProductProvider(apiClient: apiClient)..initFromCache()),
        ChangeNotifierProvider(create: (_) => ChatProvider(apiClient: apiClient, tokenStorage: tokenStorage)),
        ChangeNotifierProvider(create: (_) => ReportProvider(apiClient: apiClient)..initFromCache()),
        ChangeNotifierProvider(create: (_) => NotificationProvider(apiClient: apiClient)..initFromCache()),
      ],
      child: MaterialApp(
        title: 'VIEGUARD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        scrollBehavior: const AppScrollBehavior(),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _splashCompleted = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashCompleted) {
      return SplashScreen(
        onFinished: () {
          if (mounted) {
            setState(() => _splashCompleted = true);
          }
        },
      );
    }

    final status = context.watch<AuthProvider>().status;
    Widget currentScreen;
    switch (status) {
      case AuthStatus.unknown:
        currentScreen = const Scaffold(
          backgroundColor: AuthColors.maroonBottom,
          body: Center(
            child: CircularProgressIndicator(color: AuthColors.goldLight),
          ),
        );
        break;
      case AuthStatus.authenticated:
        currentScreen = const MainShell();
        break;
      case AuthStatus.unauthenticated:
        currentScreen = const LoginScreen();
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: currentScreen,
    );
  }
}
