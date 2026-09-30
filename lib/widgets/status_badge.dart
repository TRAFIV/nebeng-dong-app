import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Nada warna badge, sama dengan varian komponen Figma `Badge`.
enum StatusTone { success, brand, neutral }

/// Label status kecil (komponen Figma `Badge`).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusTone.brand,
  });

  final String label;
  final StatusTone tone;

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
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: foreground),
      ),
    );
  }
}
