import 'package:praktikum_mobile/core/network/json_reader.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';

/// Membaca satu tebengan dari JSON server. Bentuknya mengikuti
/// `docs/api/kontrak-api.md` bagian Rute (`GET /rides`).
///
/// Pembaca disimpan di folder data, bukan di model, supaya model tetap bebas
/// dari detail server dan bisa dipakai data lokal maupun server.
Ride rideFromJson(Object? value) {
  final json = asJsonMap(value);
  final driver = json.readMap('driver');
  final origin = _location(json.readMap('origin'));
  final destination = _location(json.readMap('destination'));
  final route = json.readMap('route');
  return Ride(
    id: json.read<Object>('id').toString(),
    driverName: driver.read<String>('name'),
    driverRating: driver.readDouble('rating'),
    driverTripCount: driver.read<int>('trip_count'),
    origin: origin.label,
    destination: destination.label,
    schedule: json.read<String>('schedule'),
    departureTime: json.read<String>('departure_time'),
    seatCapacity: json.read<int>('seat_capacity'),
    seatsAvailable: json.read<int>('seats_available'),
    farePerPerson: json.read<int>('fare_per_person'),
    scheduleDays: _days(json.readOrNull<List<Object?>>('schedule_days')),
    vehicleType: switch (driver.readOrNull<String>('vehicle_type')) {
      'motor' => VehicleKind.motor,
      'car' => VehicleKind.car,
      _ => null,
    },
    geography: RideGeography(
      origin: origin,
      destination: destination,
      route: RoadRoute(
        // Urutan koordinat GeoJSON: [lng, lat].
        points: route
            .read<List<Object?>>('coordinates')
            .map(GeoPoint.fromGeoJson),
        distanceMeters: route.readDouble('distance_m'),
        durationSeconds: route.readDouble('duration_s'),
      ),
    ),
  );
}

List<Ride> ridesFromJson(Object? value) =>
    asJsonMapList(value).map(rideFromJson).toList();

/// Hari ISO 1–7; nilai lain membuat JSON dianggap tidak sah.
Set<int>? _days(List<Object?>? values) {
  if (values == null) return null;
  return {
    for (final value in values)
      if (value is int && value >= 1 && value <= 7)
        value
      else
        throw const FormatException('schedule_days harus berisi angka 1–7'),
  };
}

MapLocation _location(JsonMap json) => MapLocation(
  label: json.read<String>('label'),
  address: json.readOrNull<String>('address') ?? '',
  point: GeoPoint.fromGeoJson([json.readDouble('lng'), json.readDouble('lat')]),
);
