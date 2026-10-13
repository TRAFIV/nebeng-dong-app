import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/legacy/driver/views/post_route_screen.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_field.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_selection_tile.dart';
import 'package:praktikum_mobile/shared/maps/widgets/route_endpoints.dart';
import 'package:praktikum_mobile/shared/views/ride_detail_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

import '../../support/map_test_support.dart';

Finder field(String hint) => find.widgetWithText(TextFormField, hint);
const originHint = 'Contoh: Jl. Khatib Sulaiman';
const destinationHint = 'Contoh: Kampus Unand Limau Manis';
Future<void> swap(WidgetTester tester) async {
  final action = find.byTooltip('Tukar asal dan tujuan');
  await tester.ensureVisible(action);
  await tester.tap(action);
  await tester.pumpAndSettle();
}

List<LocationField> locations(WidgetTester tester) =>
    tester.widgetList<LocationField>(find.byType(LocationField)).toList();
List<LocationSelectionTile> homeLocations(WidgetTester tester) => tester
    .widgetList<LocationSelectionTile>(find.byType(LocationSelectionTile))
    .toList();
Widget home() => MaterialApp(
  theme: AppTheme.light,
  home: const HomeScreen(userName: 'Mikail'),
);

void main() {
  testWidgets('Home swaps full selections; two swaps restore them', (
    tester,
  ) async {
    await pumpTestWidget(tester, home());
    await selectHomeLocation(tester, 'Dari', 'Air Tawar');
    await selectHomeLocation(tester, 'Ke', 'Unand');
    final before = homeLocations(tester);
    await swap(tester);
    var pair = homeLocations(tester);
    expect(pair[0].location, same(before[1].location));
    expect(pair[1].location, same(before[0].location));
    expect(pair[0].location!.address, 'Padang');
    await swap(tester);
    pair = homeLocations(tester);
    expect(pair[0].location, same(before[0].location));
    expect(pair[1].location, same(before[1].location));
  });
  testWidgets('Swap of a single endpoint leaves the other unselected', (
    tester,
  ) async {
    await pumpTestWidget(tester, home());
    await selectHomeLocation(tester, 'Dari', 'Air Tawar');
    await swap(tester);
    final pair = homeLocations(tester);
    expect(pair[0].location, isNull);
    expect(pair[1].location!.label, 'Air Tawar');
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Cariin Tebengan!'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('Posting setelah tukar menyimpan jalur dengan arah baru', (
    tester,
  ) async {
    final repo = LegacyDriverRepository(rides: []);
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        home: PostRouteScreen(repository: repo, driverName: 'Mikail'),
      ),
    );
    await selectTestLocation(tester, field(originHint), 'Air Tawar');
    await selectTestLocation(tester, field(destinationHint), 'Unand');
    await tester.enterText(field('07.30'), '07.30');
    await tester.enterText(field('3'), '3');
    await swap(tester);
    await tester.tap(find.text('Posting Rutenya!'));
    await tester.pumpAndSettle();
    final saved = repo.rides.single;
    expect(saved.origin, 'Unand');
    expect(saved.destination, 'Air Tawar');
    expect(saved.departureTime, '07.30');
    expect(saved.seatCapacity, 3);
    expect(saved.geography!.route.points.first.latitude, -0.94);
    expect(saved.geography!.route.points.last.latitude, -0.90);
  });

  testWidgets('Nama pin sama tetap menukar koordinat berbeda', (tester) async {
    final origin = MapLocation.pin(
      const GeoPoint(-0.90, 100.35),
      label: 'Gerbang',
    );
    final destination = MapLocation.pin(
      const GeoPoint(-0.94, 100.35),
      label: 'Gerbang',
    );
    final repo = LegacyDriverRepository(rides: []);
    final ride = repo.post(
      driverName: 'Mikail',
      origin: origin.label,
      destination: destination.label,
      departureTime: '07.30',
      capacity: 3,
      geography: RideGeography(
        origin: origin,
        destination: destination,
        route: RoadRoute(
          points: [origin.point, destination.point],
          distanceMeters: 5000,
          durationSeconds: 600,
        ),
      ),
    );
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        home: PostRouteScreen(
          repository: repo,
          driverName: 'Mikail',
          initialRide: ride,
        ),
      ),
    );
    await swap(tester);
    final pair = locations(tester);
    expect(pair[0].initialLocation, same(destination));
    expect(pair[1].initialLocation, same(origin));
    expect(find.text('Lokasi dipilih'), findsNWidgets(2));
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();
    expect(repo.rides.single.geography!.route.points.first, destination.point);
  });

  testWidgets('Cancelled pending place search cannot overwrite a swap', (
    tester,
  ) async {
    final pending = Completer<List<MapLocation>>();
    final service = FakeMapService()
      ..searchHandler = (query) => query == 'Lama'
          ? pending.future
          : Future.value([FakeMapService.place(query)]);
    await pumpTestWidget(tester, home(), service: service);
    await selectHomeLocation(tester, 'Ke', 'Unand');
    await tester.tap(find.byKey(const ValueKey('select-Dari')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('place-query')), 'Lama');
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 400));
    await swap(tester);
    pending.complete([FakeMapService.place('Hasil lama')]);
    await tester.pumpAndSettle();
    expect(homeLocations(tester)[0].location!.label, 'Unand');
    expect(homeLocations(tester)[1].location, isNull);
    expect(find.text('Hasil lama'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final scale in [1.0, 2.0]) {
    testWidgets('Home/detail responsive 320px text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = LegacyDriverRepository(rides: []);
      addTearDown(repo.dispose);
      final ride = repo.post(
        driverName: 'Mikail',
        origin: 'Gerbang utama Jalan Khatib Sulaiman Padang',
        destination: 'Kampus Universitas Andalas Limau Manis',
        departureTime: '07.30',
        capacity: 3,
      );
      Widget app(Widget screen) => MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: screen,
      );
      await pumpTestWidget(
        tester,
        app(
          HomeScreen(
            userName: 'Mikail Samyth Habibillah',
            initialOrigin: FakeMapService.place(ride.origin),
            initialDestination: FakeMapService.place(ride.destination),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Cariin Tebengan!'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      await pumpTestWidget(tester, app(RideDetailScreen(ride: ride)));
      await tester.pumpAndSettle();
      expect(find.byType(RouteLocationSummary), findsOneWidget);
      await tester.ensureVisible(find.text('Ikut Nebeng!'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.event_seat_outlined), findsWidgets);
    });
  }
}
