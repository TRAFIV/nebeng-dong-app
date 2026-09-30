import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Kotak info dua baris: label di atas, nilai di bawah
/// (komponen Figma `Info Tile`).
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.positive = false,
  });

  final String label;
  final String value;

  /// Kotak hijau untuk info yang bersifat positif, misalnya sisa kursi.
  final bool positive;

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
