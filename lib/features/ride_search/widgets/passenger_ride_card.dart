import 'package:flutter/material.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_search_matcher.dart';
import 'package:praktikum_mobile/shared/widgets/road_scene.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Kartu tebengan di Hasil Pencarian, tiga lapis:
/// 1. jam cabut + perkiraan lewat titik jemput | ongkos,
/// 2. DARI … KE … dengan jalan raya mini,
/// 3. pengemudi | sisa kursi.
class PassengerRideCard extends StatelessWidget {
  const PassengerRideCard({
    super.key,
    required this.ride,
    required this.onTap,
    this.match,
    this.phase = 0,
  });
  final Ride ride;
  final VoidCallback onTap;

  /// Hasil pencocokan; tanpa ini baris perkiraan jam lewat disembunyikan.
  final MatchedRide? match;

  /// Detik awal animasi jalan, agar kartu tidak bergerak serempak.
  final double phase;

  @override
  Widget build(BuildContext context) {
    final vehicle = ride.vehicle;
    final eta = match?.pickupEtaMinute;
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
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: ride.departureTime,
                                style: AppTextStyles.headingMedium.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const TextSpan(
                                text: '  cabut',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        if (eta != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '± ${formatMinuteOfDay(eta)} di titik jemputmu'
                            ' · jalan ${_walk(match!.walkMeters)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.successText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ride.farePerPerson == 0
                            ? 'Belum diatur'
                            : formatRupiah(ride.farePerPerson),
                        style: AppTextStyles.title.copyWith(fontSize: 15),
                      ),
                      Text(
                        ride.farePerPerson == 0 ? 'ongkos' : 'per orang',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.ms),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _End(
                      label: 'Dari',
                      color: AppColors.brandStrong,
                      place: ride.origin,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.ms),
                  Expanded(
                    child: _End(
                      label: 'Ke',
                      color: AppColors.successText,
                      place: ride.destination,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              RoadScene(vehicle: vehicle, phase: phase),
              const SizedBox(height: AppSpacing.ms),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: AppSpacing.ms),
              Row(
                children: [
                  UserAvatar(name: ride.driverName, size: 30),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driverName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF2A900),
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                '${ride.driverRating.toStringAsFixed(1).replaceAll('.', ',')}'
                                ' · ${vehicle.label}',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Boleh menyempit/turun baris saat teks diperbesar.
                  Flexible(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _SeatBadge(seats: ride.seatsAvailable),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dibulatkan ke 50 m terdekat; di atas 1 km memakai koma.
  static String _walk(double meters) {
    if (meters < 1000) {
      final rounded = ((meters / 50).round() * 50).clamp(50, 950);
      return '± $rounded m';
    }
    final km = (meters / 100).round() / 10;
    return '± ${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }
}

class _End extends StatelessWidget {
  const _End({
    required this.label,
    required this.color,
    required this.place,
    this.alignEnd = false,
  });

  final String label;
  final Color color;
  final String place;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        semanticsLabel: label,
        style: AppTextStyles.overline.copyWith(color: color),
      ),
      Text(
        place,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: AppTextStyles.labelLarge.copyWith(fontSize: 12),
      ),
    ],
  );
}

class _SeatBadge extends StatelessWidget {
  const _SeatBadge({required this.seats});

  final int seats;

  @override
  Widget build(BuildContext context) => switch (seats) {
    <= 0 => const StatusBadge(label: 'Penuh', tone: StatusTone.neutral),
    1 => const StatusBadge(
      label: 'Sisa 1 kursi!',
      icon: Icons.event_seat_outlined,
      tone: StatusTone.warning,
    ),
    _ => StatusBadge(
      label: 'Sisa $seats kursi',
      icon: Icons.event_seat_outlined,
      tone: StatusTone.success,
    ),
  };
}
