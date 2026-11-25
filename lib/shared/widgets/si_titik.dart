import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';

/// Ekspresi Si Titik.
enum SiTitikMood { greet, search, happy, sad }

/// Gerak Si Titik. [jump] sekali jalan (dua lompatan); lainnya berulang.
enum SiTitikMotion { none, idle, sway, jump }

/// Maskot Nebeng Dong: titik pada logo yang dihidupkan.
///
/// Digambar dengan [CustomPainter], tanpa aset gambar. [onBrand] dipakai di
/// atas latar oranye (tubuh putih); selain itu tubuhnya oranye.
class SiTitik extends StatefulWidget {
  const SiTitik({
    super.key,
    this.mood = SiTitikMood.greet,
    this.motion = SiTitikMotion.idle,
    this.size = 56,
    this.onBrand = false,
    this.semanticLabel,
  });

  final SiTitikMood mood;
  final SiTitikMotion motion;
  final double size;
  final bool onBrand;

  /// Label pembaca layar; `null` berarti hiasan saja.
  final String? semanticLabel;

  @override
  State<SiTitik> createState() => _SiTitikState();
}

class _SiTitikState extends State<SiTitik> with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );
  late final AnimationController _jump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _ambient = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ambient = AppMotion.ambientOf(context);
    _syncMotion();
  }

  @override
  void didUpdateWidget(SiTitik oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion != widget.motion) _syncMotion();
  }

  void _syncMotion() {
    final loops =
        _ambient &&
        (widget.motion == SiTitikMotion.idle ||
            widget.motion == SiTitikMotion.sway);
    if (loops) {
      if (!_loop.isAnimating) _loop.repeat(reverse: true);
      if (!_blink.isAnimating) _blink.repeat();
    } else {
      _loop.stop();
      _blink.stop();
      _loop.value = 0;
      _blink.value = 0;
    }
    if (widget.motion == SiTitikMotion.jump &&
        !AppMotion.reduced(context) &&
        !_jump.isAnimating) {
      _jump.repeat(count: 2);
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _blink.dispose();
    _jump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final art = AnimatedBuilder(
      animation: Listenable.merge([_loop, _blink, _jump]),
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _SiTitikPainter(
          mood: widget.mood,
          onBrand: widget.onBrand,
          blink: _blinkAmount(_blink.value),
          dy: _dy(),
          angle: widget.motion == SiTitikMotion.sway
              ? (Curves.easeInOut.transform(_loop.value) - 0.5) *
                    8 *
                    math.pi /
                    180
              : 0,
          squash: widget.motion == SiTitikMotion.jump
              ? _squash(_jump.value)
              : 0,
        ),
      ),
    );
    final label = widget.semanticLabel;
    return label == null
        ? ExcludeSemantics(child: art)
        : Semantics(label: label, image: true, child: art);
  }

  double _dy() => switch (widget.motion) {
    SiTitikMotion.idle => -3 * Curves.easeInOut.transform(_loop.value),
    SiTitikMotion.jump => -16 * math.sin(math.pi * _jump.value),
    _ => 0,
  };

  /// Pipih saat mendarat, memanjang saat melayang.
  static double _squash(double t) => 0.07 * math.cos(2 * math.pi * t);

  /// Mata tertutup sebentar sekitar 95% siklus.
  static double _blinkAmount(double t) {
    const center = 0.95;
    const half = 0.03;
    final d = (t - center).abs();
    return d >= half ? 0 : 1 - d / half;
  }
}

class _SiTitikPainter extends CustomPainter {
  _SiTitikPainter({
    required this.mood,
    required this.onBrand,
    required this.blink,
    required this.dy,
    required this.angle,
    required this.squash,
  });

  final SiTitikMood mood;
  final bool onBrand;
  final double blink;
  final double dy;
  final double angle;
  final double squash;

  @override
  void paint(Canvas canvas, Size size) {
    // Semua koordinat dalam kotak 64 × 64.
    final k = size.width / 64;
    canvas
      ..save()
      ..scale(k)
      ..translate(32, 56)
      ..rotate(angle)
      ..scale(1 + squash, 1 - squash)
      ..translate(-32, -56 + dy);

    final body = onBrand ? AppColors.surface : AppColors.brand;
    final face = onBrand ? AppColors.textPrimary : AppColors.surface;
    final cheek = onBrand ? const Color(0xFFFF9C7F) : const Color(0xFFFFB59E);

    canvas.drawCircle(const Offset(32, 34), 21, Paint()..color = body);
    canvas
      ..save()
      ..translate(24, 22)
      ..rotate(-25 * math.pi / 180)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: 12, height: 7),
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      )
      ..restore();
    final cheekPaint = Paint()..color = cheek.withValues(alpha: 0.75);
    canvas
      ..drawCircle(const Offset(20, 39), 3.2, cheekPaint)
      ..drawCircle(const Offset(44, 39), 3.2, cheekPaint);

    final fill = Paint()..color = face;
    final stroke = Paint()
      ..color = face
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    _eyes(canvas, fill, stroke);
    _mouth(canvas, fill, stroke);
    canvas.restore();
  }

  void _eyes(Canvas canvas, Paint fill, Paint stroke) {
    final open = 1 - 0.9 * blink;
    void eye(double x, double y, double w, double h) => canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: w, height: h * open),
      fill,
    );
    switch (mood) {
      case SiTitikMood.greet:
        eye(25, 31, 6.4, 8.4);
        eye(39, 31, 6.4, 8.4);
      case SiTitikMood.search:
        eye(28, 31, 6.4, 8.4);
        eye(42, 31, 6.4, 8.4);
      case SiTitikMood.happy:
        canvas.drawPath(
          Path()
            ..moveTo(21.5, 31.5)
            ..quadraticBezierTo(25, 27, 28.5, 31.5)
            ..moveTo(35.5, 31.5)
            ..quadraticBezierTo(39, 27, 42.5, 31.5),
          stroke,
        );
      case SiTitikMood.sad:
        eye(25, 33, 6, 6.8);
        eye(39, 33, 6, 6.8);
        canvas.drawPath(
          Path()
            ..moveTo(20.5, 26.5)
            ..lineTo(26.5, 28.3)
            ..moveTo(43.5, 26.5)
            ..lineTo(37.5, 28.3),
          stroke..strokeWidth = 2.4,
        );
        stroke.strokeWidth = 3;
    }
  }

  void _mouth(Canvas canvas, Paint fill, Paint stroke) {
    switch (mood) {
      case SiTitikMood.greet:
        canvas.drawPath(
          Path()
            ..moveTo(27, 40.5)
            ..quadraticBezierTo(32, 44.5, 37, 40.5),
          stroke,
        );
      case SiTitikMood.search:
        canvas.drawCircle(const Offset(35, 42), 2.2, fill);
      case SiTitikMood.happy:
        canvas.drawPath(
          Path()
            ..moveTo(25.5, 39)
            ..lineTo(38.5, 39)
            ..quadraticBezierTo(37.3, 46.5, 32, 46.5)
            ..quadraticBezierTo(26.7, 46.5, 25.5, 39)
            ..close(),
          fill,
        );
      case SiTitikMood.sad:
        canvas.drawPath(
          Path()
            ..moveTo(27, 43.5)
            ..quadraticBezierTo(32, 39.5, 37, 43.5),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(_SiTitikPainter old) =>
      old.mood != mood ||
      old.onBrand != onBrand ||
      old.blink != blink ||
      old.dy != dy ||
      old.angle != angle ||
      old.squash != squash;
}
