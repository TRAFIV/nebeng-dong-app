import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/core/di/map_service_scope.dart';

/// Fixture deterministik khusus test; tidak dipakai untuk jalur produksi.
class FakeMapService implements MapService {
  String? routeError;
  String? searchError;
  int searchCalls = 0;
  int routeCalls = 0;
  int reverseCalls = 0;
  int closeCalls = 0;
  Future<MapLocation?> Function(GeoPoint)? reverseHandler;
  Future<List<MapLocation>> Function(String)? searchHandler;
  Future<RoadRoute> Function(GeoPoint, GeoPoint)? routeHandler;

  static MapLocation place(String name) => MapLocation(
    label: name,
    address: 'Padang',
    point: switch (name.toLowerCase()) {
      'khatib' ||
      'jl. khatib sulaiman' => const GeoPoint(-0.9099249, 100.3548088),
      'veteran' => const GeoPoint(-0.9376233, 100.3545128),
      'universitas andalas' => const GeoPoint(-0.9148733, 100.4627099),
      'air tawar' => const GeoPoint(-0.90, 100.35),
      'ulak karang' => const GeoPoint(-0.92, 100.35),
      'unand' => const GeoPoint(-0.94, 100.35),
      _ => const GeoPoint(-0.93, 100.35),
    },
  );

  @override
  Future<List<MapLocation>> searchPlaces(String query) async {
    searchCalls++;
    if (searchHandler != null) return searchHandler!(query);
    if (searchError != null) throw MapServiceException(searchError!);
    return [place(query)];
  }

  @override
  Future<MapLocation?> reverseGeocode(GeoPoint point) async {
    reverseCalls++;
    if (reverseHandler != null) return reverseHandler!(point);
    return MapLocation(
      label: 'Jalan Khatib Sulaiman, Padang, Sumatera Barat, Indonesia',
      address: 'Jalan Khatib Sulaiman, Padang, Sumatera Barat, Indonesia',
      point: point,
    );
  }

  @override
  Future<RoadRoute> routeBetween(GeoPoint origin, GeoPoint destination) async {
    routeCalls++;
    if (routeHandler != null) return routeHandler!(origin, destination);
    if (routeError != null) throw MapServiceException(routeError!);
    return RoadRoute(
      points: [origin, destination],
      distanceMeters: origin.distanceTo(destination),
      durationSeconds: 600,
    );
  }

  @override
  void close() {
    closeCalls++;
  }
}

Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget child, {
  MapService? service,
}) => tester.pumpWidget(
  MapServiceProvider(
    service: service ?? FakeMapService(),
    enableTiles: false,
    child: child,
  ),
);

Future<void> selectTestLocation(
  WidgetTester tester,
  Finder field,
  String label,
) async {
  await tester.ensureVisible(field);
  await tester.enterText(field, label);
  await tester.pump(const Duration(milliseconds: 750));
  await tester.pumpAndSettle();
  final suggestion = find.widgetWithText(ListTile, label);
  await tester.ensureVisible(suggestion);
  await tester.tap(suggestion);
  await tester.pumpAndSettle();
}
