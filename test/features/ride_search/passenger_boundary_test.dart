import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';

import '../../support/map_test_support.dart';

void main() {
  test('Location palette aliases shared colors', () {
    expect(AppColors.locationFill, AppColors.surface);
    expect(AppColors.routeOrigin, AppColors.brandStrong);
    expect(AppColors.routeDestination, AppColors.successText);
  });
  testWidgets(
    'Passenger Home has no driver UI and unavailable tabs are disabled',
    (tester) async {
      await pumpTestWidget(
        tester,
        MaterialApp(
          theme: AppTheme.light,
          home: const HomeScreen(userName: 'Mikail', loadDelay: Duration.zero),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in [
        'Beri Tebengan',
        'Buat Tebengan',
        'Rute Saya',
        'Saya pengemudi',
      ]) {
        expect(find.text(label), findsNothing);
      }
      final destinations = tester
          .widgetList<NavigationDestination>(find.byType(NavigationDestination))
          .toList();
      expect(destinations.map((d) => d.label), [
        'Cari',
        'Pesanan',
        'Ongkos',
        'Profil',
      ]);
      expect(destinations.skip(1).every((d) => !d.enabled), isTrue);
      expect(find.text('Data latihan · bukan perjalanan nyata'), findsNothing);
    },
  );
  for (final path in [AppRoutes.postRoute, AppRoutes.myRoutes]) {
    testWidgets(
      'Archived route $path is blocked even with arbitrary arguments',
      (tester) async {
        expect(
          AppRoutes.onGenerateRoute(
            RouteSettings(name: path, arguments: Object()),
          ),
          isNull,
        );
        await pumpTestWidget(tester, const NebengDongApp());
        tester
            .state<NavigatorState>(find.byType(Navigator))
            .pushNamed(path, arguments: Object());
        await tester.pumpAndSettle();
        expect(find.text('404'), findsOneWidget);
        expect(find.text('Route: $path'), findsOneWidget);
        expect(find.text('Posting Rutenya!'), findsNothing);
        expect(find.text('Bikin Rute Baru'), findsNothing);
      },
    );
  }
  for (final entry in <String, String>{
    'filter with wrong arguments': AppRoutes.rideFilter,
    'results with wrong arguments': AppRoutes.rideResults,
    'an unknown route': '/tidak-ada',
  }.entries) {
    testWidgets('Typed navigation to ${entry.key} shows 404 and returns null', (
      tester,
    ) async {
      await pumpTestWidget(tester, const NebengDongApp());
      final result = tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed<RideFilter>(entry.value, arguments: 'invalid');
      await tester.pumpAndSettle();
      expect(find.text('404'), findsOneWidget);
      expect(find.text('Route: ${entry.value}'), findsOneWidget);
      await tester.tap(find.text('Kembali'));
      await tester.pumpAndSettle();
      expect(await result, isNull);
      expect(find.text('404'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
