import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/core/di/cost_repository_scope.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/features/costs/views/cost_history_screen.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

Future<LocalCostRepository> pumpCosts(
  WidgetTester tester, {
  bool simulateError = false,
}) async {
  // Layar tinggi supaya semua kartu ListView ikut dibangun.
  tester.view.physicalSize = const Size(1080, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repository = LocalCostRepository(
    delay: Duration.zero,
    clock: () => DateTime(2026, 10, 18, 11, 0),
  );
  await tester.pumpWidget(
    CostRepositoryProvider(
      repository: repository,
      child: MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
        home: CostHistoryScreen(simulateError: simulateError),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('Ongkos lists history and upcoming trips as practice data', (
    tester,
  ) async {
    await pumpCosts(tester);

    expect(find.text('Perjalanan berikutnya'), findsOneWidget);
    expect(find.text('Riwayat Ongkos'), findsOneWidget);
    expect(find.text('Data latihan · bukan pembayaran nyata'), findsOneWidget);
    expect(find.text('Estimasi'), findsOneWidget);
    expect(find.text('Belum diatur'), findsWidgets);
    expect(find.text('Rp0'), findsNothing);
  });

  testWidgets('Error state retries into the list', (tester) async {
    await pumpCosts(tester, simulateError: true);
    expect(
      find.text('Gagal memuat ongkos. Periksa koneksi internet.'),
      findsOneWidget,
    );
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets(
    'Workflow: Riwayat → Rincian → Status → Sudah Bayar → menunggu konfirmasi',
    (tester) async {
      final repository = await pumpCosts(tester);
      expect(find.text('Belum dilaporkan'), findsNWidgets(2));

      // Riwayat: buka perjalanan terbaru yang belum dilaporkan (cost-1).
      await tester.tap(find.text('Belum dilaporkan').first);
      await tester.pumpAndSettle();

      // Rincian Ongkos: tarif tetap per penumpang, sudah final.
      expect(find.text('Rincian Ongkos'), findsOneWidget);
      expect(find.text('Rp5.000'), findsOneWidget);
      expect(find.text('Final'), findsOneWidget);
      await tester.tap(find.text('Lihat Status Pembayaran'));
      await tester.pumpAndSettle();

      // Status Pembayaran: batal di dialog tidak mengubah apa pun.
      expect(find.text('Status Pembayaran'), findsOneWidget);
      await tester.tap(find.text('Sudah Bayar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Belum'));
      await tester.pumpAndSettle();
      expect(
        repository.costShares.firstWhere((s) => s.id == 'cost-1').paymentStatus,
        PaymentStatus.unreported,
      );

      // Konfirmasi deklarasi.
      await tester.tap(find.text('Sudah Bayar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iya, Udah'));
      await tester.pumpAndSettle();

      expect(
        find.text('Sip! Pembayaranmu dilaporin, tunggu konfirmasi ya.'),
        findsOneWidget,
      );
      expect(find.text('Sudah Bayar'), findsNothing);
      expect(find.textContaining('Laporanmu udah masuk'), findsOneWidget);
      expect(
        repository.costShares.firstWhere((s) => s.id == 'cost-1').paymentStatus,
        PaymentStatus.pendingConfirmation,
      );

      // Kembali: Rincian dan Riwayat ikut diperbarui dari repository sesi.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Menunggu konfirmasi'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      // Tersisa perjalanan yang ongkosnya belum diatur.
      expect(find.text('Belum dilaporkan'), findsOneWidget);
      expect(find.text('Menunggu konfirmasi'), findsNWidgets(2));
    },
  );

  testWidgets('Upcoming trip shows an estimate and cannot be declared yet', (
    tester,
  ) async {
    await pumpCosts(tester);

    await tester.tap(find.text('Estimasi'));
    await tester.pumpAndSettle();
    expect(find.text('Estimasi'), findsOneWidget);
    await tester.tap(find.text('Lihat Status Pembayaran'));
    await tester.pumpAndSettle();

    expect(
      find.text('Lapor bayar bisa setelah perjalanan selesai, ya.'),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Sudah Bayar'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Cost routes reject missing ids', (tester) async {
    for (final route in [AppRoutes.costDetail, AppRoutes.paymentStatus]) {
      expect(
        AppRoutes.onGenerateRoute(RouteSettings(name: route)),
        isNull,
        reason: route,
      );
      expect(
        AppRoutes.onGenerateRoute(
          RouteSettings(name: route, arguments: 'cost-1'),
        ),
        isNotNull,
        reason: route,
      );
    }
  });
}
