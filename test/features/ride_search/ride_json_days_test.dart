import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_json.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_schedule.dart';
import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';

Map<String, Object?> _ride({Object? days, String? vehicle}) => {
  'id': 9,
  'driver': {
    'name': 'Duha',
    'rating': 4.9,
    'trip_count': 18,
    'vehicle_type': ?vehicle,
  },
  'origin': {'label': 'Air Tawar', 'lat': -0.89, 'lng': 100.35},
  'destination': {'label': 'Unand', 'lat': -0.91, 'lng': 100.46},
  'schedule': 'Sabtu, Minggu',
  'schedule_days': days,
  'departure_time': '07.45',
  'seat_capacity': 1,
  'seats_available': 1,
  'fare_per_person': 6000,
  'route': {
    'distance_m': 12000,
    'duration_s': 900,
    'coordinates': [
      [100.35, -0.89],
      [100.46, -0.91],
    ],
  },
};

void main() {
  test('schedule_days dan vehicle_type dari server dipakai', () {
    final ride = rideFromJson(_ride(days: [6, 7], vehicle: 'car'));
    expect(ride.scheduleDays, {6, 7});
    // Server bilang mobil walau kapasitas 1: data server menang.
    expect(ride.vehicle, VehicleKind.car);
    expect(rideRunsOn(ride, DateTime(2026, 11, 29)), isTrue); // Minggu
    expect(rideRunsOn(ride, DateTime(2026, 11, 24)), isFalse); // Selasa
  });

  test('server lama tanpa kolom baru tetap terbaca', () {
    final ride = rideFromJson(_ride());
    expect(ride.scheduleDays, isNull);
    expect(ride.vehicle, VehicleKind.motor); // ditebak dari 1 kursi
    expect(rideRunsOn(ride, DateTime(2026, 11, 29)), isTrue); // dari teks
  });

  test('hari di luar 1–7 ditolak', () {
    expect(() => rideFromJson(_ride(days: [0, 8])), throwsFormatException);
  });
}
