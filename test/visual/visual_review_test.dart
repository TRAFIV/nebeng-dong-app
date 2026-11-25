import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/views/ride_results_screen.dart';
import 'package:praktikum_mobile/shared/maps/views/place_search_screen.dart';
import 'package:praktikum_mobile/shared/maps/views/location_picker_screen.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/widgets/open_street_map_view.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/shared/views/ride_detail_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/ride_filter_sheet.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

import '../support/app_fonts.dart';
import '../support/map_test_support.dart';

/// Screenshot opt-in dari widget asli, bukan mockup atau golden acuan palsu.
/// flutter test test/visual/visual_review_test.dart --dart-define=SAVE_SCREENSHOTS=true
void main() {
  testWidgets('Review passenger screens at 360×800', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const capture = bool.fromEnvironment('SAVE_SCREENSHOTS');
    if (capture) {
      await loadAppFonts();
    }
    final passengerRepository = LocalRideRepository(delay: Duration.zero);
    addTearDown(passengerRepository.dispose);
    final mapService = FakeMapService();
    final offlineService = FakeMapService()
      ..searchError = 'Pencarian tempat belum bisa dimuat. Coba lagi.'
      ..reverseHandler = (_) async => throw const MapServiceException(
        'Alamat belum bisa dimuat. Coba lagi.',
      );
    final loadingRepository = LocalRideRepository(
      delay: const Duration(seconds: 5),
    );
    addTearDown(loadingRepository.dispose);
    const request = RideSearchRequest(
      origin: khatibPlace,
      destination: unandPlace,
    );
    final screens = <String, Widget>{
      '01-filter-pencarian': const Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: RideFilterSheet(
            initialFilter: RideFilter(minimumSeats: 2, maximumFare: 10000),
          ),
        ),
      ),
      '02-beranda': HomeScreen(
        userName: 'Mikail',
        repository: passengerRepository,
      ),
      '03-detail-tebengan': RideDetailScreen(ride: demoRides.first),
      '04-cari-terisi': HomeScreen(
        userName: 'Mikail',
        repository: passengerRepository,
        initialOrigin: khatibPlace,
        initialDestination: unandPlace,
      ),
      '05-hasil-pencarian': RideResultsScreen(
        request: request,
        repository: passengerRepository,
      ),
      '06-hasil-kosong': RideResultsScreen(
        request: const RideSearchRequest(
          origin: MapLocation(
            label: 'Lokasi jauh',
            point: GeoPoint(-0.5, 100.35),
          ),
          destination: unandPlace,
        ),
        repository: passengerRepository,
      ),
      '07-hasil-gagal': RideResultsScreen(
        request: request,
        repository: passengerRepository,
        simulateError: true,
      ),
      '08-pilih-tempat': PlaceSearchScreen(label: 'Dari', service: mapService),
      '09-hasil-tempat': PlaceSearchScreen(label: 'Dari', service: mapService),
      '10-pin-siap': LocationPickerScreen(
        title: 'Pin Dari',
        service: mapService,
        initialLocation: khatibPlace,
      ),
      '11-hasil-loading': RideResultsScreen(
        request: request,
        repository: loadingRepository,
      ),
      '12-tempat-gagal': PlaceSearchScreen(
        label: 'Ke',
        service: offlineService,
      ),
      '13-pin-gagal': LocationPickerScreen(
        title: 'Pin Ke',
        service: offlineService,
        initialLocation: unandPlace,
      ),
      '14-pin-manual': LocationPickerScreen(
        title: 'Pin Ke',
        service: offlineService,
        initialLocation: unandPlace,
      ),
    };
    for (final entry in screens.entries) {
      final boundaryKey = GlobalKey();
      await pumpTestWidget(
        tester,
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
            key: ValueKey(entry.key),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(builder: (_) => entry.value),
                  ),
                  child: const Text('Review'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Review'));
      if (entry.key == '11-hasil-loading') {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      } else {
        await tester.pumpAndSettle();
      }
      if (entry.key == '09-hasil-tempat' || entry.key == '12-tempat-gagal') {
        await tester.enterText(
          find.byKey(const ValueKey('place-query')),
          'Khatib',
        );
        await tester.pump(const Duration(milliseconds: 750));
        await tester.pumpAndSettle();
        tester.testTextInput.hide();
        await tester.pumpAndSettle();
      }
      if (entry.key == '13-pin-gagal' || entry.key == '14-pin-manual') {
        tester.widget<OpenStreetMapView>(find.byType(OpenStreetMapView)).onTap!(
          unandPlace.point,
        );
        await tester.pump(const Duration(milliseconds: 750));
        await tester.pumpAndSettle();
        if (entry.key == '14-pin-manual') {
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Alamat dari titik di peta'),
            'Universitas Andalas, Limau Manis, Padang',
          );
          tester.testTextInput.hide();
          await tester.pumpAndSettle();
        }
      }
      expect(tester.takeException(), isNull, reason: entry.key);
      if (capture) {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/visual-review').create(recursive: true);
          await File('build/visual-review/${entry.key}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      if (entry.key == '11-hasil-loading') {
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
    }
  });
}
