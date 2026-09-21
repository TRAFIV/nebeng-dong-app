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

  bool get isFull => seatsAvailable <= 0;
}
