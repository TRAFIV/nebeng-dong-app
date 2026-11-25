import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

/// Posisi perangkat saat ini, diambil sekali (bukan dilacak terus).
abstract class DeviceLocation {
  /// `null` bila GPS mati, izin ditolak, atau posisi tidak didapat.
  Future<GeoPoint?> current();
}

/// Lewat paket geolocator. Izin diminta saat pertama dipakai; lokasi tidak
/// disimpan dan tidak dikirim ke server.
class GeolocatorDeviceLocation implements DeviceLocation {
  const GeolocatorDeviceLocation({this.timeout = const Duration(seconds: 8)});

  final Duration timeout;

  @override
  Future<GeoPoint?> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: timeout,
          ),
        );
      } catch (error) {
        // Sinyal GPS lemah: pakai posisi terakhir yang diketahui bila ada.
        debugPrint('Posisi sekarang belum didapat: $error');
        position = await Geolocator.getLastKnownPosition();
      }
      return position == null
          ? null
          : GeoPoint(position.latitude, position.longitude);
    } catch (error) {
      // Termasuk saat tes/perangkat tanpa layanan lokasi.
      debugPrint('Lokasi perangkat tidak tersedia: $error');
      return null;
    }
  }
}
