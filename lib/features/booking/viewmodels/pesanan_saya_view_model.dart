import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/booking/data/booking_repository.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

/// ViewModel untuk layar Pesanan Saya (FR-05, FR-07).
class PesananSayaViewModel extends ViewModel {
  PesananSayaViewModel({required this.repository}) {
    repository.addListener(_onRepositoryChanged);
  }

  final BookingRepository repository;
  bool _isLoading = false;
  String? _errorMessage;

  /// ID pesanan yang baru saja dikirim dari AjukanTebengan.
  /// Dipakai View untuk menampilkan penanda "Baru" tanpa setState.
  String? _newBookingId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Booking> get activeBookings => repository.activeBookings;
  List<Booking> get pastBookings => repository.pastBookings;
  bool get hasActiveBookings => activeBookings.isNotEmpty;
  bool get hasPastBookings => pastBookings.isNotEmpty;
  bool get isEmpty => activeBookings.isEmpty && pastBookings.isEmpty;

  /// Tebengan contoh untuk simulasi/demo alur pengajuan tebengan.
  Ride get sampleRideForSimulation => repository.sampleRideForSimulation;

  /// Kembalikan true jika [bookingId] adalah pesanan yang baru saja dikirim.
  bool isNew(String bookingId) => bookingId == _newBookingId;

  /// Tandai [bookingId] sebagai pesanan baru; publish agar View ikut rebuild.
  void markNewBooking(String bookingId) {
    _newBookingId = bookingId;
    publish();
  }

  void _onRepositoryChanged() {
    if (!isDisposed) {
      publish();
    }
  }

  Future<void> load({bool simulateError = false}) async {
    _isLoading = true;
    _errorMessage = null;
    publish();

    try {
      await repository.fetchBookings(simulateError: simulateError);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      publish();
    }
  }

  @override
  void dispose() {
    repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
