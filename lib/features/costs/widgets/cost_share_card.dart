import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/features/costs/utils/trip_date_format.dart';
import 'package:praktikum_mobile/features/costs/widgets/cost_badges.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Teks nominal ongkos; "Belum diatur" tidak pernah ditampilkan sebagai Rp0.
String fareText(CostShare share) =>
    share.isFareSet ? formatRupiah(share.farePerPerson!) : 'Belum diatur';

/// Kartu satu perjalanan pada layar Ongkos.
class CostShareCard extends StatelessWidget {
  const CostShareCard({super.key, required this.share, required this.onTap});

  final CostShare share;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations.card,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${share.origin} → ${share.destination}',
                        style: AppTextStyles.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      fareText(share),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: share.isFareSet
                            ? AppColors.brandStrong
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${formatTripDate(share.tripDate)} · ${share.driverName}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    FareStageBadge(stage: share.fareStage),
                    if (share.tripCompleted)
                      PaymentStatusBadge(status: share.paymentStatus),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
