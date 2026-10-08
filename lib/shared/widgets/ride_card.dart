import 'package:flutter/material.dart';

import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/shared/maps/widgets/route_endpoints.dart';

/// Kartu tebengan pada daftar Home (komponen Figma `Ride Card`).
class RideCard extends StatelessWidget {
  const RideCard({
    super.key,
    required this.ride,
    required this.onTap,
    this.owned = false,
  });

  final Ride ride;
  final VoidCallback onTap;
  final bool owned;

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
                            owned
                                ? 'Rute ${ride.origin} → ${ride.destination}'
                                : ride.driverName,
                            style: AppTextStyles.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            owned
                                ? '${ride.schedule} · Cabut ${ride.departureTime}'
                                : 'Rating ${ride.driverRating.toStringAsFixed(1)} · '
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
                RouteLocationSummary(
                  origin: ride.origin,
                  destination: ride.destination,
                  originAddress: ride.geography?.origin.address,
                  destinationAddress: ride.geography?.destination.address,
                ),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final badge = StatusBadge(
                      icon: ride.isFull
                          ? Icons.event_seat
                          : Icons.event_seat_outlined,
                      label: ride.isFull
                          ? 'Udah penuh'
                          : 'Sisa ${ride.seatsAvailable} kursi',
                      tone: ride.isFull
                          ? StatusTone.neutral
                          : StatusTone.success,
                    );
                    final fare = Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          size: AppSpacing.md,
                          color: AppColors.brandStrong,
                        ),
                        Text(
                          ride.farePerPerson == 0
                              ? 'Ongkos belum diatur'
                              : '${formatRupiah(ride.farePerPerson)}/orang',
                          style: AppTextStyles.labelLarge,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    );
                    if (constraints.maxWidth < 280 ||
                        MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          badge,
                          const SizedBox(height: AppSpacing.sm),
                          fare,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        badge,
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: fare),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
