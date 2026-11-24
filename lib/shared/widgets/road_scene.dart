import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';

/// Jalan raya mini di kartu tebengan: pemandangan bergeser dengan kecepatan
/// berlapis, marka berlari, kendaraan bergetar dan rodanya berputar, pin
/// asal (oranye) dan tujuan (hijau) di kedua ujung.
///
/// Hanya bergerak bila [AppMotion.ambientOf]; selain itu diam pada [phase].
class RoadScene extends StatefulWidget {
  const RoadScene({
    super.key,
    required this.vehicle,
    this.phase = 0,
    this.height = 46,
  });

  final VehicleKind vehicle;

  /// Detik awal animasi, agar kartu berdekatan tidak bergerak serempak.
  final double phase;
  final double height;

  @override
  State<RoadScene> createState() => _RoadSceneState();
}

class _RoadSceneState extends State<RoadScene>
    with SingleTickerProviderStateMixin {
  /// Semua periode gerak membagi habis 18 detik, jadi putaran ulang mulus.
  static const _cycle = 18.0;
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.ambientOf(context)) {
      if (!_clock.isAnimating) _clock.repeat();
    } else {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRect(
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => CustomPaint(
          size: Size.fromHeight(widget.height),
          painter: _RoadPainter(
            vehicle: widget.vehicle,
            seconds: (_clock.value * _cycle + widget.phase) % _cycle,
          ),
        ),
      ),
    ),
  );
}

class _RoadPainter extends CustomPainter {
  _RoadPainter({required this.vehicle, required this.seconds});

  final VehicleKind vehicle;
  final double seconds;

  static const _road = Color(0xFFECEEF4);
  static const _building = Color(0xFFE3E7F0);
  static const _window = Color(0xFFF7F8FB);
  static const _leaf = Color(0xFF9ED9BD);
  static const _leafDark = Color(0xFF86CFAE);
  static const _trunk = Color(0xFFB58D6C);
  static const _glass = Color(0xFFCFE8F5);
  static const _skin = Color(0xFFE7A07A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const roadHeight = 9.0;
    final roadTop = h - roadHeight;

    // Gedung jauh: tinggi 26, satu putaran per 18 detik.
    _tiled(canvas, w, 26 / 46, 240, 46, roadTop, seconds / 18, _drawFar);
    // Pohon dan rumah: tinggi 19, satu putaran per 6 detik.
    _tiled(canvas, w, 19 / 34, 200, 34, roadTop + 1, seconds / 6, _drawMid);

    // Jalan dan marka putih yang berlari.
    canvas.drawRect(
      Rect.fromLTWH(0, roadTop, w, roadHeight),
      Paint()..color = _road,
    );
    final dash = Paint()..color = Colors.white;
    final dashShift = (seconds / 0.5 % 1) * 18;
    for (double x = -dashShift; x < w; x += 18) {
      canvas.drawRect(Rect.fromLTWH(x, roadTop + 3.5, 9, 2), dash);
    }

    _drawVehicle(canvas, w, roadTop);
    _drawPin(canvas, Offset(8, h - 1), AppColors.brand);
    _drawPin(canvas, Offset(w - 8, h - 1), AppColors.successText);
  }

  /// Ubin pemandangan ([tileWidth] × [tileHeight]) diskalakan dan diulang ke
  /// kanan, digeser sebanyak [progress] ubin.
  void _tiled(
    Canvas canvas,
    double width,
    double scale,
    double tileWidth,
    double tileHeight,
    double bottom,
    double progress,
    void Function(Canvas) draw,
  ) {
    final scaledTile = tileWidth * scale;
    final shift = (progress % 1) * scaledTile;
    for (double x = -shift; x < width; x += scaledTile) {
      canvas
        ..save()
        ..translate(x, bottom)
        ..scale(scale)
        ..translate(0, -tileHeight);
      draw(canvas);
      canvas.restore();
    }
  }

  void _drawFar(Canvas canvas) {
    final building = Paint()..color = _building;
    for (final r in const [
      Rect.fromLTWH(4, 20, 24, 26),
      Rect.fromLTWH(32, 8, 16, 38),
      Rect.fromLTWH(54, 24, 28, 22),
      Rect.fromLTWH(100, 14, 20, 32),
      Rect.fromLTWH(128, 26, 30, 20),
      Rect.fromLTWH(178, 4, 18, 42),
      Rect.fromLTWH(202, 18, 26, 28),
    ]) {
      canvas.drawRect(r, building);
    }
    final window = Paint()..color = _window;
    for (final o in const [
      Offset(36, 13),
      Offset(42, 13),
      Offset(36, 20),
      Offset(42, 20),
      Offset(104, 19),
      Offset(112, 19),
      Offset(182, 10),
      Offset(189, 10),
      Offset(182, 17),
      Offset(189, 17),
    ]) {
      canvas.drawRect(o & const Size(3, 3), window);
    }
  }

  void _drawMid(Canvas canvas) {
    final trunk = Paint()..color = _trunk;
    final leaf = Paint()..color = _leaf;
    final white = Paint()..color = Colors.white;
    final outline = Paint()
      ..color = _building
      ..style = PaintingStyle.stroke;
    final glass = Paint()..color = _glass;
    // Pohon 1
    canvas
      ..drawRect(const Rect.fromLTWH(13, 20, 3, 14), trunk)
      ..drawCircle(const Offset(14.5, 15), 9, leaf)
      ..drawCircle(const Offset(20, 20), 6, Paint()..color = _leafDark);
    // Rumah atap oranye
    canvas
      ..drawRect(const Rect.fromLTWH(46, 16, 28, 18), white)
      ..drawRect(const Rect.fromLTWH(46, 16, 28, 18), outline)
      ..drawPath(
        Path()
          ..moveTo(43, 17)
          ..lineTo(60, 5)
          ..lineTo(77, 17)
          ..close(),
        Paint()..color = const Color(0xFFF6B39C),
      )
      ..drawRect(
        const Rect.fromLTWH(57, 24, 6, 10),
        Paint()..color = const Color(0xFFF6B39C),
      )
      ..drawRect(const Rect.fromLTWH(49, 20, 6, 5), glass);
    // Pohon 2
    canvas
      ..drawRect(const Rect.fromLTWH(108.5, 20, 3, 14), trunk)
      ..drawCircle(const Offset(110, 14), 10, leaf);
    // Rumah atap kuning
    canvas
      ..drawRect(const Rect.fromLTWH(135, 14, 32, 20), white)
      ..drawRect(const Rect.fromLTWH(135, 14, 32, 20), outline)
      ..drawPath(
        Path()
          ..moveTo(132, 15)
          ..lineTo(151, 2)
          ..lineTo(170, 15)
          ..close(),
        Paint()..color = const Color(0xFFFFD98A),
      )
      ..drawRect(const Rect.fromLTWH(140, 19, 7, 6), glass)
      ..drawRect(const Rect.fromLTWH(155, 19, 7, 6), glass);
    // Tiang lampu
    canvas
      ..drawRect(
        const Rect.fromLTWH(187, 6, 2, 28),
        Paint()..color = const Color(0xFFC9CEDB),
      )
      ..drawCircle(
        const Offset(190, 7),
        2.6,
        Paint()..color = AppColors.accentWarm,
      );
  }

  void _drawVehicle(Canvas canvas, double width, double roadTop) {
    final motor = vehicle == VehicleKind.motor;
    final drawWidth = motor ? 38.0 : 44.0;
    final boxWidth = motor ? 64.0 : 76.0;
    final boxHeight = motor ? 50.0 : 46.0;
    final scale = drawWidth / boxWidth;

    // Maju-mundur pelan di antara kedua pin (periode 9 detik).
    final wave = 1 - ((seconds / 4.5) % 2 - 1).abs();
    final progress = 0.12 + 0.46 * Curves.easeInOut.transform(wave);
    final left = (width - drawWidth) * progress;
    // Getar halus (periode 0,15 detik).
    final shake = math.sin(seconds / 0.15 * 2 * math.pi);
    final dy = -0.6 * shake.abs();
    final dx = 0.3 * shake;
    final top = roadTop + 7 - boxHeight * scale + dy;

    _drawSpeedLines(canvas, Offset(left - 2, roadTop - 1));

    canvas
      ..save()
      ..translate(left + dx, top)
      ..scale(scale);
    final wheelAngle = seconds / 0.4 * 2 * math.pi;
    if (motor) {
      _drawMotor(canvas, wheelAngle);
    } else {
      _drawCar(canvas, wheelAngle);
    }
    canvas.restore();
  }

  void _drawSpeedLines(Canvas canvas, Offset anchor) {
    final paint = Paint()
      ..color = AppColors.brand
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const lines = [(0.0, 9.0, 0.0), (4.0, 6.0, 0.33), (8.0, 8.0, 0.6)];
    for (final (y, length, delay) in lines) {
      final t = ((seconds / 0.75) + delay) % 1;
      final opacity = t < 0.3 ? t / 0.3 * 0.8 : 0.8 * (1 - (t - 0.3) / 0.7);
      final x = anchor.dx + 4 - 16 * t;
      canvas.drawLine(
        Offset(x - length, anchor.dy - 10 + y),
        Offset(x, anchor.dy - 10 + y),
        paint..color = AppColors.brand.withValues(alpha: opacity),
      );
    }
  }

  void _drawWheel(Canvas canvas, Offset center, double angle) {
    canvas.drawCircle(center, 7, Paint()..color = AppColors.textPrimary);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(angle)
      ..drawCircle(Offset.zero, 2.6, Paint()..color = Colors.white)
      ..drawLine(
        const Offset(0, -4.5),
        const Offset(0, 4.5),
        Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = 1.3,
      )
      ..drawLine(
        const Offset(-4.5, 0),
        const Offset(4.5, 0),
        Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = 1.3,
      )
      ..restore();
  }

  void _drawMotor(Canvas canvas, double wheelAngle) {
    canvas.drawPath(
      Path()
        ..moveTo(4, 41)
        ..cubicTo(4, 32, 10, 28, 19, 28)
        ..lineTo(29, 28)
        ..lineTo(32, 36)
        ..lineTo(43, 36)
        ..lineTo(47, 16)
        ..lineTo(51, 16)
        ..lineTo(53, 27)
        ..cubicTo(58, 29, 60, 33, 60, 41)
        ..close(),
      Paint()..color = AppColors.brand,
    );
    canvas
      ..drawRRect(
        RRect.fromLTRBR(13, 25, 30, 29, const Radius.circular(2)),
        Paint()..color = AppColors.textPrimary,
      )
      ..drawPath(
        Path()
          ..moveTo(21, 27)
          ..lineTo(31, 27)
          ..lineTo(38, 35)
          ..lineTo(35, 37)
          ..lineTo(28, 31)
          ..lineTo(21, 31)
          ..close(),
        Paint()..color = AppColors.textPrimary,
      )
      ..drawPath(
        Path()
          ..moveTo(18, 28)
          ..lineTo(22, 14)
          ..quadraticBezierTo(26.5, 10, 31, 14)
          ..lineTo(32, 28)
          ..close(),
        Paint()..color = AppColors.accentWarm,
      )
      ..drawLine(
        const Offset(29, 17.5),
        const Offset(43, 16),
        Paint()
          ..color = _skin
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(const Offset(27, 8.5), 4.5, Paint()..color = _skin);
    final helmet = Path()
      ..moveTo(21.8, 9)
      ..arcToPoint(const Offset(32.2, 9), radius: const Radius.circular(5.2))
      ..close();
    canvas
      ..drawPath(helmet, Paint()..color = Colors.white)
      ..drawPath(
        helmet,
        Paint()
          ..color = AppColors.textPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      )
      ..drawRRect(
        RRect.fromLTRBR(28.4, 6.2, 32.6, 8.2, const Radius.circular(1)),
        Paint()..color = AppColors.brand,
      )
      ..drawLine(
        const Offset(47, 16),
        const Offset(44, 11),
        Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(
        const Offset(56, 22),
        2.2,
        Paint()..color = AppColors.accentWarm,
      );
    _drawWheel(canvas, const Offset(14, 42), wheelAngle);
    _drawWheel(canvas, const Offset(51, 42), wheelAngle);
  }

  void _drawCar(Canvas canvas, double wheelAngle) {
    // Bagasi pendek di kiri, kap mesin panjang di kanan (arah tujuan).
    canvas
      ..drawPath(
        Path()
          ..moveTo(4, 36)
          ..lineTo(4, 25)
          ..cubicTo(4, 22, 6, 21, 9, 21)
          ..lineTo(14, 21)
          ..lineTo(20, 11)
          ..cubicTo(21, 9.5, 22.5, 9, 24, 9)
          ..lineTo(38, 9)
          ..cubicTo(40, 9, 41.5, 10, 42.5, 11.5)
          ..lineTo(49, 20)
          ..lineTo(64, 22)
          ..cubicTo(69, 22.7, 72, 25, 72, 29)
          ..lineTo(72, 36)
          ..close(),
        Paint()..color = AppColors.brand,
      )
      ..drawPath(
        Path()
          ..moveTo(20.5, 12.5)
          ..lineTo(37.5, 12.5)
          ..lineTo(43.5, 19.8)
          ..lineTo(16.2, 19.8)
          ..close(),
        Paint()..color = _glass,
      )
      ..drawLine(
        const Offset(30, 12),
        const Offset(30, 20),
        Paint()
          ..color = AppColors.brand
          ..strokeWidth = 2.4,
      )
      ..drawCircle(const Offset(36.5, 15.8), 3, Paint()..color = _skin)
      ..drawRRect(
        RRect.fromLTRBR(68, 24, 72, 27, const Radius.circular(1.5)),
        Paint()..color = AppColors.accentWarm,
      );
    _drawWheel(canvas, const Offset(16, 37), wheelAngle);
    _drawWheel(canvas, const Offset(59, 37), wheelAngle);
  }

  /// Pin lokasi berujung di [tip] (bawah), dengan lingkar putih tipis.
  void _drawPin(Canvas canvas, Offset tip, Color color) {
    const size = 18.0;
    canvas
      ..save()
      ..translate(tip.dx - size / 2, tip.dy - size * 22.5 / 24)
      ..scale(size / 24);
    final pin = Path()
      ..moveTo(12, 22.5)
      ..cubicTo(12, 22.5, 4.2, 15.7, 4.2, 9.9)
      ..arcToPoint(const Offset(19.8, 9.9), radius: const Radius.circular(7.8))
      ..cubicTo(19.8, 15.7, 12, 22.5, 12, 22.5)
      ..close();
    canvas
      ..drawPath(
        pin,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      )
      ..drawPath(pin, Paint()..color = color)
      ..drawCircle(const Offset(12, 9.9), 3.1, Paint()..color = Colors.white)
      ..restore();
  }

  @override
  bool shouldRepaint(_RoadPainter old) =>
      old.seconds != seconds || old.vehicle != vehicle;
}
