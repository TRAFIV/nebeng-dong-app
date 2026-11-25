import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/data/saved_places_store.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/services/device_location.dart';
import 'package:praktikum_mobile/shared/maps/viewmodels/current_location_view_model.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_selection_tile.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

import '../../support/map_test_support.dart';

class _FakeDevice implements DeviceLocation {
  _FakeDevice(this.point);
  final GeoPoint? point;
  int calls = 0;

  @override
  Future<GeoPoint?> current() async {
    calls++;
    return point;
  }
}

Widget _home(DeviceLocation device, {MapLocation? origin}) => MaterialApp(
  theme: AppTheme.light,
  onGenerateRoute: AppRoutes.onGenerateRoute,
  home: HomeScreen(
    userName: 'Mikail',
    showUpcoming: false,
    savedPlaces: MemorySavedPlacesStore(),
    deviceLocation: device,
    initialOrigin: origin,
  ),
);

List<LocationSelectionTile> _tiles(WidgetTester tester) => tester
    .widgetList<LocationSelectionTile>(find.byType(LocationSelectionTile))
    .toList();

void main() {
  testWidgets('Dari terisi otomatis dari lokasi perangkat', (tester) async {
    final device = _FakeDevice(khatibPlace.point);
    await pumpTestWidget(tester, _home(device));
    await tester.pumpAndSettle();
    final dari = _tiles(tester).first;
    expect(dari.location!.point, same(khatibPlace.point));
    expect(dari.note, 'lokasimu sekarang');
    expect(find.textContaining('lokasimu sekarang'), findsOneWidget);
  });

  testWidgets('pilihan Dari yang sudah ada tidak ditimpa', (tester) async {
    final device = _FakeDevice(khatibPlace.point);
    await pumpTestWidget(tester, _home(device, origin: unandPlace));
    await tester.pumpAndSettle();
    expect(device.calls, 0);
    expect(_tiles(tester).first.location, same(unandPlace));
    expect(_tiles(tester).first.note, isNull);
  });

  testWidgets('GPS tidak tersedia: Dari tetap kosong', (tester) async {
    await pumpTestWidget(tester, _home(_FakeDevice(null)));
    await tester.pumpAndSettle();
    expect(_tiles(tester).first.location, isNull);
    expect(find.text('Pilih lokasi asal'), findsOneWidget);
  });

  test('ViewModel: tanpa nama jalan tetap memakai koordinat', () async {
    final maps = FakeMapService()..reverseHandler = (_) async => null;
    final vm = CurrentLocationViewModel(
      device: _FakeDevice(khatibPlace.point),
      maps: maps,
    );
    addTearDown(vm.dispose);
    final place = await vm.locate();
    expect(place!.label, 'Lokasimu sekarang');
    expect(vm.status, CurrentLocationStatus.found);
  });

  test('HomeViewModel: lokasi sekarang hilang tandanya bila diubah', () {
    final vm = HomeViewModel();
    addTearDown(vm.dispose);
    expect(vm.useCurrentLocation(khatibPlace), isTrue);
    expect(vm.originIsCurrent, isTrue);
    expect(vm.useCurrentLocation(unandPlace), isFalse, reason: 'tidak menimpa');
    vm.swapLocations();
    expect(vm.originIsCurrent, isFalse);
  });
}
