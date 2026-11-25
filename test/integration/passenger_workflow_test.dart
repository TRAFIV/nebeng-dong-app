import 'package:flutter/material.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/utils/validators.dart';

import '../support/map_test_support.dart';

Finder _fieldWithHint(String hint) => find.widgetWithText(TextFormField, hint);

Future<void> _login(WidgetTester tester, String email) async {
  await tester.enterText(_fieldWithHint('nama@student.unand.ac.id'), email);
  await tester.enterText(_fieldWithHint('Ketik password kamu'), 'rahasia1');
  await tester.tap(find.text('Gas Masuk!'));
  await tester.pumpAndSettle();
}

void main() {
  test('formatRupiah memberi pemisah ribuan', () {
    expect(formatRupiah(500), 'Rp500');
    expect(formatRupiah(5000), 'Rp5.000');
    expect(formatRupiah(1250000), 'Rp1.250.000');
    expect(formatThousands(999), '999');
    expect(formatThousands(10000), '10.000');
  });

  test('Validators memeriksa email, password, dan panjang catatan', () {
    expect(Validators.email('abc'), 'Format email tidak valid');
    expect(Validators.email('mikail@student.unand.ac.id'), isNull);
    expect(Validators.password('123'), 'Password minimal 8 karakter');
    expect(
      Validators.minLength('abc', 5, fieldName: 'Catatan'),
      'Catatan minimal 5 karakter',
    );
  });

  testWidgets('Login menolak email di luar domain kampus', (tester) async {
    await pumpTestWidget(tester, const NebengDongApp());

    await _login(tester, 'mikail@gmail.com');

    expect(find.text('Pakai email kampus (unand.ac.id), ya!'), findsOneWidget);
    expect(find.text('Hai, Mikail!'), findsNothing);
  });

  testWidgets('Login, cari tebengan, lalu buka detail', (tester) async {
    await pumpTestWidget(tester, const NebengDongApp());

    await _login(tester, 'mikail@student.unand.ac.id');
    expect(find.text('Hai, Mikail!'), findsOneWidget);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator).first).canPop(),
      isFalse,
    );

    await selectHomeLocation(tester, 'Dari', 'veteran');
    await selectHomeLocation(tester, 'Ke', 'Universitas Andalas');
    await tester.tap(find.text('Cariin Tebengan!'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Duha Alul Bariq'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Duha Alul Bariq'), findsOneWidget);
    expect(find.text('Taris Rafivdean'), findsNothing);

    await Scrollable.ensureVisible(
      tester.element(find.text('Duha Alul Bariq')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duha Alul Bariq'));
    await tester.pumpAndSettle();
    expect(find.text('Info Tebengan'), findsOneWidget);

    await tester.ensureVisible(find.text('Ikut Nebeng!'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ikut Nebeng!'));
    await tester.pumpAndSettle();
    expect(find.text('Ajukan Tebengan'), findsOneWidget);

    // Kembali tanpa mengirim: tombol di Info Tebengan bisa dipakai lagi.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Info Tebengan'), findsOneWidget);
    final button = find.widgetWithText(FilledButton, 'Ikut Nebeng!');
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('Hasil menangani loading, kosong dan error', (tester) async {
    Widget app(String id, {bool error = false}) => MaterialApp(
      key: ValueKey(id),
      theme: AppTheme.light,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: HomeScreen(
        userName: 'Mikail',
        rides: [],
        simulateError: error,
        loadDelay: const Duration(milliseconds: 500),
        initialOrigin: FakeMapService.place('khatib'),
        initialDestination: FakeMapService.place('Universitas Andalas'),
      ),
    );
    await pumpTestWidget(tester, app('empty'));
    await tester.tap(find.text('Cariin Tebengan!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Nyari tebengan dulu...'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Belum ada yang searah'), findsOneWidget);
    expect(find.text('Ubah Pencarian'), findsOneWidget);
    await pumpTestWidget(tester, app('error', error: true));
    await tester.tap(find.text('Cariin Tebengan!'));
    await tester.pumpAndSettle();
    expect(find.text('Belum bisa memuat tebengan'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('Route yang tidak dikenal menampilkan halaman 404', (
    tester,
  ) async {
    await pumpTestWidget(tester, const NebengDongApp());

    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed('/tidak-ada');
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Route: /tidak-ada'), findsOneWidget);
  });
}
