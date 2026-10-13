import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/ride_filter_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/ride_results_screen.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/views/place_search_screen.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_selection_tile.dart';
import 'package:praktikum_mobile/shared/maps/widgets/open_street_map_view.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

import '../../support/map_test_support.dart';

class _RetryRepository extends RideRepository {
  int calls = 0;
  int disposals = 0;
  Completer<List<Ride>>? pending;
  bool get listening => hasListeners;
  @override
  bool get isSimulation => true;
  @override
  List<Ride> get rides => demoRides;
  @override
  Future<List<Ride>> fetchRides({bool simulateError = false}) async {
    calls++;
    if (pending != null) return pending!.future;
    if (calls == 1) throw StateError('Private transport details');
    return rides;
  }

  @override
  void dispose() {
    disposals++;
    super.dispose();
  }
}

Widget _app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  onGenerateRoute: AppRoutes.onGenerateRoute,
  onUnknownRoute: AppRoutes.onUnknownRoute,
  home: home,
);

List<LocationSelectionTile> _locations(WidgetTester tester) => tester
    .widgetList<LocationSelectionTile>(find.byType(LocationSelectionTile))
    .toList();

Future<void> _tap(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.scrollUntilVisible(
    target,
    160,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Ke first, typed query and cancel preserve the chosen location', (
    tester,
  ) async {
    final repository = _RetryRepository();
    addTearDown(repository.dispose);
    await pumpTestWidget(
      tester,
      _app(HomeScreen(userName: 'Mikail', repository: repository)),
    );
    expect(repository.calls, 0); // Form never waits for route data.
    await selectHomeLocation(tester, 'Ke', 'Universitas Andalas');
    final destination = _locations(tester)[1].location;
    expect(_locations(tester)[0].location, isNull);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Cariin Tebengan!'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('select-Ke')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('place-query')), 'xy');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(_locations(tester)[1].location, same(destination));
    expect(repository.calls, 0);
  });

  testWidgets('Direct pin commits full address, alias and coordinates to Ke', (
    tester,
  ) async {
    final service = FakeMapService();
    final repository = LocalRideRepository(delay: Duration.zero);
    addTearDown(repository.dispose);
    await pumpTestWidget(
      tester,
      _app(
        HomeScreen(
          userName: 'Mikail',
          repository: repository,
          initialOrigin: khatibPlace,
        ),
      ),
      service: service,
    );
    await tester.tap(find.byKey(const ValueKey('pin-Ke')));
    await tester.pumpAndSettle();
    expect(find.text('Pin Ke'), findsOneWidget);
    final map = tester.widget<OpenStreetMapView>(
      find.byType(OpenStreetMapView),
    );
    map.onTap!(unandPlace.point);
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(TextFormField, 'Contoh: Gerbang utama kampus'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contoh: Gerbang utama kampus'),
      'Gerbang kampus',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _tap(tester, 'Gunakan Pin Ini');
    final locations = _locations(tester);
    expect(locations[0].location, same(khatibPlace));
    expect(locations[1].location!.label, 'Gerbang kampus');
    expect(locations[1].location!.address, contains('Sumatera Barat'));
    expect(locations[1].location!.point, same(unandPlace.point));
    expect(find.text(locations[1].location!.address), findsOneWidget);
    // An unconfirmed replacement pin must not mutate the committed point.
    final selected = locations[1].location;
    await tester.tap(find.byKey(const ValueKey('pin-Ke')));
    await tester.pumpAndSettle();
    tester.widget<OpenStreetMapView>(find.byType(OpenStreetMapView)).onTap!(
      veteranPlace.point,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(_locations(tester)[1].location, same(selected));
    expect(service.closeCalls, 0);
  });

  testWidgets(
    'Place retry and manual pin address return through the selector',
    (tester) async {
      final service = FakeMapService()
        ..searchError = 'Pencarian gagal'
        ..reverseHandler = (_) async =>
            throw const MapServiceException('Alamat gagal');
      await pumpTestWidget(
        tester,
        _app(const HomeScreen(userName: 'Mikail')),
        service: service,
      );
      await tester.tap(find.byKey(const ValueKey('select-Dari')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('place-query')),
        'Khatib',
      );
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pumpAndSettle();
      expect(find.text('Pencarian gagal'), findsOneWidget);
      service.searchError = null;
      await _tap(tester, 'Coba Lagi');
      expect(find.text('Hasil pencarian'), findsOneWidget);
      expect(service.searchCalls, 2);
      await _tap(tester, 'Pilih langsung di peta');
      tester.widget<OpenStreetMapView>(find.byType(OpenStreetMapView)).onTap!(
        khatibPlace.point,
      );
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pumpAndSettle();
      await _tap(tester, 'Isi alamat manual');
      const manual = 'Jalan Khatib Sulaiman, Padang, Sumatera Barat';
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alamat dari titik di peta'),
        manual,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await _tap(tester, 'Gunakan Pin Ini');
      expect(find.byType(PlaceSearchScreen), findsNothing);
      final point = _locations(tester)[0].location!;
      expect(point.point, same(khatibPlace.point));
      expect(point.address, manual);
      expect(_locations(tester)[1].location, isNull);
    },
  );

  testWidgets('Search failure retries without leaking technical details', (
    tester,
  ) async {
    final repository = _RetryRepository();
    addTearDown(repository.dispose);
    await pumpTestWidget(
      tester,
      _app(
        HomeScreen(
          userName: 'Mikail',
          repository: repository,
          initialOrigin: khatibPlace,
          initialDestination: unandPlace,
        ),
      ),
    );
    await _tap(tester, 'Cariin Tebengan!');
    expect(find.text('Belum bisa memuat tebengan'), findsOneWidget);
    expect(find.textContaining('Private transport'), findsNothing);
    expect(find.text(khatibPlace.label), findsOneWidget);
    await _tap(tester, 'Coba Lagi');
    expect(find.text('1 tebengan searah'), findsOneWidget);
    expect(find.text('Taris Rafivdean'), findsOneWidget);
    expect(repository.calls, 2);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(_locations(tester)[0].location, same(khatibPlace));
    expect(repository.listening, isFalse);
    expect(repository.disposals, 0);
  });

  testWidgets('Filter cancel, apply, reset and return preserve route state', (
    tester,
  ) async {
    final repository = LocalRideRepository(
      delay: Duration.zero,
      rides: [demoRides.first, demoRides.first.copyWith(seatsAvailable: 1)],
    );
    addTearDown(repository.dispose);
    await pumpTestWidget(
      tester,
      _app(
        HomeScreen(
          userName: 'Mikail',
          repository: repository,
          initialOrigin: khatibPlace,
          initialDestination: unandPlace,
        ),
      ),
    );
    await _tap(tester, 'Cariin Tebengan!');
    expect(find.text('2 tebengan searah'), findsOneWidget);
    await _tap(tester, 'Filter');
    await _tap(tester, '2 kursi');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('2 tebengan searah'), findsOneWidget);
    await _tap(tester, 'Filter');
    await _tap(tester, '2 kursi');
    await _tap(tester, 'Terapkan');
    expect(find.text('1 tebengan searah'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _tap(tester, 'Cariin Tebengan!');
    expect(find.text('Filter aktif'), findsOneWidget);
    expect(find.text('1 tebengan searah'), findsOneWidget);
    await _tap(tester, 'Filter aktif');
    await _tap(tester, 'Atur Ulang');
    await _tap(tester, 'Terapkan');
    expect(find.text('2 tebengan searah'), findsOneWidget);
    expect(repository.rides.map((ride) => ride.seatsAvailable), [2, 1]);
  });

  testWidgets('Zero fare is rejected and a saved fare reopens formatted', (
    tester,
  ) async {
    final repository = LocalRideRepository(delay: Duration.zero);
    addTearDown(repository.dispose);
    await pumpTestWidget(
      tester,
      _app(
        HomeScreen(
          userName: 'Mikail',
          repository: repository,
          initialOrigin: khatibPlace,
          initialDestination: unandPlace,
        ),
      ),
    );
    String fareText() => tester
        .widget<TextFormField>(find.byType(TextFormField))
        .controller!
        .text;
    await _tap(tester, 'Cariin Tebengan!');
    await _tap(tester, 'Filter');
    await tester.enterText(find.byType(TextFormField), '0');
    await _tap(tester, 'Terapkan');
    expect(find.text('Batas ongkos harus lebih dari Rp0'), findsOneWidget);
    expect(find.byType(RideFilterScreen), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '10000');
    await _tap(tester, 'Terapkan');
    expect(find.textContaining('Maks. Rp10.000'), findsOneWidget);
    await _tap(tester, 'Filter aktif');
    expect(fareText(), '10.000');
    await _tap(tester, 'Terapkan');
    expect(find.textContaining('Maks. Rp10.000'), findsOneWidget);
    expect(find.text('1 tebengan searah'), findsOneWidget);
  });

  testWidgets('Leaving loading results ignores the late response', (
    tester,
  ) async {
    final repository = _RetryRepository()..pending = Completer<List<Ride>>();
    addTearDown(repository.dispose);
    await pumpTestWidget(
      tester,
      _app(
        HomeScreen(
          userName: 'Mikail',
          repository: repository,
          initialOrigin: khatibPlace,
          initialDestination: unandPlace,
        ),
      ),
    );
    await tester.tap(find.text('Cariin Tebengan!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(RideResultsScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    repository.pending!.complete(demoRides);
    await tester.pump();
    expect(repository.listening, isFalse);
    expect(find.byType(RideResultsScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Near endpoints give validation and malformed route gives 404', (
    tester,
  ) async {
    await pumpTestWidget(
      tester,
      _app(
        HomeScreen(
          userName: 'Mikail',
          initialOrigin: khatibPlace,
          initialDestination: khatibPlace,
        ),
      ),
    );
    await _tap(tester, 'Cariin Tebengan!');
    expect(find.text('Asal dan tujuan minimal 50 meter'), findsOneWidget);
    expect(find.byType(RideResultsScreen), findsNothing);
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(AppRoutes.rideResults, arguments: 'invalid');
    await tester.pumpAndSettle();
    expect(find.text('404'), findsOneWidget);
  });

  for (final entry in <String, Widget>{
    'results': RideResultsScreen(
      request: const RideSearchRequest(
        origin: khatibPlace,
        destination: unandPlace,
      ),
      repository: LocalRideRepository(delay: Duration.zero),
    ),
    'filter': const RideFilterScreen(),
    'places': PlaceSearchScreen(label: 'Ke', service: FakeMapService()),
  }.entries) {
    testWidgets('${entry.key} supports 320px with 2x text', (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      if (entry.value case RideResultsScreen(:final repository)) {
        addTearDown(repository!.dispose);
      }
      await pumpTestWidget(tester, _app(entry.value));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
