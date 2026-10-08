import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/legacy/driver/data/sample_rides.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';

void main() {
  test('Jam menerima titik/titik dua dan menolak jam tidak valid', () {
    expect(parseDepartureMinute('7:30'), 450);
    expect(parseDepartureMinute(' 07.30 '), 450);
    expect(parseDepartureMinute('23.59'), 1439);
    for (final value in ['24.00', '07.60', '7.3', '-1:00', '', 'abc']) {
      expect(parseDepartureMinute(value), isNull, reason: value);
    }
  });

  test(
    'Rupiah menerima pemisah ribuan tetapi menolak nilai pecahan/negatif',
    () {
      expect(parseFare('10.000'), 10000);
      expect(parseFare('10000'), 10000);
      expect(parseFare('0'), 0);
      for (final value in ['10.00', '-100', '1,5', 'abc', '']) {
        expect(parseFare(value), isNull, reason: value);
      }
    },
  );

  test('Filter menggabungkan asal, tujuan, jam, kursi, dan ongkos', () {
    const filter = RideFilter(
      window: DepartureWindow.morning,
      minimumSeats: 2,
      maximumFare: 5000,
    );
    final result = filter.apply(
      sampleRides,
      origin: ' KHATIB ',
      destination: 'unand',
    );
    expect(result.map((ride) => ride.id), [sampleRides.first.id]);
    expect(filter.apply(sampleRides, origin: 'Veteran'), isEmpty);
    expect(const RideFilter().apply(sampleRides).length, 2);
    final unknownFare = LegacyDriverRepository(rides: []).post(
      driverName: 'Mikail',
      origin: 'Air Tawar',
      destination: 'Unand',
      departureTime: '07.30',
      capacity: 3,
    );
    expect(const RideFilter(maximumFare: 5000).matches(unknownFare), isFalse);
  });

  test('Batas jam half-open: 08.00 hanya masuk rentang 08.00–09.00', () {
    final ride = sampleRides.first.copyWith(departureTime: '08.00');
    expect(
      const RideFilter(window: DepartureWindow.morning).matches(ride),
      isFalse,
    );
    expect(
      const RideFilter(window: DepartureWindow.lateMorning).matches(ride),
      isTrue,
    );
    expect(
      const RideFilter(window: DepartureWindow.afternoon)
          .matches(ride.copyWith(departureTime: '19.00')),
      isFalse,
    );
  });

  test('Posting milik sesi tampil pada fetch tanpa memutasi seed', () async {
    final repo = LegacyDriverRepository(delay: Duration.zero);
    final posted = repo.post(
      driverName: 'Mikail',
      origin: 'Air Tawar',
      destination: 'Unand',
      departureTime: '07.30',
      capacity: 3,
    );
    expect(repo.ownedRides.single.id, posted.id);
    expect((await repo.fetchRides()).first, posted);
    expect(sampleRides.length, 3);
    expect(() => repo.rides.clear(), throwsUnsupportedError);
    expect(LegacyDriverRepository().ownedRides, isEmpty);
  });

  test(
    'Edit menjaga kursi terisi; callback booking idempotent dan full tertutup',
    () {
      final repo = LegacyDriverRepository(rides: []);
      final posted = repo.post(
        driverName: 'Mikail',
        origin: 'Air Tawar',
        destination: 'Unand',
        departureTime: '07.30',
        capacity: 2,
      );
      repo.acceptBooking(routeId: posted.id, bookingId: 'booking-1');
      repo.acceptBooking(routeId: posted.id, bookingId: 'booking-1');
      expect(repo.ownedRides.single.seatsAvailable, 1);
      repo.updateOwned(posted.copyWith(origin: 'Veteran', seatCapacity: 3));
      expect(repo.ownedRides.single.seatsAvailable, 2);
      repo.acceptBooking(routeId: posted.id, bookingId: 'booking-2');
      expect(
        () => repo.updateOwned(posted.copyWith(seatCapacity: 1)),
        throwsStateError,
      );
      expect(() => repo.deleteOwned(posted.id), throwsStateError);
      repo.acceptBooking(routeId: posted.id, bookingId: 'booking-3');
      expect(repo.ownedRides.single.isFull, isTrue);
      expect(const RideFilter().apply(repo.rides), isEmpty);
      expect(
        () => repo.acceptBooking(routeId: posted.id, bookingId: 'booking-4'),
        throwsStateError,
      );
      expect(repo.ownedRides.single.seatsAvailable, 0);
    },
  );

  test('Repository menolak perubahan rute bukan milik sesi', () {
    final repo = LegacyDriverRepository();
    expect(() => repo.updateOwned(sampleRides.first), throwsStateError);
    expect(() => repo.deleteOwned(sampleRides.first.id), throwsStateError);
    expect(
      () => repo.acceptBooking(routeId: 'tidak-ada', bookingId: 'b'),
      throwsStateError,
    );
    expect(
      () => repo.acceptBooking(routeId: sampleRides.first.id, bookingId: ''),
      throwsArgumentError,
    );
    expect(
      () => repo.post(
        driverName: 'M',
        origin: 'A',
        destination: 'B',
        departureTime: '07.00',
        capacity: 0,
      ),
      throwsArgumentError,
    );
  });
}
