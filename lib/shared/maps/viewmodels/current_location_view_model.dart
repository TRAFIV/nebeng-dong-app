import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/services/device_location.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';

enum CurrentLocationStatus { idle, locating, found, unavailable }

/// Mengambil lokasi perangkat sekali lalu mengubahnya menjadi nama tempat,
/// untuk mengisi "Dari" secara otomatis.
class CurrentLocationViewModel extends ViewModel {
  CurrentLocationViewModel({required this.device, required this.maps});

  final DeviceLocation device;
  final MapService maps;

  CurrentLocationStatus _status = CurrentLocationStatus.idle;
  CurrentLocationStatus get status => _status;
  bool get locating => _status == CurrentLocationStatus.locating;

  /// Tempat sekarang, atau `null` bila tidak tersedia.
  Future<MapLocation?> locate() async {
    if (isDisposed || locating) return null;
    _status = CurrentLocationStatus.locating;
    publish();
    final point = await device.current();
    if (isDisposed) return null;
    if (point == null) {
      _status = CurrentLocationStatus.unavailable;
      publish();
      return null;
    }
    MapLocation? place;
    try {
      place = await maps.reverseGeocode(point);
    } catch (error) {
      // Tanpa nama jalan, koordinat tetap bisa dipakai untuk mencari.
      debugPrint('Alamat lokasi sekarang tidak didapat: $error');
    }
    if (isDisposed) return null;
    _status = CurrentLocationStatus.found;
    publish();
    return place ?? MapLocation.pin(point, label: 'Lokasimu sekarang');
  }
}
