import 'dart:math' as math;

import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

class RouteMatch {
  const RouteMatch(this.pickupDeviation, this.dropoffDeviation);
  final double pickupDeviation;
  final double dropoffDeviation;
  double get totalDeviation => pickupDeviation + dropoffDeviation;
}

/// Koridor geometry jalan + urutan jemput sebelum turun, bukan tujuan saja.
/// Belum memodelkan akses pejalan kaki, detour aktual, atau kondisi lalu lintas.
abstract final class RouteMatcher {
  static RouteMatch? match(
    RoadRoute route,
    GeoPoint pickup,
    GeoPoint dropoff, {
    double corridorMeters = 500,
    double nearestToleranceMeters = 100,
  }) {
    if (pickup.distanceTo(dropoff) < 50) return null;
    final from = _nearest(
      _projections(route.points, pickup, corridorMeters),
      nearestToleranceMeters,
    );
    final to = _nearest(
      _projections(route.points, dropoff, corridorMeters),
      nearestToleranceMeters,
    );
    int index = 0;
    _Projection? bestPickup;
    RouteMatch? best;
    for (final drop in to) {
      while (index < from.length && from[index].along + 50 < drop.along) {
        final candidate = from[index++];
        if (bestPickup == null || candidate.distance < bestPickup.distance) {
          bestPickup = candidate;
        }
      }
      if (bestPickup == null) continue;
      final match = RouteMatch(bestPickup.distance, drop.distance);
      if (best == null || match.totalDeviation < best.totalDeviation) {
        best = match;
      }
    }
    return best;
  }

  /// Hanya bagian jalur yang paling dekat dengan titiknya (ditambah toleransi).
  /// Tanpa ini, perjalanan pendek bisa memakai bagian jalur yang salah,
  /// sehingga arah terbalik ikut dianggap searah. Jalur yang melewati tempat
  /// yang sama dua kali tetap tertangani karena keduanya sama-sama dekat.
  static List<_Projection> _nearest(
    List<_Projection> projections,
    double tolerance,
  ) {
    if (projections.isEmpty) return projections;
    final closest = projections.map((p) => p.distance).reduce(math.min);
    return projections.where((p) => p.distance <= closest + tolerance).toList();
  }

  static List<_Projection> _projections(
    List<GeoPoint> points,
    GeoPoint target,
    double corridor,
  ) {
    final result = <_Projection>[];
    double along = 0;
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      const scale = 6371000 * math.pi / 180;
      final lonScale = scale * math.cos(target.latitude * math.pi / 180);
      final ax = (a.longitude - target.longitude) * lonScale;
      final ay = (a.latitude - target.latitude) * scale;
      final dx = (b.longitude - a.longitude) * lonScale;
      final dy = (b.latitude - a.latitude) * scale;
      final squared = dx * dx + dy * dy;
      final t = squared == 0
          ? 0.0
          : (-(ax * dx + ay * dy) / squared).clamp(0.0, 1.0);
      final distance = math.sqrt(
        math.pow(ax + t * dx, 2) + math.pow(ay + t * dy, 2),
      );
      final length = a.distanceTo(b);
      if (distance <= corridor) {
        result.add(_Projection(along + t * length, distance));
      }
      along += length;
    }
    return result;
  }
}

class _Projection {
  const _Projection(this.along, this.distance);
  final double along;
  final double distance;
}
