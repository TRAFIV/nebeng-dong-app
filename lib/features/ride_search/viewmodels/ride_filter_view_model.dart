import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';

class RideFilterViewModel extends ViewModel {
  RideFilterViewModel({RideFilter initialFilter = const RideFilter()})
    : _window = initialFilter.window,
      _seats = initialFilter.minimumSeats;
  DepartureWindow? _window;
  int _seats;
  DepartureWindow? get window => _window;
  int get seats => _seats;

  void selectWindow(DepartureWindow? value) {
    _window = value;
    publish();
  }

  void selectSeats(int value) {
    _seats = value;
    publish();
  }

  void reset() {
    _window = null;
    _seats = 1;
    publish();
  }

  /// Kosong berarti tanpa batas. Batas Rp0 ditolak karena tidak ada tebengan
  /// yang bisa lolos: ongkos 0 berarti belum diatur, bukan gratis.
  String? validateFare(String? value) {
    if (value?.trim().isEmpty ?? true) return null;
    final fare = parseFare(value!);
    if (fare == null) return 'Isi rupiah bulat, contoh 10.000';
    if (fare <= 0) return 'Batas ongkos harus lebih dari Rp0';
    return null;
  }

  RideFilter? apply(String fare) => validateFare(fare) != null
      ? null
      : RideFilter(
          window: _window,
          minimumSeats: _seats,
          maximumFare: fare.trim().isEmpty ? null : parseFare(fare),
        );
}
