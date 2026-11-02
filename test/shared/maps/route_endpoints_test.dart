import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_selection_tile.dart';
import 'package:praktikum_mobile/shared/maps/widgets/route_endpoints.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/views/ride_detail_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

import '../../support/map_test_support.dart';

Future<void> swap(WidgetTester tester) async {
  final action = find.byTooltip('Tukar asal dan tujuan');
  await tester.ensureVisible(action);
  await tester.tap(action);
  await tester.pumpAndSettle();
}

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
      // Nama tempat panjang untuk menguji tata letak sempit.
      const ride = Ride(
        id: 'r1',
        driverName: 'Mikail',
        driverRating: 0,
        driverTripCount: 0,
        origin: 'Gerbang utama Jalan Khatib Sulaiman Padang',
        destination: 'Kampus Universitas Andalas Limau Manis',
        schedule: 'Senin–Jumat',
        departureTime: '07.30',
        seatCapacity: 3,
        seatsAvailable: 3,
        farePerPerson: 0,
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
      await pumpTestWidget(tester, app(const RideDetailScreen(ride: ride)));
      await tester.pumpAndSettle();
      expect(find.byType(RouteLocationSummary), findsOneWidget);
      await tester.ensureVisible(find.text('Ikut Nebeng!'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.event_seat_outlined), findsWidgets);
    });
  }
}
