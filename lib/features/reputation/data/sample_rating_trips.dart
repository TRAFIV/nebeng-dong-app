import '../models/trip_rating.dart';

// Data demo tetap, bukan hasil API atau perjalanan nyata pengguna.
const ratingDemoUserId = 'duha';
const sampleRatingTrips = [
  RatingTrip(
    id: 'trip-30sep',
    driverId: 'taris',
    driverName: 'Taris Rafivdean',
    passengerId: ratingDemoUserId,
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand',
    dateLabel: '30 Sep 2026 · 07.30',
  ),
  RatingTrip(
    id: 'passenger-trip-28sep',
    driverId: 'mikail',
    driverName: 'Mikail Samyth',
    passengerId: ratingDemoUserId,
    origin: 'Kampus Unand',
    destination: 'Jl. Khatib Sulaiman',
    dateLabel: '28 Sep 2026 · 16.30',
  ),
];
