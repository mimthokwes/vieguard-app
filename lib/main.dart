import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';

void main() {
  runApp(const VieguardAdminApp());
}

class VieguardAdminApp extends StatelessWidget {
  const VieguardAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIEGUARD Admin Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
