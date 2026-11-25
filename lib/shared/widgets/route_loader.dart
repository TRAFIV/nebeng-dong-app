import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';

/// Loading khas Nebeng Dong: titik oranye berjalan di garis rute bertitik
/// dari asal (oranye) ke tujuan (hijau), seperti logo yang bergerak.
///
/// Tetap bergerak di tes (seperti spinner biasa) agar `pumpAndSettle` menunggu
/// data selesai dimuat; berhenti di tengah bila animasi HP dimatikan.
class RouteLoader extends StatefulWidget {
  const RouteLoader({super.key, this.width = 180});

  final double width;

  @override
  State<RouteLoader> createState() => _RouteLoaderState();
}

class _RouteLoaderState extends State<RouteLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size(widget.width, widget.width * 70 / 200),
        painter: _RouteLoaderPainter(
          Curves.easeInOut.transform(_controller.value),
        ),
      ),
    ),
  );
}

class _RouteLoaderPainter extends CustomPainter {
  _RouteLoaderPainter(this.progress);

  final double progress;

  static final Path _route = Path()
    ..moveTo(8, 54)
    ..cubicTo(50, 54, 60, 14, 100, 14)
    ..cubicTo(140, 14, 150, 54, 192, 54);

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 200);
    final metric = _route.computeMetrics().first;
    _dots(canvas, metric);
    canvas
      ..drawCircle(const Offset(8, 54), 5, Paint()..color = AppColors.brand)
      ..drawCircle(
        const Offset(192, 54),
        6,
        Paint()..color = AppColors.successText,
      );
    final runner = metric.getTangentForOffset(metric.length * progress)!;
    canvas
      ..drawCircle(runner.position, 13, Paint()..color = AppColors.brandSubtle)
      ..drawCircle(runner.position, 8, Paint()..color = AppColors.brand)
      ..restore();
  }

  void _dots(Canvas canvas, PathMetric metric) {
    final paint = Paint()..color = AppColors.border;
    for (double d = 0; d < metric.length; d += 11) {
      canvas.drawCircle(metric.getTangentForOffset(d)!.position, 2, paint);
    }
  }

  @override
  bool shouldRepaint(_RouteLoaderPainter old) => old.progress != progress;
}
