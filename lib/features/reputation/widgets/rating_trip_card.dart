import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';

import 'package:flutter/material.dart';

import '../models/trip_rating.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';

class RatingTripCard extends StatelessWidget {
  const RatingTripCard({
    super.key,
    required this.trip,
    this.showFare = true,
    this.footer,
  });
  final RatingTrip trip;
  final bool showFare;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: AppRadius.mdAll,
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(name: trip.driverName),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.driverName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Pengemudi',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...[
          Text(
            '${trip.dateLabel} · ${trip.completed ? 'Selesai' : 'Belum selesai'}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
        ],
        Text('Dari: ${trip.origin}'),
        const SizedBox(height: 8),
        Text('Ke: ${trip.destination}'),
        if (showFare) ...[
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Ongkos perjalanan',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Text('Rp5.000', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
        if (footer != null) ...[
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: footer!),
        ],
      ],
    ),
  );
}
