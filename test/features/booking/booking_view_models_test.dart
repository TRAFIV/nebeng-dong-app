import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/booking/data/local_booking_repository.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';
import 'package:praktikum_mobile/features/booking/viewmodels/ajukan_tebengan_view_model.dart';
import 'package:praktikum_mobile/features/booking/viewmodels/detail_pesanan_view_model.dart';
import 'package:praktikum_mobile/features/booking/viewmodels/pesanan_saya_view_model.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

void main() {
  group('PesananSayaViewModel', () {
    late LocalBookingRepository repo;
    late PesananSayaViewModel vm;

    setUp(() {
      repo = LocalBookingRepository(delay: Duration.zero);
      vm = PesananSayaViewModel(repository: repo);
    });

    tearDown(() {
      vm.dispose();
      repo.dispose();
    });

    test('memuat data pesanan dengan benar', () async {
      expect(vm.isLoading, isFalse);
      await vm.load();
      expect(vm.activeBookings.length, 2);
      expect(vm.pastBookings.length, 2);
      expect(vm.hasActiveBookings, isTrue);
      expect(vm.hasPastBookings, isTrue);
      expect(vm.isEmpty, isFalse);
      expect(vm.errorMessage, isNull);
    });

    test('menangani error saat load', () async {
      await vm.load(simulateError: true);
      expect(vm.errorMessage, isNotNull);
    });

    test('bereaksi saat repository menerbitkan perubahan', () {
      int notifications = 0;
      vm.addListener(() => notifications++);

      repo.simulateStatusChange('booking-2', BookingStatus.diterima);
      expect(notifications, 1);
    });
  });

  group('AjukanTebenganViewModel', () {
    late LocalBookingRepository repo;
    late AjukanTebenganViewModel vm;
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

    setUp(() {
      repo = LocalBookingRepository(delay: Duration.zero);
      vm = AjukanTebenganViewModel(ride: testRide, repository: repo);
    });

    tearDown(() {
      vm.dispose();
      repo.dispose();
    });

    test('validasi pickup dan note', () {
      expect(vm.validatePickup(null), 'Titik jemput wajib diisi');
      expect(vm.validatePickup(''), 'Titik jemput wajib diisi');
      expect(vm.validatePickup('ab'), 'Titik jemput minimal 3 karakter');
      expect(vm.validatePickup('Gerbang Veteran'), isNull);

      expect(vm.validateNote(null), isNull);
      expect(vm.validateNote(''), isNull);
      expect(vm.validateNote('ab'), 'Catatan minimal 3 karakter bila diisi');
      expect(vm.validateNote('depan pagar biru'), isNull);
    });

    test('submitBooking berhasil membuat booking baru', () async {
      final booking = await vm.submitBooking(
        pickup: 'Gerbang Kompleks Veteran, Padang',
        note: 'depan pagar biru',
      );

      expect(booking, isNotNull);
      expect(booking?.pickupLocation, 'Gerbang Kompleks Veteran, Padang');
      expect(booking?.note, 'depan pagar biru');
      expect(booking?.status, BookingStatus.menunggu);
      expect(booking?.driverName, 'Taris Rafivdean');
      expect(vm.errorMessage, isNull);
    });

    test('submitBooking gagal bila pickup tidak valid', () async {
      final booking = await vm.submitBooking(pickup: '');
      expect(booking, isNull);
      expect(vm.errorMessage, 'Titik jemput wajib diisi');
    });

    test(
      'submitBooking gagal bila repo melempar Exception (simulateSendError)',
      () async {
        // Buat repo yang disimulasikan selalu gagal kirim.
        final repoGagal = LocalBookingRepository(
          delay: Duration.zero,
          simulateSendError: true,
        );
        final vmGagal = AjukanTebenganViewModel(
          ride: testRide,
          repository: repoGagal,
        );

        final result = await vmGagal.submitBooking(
          pickup: 'Gerbang Kompleks Veteran, Padang',
        );

        expect(result, isNull);
        expect(vmGagal.errorMessage, isNotNull);
        expect(vmGagal.isSubmitting, isFalse);

        vmGagal.dispose();
        repoGagal.dispose();
      },
    );
  });

  group('DetailPesananViewModel', () {
    late LocalBookingRepository repo;
    late DetailPesananViewModel vm;

    setUp(() {
      repo = LocalBookingRepository(delay: Duration.zero);
      final booking = repo.getBookingById('booking-1')!;
      vm = DetailPesananViewModel(booking: booking, repository: repo);
    });

    tearDown(() {
      vm.dispose();
      repo.dispose();
    });

    test('status awal dan cancel booking', () async {
      expect(vm.booking.driverName, 'Taris Rafivdean');
      expect(vm.canCancel, isTrue);

      final success = await vm.cancelBooking();
      expect(success, isTrue);
      expect(vm.booking.status, BookingStatus.dibatalkan);
      expect(vm.canCancel, isFalse);
    });
  });

  group('PesananSayaViewModel.markNewBooking', () {
    late LocalBookingRepository repo;
    late PesananSayaViewModel vm;

    setUp(() {
      repo = LocalBookingRepository(delay: Duration.zero);
      vm = PesananSayaViewModel(repository: repo);
    });

    tearDown(() {
      vm.dispose();
      repo.dispose();
    });

    test('markNewBooking mengisi isNew tanpa setState di View', () {
      // Sebelum mark, semua booking bukan "baru".
      for (final b in repo.bookings) {
        expect(vm.isNew(b.id), isFalse);
      }

      // Setelah markNewBooking, hanya id yang ditandai.
      const targetId = 'booking-1';
      int notifications = 0;
      vm.addListener(() => notifications++);

      vm.markNewBooking(targetId);

      expect(vm.isNew(targetId), isTrue);
      expect(vm.isNew('booking-2'), isFalse);
      // VM publish sekali agar View rebuild melalui ListenableBuilder.
      expect(notifications, 1);
    });
  });
}
