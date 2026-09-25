import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeType {
  warning, // Amber / Orange
  success, // Green
  info,    // Blue
  neutral, // Muted Grey
  danger,  // Red
  purple,  // Purple / Custom
}

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final Color? customBgColor;
  final Color? customTextColor;
  final bool isPill;

  const AppBadge({
    super.key,
    required this.label,
    this.type = BadgeType.info,
    this.icon,
    this.customBgColor,
    this.customTextColor,
    this.isPill = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (customBgColor != null && customTextColor != null) {
      bg = customBgColor!;
      fg = customTextColor!;
    } else {
      switch (type) {
        case BadgeType.warning:
          bg = AppColors.accentOrangeBg;
          fg = const Color(0xFFD97706);
          break;
        case BadgeType.success:
          bg = AppColors.accentGreenBg;
          fg = const Color(0xFF059669);
          break;
        case BadgeType.info:
          bg = AppColors.primaryLight;
          fg = AppColors.primary;
          break;
        case BadgeType.neutral:
          bg = const Color(0xFFF1F5F9);
          fg = AppColors.textSecondary;
          break;
        case BadgeType.danger:
          bg = AppColors.accentRedBg;
          fg = AppColors.accentRed;
          break;
        case BadgeType.purple:
          bg = const Color(0xFFF3E8FF);
          fg = const Color(0xFF7E22CE);
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(isPill ? 20 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
