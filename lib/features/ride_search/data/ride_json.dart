import 'package:praktikum_mobile/core/network/json_reader.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

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

MapLocation _location(JsonMap json) => MapLocation(
  label: json.read<String>('label'),
  address: json.readOrNull<String>('address') ?? '',
  point: GeoPoint.fromGeoJson([json.readDouble('lng'), json.readDouble('lat')]),
);
