import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
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
      // Modul 1 (Cari) dan Modul 2 (Pesanan) aktif; Ongkos dan Profil tetap disabled.
      expect(destinations[0].enabled, isTrue);
      expect(destinations[1].enabled, isTrue);
      expect(destinations[2].enabled, isFalse);
      expect(destinations[3].enabled, isFalse);
      expect(
        find.text('Data latihan · bukan perjalanan nyata'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'Tapping Pesanan tab in navigation bar navigates to PesananSayaScreen',
    (tester) async {
      await pumpTestWidget(
        tester,
        MaterialApp(
          theme: AppTheme.light,
          home: const HomeScreen(userName: 'Mikail', loadDelay: Duration.zero),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      final pesananTab = find.text('Pesanan');
      expect(pesananTab, findsOneWidget);
      await tester.tap(pesananTab);
      await tester.pumpAndSettle();

      expect(find.text('Pesanan Saya'), findsOneWidget);
      expect(find.text('Pesanan Aktif'), findsOneWidget);
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
}
