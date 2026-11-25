import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_search_matcher.dart';
import 'package:praktikum_mobile/features/ride_search/utils/route_matcher.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_results_view_model.dart';
import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';

void main() {
  test('Perkiraan lewat = jam cabut + durasi × posisi jemput', () {
    final ride = demoRides.first; // 07.30
    final duration = ride.geography!.route.durationSeconds;
    final atStart = MatchedRide(ride, const RouteMatch(80, 40));
    final halfway = MatchedRide(
      ride,
      const RouteMatch(80, 40, pickupFraction: 0.5),
    );
    expect(atStart.pickupEtaMinute, 7 * 60 + 30);
    expect(halfway.pickupEtaMinute, 7 * 60 + 30 + (duration / 60 * .5).round());
    expect(halfway.walkMeters, 80);
  });

  test('Jam menit-dalam-hari diformat HH.mm dan melewati tengah malam', () {
    expect(formatMinuteOfDay(7 * 60 + 5), '07.05');
    expect(formatMinuteOfDay(24 * 60 + 10), '00.10');
  });

  test('Posisi jemput di jalur terbaca dari asal ke tujuan', () {
    final route = demoRides.first.geography!.route;
    final match = RouteMatcher.match(
      route,
      route.points.first,
      route.points.last,
    )!;
    expect(match.pickupFraction, closeTo(0, 0.01));
  });

  test('Urutan hasil: paling cepat, termurah, kursi terbanyak', () async {
    final repository = LocalRideRepository(delay: Duration.zero);
    final vm = RideResultsViewModel(
      repository: repository,
      request: const RideSearchRequest(
        origin: khatibPlace,
        destination: unandPlace,
      ),
    );
    addTearDown(() {
      vm.dispose();
      repository.dispose();
    });
    await vm.load();
    expect(vm.results, isNotEmpty);
    expect(vm.sort, RideSort.earliest);
    final etas = vm.matches.map((m) => m.pickupEtaMinute!).toList();
    expect(etas, [...etas]..sort());

    vm.setSort(RideSort.cheapest);
    final fares = vm.results.map((r) => r.farePerPerson).toList();
    expect(fares, [...fares]..sort());

    vm.setSort(RideSort.mostSeats);
    final seats = vm.results.map((r) => r.seatsAvailable).toList();
    expect(seats, [...seats]..sort((a, b) => b.compareTo(a)));
  });

  test('Jenis kendaraan ditebak dari kapasitas kursi', () {
    expect(VehicleKind.fromSeatCapacity(1), VehicleKind.motor);
    expect(VehicleKind.fromSeatCapacity(3), VehicleKind.car);
  });
}
