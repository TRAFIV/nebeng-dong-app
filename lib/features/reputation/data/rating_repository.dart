import '../models/trip_rating.dart';

class RatingException implements Exception {
  const RatingException(this.message);
  final String message;
}

/// Contract for the passenger's trip history and driver ratings.
/// Backend eligibility/authentication remains pending; the local adapter is a demo.
abstract interface class RatingRepository {
  List<RatingTrip> tripsFor(String userId);
  Future<void> load();
  TripRating? forTrip(RatingTrip trip, String userId);
  Future<TripRating> save({
    required RatingTrip trip,
    required String userId,
    required int score,
    required String comment,
  });
  Future<void> resetDemo();
}
