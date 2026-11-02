import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';

/// Status pemesanan tebengan oleh penumpang (FR-05, FR-08).
enum BookingStatus {
  menunggu,
  diterima,
  ditolak,
  dibatalkan;

  String get label => switch (this) {
    BookingStatus.menunggu => 'Menunggu',
    BookingStatus.diterima => 'Diterima',
    BookingStatus.ditolak => 'Ditolak',
    BookingStatus.dibatalkan => 'Dibatalkan',
  };

  StatusTone get tone => switch (this) {
    BookingStatus.diterima => StatusTone.success,
    BookingStatus.menunggu => StatusTone.brand,
    BookingStatus.ditolak => StatusTone.neutral,
    BookingStatus.dibatalkan => StatusTone.neutral,
  };
}

/// Riwayat linimasa status pesanan (FR-07).
class BookingTimeline {
  const BookingTimeline({
    required this.requestSentTime,
    this.decisionTime,
    this.pickupTime,
    this.cancelledTime,
  });

  final String requestSentTime;
  final String? decisionTime;
  final String? pickupTime;
  final String? cancelledTime;

  BookingTimeline copyWith({
    String? requestSentTime,
    String? decisionTime,
    String? pickupTime,
    String? cancelledTime,
  }) {
    return BookingTimeline(
      requestSentTime: requestSentTime ?? this.requestSentTime,
      decisionTime: decisionTime ?? this.decisionTime,
      pickupTime: pickupTime ?? this.pickupTime,
      cancelledTime: cancelledTime ?? this.cancelledTime,
    );
  }
}

/// Entitas pemesanan tebengan dari sisi penumpang (FR-05 s.d. FR-08).
class Booking {
  const Booking({
    required this.id,
    required this.rideId,
    required this.driverName,
    required this.driverRating,
    required this.driverTripCount,
    required this.schedule,
    required this.origin,
    required this.destination,
    required this.pickupLocation,
    this.note,
    required this.status,
    required this.timeline,
    required this.updatedAtLabel,
    this.ride,
  });

  final String id;
  final String rideId;
  final String driverName;
  final double driverRating;
  final int driverTripCount;
  final String schedule;
  final String origin;
  final String destination;
  final String pickupLocation;
  final String? note;
  final BookingStatus status;
  final BookingTimeline timeline;
  final String updatedAtLabel;
  final Ride? ride;

  bool get isActive =>
      status == BookingStatus.menunggu || status == BookingStatus.diterima;

  bool get isPast =>
      status == BookingStatus.ditolak || status == BookingStatus.dibatalkan;

  bool get canCancel =>
      status == BookingStatus.menunggu || status == BookingStatus.diterima;

  Booking copyWith({
    String? id,
    String? rideId,
    String? driverName,
    double? driverRating,
    int? driverTripCount,
    String? schedule,
    String? origin,
    String? destination,
    String? pickupLocation,
    String? note,
    BookingStatus? status,
    BookingTimeline? timeline,
    String? updatedAtLabel,
    Ride? ride,
  }) {
    return Booking(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      driverTripCount: driverTripCount ?? this.driverTripCount,
      schedule: schedule ?? this.schedule,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      note: note ?? this.note,
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      updatedAtLabel: updatedAtLabel ?? this.updatedAtLabel,
      ride: ride ?? this.ride,
    );
  }
}
