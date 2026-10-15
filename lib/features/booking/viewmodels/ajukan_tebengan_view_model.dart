import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/booking/data/booking_repository.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

/// ViewModel untuk layar Ajukan Tebengan (FR-05, FR-06).
class AjukanTebenganViewModel extends ViewModel {
  AjukanTebenganViewModel({required this.ride, required this.repository});

  final Ride ride;
  final BookingRepository repository;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  String? validatePickup(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Titik jemput wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Titik jemput minimal 3 karakter';
    }
    return null;
  }

  String? validateNote(String? value) {
    // Catatan bersifat opsional, tetapi jika diisi minimal 3 karakter
    if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
      return 'Catatan minimal 3 karakter bila diisi';
    }
    return null;
  }

  Future<Booking?> submitBooking({required String pickup, String? note}) async {
    final pickupError = validatePickup(pickup);
    if (pickupError != null) {
      _errorMessage = pickupError;
      publish();
      return null;
    }

    final noteError = validateNote(note);
    if (noteError != null) {
      _errorMessage = noteError;
      publish();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    publish();

    try {
      final booking = await repository.createBooking(
        ride: ride,
        pickupLocation: pickup.trim(),
        note: note,
      );
      _errorMessage = null;
      return booking;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isSubmitting = false;
      publish();
    }
  }
}
