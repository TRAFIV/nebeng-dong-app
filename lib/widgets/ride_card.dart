import 'package:flutter/material.dart';

import '../models/ride.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/rupiah_format.dart';
import 'user_avatar.dart';

/// Kartu tebengan pada daftar Home (komponen Figma `Ride Card`).
class RideCard extends StatelessWidget {
  const RideCard({super.key, required this.ride, required this.onTap});

  final Ride ride;
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
                  children: [
                    UserAvatar(name: ride.driverName),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.driverName,
                            style: AppTextStyles.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Rating ${ride.driverRating.toStringAsFixed(1)} · '
                            'Cabut jam ${ride.departureTime}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Dari: ${ride.origin}', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Ke: ${ride.destination}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _SeatBadge(ride: ride),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${formatRupiah(ride.farePerPerson)}/orang',
                        style: AppTextStyles.labelLarge,
                        textAlign: TextAlign.end,
                      ),
                    ),
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

class _SeatBadge extends StatelessWidget {
  const _SeatBadge({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    final isFull = ride.isFull;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isFull ? AppColors.border : AppColors.brandSubtle,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        isFull ? 'Udah penuh' : 'Sisa ${ride.seatsAvailable} kursi',
        style: AppTextStyles.labelLarge.copyWith(
          color: isFull ? AppColors.textSecondary : AppColors.brand,
        ),
      ),
    );
  }
}
