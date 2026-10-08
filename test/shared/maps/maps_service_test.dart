import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/features/ride_search/utils/route_matcher.dart';

const start = GeoPoint(-0.90, 100.35);
const finish = GeoPoint(-0.94, 100.35);

Map<String, Object> feature(String name, List<double> coordinates) => {
  'properties': {'name': name, 'city': 'Padang', 'osm_type': 'N', 'osm_id': 1},
  'geometry': {'type': 'Point', 'coordinates': coordinates},
};

Map<String, Object> routeResponse({double snap = 5}) => {
  'code': 'Ok',
  'waypoints': [
    {'distance': snap},
    {'distance': snap},
  ],
  'routes': [
    {
      'distance': 5000,
      'duration': 600,
      'geometry': {
        'coordinates': [
          [100.35, -0.90],
          [100.35, -0.94],
        ],
      },
    },
  ],
};

OpenMapService serviceWith(
  Future<http.Response> Function(http.Request) handler, {
  Duration timeout = const Duration(seconds: 1),
}) {
  final service = OpenMapService(
    client: MockClient(handler),
    requestInterval: Duration.zero,
    timeout: timeout,
  );
  addTearDown(service.close);
  return service;
}

void main() {
  test('GeoJSON memakai lon/lat; input tidak valid ditolak', () {
    final point = GeoPoint.fromGeoJson([100.35, -0.90]);
    expect(point.latitude, start.latitude);
    expect(point.longitude, start.longitude);
    expect(point.distanceTo(start), 0);
    expect(start.distanceTo(finish), closeTo(4448, 10));
    for (final invalid in [
      null,
      [],
      [1],
      ['a', 2],
      [181, 0],
      [0, 91],
      [double.nan, 0],
    ]) {
      expect(() => GeoPoint.fromGeoJson(invalid), throwsFormatException);
    }
    expect(MapLocation.pin(start).label, 'Lokasi di peta');
    expect(MapLocation.pin(start, label: ' Gerbang ').label, 'Gerbang');
  });

  test('Jalur harus valid dan geometry tidak boleh dimutasi', () {
    final route = RoadRoute(
      points: [start, finish],
      distanceMeters: 5000,
      durationSeconds: 600,
    );
    expect(() => route.points.add(start), throwsUnsupportedError);
    expect(
      () =>
          RoadRoute(points: [start], distanceMeters: 5000, durationSeconds: 0),
      throwsFormatException,
    );
    expect(
      () => RoadRoute(
        points: [start, finish],
        distanceMeters: double.nan,
        durationSeconds: 0,
      ),
      throwsFormatException,
    );
  });

  test('Koridor memperhatikan arah dan asal, bukan sekadar tujuan sama', () {
    final road = RoadRoute(
      points: [start, const GeoPoint(-0.92, 100.35), finish],
      distanceMeters: 5000,
      durationSeconds: 600,
    );
    const pickup = GeoPoint(-0.91, 100.352);
    const dropoff = GeoPoint(-0.93, 100.352);
    expect(RouteMatcher.match(road, pickup, dropoff), isNotNull);
    expect(RouteMatcher.match(road, dropoff, pickup), isNull);
    expect(
      RouteMatcher.match(road, const GeoPoint(-0.91, 100.36), dropoff),
      isNull,
    );
    expect(RouteMatcher.match(road, pickup, pickup), isNull);
    expect(
      RouteMatcher.match(road, pickup, dropoff, corridorMeters: 100),
      isNull,
    );
  });

  test('Geometry belok dan vertex duplikat tetap mengikuti jalan', () {
    final road = RoadRoute(
      points: [
        start,
        start,
        const GeoPoint(-0.90, 100.40),
        const GeoPoint(-0.94, 100.40),
      ],
      distanceMeters: 10000,
      durationSeconds: 900,
    );
    expect(
      RouteMatcher.match(
        road,
        const GeoPoint(-0.90, 100.37),
        const GeoPoint(-0.93, 100.40),
      ),
      isNotNull,
    );
    // Titik di diagonal lurus bukan berada di geometry jalan yang belok.
    expect(
      RouteMatcher.match(
        road,
        const GeoPoint(-0.92, 100.38),
        const GeoPoint(-0.93, 100.40),
      ),
      isNull,
    );
  });

  test('Edit nama membuang geometry lama, update kursi mempertahankannya', () {
    final geography = RideGeography(
      origin: MapLocation.pin(start),
      destination: MapLocation.pin(finish),
      route: RoadRoute(
        points: [start, finish],
        distanceMeters: 5000,
        durationSeconds: 600,
      ),
    );
    final repo = LegacyDriverRepository(rides: []);
    final ride = repo.post(
      driverName: 'Mikail',
      origin: 'Asal',
      destination: 'Tujuan',
      departureTime: '07.30',
      capacity: 3,
      geography: geography,
    );
    expect(ride.copyWith(origin: 'Asal baru').geography, isNull);
    expect(ride.copyWith(seatsAvailable: 2).geography, same(geography));
    repo.acceptBooking(routeId: ride.id, bookingId: 'b1');
    expect(repo.rides.single.geography, same(geography));
  });

  test('Photon query, User-Agent, parsing, input pendek dan cache', () async {
    var calls = 0;
    final service = serviceWith((request) async {
      calls++;
      expect(request.url.host, 'photon.komoot.io');
      expect(request.url.queryParameters['q'], 'Air Tawar');
      expect(request.url.queryParameters['limit'], '5');
      expect(request.url.queryParameters['lat'], '-0.9471');
      expect(request.headers['User-Agent'], MapConfig.userAgent);
      return http.Response(
        jsonEncode({
          'features': [
            feature('Air Tawar', [100.35, -0.9]),
            feature('Rusak', [200, 0]),
            null,
          ],
        }),
        200,
      );
    });
    expect(await service.searchPlaces('ab'), isEmpty);
    final places = await service.searchPlaces(' Air Tawar ');
    expect(places.single.label, 'Air Tawar');
    expect(places.single.address, 'Padang');
    expect(places.single.point.latitude, -0.9);
    expect(places.single.sourceId, 'N:1');
    expect(await service.searchPlaces('air tawar'), same(places));
    expect(calls, 1);
  });

  test('OSRM memakai lon/lat, geometry asli, dan cache berarah', () async {
    var calls = 0;
    final service = serviceWith((request) async {
      calls++;
      expect(request.url.path, contains('100.35,-0.9;100.35,-0.94'));
      expect(request.url.queryParameters['geometries'], 'geojson');
      expect(request.url.queryParameters['overview'], 'full');
      return http.Response(jsonEncode(routeResponse()), 200);
    });
    final road = await service.routeBetween(start, finish);
    expect(road.distanceMeters, 5000);
    expect(road.points.first.latitude, start.latitude);
    expect(road.points.last.latitude, finish.latitude);
    expect(await service.routeBetween(start, finish), same(road));
    expect(calls, 1);
    expect(
      () => service.routeBetween(start, start),
      throwsA(isA<MapServiceException>()),
    );
  });

  test('Reverse route bukan cache jalur berangkat', () async {
    var calls = 0;
    final service = serviceWith((request) async {
      calls++;
      return http.Response(jsonEncode(routeResponse()), 200);
    });
    await service.routeBetween(start, finish);
    await service.routeBetween(finish, start);
    expect(calls, 2);
  });

  for (final response in [
    http.Response('limited', 429),
    http.Response('unavailable', 503),
    http.Response('not JSON', 200),
    http.Response('[]', 200),
  ]) {
    test(
      'Error HTTP/JSON ${response.statusCode} diterima caller; antrean pulih',
      () async {
        var calls = 0;
        final service = serviceWith((_) async {
          calls++;
          return calls == 1 ? response : http.Response('{"features":[]}', 200);
        });
        await expectLater(
          service.searchPlaces('Gagal'),
          throwsA(isA<MapServiceException>()),
        );
        expect(await service.searchPlaces('Lagi'), isEmpty);
        expect(calls, 2);
      },
    );
  }

  test('Timeout respons menghasilkan pesan tanpa menunggu selamanya', () async {
    final pending = Completer<http.Response>();
    final service = serviceWith(
      (_) => pending.future,
      timeout: const Duration(milliseconds: 5),
    );
    await expectLater(
      service.searchPlaces('Lama'),
      throwsA(isA<MapServiceException>()),
    );
    pending.complete(http.Response('{"features":[]}', 200));
  });

  test('NoRoute dan snap terlalu jauh tidak diganti garis lurus', () async {
    var calls = 0;
    final service = serviceWith(
      (_) async => http.Response(
        jsonEncode(
          ++calls == 1
              ? {'code': 'NoRoute', 'routes': []}
              : routeResponse(snap: 2000),
        ),
        200,
      ),
    );
    await expectLater(
      service.routeBetween(start, finish),
      throwsA(isA<MapServiceException>()),
    );
    await expectLater(
      service.routeBetween(start, finish),
      throwsA(isA<MapServiceException>()),
    );
  });

  test('Service ditutup tidak menerima request atau cache baru', () async {
    final service = serviceWith(
      (_) async => http.Response('{"features":[]}', 200),
    );
    await service.searchPlaces('Air Tawar');
    service.close();
    await expectLater(
      service.searchPlaces('Air Tawar'),
      throwsA(isA<MapServiceException>()),
    );
    await expectLater(
      service.routeBetween(start, finish),
      throwsA(isA<MapServiceException>()),
    );
  });
}
