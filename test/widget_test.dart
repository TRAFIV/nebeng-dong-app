import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/screens/home_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';
import 'package:praktikum_mobile/utils/rupiah_format.dart';
import 'package:praktikum_mobile/utils/validators.dart';

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
    await tester.pumpWidget(const NebengDongApp());

    await _login(tester, 'mikail@gmail.com');

    expect(find.text('Pakai email kampus (unand.ac.id), ya!'), findsOneWidget);
    expect(find.text('Hai, Mikail!'), findsNothing);
  });

  testWidgets('Login, cari tebengan, lalu buka detail', (tester) async {
    await tester.pumpWidget(const NebengDongApp());

    await _login(tester, 'mikail@student.unand.ac.id');
    expect(find.text('Hai, Mikail!'), findsOneWidget);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );

    await tester.enterText(
      _fieldWithHint('Contoh: Jl. Khatib Sulaiman'),
      'veteran',
    );
    await tester.tap(find.text('Cariin Tebengan!'));
    await tester.pumpAndSettle();
    expect(find.text('Duha Alul Bariq'), findsOneWidget);
    expect(find.text('Taris Rafivdean'), findsNothing);

    await tester.ensureVisible(find.text('Duha Alul Bariq'));
    await tester.tap(find.text('Duha Alul Bariq'));
    await tester.pumpAndSettle();
    expect(find.text('Info Tebengan'), findsOneWidget);

    await tester.tap(find.text('Ikut Nebeng!'));
    await tester.pump();
    expect(find.text('Titik jemputnya diisi dulu, ya'), findsOneWidget);
  });

  testWidgets('Home menangani data kosong dan error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const HomeScreen(
          key: ValueKey('empty-home'),
          userName: 'Mikail',
          rides: [],
          loadDelay: Duration(milliseconds: 100),
        ),
      ),
    );
    expect(find.text('Nyari tebengan dulu...'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Belum ada tebengan.'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const HomeScreen(
          key: ValueKey('error-home'),
          userName: 'Mikail',
          simulateError: true,
          loadDelay: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Oops, terjadi kesalahan'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('Catatan dari form kembali dan tampil di Detail', (tester) async {
    await tester.pumpWidget(const NebengDongApp());
    await _login(tester, 'mikail@student.unand.ac.id');

    await tester.enterText(
      _fieldWithHint('Contoh: Jl. Khatib Sulaiman'),
      'khatib',
    );
    await tester.tap(find.text('Cariin Tebengan!'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Taris Rafivdean'));
    await tester.tap(find.text('Taris Rafivdean'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tulis Catatan'));
    await tester.pumpAndSettle();
    expect(find.text('Tulis Catatan'), findsOneWidget);

    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Catatan wajib diisi'), findsOneWidget);

    await tester.enterText(
      _fieldWithHint('Tulis catatan untuk tebengan ini'),
      'Tunggu di gerbang utama',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Tunggu di gerbang utama'), findsOneWidget);
    expect(find.text('Catatan berhasil disimpan'), findsOneWidget);
  });

  testWidgets('Route yang tidak dikenal menampilkan halaman 404', (
    tester,
  ) async {
    await tester.pumpWidget(const NebengDongApp());

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/tidak-ada');
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Route: /tidak-ada'), findsOneWidget);
  });
}
