import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';

/// Kontrak repository pemesanan tebengan dari sudut pandang penumpang (FR-05 s.d. FR-08).
/// Keputusan diterima/ditolak berasal dari backend/admin, bukan aksi ACC penumpang di aplikasi mobile.
abstract class BookingRepository extends ChangeNotifier {
  bool get isSimulation;
  List<Booking> get bookings;
  List<Booking> get activeBookings;
  List<Booking> get pastBookings;

  /// Tebengan contoh untuk simulasi alur pengajuan tebengan.
  Ride get sampleRideForSimulation;

  Future<List<Booking>> fetchBookings({bool simulateError = false});

  Future<Booking> createBooking({
    required Ride ride,
    required String pickupLocation,
    String? note,
  });

  Future<bool> cancelBooking(String bookingId);

  Booking? getBookingById(String id);
}
