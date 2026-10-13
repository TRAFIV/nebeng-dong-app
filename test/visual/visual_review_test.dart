import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
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
import 'package:praktikum_mobile/legacy/driver/views/my_routes_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/shared/views/ride_detail_screen.dart';
import 'package:praktikum_mobile/legacy/driver/views/post_route_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/ride_filter_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

import '../support/map_test_support.dart';

ThemeData _reviewTheme() {
  final theme = AppTheme.light;
  final label = WidgetStatePropertyAll(
    AppTextStyles.labelLarge.copyWith(fontFamily: 'Roboto'),
  );
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: theme.appBarTheme.titleTextStyle!.copyWith(
        fontFamily: 'Roboto',
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: theme.filledButtonTheme.style!.copyWith(textStyle: label),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: theme.outlinedButtonTheme.style!.copyWith(textStyle: label),
    ),
    textButtonTheme: TextButtonThemeData(
      style: theme.textButtonTheme.style!.copyWith(textStyle: label),
    ),
    chipTheme: theme.chipTheme.copyWith(
      labelStyle: theme.chipTheme.labelStyle!.copyWith(fontFamily: 'Roboto'),
    ),
  );
}

/// Screenshot opt-in dari widget asli, bukan mockup atau golden acuan palsu.
/// flutter test test/visual/visual_review_test.dart --dart-define=SAVE_SCREENSHOTS=true
void main() {
  testWidgets('Review passenger screens and legacy archive at 360×800', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const capture = bool.fromEnvironment('SAVE_SCREENSHOTS');
    if (capture) {
      final sdk = Platform.environment['FLUTTER_ROOT'];
      if (sdk == null) {
        throw StateError('FLUTTER_ROOT diperlukan untuk font review');
      }
      final loader = FontLoader('Roboto');
      for (final weight in ['regular', 'medium', 'bold']) {
        final bytes = File(
          '$sdk/bin/cache/artifacts/material_fonts/roboto-$weight.ttf',
        ).readAsBytesSync();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
            ).readAsBytesSync(),
          ),
        ),
      );
      await icons.load();
    }
    final repository = LegacyDriverRepository(rides: []);
    final passengerRepository = LocalRideRepository(delay: Duration.zero);
    addTearDown(repository.dispose);
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
    repository.post(
      driverName: 'Mikail',
      origin: 'Jl. Khatib Sulaiman',
      destination: 'Kampus Unand Limau Manis',
      departureTime: '07.30',
      capacity: 3,
    );
    final returning = repository.post(
      driverName: 'Mikail',
      origin: 'Kampus Unand Limau Manis',
      destination: 'Jl. Khatib Sulaiman',
      departureTime: '16.30',
      capacity: 1,
    );
    repository.acceptBooking(routeId: returning.id, bookingId: 'review-full');
    final screens = <String, Widget>{
      '01-posting-rute': PostRouteScreen(
        repository: repository,
        driverName: 'Mikail',
      ),
      '02-rute-saya': MyRoutesScreen(
        repository: repository,
        userName: 'Mikail',
      ),
      '03-filter-pencarian': const RideFilterScreen(
        initialFilter: RideFilter(
          window: DepartureWindow.morning,
          minimumSeats: 2,
        ),
      ),
      '04-beranda': HomeScreen(
        userName: 'Mikail',
        repository: passengerRepository,
      ),
      '05-detail-tebengan': RideDetailScreen(ride: demoRides.first),
      '06-cari-terisi': HomeScreen(
        userName: 'Mikail',
        repository: passengerRepository,
        initialOrigin: khatibPlace,
        initialDestination: unandPlace,
      ),
      '07-hasil-pencarian': RideResultsScreen(
        request: request,
        repository: passengerRepository,
      ),
      '08-hasil-kosong': RideResultsScreen(
        request: const RideSearchRequest(
          origin: MapLocation(
            label: 'Lokasi jauh',
            point: GeoPoint(-0.5, 100.35),
          ),
          destination: unandPlace,
        ),
        repository: passengerRepository,
      ),
      '09-hasil-gagal': RideResultsScreen(
        request: request,
        repository: passengerRepository,
        simulateError: true,
      ),
      '10-pilih-tempat': PlaceSearchScreen(label: 'Dari', service: mapService),
      '11-hasil-tempat': PlaceSearchScreen(label: 'Dari', service: mapService),
      '12-pin-siap': LocationPickerScreen(
        title: 'Pin Dari',
        service: mapService,
        initialLocation: khatibPlace,
      ),
      '13-hasil-loading': RideResultsScreen(
        request: request,
        repository: loadingRepository,
      ),
      '14-tempat-gagal': PlaceSearchScreen(
        label: 'Ke',
        service: offlineService,
      ),
      '15-pin-gagal': LocationPickerScreen(
        title: 'Pin Ke',
        service: offlineService,
        initialLocation: unandPlace,
      ),
      '16-pin-manual': LocationPickerScreen(
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
            theme: capture ? _reviewTheme() : AppTheme.light,
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
      if (entry.key == '13-hasil-loading') {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      } else {
        await tester.pumpAndSettle();
      }
      if (entry.key == '11-hasil-tempat' || entry.key == '14-tempat-gagal') {
        await tester.enterText(
          find.byKey(const ValueKey('place-query')),
          'Khatib',
        );
        await tester.pump(const Duration(milliseconds: 750));
        await tester.pumpAndSettle();
        tester.testTextInput.hide();
        await tester.pumpAndSettle();
      }
      if (entry.key == '15-pin-gagal' || entry.key == '16-pin-manual') {
        tester.widget<OpenStreetMapView>(find.byType(OpenStreetMapView)).onTap!(
          unandPlace.point,
        );
        await tester.pump(const Duration(milliseconds: 750));
        await tester.pumpAndSettle();
        if (entry.key == '16-pin-manual') {
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
      if (entry.key == '13-hasil-loading') {
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
    }
  });
}
