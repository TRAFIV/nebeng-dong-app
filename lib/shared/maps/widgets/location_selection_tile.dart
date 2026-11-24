import 'package:flutter/material.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Kolom Dari/Ke: ketuk untuk mencari tempat atau memilih pin di peta.
///
/// Pin oranye untuk asal, hijau untuk tujuan; label DARI/KE berwarna sama.
/// Saat lokasinya berganti (mis. ditukar), isinya meluncur masuk.
class LocationSelectionTile extends StatelessWidget {
  const LocationSelectionTile({
    super.key,
    required this.label,
    required this.onSearch,
    this.location,
    this.note,
  });
  final String label;
  final MapLocation? location;
  final VoidCallback onSearch;

  /// Keterangan kecil di samping label, mis. "lokasimu sekarang".
  final String? note;

  @override
  Widget build(BuildContext context) {
    final from = label == 'Dari';
    final tone = from ? AppColors.brand : AppColors.successText;
    final labelTone = from ? AppColors.brandStrong : AppColors.successText;
    return Material(
      color: AppColors.subtleFill,
      borderRadius: AppRadius.controlAll,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: ValueKey('select-$label'),
              borderRadius: AppRadius.controlAll,
              onTap: onSearch,
              child: Padding(
                // Sisi kanan dikosongkan untuk tombol tukar Dari/Ke.
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.ms,
                  AppSpacing.sm,
                  56,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: tone, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: AppMotion.reduced(context)
                            ? Duration.zero
                            : AppMotion.medium,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.35),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.centerLeft,
                          children: [...previous, ?current],
                        ),
                        child: _Value(
                          key: ValueKey(location),
                          label: label,
                          labelTone: labelTone,
                          location: location,
                          note: note,
                          placeholder: from
                              ? 'Pilih lokasi asal'
                              : 'Pilih tujuanmu',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    super.key,
    required this.label,
    required this.labelTone,
    required this.location,
    required this.note,
    required this.placeholder,
  });

  final String label;
  final Color labelTone;
  final MapLocation? location;
  final String? note;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final place = location;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: label.toUpperCase()),
              if (note != null)
                TextSpan(
                  text: ' · $note',
                  style: const TextStyle(letterSpacing: 0),
                ),
            ],
          ),
          semanticsLabel: label,
          style: AppTextStyles.overline.copyWith(color: labelTone),
        ),
        if (place != null) ...[
          Text(
            place.label,
            style: AppTextStyles.labelLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (place.address.isNotEmpty)
            Text(
              place.address,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ] else
          Text(
            placeholder,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
