import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isSecondary;
  final bool isOutline;
  final bool isWarning;
  final bool isSuccess;
  final bool isFullWidth;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isSecondary = false,
    this.isOutline = false,
    this.isWarning = false,
    this.isSuccess = false,
    this.isFullWidth = true,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.primary;
    Color fg = Colors.white;
    BorderSide border = BorderSide.none;

    if (isSuccess) {
      bg = AppColors.accentGreen;
      fg = Colors.white;
    } else if (isWarning) {
      bg = AppColors.accentOrange;
      fg = Colors.white;
    } else if (isSecondary) {
      bg = AppColors.primaryLight;
      fg = AppColors.primary;
    } else if (isOutline) {
      bg = Colors.transparent;
      fg = AppColors.primary;
      border = const BorderSide(color: AppColors.primary, width: 1.5);
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: fg,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onPressed,
        child: content,
      ),
    );
  }
}
