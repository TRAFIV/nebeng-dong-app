import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/utils/route_matcher.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

/// Tebengan yang searah beserta hasil pencocokannya.
class MatchedRide {
  const MatchedRide(this.ride, this.match);
  final Ride ride;
  final RouteMatch match;

  /// Jarak jalan kaki lurus dari titik jemputmu ke jalur (meter).
  double get walkMeters => match.pickupDeviation;

  /// Perkiraan menit-dalam-hari pengemudi lewat titik jemputmu:
  /// jam cabut + durasi rute × posisi titik jemput di jalur. Tanpa macet.
  int? get pickupEtaMinute {
    final departure = parseDepartureMinute(ride.departureTime);
    final geography = ride.geography;
    if (departure == null || geography == null) return null;
    final minutes = geography.route.durationSeconds / 60 * match.pickupFraction;
    return departure + minutes.round();
  }
}

/// "07.30" dari menit-dalam-hari; lewat tengah malam kembali ke 00.
String formatMinuteOfDay(int minute) {
  final wrapped = minute % (24 * 60);
  final hours = (wrapped ~/ 60).toString().padLeft(2, '0');
  final minutes = (wrapped % 60).toString().padLeft(2, '0');
  return '$hours.$minutes';
}

/// Pencocokan geografis bersama, dipakai ViewModel lewat fungsi ini.
/// Diurutkan dari yang paling dekat jalurnya.
List<MatchedRide> matchPassengerRideDetails(
  Iterable<Ride> rides,
  RideSearchRequest request,
  RideFilter filter,
) {
  final matches = <MatchedRide>[];
  for (final ride in rides) {
    if (!filter.matches(ride) || ride.geography == null) continue;
    final match = RouteMatcher.match(
      ride.geography!.route,
      request.origin.point,
      request.destination.point,
    );
    if (match != null) matches.add(MatchedRide(ride, match));
  }
  matches.sort(
    (a, b) => a.match.totalDeviation.compareTo(b.match.totalDeviation),
  );
  return matches;
}

List<Ride> matchPassengerRides(
  Iterable<Ride> rides,
  RideSearchRequest request,
  RideFilter filter,
) => matchPassengerRideDetails(
  rides,
  request,
  filter,
).map((item) => item.ride).toList();
