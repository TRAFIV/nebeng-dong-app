import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

/// Immutable snapshot. Editing the form later cannot change an open result page.
class RideSearchRequest {
  const RideSearchRequest({
    required this.origin,
    required this.destination,
    this.filter = const RideFilter(),
  });
  final MapLocation origin;
  final MapLocation destination;
  final RideFilter filter;
}
