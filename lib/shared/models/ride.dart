import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

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

  bool get isFull => seatsAvailable <= 0;

  Ride copyWith({
    String? origin,
    String? destination,
    String? departureTime,
    int? seatCapacity,
    int? seatsAvailable,
    RideGeography? geography,
  }) => Ride(
    id: id,
    driverName: driverName,
    driverRating: driverRating,
    driverTripCount: driverTripCount,
    origin: origin ?? this.origin,
    destination: destination ?? this.destination,
    schedule: schedule,
    departureTime: departureTime ?? this.departureTime,
    seatCapacity: seatCapacity ?? this.seatCapacity,
    seatsAvailable: seatsAvailable ?? this.seatsAvailable,
    farePerPerson: farePerPerson,
    geography:
        geography ??
        ((origin != null && origin != this.origin) ||
                (destination != null && destination != this.destination)
            ? null
            : this.geography),
  );
}
