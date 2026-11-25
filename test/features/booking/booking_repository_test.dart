import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/booking/data/local_booking_repository.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

void main() {
  group('LocalBookingRepository', () {
    late LocalBookingRepository repo;

    setUp(() {
      repo = LocalBookingRepository(delay: Duration.zero);
    });

    test('memiliki data awal fixture yang membedakan aktif dan riwayat', () {
      expect(repo.isSimulation, isTrue);
      expect(repo.bookings.length, greaterThanOrEqualTo(4));
      expect(repo.activeBookings.length, 2);
      expect(repo.pastBookings.length, 2);

      expect(repo.activeBookings.first.driverName, 'Taris Rafivdean');
      expect(repo.activeBookings.first.status, BookingStatus.diterima);
      expect(repo.activeBookings[1].driverName, 'Duha Alul Bariq');
      expect(repo.activeBookings[1].status, BookingStatus.menunggu);

      expect(repo.pastBookings.first.status, BookingStatus.ditolak);
      expect(repo.pastBookings[1].status, BookingStatus.dibatalkan);
    });

    test('createBooking membuat pesanan baru dengan status menunggu', () async {
      int notifications = 0;
      repo.addListener(() => notifications++);

      const ride = Ride(
        id: 'test-ride-99',
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

      final newBooking = await repo.createBooking(
        ride: ride,
        pickupLocation: 'Depan Gerbang Utama',
        note: 'Bawa tas ransel',
      );

      expect(newBooking.status, BookingStatus.menunggu);
      expect(newBooking.driverName, 'Taris Rafivdean');
      expect(newBooking.pickupLocation, 'Depan Gerbang Utama');
      expect(newBooking.note, 'Bawa tas ransel');
      expect(newBooking.timeline.requestSentTime.isNotEmpty, isTrue);
      expect(newBooking.isActive, isTrue);
      expect(repo.activeBookings.contains(newBooking), isTrue);
      expect(notifications, 1);
    });

    test('cancelBooking membatalkan pesanan yang diizinkan', () async {
      int notifications = 0;
      repo.addListener(() => notifications++);

      final success = await repo.cancelBooking('booking-1');
      expect(success, isTrue);

      final cancelled = repo.getBookingById('booking-1');
      expect(cancelled?.status, BookingStatus.dibatalkan);
      expect(cancelled?.timeline.cancelledTime != null, isTrue);
      expect(cancelled?.isPast, isTrue);
      expect(notifications, 1);
    });

    test(
      'cancelBooking menolak membatalkan pesanan yang sudah dibatalkan/ditolak',
      () async {
        final success = await repo.cancelBooking('booking-4');
        expect(success, isFalse);

        final notFound = await repo.cancelBooking('non-existent');
        expect(notFound, isFalse);
      },
    );

    test('fetchBookings mendukung simulasi error untuk pengujian UI', () async {
      expect(
        () => repo.fetchBookings(simulateError: true),
        throwsA(isA<Exception>()),
      );
    });

    test('simulateStatusChange memperbarui status pesanan dari luar', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      repo.simulateStatusChange('booking-2', BookingStatus.diterima);

      final updated = repo.getBookingById('booking-2');
      expect(updated?.status, BookingStatus.diterima);
      expect(updated?.timeline.decisionTime != null, isTrue);
      expect(notifications, 1);
    });

    test(
      'createBooking melempar Exception bila simulateSendError = true',
      () async {
        // Untuk memicu jalur ini: LocalBookingRepository(simulateSendError: true).
        // Balik ke false untuk kembali ke alur normal.
        final repoGagal = LocalBookingRepository(
          delay: Duration.zero,
          simulateSendError: true,
        );
        final jumlahSebelum = repoGagal.bookings.length;

        const ride = Ride(
          id: 'ride-gagal',
          driverName: 'Driver Test',
          driverRating: 4.5,
          driverTripCount: 10,
          origin: 'A',
          destination: 'B',
          schedule: 'Sen',
          departureTime: '07.00',
          seatCapacity: 2,
          seatsAvailable: 2,
          farePerPerson: 5000,
        );

        expect(
          () => repoGagal.createBooking(
            ride: ride,
            pickupLocation: 'Gerbang Utama',
          ),
          throwsA(isA<Exception>()),
        );
        // Daftar pesanan tidak bertambah ketika gagal.
        expect(repoGagal.bookings.length, jumlahSebelum);

        repoGagal.dispose();
      },
    );
  });
}
