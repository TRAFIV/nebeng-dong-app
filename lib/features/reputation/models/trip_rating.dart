class RatingTrip {
  const RatingTrip({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.passengerId,
    required this.origin,
    required this.destination,
    required this.dateLabel,
    this.completed = true,
  });
  final String id, driverId, driverName, origin, destination, dateLabel;
  final String passengerId;
  final bool completed;
}

class TripRating {
  const TripRating({
    required this.tripId,
    required this.raterId,
    required this.targetId,
    required this.score,
    required this.comment,
  });
  final String tripId, raterId, targetId, comment;
  final int score;
  String get key => '$tripId/$raterId/$targetId';
  Map<String, Object> toJson() => {
    'tripId': tripId,
    'raterId': raterId,
    'targetId': targetId,
    'score': score,
    'comment': comment,
  };
  factory TripRating.fromJson(Map<String, dynamic> json) {
    final rating = TripRating(
      tripId: json['tripId'] as String,
      raterId: json['raterId'] as String,
      targetId: json['targetId'] as String,
      score: json['score'] as int,
      comment: json['comment'] as String,
    );
    if (rating.score < 1 ||
        rating.score > 5 ||
        rating.comment.length > 200 ||
        rating.tripId.isEmpty ||
        rating.raterId.isEmpty ||
        rating.targetId.isEmpty) {
      throw const FormatException('Data rating tidak valid');
    }
    return rating;
  }
}
