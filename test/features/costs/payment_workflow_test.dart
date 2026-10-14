import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/views/cost_detail_screen.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

Future<void> _openApp(
  WidgetTester tester,
  LocalCostRepository repository,
) async {
  // Lebar 500 dp, bukan 360 dp: font tes (Ahem) jauh lebih lebar daripada
  // Roboto, sehingga badge "Menunggu konfirmasi" tidak muat di 360 dp.
  tester.view.physicalSize = const Size(1500, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
      home: CostDetailScreen(repository: repository),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapCheckbox(WidgetTester tester) async {
  final checkbox = find.byType(CheckboxListTile);
  await tester.ensureVisible(checkbox);
  await tester.tap(checkbox);
  await tester.pump();
}

Future<void> _tapSubmit(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Workflow lengkap: rincian → validasi → konfirmasi → result', (
    tester,
  ) async {
    final repository = LocalCostRepository(delay: Duration.zero);
    await _openApp(tester, repository);

    // Rincian Ongkos tampil dengan bagian tiap penumpang (15.000 : 2).
    expect(find.text('Shiddiq (Kamu)'), findsOneWidget);
    expect(find.text('Bagian Rp7.500'), findsNWidgets(2));

    // EVENT + NAVIGATION: buka Konfirmasi Pembayaran membawa data.
    await tester.tap(find.text('Konfirmasi Pembayaran'));
    await tester.pumpAndSettle();
    expect(find.text('Status pembayaran'), findsOneWidget);

    // VALIDATION: belum dicentang → pesan, user tetap di layar ini.
    await _tapSubmit(tester, 'Udah Bayar!');
    expect(find.text('Centang dulu ya, kalau udah bayar'), findsOneWidget);
    expect(find.text('Konfirmasi driver'), findsNothing);

    // Centang → pesan hilang, kirim → dialog info driver.
    await _tapCheckbox(tester);
    expect(find.text('Centang dulu ya, kalau udah bayar'), findsNothing);
    await _tapSubmit(tester, 'Udah Bayar!');
    expect(find.text('Konfirmasi driver'), findsOneWidget);
    expect(
      find.text('Menunggu konfirmasi pembayaran dari driver'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    // RESULT: kembali ke Rincian, snackbar & status baru tampil.
    expect(find.text('Rincian Ongkos'), findsOneWidget);
    expect(
      find.text('Sip! Udah dicatat, tinggal nunggu konfirmasi sistem.'),
      findsOneWidget,
    );
    // Aulia + Shiddiq badge, ditambah label tombol bawah yang nonaktif.
    expect(find.text('Menunggu konfirmasi'), findsNWidgets(3));
  });

  testWidgets('Gagal kirim menampilkan error, lalu Coba Lagi berhasil', (
    tester,
  ) async {
    final repository = LocalCostRepository(delay: Duration.zero)
      ..failNextDeclaration = true;
    await _openApp(tester, repository);

    await tester.tap(find.text('Konfirmasi Pembayaran'));
    await tester.pumpAndSettle();
    await _tapCheckbox(tester);
    await _tapSubmit(tester, 'Udah Bayar!');

    // FEEDBACK gagal: tetap di layar, banner error, tombol jadi Coba Lagi.
    expect(
      find.text('Gagal ngirim konfirmasi. Cek koneksi kamu, terus coba lagi.'),
      findsOneWidget,
    );
    expect(find.text('Konfirmasi driver'), findsNothing);
    await _tapSubmit(tester, 'Coba Lagi');
    expect(find.text('Konfirmasi driver'), findsOneWidget);
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    expect(find.text('Rincian Ongkos'), findsOneWidget);
  });

  test('Rute konfirmasi tanpa data ditolak (jatuh ke 404)', () {
    final route = AppRoutes.onGenerateRoute(
      const RouteSettings(name: AppRoutes.paymentConfirmation),
    );
    expect(route, isNull);
  });
}
