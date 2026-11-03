import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/booking/views/detail_pesanan_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/shared/views/passenger_shell_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';

import '../../support/map_test_support.dart';

void main() {
  test('Location palette aliases shared colors', () {
    expect(AppColors.locationFill, AppColors.surface);
    expect(AppColors.routeOrigin, AppColors.brandStrong);
    expect(AppColors.routeDestination, AppColors.successText);
  });
  Finder navTab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Future<void> pumpShell(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        home: const PassengerShellScreen(userName: 'Mikail'),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Passenger shell has no driver UI and all four tabs', (
    tester,
  ) async {
    await pumpShell(tester);
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
    expect(destinations.every((d) => d.enabled), isTrue);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Switching tabs keeps one navbar and preserves each tab', (
    tester,
  ) async {
    await pumpShell(tester);
    final rootNavigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    await selectHomeLocation(tester, 'Dari', 'Air Tawar');

    await tester.tap(navTab('Pesanan'));
    await tester.pumpAndSettle();
    expect(find.text('Pesanan Saya'), findsOneWidget);
    expect(find.text('Pesanan Aktif'), findsOneWidget);
    // Tab berganti di tempat: tidak ada halaman baru di navigator utama.
    expect(rootNavigator.canPop(), isFalse);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);

    await tester.tap(navTab('Ongkos'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Ongkos'), findsOneWidget);

    await tester.tap(navTab('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Perjalanan'), findsOneWidget);

    await tester.tap(navTab('Cari'));
    await tester.pumpAndSettle();
    expect(find.text('Hai, Mikail!'), findsOneWidget);
    // Isi form Cari tetap ada setelah berkeliling tab.
    expect(find.text('Air Tawar'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Detail opens over the navbar; back returns to the same tab', (
    tester,
  ) async {
    await pumpShell(tester);
    await tester.tap(navTab('Pesanan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Taris Rafivdean').first);
    await tester.pumpAndSettle();
    expect(find.byType(DetailPesananScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DetailPesananScreen), findsNothing);
    expect(find.text('Pesanan Aktif'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Back on another tab goes to Cari before leaving the app', (
    tester,
  ) async {
    await pumpShell(tester);
    await tester.tap(navTab('Ongkos'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Hai, Mikail!'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
  });

  // Halaman pengemudi lama sudah dihapus; alamatnya harus berakhir di 404.
  for (final path in ['/post-route', '/my-routes']) {
    testWidgets(
      'Old driver route $path shows 404 even with arbitrary arguments',
      (tester) async {
        expect(
          AppRoutes.onGenerateRoute(
            RouteSettings(name: path, arguments: Object()),
          ),
          isNull,
        );
        await pumpTestWidget(tester, const NebengDongApp());
        tester
            .state<NavigatorState>(find.byType(Navigator).first)
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
