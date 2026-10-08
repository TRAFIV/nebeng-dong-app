import 'dart:math' as math;

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude)
    : assert(latitude >= -90 && latitude <= 90),
      assert(longitude >= -180 && longitude <= 180);
  final double latitude;
  final double longitude;

  factory GeoPoint.fromGeoJson(dynamic coordinate) {
    if (coordinate is! List ||
        coordinate.length < 2 ||
        coordinate[0] is! num ||
        coordinate[1] is! num) {
      throw const FormatException('Koordinat tidak valid');
    }
    final lon = (coordinate[0] as num).toDouble();
    final lat = (coordinate[1] as num).toDouble();
    if (!lat.isFinite || !lon.isFinite || lat.abs() > 90 || lon.abs() > 180) {
      throw const FormatException('Koordinat di luar batas');
    }
    return GeoPoint(lat, lon);
  }

  String get coordinateLabel =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  double distanceTo(GeoPoint other) {
    const radians = math.pi / 180;
    final a =
        math.pow(math.sin((other.latitude - latitude) * radians / 2), 2) +
        math.cos(latitude * radians) *
            math.cos(other.latitude * radians) *
            math.pow(math.sin((other.longitude - longitude) * radians / 2), 2);
    return 6371000 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
  }
}

class MapLocation {
  const MapLocation({
    required this.label,
    required this.point,
    this.address = '',
    this.sourceId,
  });
  final String label;
  final String address;
  final GeoPoint point;
  final String? sourceId;

  factory MapLocation.pin(GeoPoint point, {String? label}) => MapLocation(
    label: label?.trim().isNotEmpty == true ? label!.trim() : 'Lokasi di peta',
    point: point,
  );
}

class RoadRoute {
  RoadRoute({
    required Iterable<GeoPoint> points,
    required this.distanceMeters,
    required this.durationSeconds,
  }) : points = List.unmodifiable(points) {
    if (this.points.length < 2 ||
        !distanceMeters.isFinite ||
        distanceMeters <= 0 ||
        !durationSeconds.isFinite ||
        durationSeconds < 0) {
      throw const FormatException('Jalur jalan tidak valid');
    }
  }
  final List<GeoPoint> points;
  final double distanceMeters;
  final double durationSeconds;
}

/// Lokasi dan geometry satu paket, supaya nama baru tidak memakai jalur lama.
class RideGeography {
  const RideGeography({
    required this.origin,
    required this.destination,
    required this.route,
  });
  final MapLocation origin;
  final MapLocation destination;
  final RoadRoute route;
}
