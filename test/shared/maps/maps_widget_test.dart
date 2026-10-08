import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/shared/maps/views/location_picker_screen.dart';
import 'package:praktikum_mobile/legacy/driver/views/post_route_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_field.dart';

import '../../support/map_test_support.dart';

Finder field(String hint) => find.widgetWithText(TextFormField, hint);

Widget fieldApp(
  TextEditingController controller,
  FakeMapService service,
  ValueChanged<MapLocation?> onSelected,
) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: SingleChildScrollView(
      child: LocationField(
        label: 'Asal',
        hint: 'Cari lokasi',
        controller: controller,
        service: service,
        onSelected: onSelected,
      ),
    ),
  ),
);

Future<void> openPicker(
  WidgetTester tester,
  FakeMapService service,
  ValueChanged<MapLocation?> onResult, {
  MapLocation? initial,
}) async {
  await pumpTestWidget(
    tester,
    MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => onResult(
              await Navigator.push<MapLocation>(
                context,
                MaterialPageRoute(
                  builder: (_) => LocationPickerScreen(
                    title: 'Pin asal',
                    service: service,
                    initialLocation: initial,
                  ),
                ),
              ),
            ),
            child: const Text('Buka peta'),
          ),
        ),
      ),
    ),
    service: service,
  );
  await tester.tap(find.text('Buka peta'));
  await tester.pumpAndSettle();
}

Future<void> fillPost(WidgetTester tester) async {
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
  await tester.enterText(field('07.30'), '07.30');
  await tester.enterText(field('3'), '3');
}

void main() {
  testWidgets(
    'Pin dari LocationField mengisi nama dan koordinat; batal tidak mengubah pilihan',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final service = FakeMapService();
      MapLocation? selected;
      await pumpTestWidget(
        tester,
        fieldApp(controller, service, (place) => selected = place),
        service: service,
      );
      final pinAction = find.byTooltip('Pilih pin di peta');
      expect(
        tester.getCenter(pinAction).dx,
        greaterThan(tester.getRect(find.byType(LocationField)).center.dx),
      );
      await tester.tap(pinAction);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FlutterMap));
      await tester.pumpAndSettle();
      final visibleMap = tester
          .getRect(find.byType(FlutterMap))
          .intersect(tester.getRect(find.byType(SingleChildScrollView).first));
      expect(visibleMap.height, greaterThan(0));
      await tester.tapAt(visibleMap.center);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gunakan Pin Ini'));
      await tester.pumpAndSettle();
      expect(selected, isNotNull);
      expect(controller.text, selected!.label);
      final original = selected;
      final editPinAction = find.byTooltip('Ubah pin di peta');
      expect(
        tester.getCenter(editPinAction).dx,
        greaterThan(tester.getRect(find.byType(LocationField)).center.dx),
      );
      await tester.tap(editPinAction);
      await tester.pumpAndSettle();
      await tester.tapAt(
        tester.getRect(find.byType(FlutterMap)).center + const Offset(50, 20),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(selected, same(original));
      expect(controller.text, original!.label);
    },
  );
  testWidgets('Koordinat batal jika teks berubah, bukan jika kursor bergeser', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final service = FakeMapService();
    MapLocation? selected;
    await pumpTestWidget(
      tester,
      fieldApp(controller, service, (place) => selected = place),
      service: service,
    );
    await selectTestLocation(tester, field('Cari lokasi'), 'Air Tawar');
    expect(selected, isNotNull);
    controller.selection = const TextSelection.collapsed(offset: 1);
    await tester.pump();
    expect(selected, isNotNull);
    await tester.enterText(field('Cari lokasi'), 'Lokasi lain');
    await tester.pump();
    expect(selected, isNull);
    expect(find.text('Lokasi dipilih'), findsNothing);
  });

  testWidgets('Respons autocomplete lama tidak mengganti query terbaru', (
    tester,
  ) async {
    final first = Completer<List<MapLocation>>();
    final second = Completer<List<MapLocation>>();
    final service = FakeMapService()
      ..searchHandler = (query) =>
          query == 'Lama' ? first.future : second.future;
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpTestWidget(
      tester,
      fieldApp(controller, service, (_) {}),
      service: service,
    );
    await tester.enterText(field('Cari lokasi'), 'Lama');
    await tester.pump(const Duration(milliseconds: 750));
    await tester.enterText(field('Cari lokasi'), 'Baru');
    await tester.pump(const Duration(milliseconds: 750));
    second.complete([FakeMapService.place('Baru')]);
    await tester.pumpAndSettle();
    first.complete([FakeMapService.place('Lama')]);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Baru'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Lama'), findsNothing);
  });

  testWidgets('Pencarian gagal bisa retry dan dispose membatalkan debounce', (
    tester,
  ) async {
    final service = FakeMapService()..searchError = 'Internet tidak tersedia';
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpTestWidget(
      tester,
      fieldApp(controller, service, (_) {}),
      service: service,
    );
    await tester.enterText(field('Cari lokasi'), 'Air Tawar');
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();
    expect(find.text('Internet tidak tersedia'), findsOneWidget);
    service.searchError = null;
    await tester.tap(find.text('Coba cari lagi'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Air Tawar'), findsOneWidget);
    await tester.enterText(field('Cari lokasi'), 'Debounce');
    final calls = service.searchCalls;
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(service.searchCalls, calls);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ketuk peta membuat dan memindahkan pin, lalu memberi nama', (
    tester,
  ) async {
    MapLocation? result;
    await openPicker(tester, FakeMapService(), (place) => result = place);
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'Gunakan Pin Ini'))
          .onPressed,
      isNull,
    );
    expect(
      find.byType(TileLayer),
      findsNothing,
    ); // Tidak mengakses server publik.
    final map = find.byType(FlutterMap);
    await tester.tapAt(tester.getRect(map).center);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    final firstPoint = tester
        .widget<MarkerLayer>(find.byType(MarkerLayer))
        .markers
        .single
        .point;
    await tester.tapAt(tester.getRect(map).center + const Offset(70, -30));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MarkerLayer>(find.byType(MarkerLayer)).markers.single.point,
      isNot(firstPoint),
    );
    await tester.dragFrom(const Offset(4, 400), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.ensureVisible(field('Contoh: Gerbang utama kampus'));
    await tester.enterText(
      field('Contoh: Gerbang utama kampus'),
      'Gerbang utama',
    );
    await tester.tap(find.text('Gunakan Pin Ini'));
    await tester.pumpAndSettle();
    expect(result!.label, 'Gerbang utama');
    expect(result!.point.latitude, inInclusiveRange(-90, 90));
    expect(
      result!.address,
      'Jalan Khatib Sulaiman, Padang, Sumatera Barat, Indonesia',
    );
  });

  testWidgets('Geser peta tidak memilih pin; kembali membatalkan perubahan', (
    tester,
  ) async {
    MapLocation? result;
    final initial = FakeMapService.place('Air Tawar');
    await openPicker(tester, FakeMapService(), (place) => result = place);
    await tester.drag(find.byType(FlutterMap), const Offset(60, 0));
    await tester.pumpAndSettle();
    expect(find.text('Pin sudah dipilih'), findsNothing);
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'Gunakan Pin Ini'))
          .onPressed,
      isNull,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await openPicker(
      tester,
      FakeMapService(),
      (place) => result = place,
      initial: initial,
    );
    await tester.tapAt(
      tester.getRect(find.byType(FlutterMap)).center + const Offset(30, 10),
    );
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(initial.point.latitude, -0.90);
  });

  testWidgets(
    'Saran tempat pada picker memusatkan peta dan mengembalikan koordinat',
    (tester) async {
      MapLocation? result;
      await openPicker(tester, FakeMapService(), (place) => result = place);
      await selectTestLocation(
        tester,
        field('Cari tempat atau alamat'),
        'Air Tawar',
      );
      await tester.tap(find.text('Gunakan Pin Ini'));
      await tester.pumpAndSettle();
      expect(result!.point.latitude, -0.90);
      expect(result!.label, 'Air Tawar');
    },
  );

  testWidgets('Gagal OSRM tidak posting; retry menyimpan geometry', (
    tester,
  ) async {
    final repo = LegacyDriverRepository(rides: []);
    final service = FakeMapService()..routeError = 'Jalur belum tersedia';
    await pumpTestWidget(
      tester,
      MaterialApp(
        theme: AppTheme.light,
        home: PostRouteScreen(repository: repo, driverName: 'Mikail'),
      ),
      service: service,
    );
    await fillPost(tester);
    await tester.tap(find.text('Posting Rutenya!'));
    await tester.pumpAndSettle();
    expect(find.text('Jalur belum tersedia'), findsOneWidget);
    expect(repo.rides, isEmpty);
    service.routeError = null;
    await tester.tap(find.text('Posting Rutenya!'));
    await tester.pumpAndSettle();
    expect(repo.rides.single.geography, isNotNull);
    expect(service.routeCalls, 2);
  });

  testWidgets(
    'Kembali saat perhitungan belum selesai tidak memposting diam-diam',
    (tester) async {
      final repo = LegacyDriverRepository(rides: []);
      final pending = Completer<RoadRoute>();
      final service = FakeMapService()..routeHandler = (_, _) => pending.future;
      await pumpTestWidget(
        tester,
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PostRouteScreen(repository: repo, driverName: 'Mikail'),
                  ),
                ),
                child: const Text('Buka posting'),
              ),
            ),
          ),
        ),
        service: service,
      );
      await tester.tap(find.text('Buka posting'));
      await tester.pumpAndSettle();
      await fillPost(tester);
      await tester.tap(find.text('Posting Rutenya!'));
      await tester.pump();
      expect(
        tester
            .widget<AppButton>(
              find.widgetWithText(AppButton, 'Menghitung Jalur...'),
            )
            .onPressed,
        isNull,
      );
      await tester.pageBack();
      // Complete while the popped screen is still mounted in its animation.
      await tester.pump(const Duration(milliseconds: 10));
      pending.complete(
        RoadRoute(
          points: [
            FakeMapService.place('Air Tawar').point,
            FakeMapService.place('Unand').point,
          ],
          distanceMeters: 5000,
          durationSeconds: 600,
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.rides, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Home cocok berdasarkan koordinat berbeda nama, bukan rute contoh tanpa geo',
    (tester) async {
      final repo = LegacyDriverRepository(rides: []);
      final origin = FakeMapService.place('Air Tawar');
      final destination = FakeMapService.place('Unand');
      final road = RoadRoute(
        points: [origin.point, destination.point],
        distanceMeters: 5000,
        durationSeconds: 600,
      );
      repo.post(
        driverName: 'Pengemudi cocok',
        origin: 'Nama A',
        destination: 'Nama B',
        departureTime: '07.30',
        capacity: 3,
        geography: RideGeography(
          origin: origin,
          destination: destination,
          route: road,
        ),
      );
      repo.post(
        driverName: 'Tanpa koordinat',
        origin: 'Air Tawar',
        destination: 'Unand',
        departureTime: '07.30',
        capacity: 3,
      );
      await pumpTestWidget(
        tester,
        MaterialApp(
          theme: AppTheme.light,
          home: HomeScreen(
            userName: 'Mikail',
            rides: repo.rides,
            loadDelay: Duration.zero,
          ),
        ),
      );
      await tester.pumpAndSettle();
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
      await tester.tap(find.text('Pesanan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cari'));
      await tester.pumpAndSettle();
      expect(find.text('Lokasi dipilih'), findsNWidgets(2));
      expect(find.textContaining('Mode teks'), findsNothing);
      expect(find.textContaining('Mode jalur'), findsNothing);
      expect(find.textContaining('Contoh lama'), findsNothing);
      expect(find.textContaining('100.35000'), findsNothing);
      await Scrollable.ensureVisible(
        tester.element(find.text('Cariin Tebengan!')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cariin Tebengan!'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Pengemudi cocok'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pengemudi cocok'), findsOneWidget);
      expect(find.text('Tanpa koordinat'), findsNothing);
      expect(find.text('Searah jalur'), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, 1500));
      await tester.pumpAndSettle();
      await selectTestLocation(
        tester,
        field('Contoh: Jl. Khatib Sulaiman'),
        'Unand',
      );
      await selectTestLocation(
        tester,
        field('Contoh: Kampus Unand Limau Manis'),
        'Air Tawar',
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Cariin Tebengan!')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cariin Tebengan!'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(
          'Yah, belum ada yang cocok. Coba ganti lokasi atau filternya, deh!',
        ),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pengemudi cocok'), findsNothing);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets('Picker pin responsif pada 320px skala teks $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpTestWidget(
        tester,
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: LocationPickerScreen(
            title: 'Pin Berangkat dari mana?',
            service: FakeMapService(),
            initialLocation: FakeMapService.place('Air Tawar'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FlutterMap));
      await tester.pumpAndSettle();
      final visibleMap = tester
          .getRect(find.byType(FlutterMap))
          .intersect(tester.getRect(find.byType(SingleChildScrollView).first));
      expect(visibleMap.height, greaterThan(0));
      await tester.tapAt(visibleMap.center);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      // Scroll the enclosing page, not the embedded map's own pan gesture.
      for (var i = 0; i < 3; i++) {
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position;
        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(field('Contoh: Gerbang utama kampus'));
      await tester.enterText(
        field('Contoh: Gerbang utama kampus'),
        'Nama pin panjang',
      );
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Gunakan Pin Ini').hitTestable(), findsOneWidget);
    });
  }
}
