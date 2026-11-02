import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/core/di/booking_repository_scope.dart';
import 'package:praktikum_mobile/features/booking/data/local_booking_repository.dart';
import 'package:praktikum_mobile/features/booking/views/ajukan_tebengan_screen.dart';
import 'package:praktikum_mobile/features/booking/views/detail_pesanan_screen.dart';
import 'package:praktikum_mobile/features/booking/views/pesanan_saya_screen.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

void main() {
  const testRide = Ride(
    id: 'ride-taris-1',
    driverName: 'Taris Rafivdean',
    driverRating: 4.8,
    driverTripCount: 32,
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand',
    schedule: 'Sen, 12 Okt',
    departureTime: '07.30',
    seatCapacity: 3,
    seatsAvailable: 2,
    farePerPerson: 10000,
  );

  Widget testApp({required Widget home, LocalBookingRepository? repository}) {
    final repo = repository ?? LocalBookingRepository(delay: Duration.zero);
    return BookingRepositoryProvider(
      repository: repo,
      child: MaterialApp(
        theme: AppTheme.light,
        home: home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }

  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('PesananSayaScreen', () {
    testWidgets('menampilkan pesanan aktif dan riwayat sesuai desain Figma', (
      tester,
    ) async {
      setScreenSize(tester);
      final repo = LocalBookingRepository(delay: Duration.zero);

      await tester.pumpWidget(
        testApp(home: PesananSayaScreen(repository: repo)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pesanan Saya'), findsOneWidget);
      expect(find.text('Pantau permintaan nebengmu di sini.'), findsOneWidget);

      expect(find.text('Pesanan Aktif'), findsOneWidget);
      expect(find.text('Diterima'), findsOneWidget);
      expect(find.text('Menunggu'), findsOneWidget);
      expect(find.text('Duha Alul Bariq'), findsOneWidget);

      expect(find.text('Riwayat Pesanan'), findsOneWidget);
      expect(find.text('Ditolak'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Dibatalkan'),
        50,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Dibatalkan'), findsOneWidget);
      expect(find.text('M Shiddiq'), findsOneWidget);
    });

    testWidgets('mengetuk kartu pesanan membuka detail pesanan', (
      tester,
    ) async {
      setScreenSize(tester);
      final repo = LocalBookingRepository(delay: Duration.zero);

      await tester.pumpWidget(
        testApp(home: PesananSayaScreen(repository: repo)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Duha Alul Bariq'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Pesanan'), findsOneWidget);
      expect(find.text('Menunggu konfirmasi...'), findsOneWidget);
    });

    testWidgets(
      'FAB + Ajukan Tebengan membuka form dan menampilkan pesanan baru saat pop',
      (tester) async {
        setScreenSize(tester);
        final repo = LocalBookingRepository(delay: Duration.zero);

        await tester.pumpWidget(
          testApp(
            home: PesananSayaScreen(repository: repo),
            repository: repo,
          ),
        );
        await tester.pumpAndSettle();

        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);
        expect(find.text('+ Ajukan Tebengan'), findsOneWidget);

        await tester.tap(fab);
        await tester.pumpAndSettle();

        expect(find.text('Ajukan Tebengan'), findsOneWidget);
        expect(find.text('Taris Rafivdean (Simulasi)'), findsOneWidget);

        final pickupField = find.byType(TextFormField).first;
        await tester.enterText(pickupField, 'Gerbang Unand Depan');
        await tester.pumpAndSettle();

        final submitButton = find.text('Kirim Permintaan!');
        await tester.scrollUntilVisible(
          submitButton,
          50,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.text('Pesanan Saya'), findsOneWidget);
        expect(
          find.text('Permintaan terkirim! Tunggu kabar ya.'),
          findsOneWidget,
        );
        expect(find.text('Baru'), findsOneWidget);
        expect(find.text('Taris Rafivdean (Simulasi)'), findsOneWidget);
      },
    );
  });

  group('AjukanTebenganScreen', () {
    testWidgets('menampilkan form dan validasi titik jemput', (tester) async {
      setScreenSize(tester);
      final repo = LocalBookingRepository(delay: Duration.zero);

      await tester.pumpWidget(
        testApp(
          home: AjukanTebenganScreen(
            ride: testRide,
            repository: repo,
            initialPickup: '',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ajukan Tebengan'), findsOneWidget);
      expect(find.text('Sisa 2 kursi'), findsOneWidget);
      expect(find.text('Catatan buat Taris Rafivdean'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Pin harus dekat jalur tebengan Taris Rafivdean.'),
        50,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('Pin harus dekat jalur tebengan Taris Rafivdean.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Kirim Permintaan!'));
      await tester.pumpAndSettle();

      expect(find.text('Titik jemput wajib diisi'), findsOneWidget);
    });

    testWidgets('submit berhasil menutup layar dengan Navigator.pop', (
      tester,
    ) async {
      setScreenSize(tester);
      final repo = LocalBookingRepository(delay: Duration.zero);

      // Bungkus di Navigator agar kita bisa mendeteksi layar kembali ke home.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: Center(child: Text('Halaman Sebelumnya'))),
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.ajukanTebengan) {
              return MaterialPageRoute<void>(
                builder: (_) =>
                    AjukanTebenganScreen(ride: testRide, repository: repo),
                settings: settings,
              );
            }
            return AppRoutes.onGenerateRoute(settings);
          },
          initialRoute: AppRoutes.ajukanTebengan,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ajukan Tebengan'), findsOneWidget);

      // Isi form dengan data yang valid dan kirim.
      await tester.enterText(
        find.byType(TextFormField).first,
        'Gerbang Kompleks Veteran, Padang',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'depan pagar biru',
      );
      await tester.tap(find.text('Kirim Permintaan!'));
      await tester.pumpAndSettle();

      // Layar harus pop kembali ke halaman sebelumnya.
      expect(find.text('Ajukan Tebengan'), findsNothing);
      expect(find.text('Halaman Sebelumnya'), findsOneWidget);
    });
  });

  group('DetailPesananScreen', () {
    testWidgets(
      'menampilkan status diterima dan alur pembatalan dengan bottom sheet',
      (tester) async {
        setScreenSize(tester);
        final repo = LocalBookingRepository(delay: Duration.zero);
        final booking = repo.getBookingById('booking-1')!;

        await tester.pumpWidget(
          testApp(
            home: DetailPesananScreen(booking: booking, repository: repo),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Detail Pesanan'), findsOneWidget);
        expect(find.text('Yey, kamu dapet kursi!'), findsOneWidget);
        expect(
          find.text('Pesananmu udah diterima. Siap-siap di titik jemput ya.'),
          findsOneWidget,
        );
        expect(find.text('Permintaan dikirim'), findsOneWidget);
        expect(find.text('Pesanan diterima'), findsOneWidget);
        expect(find.text('Dijemput di titik jemput'), findsOneWidget);

        // Batalkan pesanan
        await tester.tap(find.text('Batalkan Pesanan'));
        await tester.pumpAndSettle();

        // Bottom sheet muncul
        expect(find.text('Batalin pesanan ini?'), findsOneWidget);
        expect(find.text('Nggak Jadi'), findsOneWidget);
        expect(find.text('Ya, Batalkan'), findsOneWidget);

        // Konfirmasi pembatalan
        await tester.tap(find.text('Ya, Batalkan'));
        await tester.pumpAndSettle();

        // Status berubah jadi dibatalkan
        expect(find.text('Pesanan dibatalkan'), findsAtLeastNWidgets(1));
        expect(
          find.text('Kursimu udah dilepas. Mau cari tebengan lain?'),
          findsOneWidget,
        );
        expect(find.text('Cariin Tebengan Lain!'), findsOneWidget);
      },
    );

    testWidgets('menampilkan status ditolak sesuai desain', (tester) async {
      setScreenSize(tester);
      final repo = LocalBookingRepository(delay: Duration.zero);
      final booking = repo.getBookingById('booking-3')!;

      await tester.pumpWidget(
        testApp(
          home: DetailPesananScreen(booking: booking, repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Yah, belum rezeki'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Pesanan ini nggak bisa dibatalkan lagi.'),
        50,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('Pesanan ini nggak bisa dibatalkan lagi.'),
        findsOneWidget,
      );
      expect(find.text('Cariin Tebengan Lain!'), findsOneWidget);
    });
  });
}
