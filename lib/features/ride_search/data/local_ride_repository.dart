import 'package:praktikum_mobile/shared/models/ride.dart';

import 'fixtures/demo_rides.dart';
import 'ride_repository.dart';

/// In-memory practical fixtures, not a production/backend adapter.
class LocalRideRepository extends RideRepository {
  LocalRideRepository({
    List<Ride>? rides,
    this.delay = const Duration(seconds: 2),
  }) : _rides = List<Ride>.unmodifiable(rides ?? demoRides);
  final List<Ride> _rides;
  final Duration delay;
  @override
  bool get isSimulation => true;
  @override
  List<Ride> get rides => _rides;
  @override
  Future<List<Ride>> fetchRides({bool simulateError = false}) async {
    await Future<void>.delayed(delay);
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _rides;
  }
}
