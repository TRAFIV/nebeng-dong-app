import 'package:flutter/material.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// M1 Location Input: field opens search, right-hand action opens the pin map.
class LocationSelectionTile extends StatelessWidget {
  const LocationSelectionTile({
    super.key,
    required this.label,
    required this.onSearch,
    required this.onMap,
    this.location,
  });
  final String label;
  final MapLocation? location;
  final VoidCallback onSearch;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    final from = label == 'Dari';
    return DecoratedBox(
      decoration: AppDecorations.outlined,
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                key: ValueKey('select-$label'),
                borderRadius: AppRadius.mdAll,
                onTap: onSearch,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: from ? AppColors.brandStrong : AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: AppTextStyles.labelLarge),
                            if (location != null) ...[
                              Text(
                                location!.label,
                                style: AppTextStyles.labelLarge,
                              ),
                              if (location!.address.isNotEmpty)
                                Text(
                                  location!.address,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ] else
                              Text(
                                from ? 'Pilih lokasi asal' : 'Pilih tujuanmu',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              key: ValueKey('pin-$label'),
              tooltip: location == null
                  ? 'Pilih pin $label di peta'
                  : 'Ubah pin $label di peta',
              onPressed: onMap,
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.brandStrong,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
