import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Shared pill surface for editable and read-only locations.
class LocationPill extends StatelessWidget {
  const LocationPill({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: AppSizes.locationHeight),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: const BoxDecoration(
      color: AppColors.locationFill,
      borderRadius: AppRadius.mdAll,
      border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
    ),
    child: child,
  );
}

/// Dotted endpoint rail grows with validators/autocomplete, without fixed form height.
class RouteEndpoints extends StatelessWidget {
  const RouteEndpoints({
    super.key,
    required this.origin,
    required this.destination,
    this.onSwap,
  });
  final Widget origin;
  final Widget destination;
  final VoidCallback? onSwap;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Padding(
        padding: EdgeInsets.only(
          right: onSwap == null ? 0 : AppSizes.touchTarget,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: AppSizes.routeRail,
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        Semantics(
                          label: 'Titik berangkat',
                          child: Container(
                            width: AppSpacing.md,
                            height: AppSpacing.md,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.routeOrigin,
                              border: Border.all(
                                color: AppColors.locationFill,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Expanded(
                          child: CustomPaint(
                            painter: _RouteDots(),
                            child: SizedBox(width: AppSizes.routeRail),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: origin,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md + AppSpacing.xs),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.routeDestination,
                    size: AppSizes.routeRail,
                    semanticLabel: 'Titik tujuan',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: destination),
              ],
            ),
          ],
        ),
      ),
      if (onSwap != null)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: IconButton.filledTonal(
              tooltip: 'Tukar asal dan tujuan',
              onPressed: onSwap,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.brandSubtle,
                foregroundColor: AppColors.routeOrigin,
              ),
              icon: const Icon(Icons.swap_vert_rounded),
            ),
          ),
        ),
    ],
  );
}

/// Same endpoint language on cards, details, and owned routes.
class RouteLocationSummary extends StatelessWidget {
  const RouteLocationSummary({
    super.key,
    required this.origin,
    required this.destination,
    this.originAddress,
    this.destinationAddress,
  });
  final String origin;
  final String destination;
  final String? originAddress;
  final String? destinationAddress;

  Widget _location(String label, String value, String? address) => LocationPill(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.bodyMedium),
        if (address != null && address.isNotEmpty && address != value) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(address, style: AppTextStyles.bodyMedium),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => RouteEndpoints(
    origin: _location('Dari', origin, originAddress),
    destination: _location('Ke', destination, destinationAddress),
  );
}

class _RouteDots extends CustomPainter {
  const _RouteDots();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.routeConnector;
    for (double y = AppSpacing.xs; y < size.height; y += AppSpacing.sm) {
      canvas.drawCircle(Offset(size.width / 2, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(_RouteDots oldDelegate) => false;
}
