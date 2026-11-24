import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

/// Immutable snapshot. Editing the form later cannot change an open result page.
class RideSearchRequest {
  const RideSearchRequest({
    required this.origin,
    required this.destination,
    this.filter = const RideFilter(),
    this.date,
    this.time,
  });
  final MapLocation origin;
  final MapLocation destination;
  final RideFilter filter;

  /// Tanggal berangkat (tanpa jam). `null` = tidak disaring per hari.
  final DateTime? date;

  /// Jam berangkat pilihan penumpang dalam menit-dalam-hari. `null` = semua
  /// jam; selain itu hasil disaring ±15 menit dari perkiraan jam lewat.
  final int? time;
}
