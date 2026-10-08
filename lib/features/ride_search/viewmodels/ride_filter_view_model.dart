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

  String? validateFare(String? value) =>
      (value?.trim().isEmpty ?? true) || parseFare(value!) != null
      ? null
      : 'Isi rupiah bulat, contoh 10.000';

  RideFilter? apply(String fare) => validateFare(fare) != null
      ? null
      : RideFilter(
          window: _window,
          minimumSeats: _seats,
          maximumFare: fare.trim().isEmpty ? null : parseFare(fare),
        );
}
