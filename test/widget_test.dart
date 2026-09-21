import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/utils/rupiah_format.dart';

Finder _fieldWithHint(String hint) => find.widgetWithText(TextFormField, hint);

Future<void> _login(WidgetTester tester, String email) async {
  await tester.enterText(_fieldWithHint('nama@student.unand.ac.id'), email);
  await tester.enterText(_fieldWithHint('Ketik password kamu'), 'rahasia');
  await tester.tap(find.text('Gas Masuk!'));
  await tester.pumpAndSettle();
}

void main() {
  test('formatRupiah memberi pemisah ribuan', () {
    expect(formatRupiah(500), 'Rp500');
    expect(formatRupiah(5000), 'Rp5.000');
    expect(formatRupiah(1250000), 'Rp1.250.000');
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
}
