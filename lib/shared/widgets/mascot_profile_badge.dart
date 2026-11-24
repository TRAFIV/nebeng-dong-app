import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:praktikum_mobile/shared/widgets/si_titik.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';

/// Lencana kanan atas Cari: Si Titik di depan, avatar profil di belakang.
///
/// Tiap [cycle] berputar seperti koin memperlihatkan avatar sebentar, lalu
/// kembali ke Si Titik. Diam di sisi Si Titik bila gerak berulang dimatikan
/// ([AppMotion.ambientOf]). Ketuk untuk membuka profil bila [onTap] ada.
class MascotProfileBadge extends StatefulWidget {
  const MascotProfileBadge({
    super.key,
    required this.name,
    this.onTap,
    this.size = 56,
    this.cycle = const Duration(seconds: 8),
  });

  final String name;
  final VoidCallback? onTap;
  final double size;
  final Duration cycle;

  @override
  State<MascotProfileBadge> createState() => _MascotProfileBadgeState();
}

class _MascotProfileBadgeState extends State<MascotProfileBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cycle = AnimationController(
    vsync: this,
    duration: widget.cycle,
  );

  // Bagian siklus 8 detik: depan ±5 detik, putar 0,6 detik, belakang ±2
  // detik, putar balik 0,6 detik.
  static const _flipOutStart = 0.6;
  static const _flipOutEnd = 0.675;
  static const _flipBackStart = 0.9;
  static const _flipBackEnd = 0.975;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.ambientOf(context)) {
      if (!_cycle.isAnimating) _cycle.repeat();
    } else {
      _cycle
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  /// Sudut putar (0 = Si Titik menghadap depan, π = avatar menghadap depan).
  double _angle(double t) {
    double eased(double from, double to) =>
        Curves.easeInOutBack.transform(((t - from) / (to - from)).clamp(0, 1));
    if (t < _flipOutStart) return 0;
    if (t < _flipOutEnd) return math.pi * eased(_flipOutStart, _flipOutEnd);
    if (t < _flipBackStart) return math.pi;
    if (t < _flipBackEnd) {
      return math.pi * (1 - eased(_flipBackStart, _flipBackEnd));
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final coin = AnimatedBuilder(
      animation: _cycle,
      builder: (context, _) {
        final angle = _angle(_cycle.value);
        final showBack = angle.abs() > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: showBack
              // Diputar balik sekali lagi agar huruf tidak terbalik.
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: _Back(name: widget.name, size: widget.size),
                )
              : SiTitik(onBrand: true, size: widget.size),
        );
      },
    );
    final onTap = widget.onTap;
    if (onTap == null) return ExcludeSemantics(child: coin);
    return Tooltip(
      message: 'Buka profil',
      child: Semantics(
        button: true,
        label: 'Buka profil',
        child: InkResponse(
          onTap: onTap,
          radius: widget.size / 2 + 4,
          child: ExcludeSemantics(child: coin),
        ),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Center(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: UserAvatar(name: name, size: size * 0.74),
        ),
      ),
    ),
  );
}
