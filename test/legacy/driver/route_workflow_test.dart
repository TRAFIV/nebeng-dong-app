import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/legacy/driver/routes/legacy_driver_routes.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/legacy/driver/views/post_route_screen.dart';
import 'package:praktikum_mobile/legacy/driver/views/my_routes_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/ride_filter_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

import '../../support/map_test_support.dart';

Future<LegacyDriverRepository> openLegacyRoutes(WidgetTester tester) async {
  final repo = LegacyDriverRepository(rides: [], delay: Duration.zero);
  addTearDown(repo.dispose);
  await pumpTestWidget(
    tester,
    MaterialApp(
      theme: AppTheme.light,
      onGenerateRoute: LegacyDriverRoutes.onGenerateRoute,
      home: MyRoutesScreen(repository: repo, userName: 'Mikail'),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Finder field(String hint) => find.widgetWithText(TextFormField, hint);

Future<void> login(WidgetTester tester) async {
  await pumpTestWidget(tester, const NebengDongApp());
  await tester.enterText(
    field('nama@student.unand.ac.id'),
    'mikail@student.unand.ac.id',
  );
  await tester.enterText(field('Ketik password kamu'), 'rahasia1');
  await tester.tap(find.text('Gas Masuk!'));
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, String text) async {
  final target = find.text(text);
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      target,
      100,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> fillRoute(WidgetTester tester) async {
  await selectTestLocation(
    tester,
    field('Contoh: Jl. Khatib Sulaiman'),
    'Air Tawar',
  );
  await selectTestLocation(
    tester,
    field('Contoh: Kampus Unand Limau Manis'),
    'Unand',
  );
  await tester.enterText(field('07.30'), '7:30');
  await tester.enterText(field('3'), '3');
}

void main() {
  testWidgets('Posting → result/feedback → edit → Home menampilkan perubahan', (
    tester,
  ) async {
    final repo = await openLegacyRoutes(tester);
    expect(
      find.text('Belum ada rute kamu. Yuk, bikin rute pertama!'),
      findsOneWidget,
    );
    await tapVisible(tester, 'Bikin Rute Baru');
    await tapVisible(tester, 'Posting Rutenya!');
    expect(find.text('Lokasi wajib diisi'), findsNWidgets(2));
    expect(find.text('Isi 1–8 kursi'), findsOneWidget);
    await fillRoute(tester);
    await tapVisible(tester, 'Posting Rutenya!');
    expect(find.text('Rute berhasil diposting'), findsOneWidget);
    expect(find.text('Rute Air Tawar → Unand'), findsOneWidget);
    await tapVisible(tester, 'Rute Air Tawar → Unand');
    await selectTestLocation(
      tester,
      field('Contoh: Jl. Khatib Sulaiman'),
      'Ulak Karang',
    );
    await tapVisible(tester, 'Simpan Perubahan');
    expect(find.text('Rute Ulak Karang → Unand'), findsOneWidget);
    expect(find.text('Rute berhasil diperbarui'), findsOneWidget);
    expect(repo.rides.first.origin, 'Ulak Karang');
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        home: HomeScreen(userName: 'Mikail', repository: repo),
      ),
    );
    await tester.pumpAndSettle();
    await selectTestLocation(
      tester,
      field('Contoh: Jl. Khatib Sulaiman'),
      'Ulak Karang',
    );
    await selectTestLocation(
      tester,
      field('Contoh: Kampus Unand Limau Manis'),
      'Unand',
    );
    await tapVisible(tester, 'Cariin Tebengan!');
    await tester.scrollUntilVisible(
      find.text('Ongkos belum diatur'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ulak Karang'), findsWidgets);
    expect(find.text('Ongkos belum diatur'), findsOneWidget);
  });

  testWidgets('Form menolak asal sama, jam di luar batas, dan kuota nol', (
    tester,
  ) async {
    final repo = LegacyDriverRepository(rides: []);
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        home: PostRouteScreen(repository: repo, driverName: 'Mikail'),
      ),
    );
    await fillRoute(tester);
    await tester.enterText(
      field('Contoh: Kampus Unand Limau Manis'),
      ' air tawar ',
    );
    await tester.enterText(field('07.30'), '24.00');
    await tester.enterText(field('3'), '0');
    await tapVisible(tester, 'Posting Rutenya!');
    expect(find.text('Tujuan harus berbeda dari asal'), findsOneWidget);
    expect(find.text('Gunakan jam 00.00–23.59'), findsOneWidget);
    expect(find.text('Isi 1–8 kursi'), findsOneWidget);
    expect(repo.rides, isEmpty);
  });

  testWidgets('Batal form tidak posting; hapus harus dikonfirmasi', (
    tester,
  ) async {
    await openLegacyRoutes(tester);
    await tapVisible(tester, 'Bikin Rute Baru');
    await fillRoute(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Rute Air Tawar → Unand'), findsNothing);
    await tapVisible(tester, 'Bikin Rute Baru');
    await fillRoute(tester);
    await tapVisible(tester, 'Posting Rutenya!');
    await tapVisible(tester, 'Atur');
    await tapVisible(tester, 'Hapus');
    await tapVisible(tester, 'Batal');
    expect(find.text('Rute Air Tawar → Unand'), findsOneWidget);
    await tapVisible(tester, 'Hapus');
    await tester.tap(find.widgetWithText(TextButton, 'Hapus').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Belum ada rute kamu. Yuk, bikin rute pertama!'),
      findsOneWidget,
    );
    expect(find.text('Rute berhasil dihapus'), findsOneWidget);
  });

  testWidgets(
    'Filter draft batal, apply 2 kursi, reset/apply mengembalikan hasil',
    (tester) async {
      await login(tester);
      await tapVisible(tester, 'Filter');
      await tapVisible(tester, '3 kursi');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Filter aktif'), findsNothing);
      await tapVisible(tester, 'Filter');
      await tapVisible(tester, '2 kursi');
      await tester.enterText(field('Contoh: 10.000'), '5.000');
      await tapVisible(tester, 'Terapkan');
      expect(find.text('Filter aktif'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Taris Rafivdean'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Duha Alul Bariq'), findsNothing);
      await tapVisible(tester, 'Filter aktif');
      await tapVisible(tester, 'Atur Ulang');
      expect(
        tester.widget<TextFormField>(field('Contoh: 10.000')).controller!.text,
        isEmpty,
      );
      await tapVisible(tester, 'Terapkan');
      expect(find.text('Filter aktif'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Duha Alul Bariq'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Duha Alul Bariq'), findsOneWidget);
    },
  );

  testWidgets(
    'Filter menolak ongkos invalid dan mengembalikan result bertipe',
    (tester) async {
      RideFilter? result;
      await pumpTestWidget(
        tester,
        MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.pushNamed<RideFilter>(
                    context,
                    AppRoutes.rideFilter,
                  );
                },
                child: const Text('Buka filter'),
              ),
            ),
          ),
        ),
      );
      await tapVisible(tester, 'Buka filter');
      await tester.enterText(field('Contoh: 10.000'), '-100');
      await tapVisible(tester, 'Terapkan');
      expect(find.text('Isi rupiah bulat, contoh 10.000'), findsOneWidget);
      expect(result, isNull);
      await tester.enterText(field('Contoh: 10.000'), '10.000');
      await tapVisible(tester, '07.00–08.00');
      await tapVisible(tester, 'Terapkan');
      expect(result!.maximumFare, 10000);
      expect(result!.window, DepartureWindow.morning);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets('Layar Modul 1 tidak overflow pada 320px, skala teks $scale', (
      tester,
    ) async {
      final originalHandler = FlutterError.onError;
      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = (details) {
        errors.add(details);
        originalHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalHandler);
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
          PostRouteScreen(
            repository: LegacyDriverRepository(),
            driverName: 'Mikail',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Posting Rutenya!'));
      await tester.pumpAndSettle();
      expect(find.text('Lokasi wajib diisi'), findsNWidgets(2));
      expect(find.text('Isi 1–8 kursi'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await pumpTestWidget(tester, app(const RideFilterScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final repo = LegacyDriverRepository(rides: []);
      repo.post(
        driverName: 'Mikail',
        origin: 'Khatib Sulaiman',
        destination: 'Kampus Unand Limau Manis',
        departureTime: '07.30',
        capacity: 3,
      );
      await pumpTestWidget(
        tester,
        app(MyRoutesScreen(repository: repo, userName: 'Mikail')),
      );
      await tester.pumpAndSettle();
      final error = tester.takeException();
      expect(
        error,
        isNull,
        reason: errors.map((details) => details.toString()).join('\n'),
      );
    });
  }
}
