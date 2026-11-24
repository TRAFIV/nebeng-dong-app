import 'package:flutter/material.dart';
import 'package:praktikum_mobile/features/ride_search/models/saved_place.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Baris pintasan "Tempat tujuan": ketuk untuk mengisi Ke, tekan lama untuk
/// menghapus, "Tambah" untuk menyimpan tempat baru.
class SavedPlaceShortcuts extends StatelessWidget {
  const SavedPlaceShortcuts({
    super.key,
    required this.places,
    required this.isSelected,
    this.tagFor,
    required this.onSelect,
    required this.onRemove,
    this.onAdd,
  });

  final List<SavedPlace> places;
  final bool Function(SavedPlace place) isSelected;

  /// Label kecil kuning di pojok (mis. "Pagi ini"); `null` = tanpa label.
  final String? Function(SavedPlace place)? tagFor;
  final ValueChanged<SavedPlace> onSelect;
  final ValueChanged<SavedPlace> onRemove;

  /// `null` bila sudah penuh.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (final place in places)
        _Shortcut(
          key: ValueKey('saved-${place.name}'),
          name: place.name,
          kind: place.kind,
          selected: isSelected(place),
          tag: tagFor?.call(place),
          semanticHint: 'Isi tujuan dengan ${place.location.label}',
          onTap: () => onSelect(place),
          onLongPress: () => onRemove(place),
        ),
      if (onAdd != null)
        _Shortcut(
          key: const ValueKey('saved-add'),
          name: 'Tambah',
          kind: null,
          selected: false,
          semanticHint: 'Simpan tempat tujuan baru',
          onTap: onAdd!,
        ),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(child: i < items.length ? items[i] : const SizedBox()),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    super.key,
    required this.name,
    required this.kind,
    required this.selected,
    required this.semanticHint,
    required this.onTap,
    this.onLongPress,
    this.tag,
  });

  /// Label kecil kuning di pojok kanan atas ikon.
  final String? tag;

  final String name;

  /// `null` untuk tombol Tambah.
  final SavedPlaceKind? kind;
  final bool selected;
  final String semanticHint;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final (icon, background, foreground) = switch (kind) {
      SavedPlaceKind.campus => (
        Icons.school_rounded,
        AppColors.successSubtle,
        AppColors.successText,
      ),
      SavedPlaceKind.home => (
        Icons.home_rounded,
        AppColors.brandSubtle,
        AppColors.brandStrong,
      ),
      SavedPlaceKind.market => (
        Icons.storefront_rounded,
        const Color(0xFFFFF1CC),
        const Color(0xFF8A5A00),
      ),
      SavedPlaceKind.other => (
        Icons.place_rounded,
        AppColors.subtleFill,
        AppColors.textPrimary,
      ),
      null => (Icons.add_rounded, AppColors.surface, AppColors.textSecondary),
    };
    return Semantics(
      button: true,
      selected: selected,
      hint: semanticHint,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppRadius.controlAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.fast,
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: AppRadius.mdAll,
                      border: kind == null
                          ? Border.all(color: AppColors.border, width: 1.5)
                          : null,
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                color: AppColors.background,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: AppColors.brand,
                                spreadRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(icon, color: foreground, size: 24),
                  ),
                  if (tag != null)
                    Positioned(
                      top: -7,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentWarm,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag!,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onAccentWarm,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
