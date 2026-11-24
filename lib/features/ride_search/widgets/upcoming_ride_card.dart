import 'package:flutter/material.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/upcoming_rides_view_model.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Kartu kecil "Berangkat sebentar lagi": jam + hitung mundur, ongkos,
/// rute dua baris, lalu pengemudi dan sisa kursi.
class UpcomingRideCard extends StatelessWidget {
  const UpcomingRideCard({
    super.key,
    required this.item,
    required this.onTap,
    this.highlight = false,
  });

  final UpcomingRide item;
  final VoidCallback onTap;

  /// Kartu paling dekat jamnya: hitung mundur berwarna oranye.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ride = item.ride;
    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.ms),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.departureTime,
                          style: AppTextStyles.headingMedium.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          'cabut ${_countdown(item.minutesUntil)}',
                          style: AppTextStyles.caption.copyWith(
                            color: highlight
                                ? AppColors.brandStrong
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ride.farePerPerson == 0
                        ? 'Belum diatur'
                        : formatRupiah(ride.farePerPerson),
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.ms),
              _Stop(color: AppColors.brand, label: ride.origin),
              const SizedBox(height: AppSpacing.xs),
              _Stop(color: AppColors.successText, label: ride.destination),
              const SizedBox(height: AppSpacing.ms),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: AppSpacing.ms),
              Row(
                children: [
                  UserAvatar(name: ride.driverName, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      ride.driverName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(
                    label: ride.seatsAvailable == 1
                        ? 'Sisa 1!'
                        : 'Sisa ${ride.seatsAvailable}',
                    icon: Icons.event_seat_outlined,
                    tone: ride.seatsAvailable == 1
                        ? StatusTone.warning
                        : StatusTone.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _countdown(int minutes) {
    if (minutes < 60) return '$minutes mnt lagi';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours jam lagi' : '$hours jam $rest mnt lagi';
  }
}

class _Stop extends StatelessWidget {
  const _Stop({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.location_on_rounded, size: 15, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(fontSize: 12),
        ),
      ),
    ],
  );
}
