import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

import 'padang_road_geometry.dart';

const khatibPlace = MapLocation(
  label: 'Jl. Khatib Sulaiman',
  address: 'Jalan Khatib Sulaiman, Ulak Karang Utara, Padang, Sumatera Barat, Indonesia',
  point: GeoPoint(-0.9099249, 100.3548088),
);
const veteranPlace = MapLocation(
  label: 'Jl. Veteran',
  address: 'Jalan Veteran, Ujung Gurun, Padang, Sumatera Barat, Indonesia',
  point: GeoPoint(-0.9376233, 100.3545128),
);
const unandPlace = MapLocation(
  label: 'Kampus Unand Limau Manis',
  address: 'Universitas Andalas, Jalan Limau Manis, Padang, Sumatera Barat, Indonesia',
  point: GeoPoint(-0.9148733, 100.4627099),
);

/// Example names/rating/fares are not actual driver offers.
final demoRides = List<Ride>.unmodifiable([
  Ride(
    id: 'ride-1',
    driverName: 'Taris Rafivdean',
    driverRating: 4.8,
    driverTripCount: 32,
    origin: khatibPlace.label,
    destination: unandPlace.label,
    schedule: 'Senin–Jumat',
    departureTime: '07.30',
    seatCapacity: 3,
    seatsAvailable: 2,
    farePerPerson: 5000,
    geography: RideGeography(
      origin: khatibPlace,
      destination: unandPlace,
      route: khatibRoad,
    ),
  ),
  Ride(
    id: 'ride-2',
    driverName: 'Duha Alul Bariq',
    driverRating: 4.6,
    driverTripCount: 18,
    origin: veteranPlace.label,
    destination: unandPlace.label,
    schedule: 'Senin–Kamis',
    departureTime: '07.45',
    seatCapacity: 2,
    seatsAvailable: 1,
    farePerPerson: 4000,
    geography: RideGeography(
      origin: veteranPlace,
      destination: unandPlace,
      route: veteranRoad,
    ),
  ),
  Ride(
    id: 'ride-3',
    driverName: 'M Shiddiq Maihendra',
    driverRating: 4.9,
    driverTripCount: 41,
    origin: khatibPlace.label,
    destination: unandPlace.label,
    schedule: 'Senin–Jumat',
    departureTime: '08.00',
    seatCapacity: 3,
    seatsAvailable: 0,
    farePerPerson: 6000,
    geography: RideGeography(
      origin: khatibPlace,
      destination: unandPlace,
      route: khatibRoad,
    ),
  ),
  Ride(
    id: 'ride-return',
    driverName: 'Pengemudi contoh',
    driverRating: 0,
    driverTripCount: 0,
    origin: unandPlace.label,
    destination: khatibPlace.label,
    schedule: 'Senin–Jumat',
    departureTime: '16.00',
    seatCapacity: 2,
    seatsAvailable: 2,
    farePerPerson: 5000,
    geography: RideGeography(
      origin: unandPlace,
      destination: khatibPlace,
      route: pulangRoad,
    ),
  ),
]);
