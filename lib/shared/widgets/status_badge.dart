import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Nada warna badge, sama dengan varian komponen Figma `Badge`.
enum StatusTone { success, brand, neutral }

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
      StatusTone.neutral => (AppColors.border, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: AppSpacing.md, color: foreground),
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
