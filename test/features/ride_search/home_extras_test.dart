import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/saved_places_store.dart';
import 'package:praktikum_mobile/features/ride_search/models/saved_place.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/saved_places_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/upcoming_rides_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_selection_tile.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

import '../../support/map_test_support.dart';

class _FailingStore implements SavedPlacesStore {
  @override
  Future<List<SavedPlace>> load() async => defaultSavedPlaces;

  @override
  Future<void> save(List<SavedPlace> places) async =>
      throw StateError('disk penuh');
}

void main() {
  group('Berangkat sebentar lagi', () {
    test('hanya yang belum cabut dan belum penuh, urut paling dekat', () {
      final upcoming = UpcomingRidesViewModel.upcomingFrom(
        demoRides,
        DateTime(2026, 11, 24, 7, 35),
      );
      // Taris 07.30 sudah lewat, Shiddiq 08.00 penuh.
      expect(upcoming.map((u) => u.ride.driverName), [
        'Duha Alul Bariq',
        'Pengemudi contoh',
      ]);
      expect(upcoming.first.minutesUntil, 10);
    });

    test('dibatasi jumlahnya', () {
      final upcoming = UpcomingRidesViewModel.upcomingFrom(
        demoRides,
        DateTime(2026, 11, 24, 6),
        limit: 1,
      );
      expect(upcoming.single.ride.driverName, 'Taris Rafivdean');
      expect(upcoming.single.minutesUntil, 90);
    });
  });

  group('Tempat tujuan', () {
    test('JSON bolak-balik dan data rusak dilewati', () {
      final place = SavedPlace(name: 'Rumah', location: khatibPlace);
      final again = SavedPlace.fromJson(place.toJson())!;
      expect(again.name, 'Rumah');
      expect(again.location.point.latitude, khatibPlace.point.latitude);
      expect(again.kind, SavedPlaceKind.home);
      expect(SavedPlace.fromJson({'name': 'x'}), isNull);
      expect(
        SavedPlace.fromJson({'name': 'x', 'label': 'y', 'lat': 200, 'lng': 0}),
        isNull,
      );
    });

    test('validasi nama, simpan, hapus', () async {
      final store = MemorySavedPlacesStore();
      final vm = SavedPlacesViewModel(store: store);
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.places.single.name, 'Kampus');
      expect(vm.validateName('  '), isNotNull);
      expect(vm.validateName('kampus'), 'Nama ini sudah dipakai');
      expect(vm.validateName('x' * 21), isNotNull);

      expect(await vm.add('Rumah', khatibPlace), isTrue);
      expect((await store.load()).map((p) => p.name), ['Kampus', 'Rumah']);

      expect(await vm.remove(vm.places.first), isTrue);
      expect((await store.load()).map((p) => p.name), ['Rumah']);
    });

    test('gagal simpan dikembalikan dan memberi pesan', () async {
      final vm = SavedPlacesViewModel(store: _FailingStore());
      addTearDown(vm.dispose);
      await vm.load();
      expect(await vm.add('Rumah', khatibPlace), isFalse);
      expect(vm.places.map((p) => p.name), ['Kampus']);
      expect(vm.errorMessage, isNotNull);
    });
  });

  test('Tukar Dari/Ke menghitung putaran', () {
    final vm = HomeViewModel()..setLocations(khatibPlace, unandPlace);
    addTearDown(vm.dispose);
    vm.swapLocations();
    expect(vm.originPlace, same(unandPlace));
    expect(vm.destinationPlace, same(khatibPlace));
    expect(vm.swapCount, 1);
  });

  testWidgets('Cari: tempat tujuan mengisi Ke, keberangkatan tampil', (
    tester,
  ) async {
    final repository = LocalRideRepository(delay: Duration.zero);
    addTearDown(repository.dispose);
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: HomeScreen(
          userName: 'Mikail',
          repository: repository,
          savedPlaces: MemorySavedPlacesStore(),
          now: () => DateTime(2026, 11, 24, 7, 12),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('saved-Kampus')));
    await tester.pumpAndSettle();
    final tiles = tester
        .widgetList<LocationSelectionTile>(find.byType(LocationSelectionTile))
        .toList();
    expect(tiles[1].location, same(unandPlace));

    await tester.scrollUntilVisible(
      find.text('cabut 18 mnt lagi'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('cabut 18 mnt lagi'), findsOneWidget);
    expect(find.text('Sisa 1!'), findsOneWidget);
  });
}
