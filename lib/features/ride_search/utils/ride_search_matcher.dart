import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/utils/route_matcher.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

/// Geographic matching shared by presentation models, not by ViewModels.
List<Ride> matchPassengerRides(
  Iterable<Ride> rides,
  RideSearchRequest request,
  RideFilter filter,
) {
  final matches = <(Ride, RouteMatch)>[];
  for (final ride in rides) {
    if (!filter.matches(ride) || ride.geography == null) continue;
    final match = RouteMatcher.match(
      ride.geography!.route,
      request.origin.point,
      request.destination.point,
    );
    if (match != null) matches.add((ride, match));
  }
  matches.sort((a, b) => a.$2.totalDeviation.compareTo(b.$2.totalDeviation));
  return matches.map((item) => item.$1).toList();
}
