import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';

import 'booking_repository.dart';
import 'fixtures/demo_bookings.dart';

/// Implementasi lokal in-memory untuk simulasi latihan modul 2.
class LocalBookingRepository extends BookingRepository {
  LocalBookingRepository({
    List<Booking>? initialBookings,
    this.delay = const Duration(milliseconds: 300),
    // Simulasi, bukan backend: ubah ke true untuk memicu jalur gagal kirim.
    // Berguna saat demo: pastikan SnackBar 'Gagal mengirim. Coba lagi ya.' muncul.
    this.simulateSendError = false,
  }) : _bookings = List<Booking>.from(initialBookings ?? demoBookings);

  final List<Booking> _bookings;
  final Duration delay;

  /// Jika true, createBooking akan melempar Exception (simulasi latihan).
  /// Balik ke false untuk kembali ke alur normal.
  final bool simulateSendError;

  @override
  bool get isSimulation => true;

  @override
  List<Booking> get bookings => List.unmodifiable(_bookings);

  @override
  List<Booking> get activeBookings =>
      List.unmodifiable(_bookings.where((b) => b.isActive));

  @override
  List<Booking> get pastBookings =>
      List.unmodifiable(_bookings.where((b) => b.isPast));

  @override
  Ride get sampleRideForSimulation => demoSimulationRide;

  @override
  Future<List<Booking>> fetchBookings({bool simulateError = false}) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (simulateError) {
      throw Exception('Gagal memuat daftar pesanan. Periksa koneksi internet.');
    }
    return bookings;
  }

  @override
  Future<Booking> createBooking({
    required Ride ride,
    required String pickupLocation,
    String? note,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    // Simulasi, bukan backend: lempar Exception jika simulateSendError == true.
    if (simulateSendError) {
      throw Exception('Gagal mengirim permintaan. Periksa koneksi internet.');
    }
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour.$minute';

    final newBooking = Booking(
      id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
      rideId: ride.id,
      driverName: ride.driverName,
      driverRating: ride.driverRating,
      driverTripCount: ride.driverTripCount,
      schedule: '${ride.schedule} · Cabut ${ride.departureTime}',
      origin: ride.origin,
      destination: ride.destination,
      pickupLocation: pickupLocation,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
      status: BookingStatus.menunggu,
      timeline: BookingTimeline(requestSentTime: timeStr),
      updatedAtLabel: 'Baru saja',
      ride: ride,
    );

    _bookings.insert(0, newBooking);
    notifyListeners();
    return newBooking;
  }

  @override
  Future<bool> cancelBooking(String bookingId) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return false;

    final target = _bookings[index];
    if (!target.canCancel) return false;

    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour.$minute';

    final updated = target.copyWith(
      status: BookingStatus.dibatalkan,
      updatedAtLabel: 'Diperbarui $timeStr',
      timeline: target.timeline.copyWith(cancelledTime: timeStr),
    );

    _bookings[index] = updated;
    notifyListeners();
    return true;
  }

  @override
  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Hook simulasi latihan: mengubah status pesanan dari luar (mewakili respon backend/admin).
  void simulateStatusChange(String bookingId, BookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;

    final target = _bookings[index];
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour.$minute';

    _bookings[index] = target.copyWith(
      status: newStatus,
      updatedAtLabel: 'Diperbarui $timeStr',
      timeline: switch (newStatus) {
        BookingStatus.diterima => target.timeline.copyWith(
          decisionTime: timeStr,
        ),
        BookingStatus.ditolak => target.timeline.copyWith(
          decisionTime: timeStr,
        ),
        BookingStatus.dibatalkan => target.timeline.copyWith(
          cancelledTime: timeStr,
        ),
        BookingStatus.menunggu => target.timeline,
      },
    );
    notifyListeners();
  }
}
