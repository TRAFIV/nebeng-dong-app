import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';

/// Data tebengan contoh untuk simulasi/demo alur pengajuan tebengan (FR-05, FR-06).
const demoSimulationRide = Ride(
  id: 'ride-simulasi',
  driverName: 'Taris Rafivdean (Simulasi)',
  driverRating: 4.9,
  driverTripCount: 45,
  origin: 'Jl. Khatib Sulaiman',
  destination: 'Kampus Unand Limau Manis',
  schedule: 'Hari ini · Cabut 08.00',
  departureTime: '08.00',
  seatCapacity: 4,
  seatsAvailable: 3,
  farePerPerson: 10000,
);

/// Data fixture untuk simulasi latihan modul 2 (bukan data server nyata).
final List<Booking> demoBookings = [
  // 1. Pesanan Aktif (Diterima) - Taris Rafivdean
  const Booking(
    id: 'booking-1',
    rideId: 'ride-1',
    driverName: 'Taris Rafivdean',
    driverRating: 4.8,
    driverTripCount: 32,
    schedule: 'Sen, 12 Okt · 07.30',
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand',
    pickupLocation: 'Gerbang Kompleks Veteran, Padang',
    note: 'depan pagar biru',
    status: BookingStatus.diterima,
    timeline: BookingTimeline(
      requestSentTime: '07.12',
      decisionTime: '07.15',
      pickupTime: '07.30',
    ),
    updatedAtLabel: 'Baru saja',
  ),

  // 2. Pesanan Aktif (Menunggu) - Duha Alul Bariq
  const Booking(
    id: 'booking-2',
    rideId: 'ride-2',
    driverName: 'Duha Alul Bariq',
    driverRating: 4.9,
    driverTripCount: 18,
    schedule: 'Sel, 13 Okt · 07.45',
    origin: 'Kos Isan, Air Tawar',
    destination: 'Kampus Unand',
    pickupLocation: 'Depan Kos Isan',
    note: 'bawa ransel 1',
    status: BookingStatus.menunggu,
    timeline: BookingTimeline(requestSentTime: '07.20'),
    updatedAtLabel: 'Baru saja',
  ),

  // 3. Riwayat Pesanan (Ditolak) - M Shiddiq
  const Booking(
    id: 'booking-3',
    rideId: 'ride-3',
    driverName: 'M Shiddiq',
    driverRating: 4.7,
    driverTripCount: 10,
    schedule: 'Kam, 8 Okt · 07.30',
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand',
    pickupLocation: 'Gerbang Kompleks Veteran',
    note: 'depan pagar biru',
    status: BookingStatus.ditolak,
    timeline: BookingTimeline(requestSentTime: '07.12', decisionTime: '07.20'),
    updatedAtLabel: 'Diperbarui 07.20',
  ),

  // 4. Riwayat Pesanan (Dibatalkan) - Taris Rafivdean
  const Booking(
    id: 'booking-4',
    rideId: 'ride-1',
    driverName: 'Taris Rafivdean',
    driverRating: 4.8,
    driverTripCount: 32,
    schedule: 'Rab, 7 Okt · 07.30',
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand',
    pickupLocation: 'Gerbang Kompleks Veteran',
    note: 'depan pagar biru',
    status: BookingStatus.dibatalkan,
    timeline: BookingTimeline(
      requestSentTime: '07.12',
      decisionTime: '07.15',
      cancelledTime: '08.40',
    ),
    updatedAtLabel: 'Diperbarui 08.40',
  ),
];
