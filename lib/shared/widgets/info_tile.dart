import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Kotak info dua baris: label di atas, nilai di bawah
/// (komponen Figma `Info Tile`).
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.positive = false,
    this.icon,
  });

  final String label;
  final String value;

  /// Kotak hijau untuk info yang bersifat positif, misalnya sisa kursi.
  final bool positive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: positive ? AppColors.successSubtle : AppColors.brandSubtle,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: positive ? AppColors.successText : AppColors.brandStrong,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(
              color: positive ? AppColors.successText : AppColors.brandStrong,
            ),
          ),
        ],
      ),
    );
  }
}
