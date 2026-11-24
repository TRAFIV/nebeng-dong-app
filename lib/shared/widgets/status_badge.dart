import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Nada warna badge, sama dengan varian komponen Figma `Badge`.
enum StatusTone { success, brand, neutral, warning }

/// Label status kecil (komponen Figma `Badge`).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusTone.brand,
    this.icon,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      StatusTone.success => (AppColors.successSubtle, AppColors.successText),
      StatusTone.brand => (AppColors.brandSubtle, AppColors.brandStrong),
      StatusTone.neutral => (AppColors.subtleFill, AppColors.textPrimary),
      StatusTone.warning => (AppColors.accentWarm, AppColors.onAccentWarm),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pill,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 14, color: foreground),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
