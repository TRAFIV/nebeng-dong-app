import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

/// Jenis tempat, menentukan ikon dan warnanya di Cari.
enum SavedPlaceKind { campus, home, market, other }

/// Tempat tujuan yang disimpan penumpang (mis. Kampus, Rumah, Kos).
///
/// Hanya disimpan di HP penumpang; tidak dikirim ke server.
class SavedPlace {
  const SavedPlace({required this.name, required this.location});

  /// Nama pendek pilihan penumpang, mis. "Rumah".
  final String name;
  final MapLocation location;

  /// Ditebak dari nama/alamat; cukup untuk memilih ikon.
  SavedPlaceKind get kind {
    final text = '$name ${location.label}'.toLowerCase();
    if (text.contains('kampus') ||
        text.contains('unand') ||
        text.contains('universitas')) {
      return SavedPlaceKind.campus;
    }
    if (text.contains('rumah') || text.contains('kos')) {
      return SavedPlaceKind.home;
    }
    if (text.contains('pasar') || text.contains('mall')) {
      return SavedPlaceKind.market;
    }
    return SavedPlaceKind.other;
  }

  Map<String, Object?> toJson() => {
    'name': name,
    'label': location.label,
    'address': location.address,
    'lat': location.point.latitude,
    'lng': location.point.longitude,
    if (location.sourceId != null) 'source_id': location.sourceId,
  };

  /// `null` bila data tersimpan rusak (mis. versi lama); pemanggil melewatinya.
  static SavedPlace? fromJson(Object? value) {
    if (value is! Map) return null;
    final name = value['name'];
    final label = value['label'];
    final lat = value['lat'];
    final lng = value['lng'];
    if (name is! String || label is! String || lat is! num || lng is! num) {
      return null;
    }
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    final address = value['address'];
    final sourceId = value['source_id'];
    return SavedPlace(
      name: name,
      location: MapLocation(
        label: label,
        address: address is String ? address : '',
        point: GeoPoint(lat.toDouble(), lng.toDouble()),
        sourceId: sourceId is String ? sourceId : null,
      ),
    );
  }
}
