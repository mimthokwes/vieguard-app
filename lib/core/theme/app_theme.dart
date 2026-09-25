import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E3A8A); // Deep Navy Blue
  static const Color primaryDark = Color(0xFF0F2C59);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryBorder = Color(0xFFDBEAFE);

  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentOrangeBg = Color(0xFFFFFBEB);
  static const Color accentOrangeBorder = Color(0xFFFDE68A);

  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentGreenBg = Color(0xFFECFDF5);
  static const Color accentGreenBorder = Color(0xFFA7F3D0);

  static const Color accentTeal = Color(0xFF0D9488);
  static const Color accentTealBg = Color(0xFFF0FDFA);

  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentBlueBg = Color(0xFFEFF6FF);

  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentRedBg = Color(0xFFFEF2F2);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
    );
  }
}
