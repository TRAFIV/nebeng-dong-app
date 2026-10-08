import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum_mobile/data/ride_repository.dart';
import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/models/ride.dart';
import 'package:praktikum_mobile/screens/home_screen.dart';
import 'package:praktikum_mobile/screens/ride_detail_screen.dart';
import 'package:praktikum_mobile/utils/rupiah_format.dart';
import 'package:praktikum_mobile/utils/validators.dart';

Finder _fieldWithHint(String hint) => find.widgetWithText(TextFormField, hint);

Future<void> _login(WidgetTester tester, String email) async {
  await tester.enterText(_fieldWithHint('nama@student.unand.ac.id'), email);
  await tester.enterText(_fieldWithHint('Ketik password kamu'), 'rahasia123');
  await tester.tap(find.text('Gas Masuk!'));
  await tester.pumpAndSettle();
}

class _FailingRepository extends RideRepository {
  const _FailingRepository();

  @override
  Future<List<Ride>> fetchRides({bool simulateError = false}) =>
      Future<List<Ride>>.error(Exception('Server lagi ngambek'));
}

void main() {
  test('formatRupiah memberi pemisah ribuan', () {
    expect(formatRupiah(500), 'Rp500');
    expect(formatRupiah(5000), 'Rp5.000');
    expect(formatRupiah(1250000), 'Rp1.250.000');
  });

  test('Validators', () {
    expect(Validators.email(''), 'Email wajib diisi');
    expect(Validators.email('abc'), 'Format email tidak valid');
    expect(Validators.email('a@b.co'), isNull);
    expect(Validators.password('123'), 'Password minimal 8 karakter');
    expect(Validators.password('12345678'), isNull);
    expect(
      Validators.minLength('abc', 5, fieldName: 'Catatan'),
      'Catatan minimal 5 karakter',
    );
  });

  testWidgets('Login menampilkan pesan error untuk isian salah', (
    tester,
  ) async {
    await tester.pumpWidget(const NebengDongApp());

    await tester.tap(find.text('Gas Masuk!'));
    await tester.pump();
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);

    await _login(tester, 'mikail@gmail.com');
    expect(find.text('Pakai email kampus (unand.ac.id), ya!'), findsOneWidget);
    expect(find.text('Hai, Mikail!'), findsNothing);
  });

  testWidgets('Login, cari tebengan, buka detail, tulis catatan', (
    tester,
  ) async {
    await tester.pumpWidget(const NebengDongApp());

    await _login(tester, 'mikail@student.unand.ac.id');
    expect(find.text('Hai, Mikail!'), findsOneWidget);
    expect(find.text('Taris Rafivdean'), findsOneWidget);

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

    // Form catatan: validasi, lalu simpan dan tampil di Detail.
    await tester.scrollUntilVisible(
      find.text('Tulis Catatan'),
      100,
      scrollable: find
          .descendant(
            of: find.byType(RideDetailScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Tulis Catatan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Catatan wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.pump();
    expect(find.text('Catatan minimal 5 karakter'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Aku bawa helm sendiri');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan: Aku bawa helm sendiri'), findsOneWidget);
  });

  testWidgets('Home menampilkan error dan tombol Coba Lagi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(userName: 'Mikail', repository: _FailingRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Server lagi ngambek'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('Route tidak terdaftar menampilkan halaman 404', (tester) async {
    await tester.pumpWidget(const NebengDongApp());
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    navigator.pushNamed('/tidak-ada');
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Route: /tidak-ada'), findsOneWidget);
  });
}
