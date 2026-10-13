import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_results_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

void main() {
  test(
    'Local adapter is simulated, immutable and has stored real-road geometry',
    () async {
      final repo = LocalRideRepository(delay: Duration.zero);
      addTearDown(repo.dispose);
      expect(repo.isSimulation, isTrue);
      expect(await repo.fetchRides(), hasLength(4));
      expect(() => repo.rides.clear(), throwsUnsupportedError);
      for (final ride in repo.rides) {
        final geo = ride.geography!;
        expect(geo.route.points.length, greaterThan(100));
        expect(
          geo.route.points.first.distanceTo(geo.origin.point),
          lessThan(2),
        );
        expect(
          geo.route.points.last.distanceTo(geo.destination.point),
          lessThan(2),
        );
        expect(geo.route.distanceMeters, greaterThan(10000));
      }
    },
  );
  test(
    'Stored roads match outbound, reverse and no-match; full rides excluded',
    () async {
      final repo = LocalRideRepository(delay: Duration.zero);
      addTearDown(repo.dispose);
      Future<List<String>> ids(MapLocation from, MapLocation to) async {
        final vm = RideResultsViewModel(
          repository: repo,
          request: RideSearchRequest(origin: from, destination: to),
        );
        try {
          await vm.load();
          expect(vm.results.any((r) => r.isFull), isFalse);
          return vm.results.map((r) => r.id).toList();
        } finally {
          vm.dispose();
        }
      }

      expect(await ids(khatibPlace, unandPlace), contains('ride-1'));
      expect(
        await ids(khatibPlace, unandPlace),
        isNot(contains('ride-return')),
      );
      expect(await ids(unandPlace, khatibPlace), ['ride-return']);
      expect(
        await ids(
          const MapLocation(label: 'Jauh', point: GeoPoint(-1.5, 100.0)),
          unandPlace,
        ),
        isEmpty,
      );
    },
  );
  test('Unselected location does not replace previously applied request', () {
    final repo = LocalRideRepository(delay: Duration.zero);
    addTearDown(repo.dispose);
    final vm = HomeViewModel(repository: repo);
    addTearDown(vm.dispose);
    vm.setLocations(khatibPlace, unandPlace);
    vm.search();
    final previous = vm.searchRequest;
    vm.selectDestination(null);
    expect(vm.search(), isNotNull);
    expect(vm.searchRequest, same(previous));
  });
}
