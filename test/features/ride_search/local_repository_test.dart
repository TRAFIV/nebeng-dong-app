import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

void main() {
  test('Local adapter is explicitly simulated and immutable, with stored road geometry', () async {
    final repo = LocalRideRepository(delay: Duration.zero);
    addTearDown(repo.dispose);
    expect(repo.isSimulation, isTrue);
    expect(await repo.fetchRides(), hasLength(4));
    expect(() => repo.rides.clear(), throwsUnsupportedError);
    for (final ride in repo.rides) {
      final geo = ride.geography!;
      expect(geo.route.points.length, greaterThan(100));
      expect(geo.route.points.first.distanceTo(geo.origin.point), lessThan(2));
      expect(
        geo.route.points.last.distanceTo(geo.destination.point),
        lessThan(2),
      );
      expect(geo.route.distanceMeters, greaterThan(10000));
    }
  });
  test(
    'Stored routes match outbound, reverse and no-match; full rides excluded',
    () async {
      final repo = LocalRideRepository(delay: Duration.zero);
      final vm = HomeViewModel(repository: repo);
      addTearDown(repo.dispose);
      addTearDown(vm.dispose);
      await vm.load();
      vm.setLocations(khatibPlace, unandPlace);
      expect(
        vm.search(origin: khatibPlace.label, destination: unandPlace.label),
        isNull,
      );
      expect(vm.results.map((r) => r.id), contains('ride-1'));
      expect(vm.results.any((r) => r.isFull || r.id == 'ride-return'), isFalse);
      vm.setLocations(unandPlace, khatibPlace);
      expect(
        vm.search(origin: unandPlace.label, destination: khatibPlace.label),
        isNull,
      );
      expect(vm.results.map((r) => r.id), ['ride-return']);
      vm.setLocations(
        const MapLocation(label: 'Jauh', point: GeoPoint(-1.5, 100.0)),
        unandPlace,
      );
      expect(vm.search(origin: 'Jauh', destination: unandPlace.label), isNull);
      expect(vm.results, isEmpty);
    },
  );
  test(
    'Invalid unselected location cannot replace previously applied search',
    () async {
      final repo = LocalRideRepository(delay: Duration.zero);
      final vm = HomeViewModel(repository: repo);
      addTearDown(repo.dispose);
      addTearDown(vm.dispose);
      await vm.load();
      vm.setLocations(khatibPlace, unandPlace);
      vm.search(origin: khatibPlace.label, destination: unandPlace.label);
      final previous = vm.results.map((r) => r.id).toList();
      vm.selectDestination(null);
      expect(
        vm.search(origin: khatibPlace.label, destination: 'teks bebas'),
        isNotNull,
      );
      expect(vm.results.map((r) => r.id), previous);
    },
  );
}
