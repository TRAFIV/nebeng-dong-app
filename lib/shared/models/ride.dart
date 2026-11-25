import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';

/// Tebengan yang diposting pemberi (entitas Route pada PRD 2.5).
class Ride {
  const Ride({
    required this.id,
    required this.driverName,
    required this.driverRating,
    required this.driverTripCount,
    required this.origin,
    required this.destination,
    required this.schedule,
    required this.departureTime,
    required this.seatCapacity,
    required this.seatsAvailable,
    required this.farePerPerson,
    this.geography,
    this.scheduleDays,
    this.vehicleType,
  });

  final String id;
  final String driverName;
  final double driverRating;
  final int driverTripCount;
  final String origin;
  final String destination;

  /// Hari berangkat rutin, misalnya "Senin–Jumat".
  final String schedule;

  /// Jam berangkat, misalnya "07.30".
  final String departureTime;
  final int seatCapacity;
  final int seatsAvailable;

  /// Ongkos per penumpang dalam rupiah.
  final int farePerPerson;
  final RideGeography? geography;

  /// Hari jalan dari server (ISO 1 = Senin … 7 = Minggu). `null` bila tidak
  /// dikirim; aplikasi lalu membaca teks [schedule].
  final Set<int>? scheduleDays;

  /// Jenis kendaraan dari server (`driver.vehicle_type`); `null` pada data
  /// lama/latihan.
  final VehicleKind? vehicleType;

  bool get isFull => seatsAvailable <= 0;

  /// Jenis kendaraan: dari server bila ada, selain itu ditebak dari kapasitas.
  VehicleKind get vehicle =>
      vehicleType ?? VehicleKind.fromSeatCapacity(seatCapacity);
}
