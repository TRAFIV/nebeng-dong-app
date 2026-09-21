import '../models/ride.dart';

/// Contoh tebengan sementara sampai REST API tersedia (PRD 2.6).
/// Isinya sama dengan contoh di desain Figma.
const sampleRides = <Ride>[
  Ride(
    id: 'ride-1',
    driverName: 'Taris Rafivdean',
    driverRating: 4.8,
    driverTripCount: 32,
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand Limau Manis',
    schedule: 'Senin–Jumat',
    departureTime: '07.30',
    seatCapacity: 3,
    seatsAvailable: 2,
    farePerPerson: 5000,
  ),
  Ride(
    id: 'ride-2',
    driverName: 'Duha Alul Bariq',
    driverRating: 4.6,
    driverTripCount: 18,
    origin: 'Jl. Veteran',
    destination: 'Kampus Unand Limau Manis',
    schedule: 'Senin–Kamis',
    departureTime: '07.45',
    seatCapacity: 2,
    seatsAvailable: 1,
    farePerPerson: 4000,
  ),
  Ride(
    id: 'ride-3',
    driverName: 'M Shiddiq Maihendra',
    driverRating: 4.9,
    driverTripCount: 41,
    origin: 'Lubuk Buaya',
    destination: 'Kampus Unand Limau Manis',
    schedule: 'Senin–Jumat',
    departureTime: '08.00',
    seatCapacity: 3,
    seatsAvailable: 0,
    farePerPerson: 6000,
  ),
];
