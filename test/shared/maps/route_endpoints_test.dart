import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/legacy/driver/views/post_route_screen.dart';
import 'package:praktikum_mobile/shared/views/ride_detail_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_field.dart';
import 'package:praktikum_mobile/shared/maps/widgets/route_endpoints.dart';

import '../../support/map_test_support.dart';

Finder field(String hint) => find.widgetWithText(TextFormField, hint);
const originHint = 'Contoh: Jl. Khatib Sulaiman';
const destinationHint = 'Contoh: Kampus Unand Limau Manis';

Future<void> swap(WidgetTester tester) async {
  final action = find.byTooltip('Tukar asal dan tujuan');
  await tester.ensureVisible(action);
  await tester.pumpAndSettle();
  await tester.tap(action);
  await tester.pumpAndSettle();
}

List<LocationField> locations(WidgetTester tester) =>
    tester.widgetList<LocationField>(find.byType(LocationField)).toList();

void main() {
  testWidgets('Beranda menukar nama dan koordinat; dua kali kembali semula', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        home: const HomeScreen(userName: 'Mikail', loadDelay: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();
    await selectTestLocation(tester, field(originHint), 'Air Tawar');
    await selectTestLocation(tester, field(destinationHint), 'Unand');
    await swap(tester);
    var pair = locations(tester);
    expect(pair[0].controller.text, 'Unand');
    expect(pair[0].initialLocation!.point.latitude, -0.94);
    expect(pair[1].controller.text, 'Air Tawar');
    expect(pair[1].initialLocation!.point.latitude, -0.90);
    expect(find.text('Lokasi dipilih'), findsNWidgets(2));
    await swap(tester);
    pair = locations(tester);
    expect(pair[0].initialLocation!.label, 'Air Tawar');
    expect(pair[1].initialLocation!.label, 'Unand');
  });

  testWidgets('Tukar satu lokasi tidak membuat koordinat untuk draft kosong', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        home: const HomeScreen(userName: 'Mikail', loadDelay: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();
    await selectTestLocation(tester, field(originHint), 'Air Tawar');
    await swap(tester);
    final pair = locations(tester);
    expect(pair[0].controller.text, isEmpty);
    expect(pair[0].initialLocation, isNull);
    expect(pair[1].controller.text, 'Air Tawar');
    expect(pair[1].initialLocation!.point.latitude, -0.90);
    expect(find.text('Lokasi dipilih'), findsOneWidget);
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

  testWidgets('Respons lama setelah tukar tidak menimpa lokasi pilihan', (
    tester,
  ) async {
    final pending = Completer<List<MapLocation>>();
    var firstQuery = true;
    final service = FakeMapService()
      ..searchHandler = (query) async {
        if (query == 'Lama' && firstQuery) {
          firstQuery = false;
          return pending.future;
        }
        return [FakeMapService.place(query)];
      };
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        home: const HomeScreen(userName: 'Mikail', loadDelay: Duration.zero),
      ),
      service: service,
    );
    await tester.pumpAndSettle();
    await selectTestLocation(tester, field(destinationHint), 'Unand');
    await tester.enterText(field(originHint), 'Lama');
    await tester.pump(const Duration(milliseconds: 750));
    // Don't settle while the pending query's loading indicator is animating.
    await tester.ensureVisible(find.byTooltip('Tukar asal dan tujuan'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byTooltip('Tukar asal dan tujuan'));
    await tester.pump();
    pending.complete([FakeMapService.place('Hasil lama')]);
    await tester.pumpAndSettle();
    expect(locations(tester)[0].initialLocation!.label, 'Unand');
    expect(find.widgetWithText(ListTile, 'Hasil lama'), findsNothing);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('Beranda/detail responsif 320px pada skala teks $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = LegacyDriverRepository(rides: []);
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
            userName: 'Mikail',
            rides: repo.rides,
            loadDelay: Duration.zero,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byType(RouteLocationSummary),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
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
