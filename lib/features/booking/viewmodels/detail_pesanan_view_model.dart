import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/booking/data/booking_repository.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';

/// ViewModel untuk layar Detail Pesanan (FR-05, FR-07, FR-08).
class DetailPesananViewModel extends ViewModel {
  DetailPesananViewModel({required this.booking, required this.repository}) {
    repository.addListener(_onRepositoryChanged);
  }

  final BookingRepository repository;
  Booking booking;
  bool _isCancelling = false;
  String? _errorMessage;

  bool get isCancelling => _isCancelling;
  String? get errorMessage => _errorMessage;
  bool get canCancel => booking.canCancel;

  void _onRepositoryChanged() {
    final updated = repository.getBookingById(booking.id);
    if (updated != null && !isDisposed) {
      booking = updated;
      publish();
    }
  }

  Future<bool> cancelBooking() async {
    if (!canCancel || _isCancelling) return false;

    _isCancelling = true;
    _errorMessage = null;
    publish();

    try {
      final success = await repository.cancelBooking(booking.id);
      if (success) {
        final updated = repository.getBookingById(booking.id);
        if (updated != null) booking = updated;
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isCancelling = false;
      publish();
    }
  }

  @override
  void dispose() {
    repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
