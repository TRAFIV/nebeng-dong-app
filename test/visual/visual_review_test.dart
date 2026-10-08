import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
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
  testWidgets('Review enam tampilan pada viewport 360×800', (tester) async {
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
        rides: repository.rides,
        loadDelay: Duration.zero,
      ),
      '05-detail-tebengan': RideDetailScreen(ride: repository.rides.first),
      '06-cari-kosong': HomeScreen(
        userName: 'Mikail',
        rides: const [],
        loadDelay: Duration.zero,
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
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (_) => entry.value),
                  ),
                  child: const Text('Review'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
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
    }
  });
}
