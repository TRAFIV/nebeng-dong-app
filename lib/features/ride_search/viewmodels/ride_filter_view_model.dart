import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';

class RideFilterViewModel extends ViewModel {
  /// Pilihan minimal kursi di layar Filter. Tambah angka di sini untuk
  /// menambah pilihan; layar membuat tombolnya otomatis.
  static const seatOptions = [1, 2, 3];

  RideFilterViewModel({RideFilter initialFilter = const RideFilter()})
    : _window = initialFilter.window,
      _seats = initialFilter.minimumSeats,
      _vehicle = initialFilter.vehicle;
  DepartureWindow? _window;
  int _seats;
  VehicleKind? _vehicle;
  DepartureWindow? get window => _window;
  int get seats => _seats;

  /// `null` = semua kendaraan.
  VehicleKind? get vehicle => _vehicle;

  /// Motor hanya muat satu penumpang, jadi pilihan kursi di atas 1 dimatikan.
  bool canSelectSeats(int value) => _vehicle != VehicleKind.motor || value <= 1;

  void selectVehicle(VehicleKind? value) {
    _vehicle = value;
    if (!canSelectSeats(_seats)) _seats = 1;
    publish();
  }

  void selectWindow(DepartureWindow? value) {
    _window = value;
    publish();
  }

  void selectSeats(int value) {
    if (!canSelectSeats(value)) return;
    _seats = value;
    publish();
  }

  void reset() {
    _window = null;
    _seats = 1;
    _vehicle = null;
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
          vehicle: _vehicle,
        );
}
