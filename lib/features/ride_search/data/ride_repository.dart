import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

/// Passenger read contract; driver mutations are deliberately not exposed.
/// Replace local data with an API adapter only after the team agrees its contract.
abstract class RideRepository extends ChangeNotifier {
  bool get isSimulation;
  List<Ride> get rides;

  /// Practical-test hook, not a server API parameter.
  Future<List<Ride>> fetchRides({bool simulateError = false});
}
