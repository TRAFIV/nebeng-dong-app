import 'package:praktikum_mobile/features/costs/models/cost_share.dart';

/// Data latihan Modul 3, bukan pesanan atau pembayaran nyata.
///
/// `rideId`, nama pengemudi, rute dan tarif menyalin fixture `demo_rides.dart`
/// (Modul 1). `bookingId` adalah contoh sampai model pesanan Modul 2 tersedia.
/// Status pembayaran sengaja beragam untuk menggantikan konfirmasi backend:
/// aplikasi penumpang tidak punya tombol konfirmasi admin.
final demoCostShares = List<CostShare>.unmodifiable([
  // Selesai, belum dilaporkan: alur utama "Sudah bayar".
  CostShare(
    id: 'cost-1',
    bookingId: 'booking-1',
    rideId: 'ride-1',
    driverName: 'Taris Rafivdean',
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand Limau Manis',
    tripDate: DateTime(2026, 10, 16, 7, 30),
    tripCompleted: true,
    farePerPerson: 5000,
  ),
  // Selesai, sudah dilaporkan, menunggu backend/admin.
  CostShare(
    id: 'cost-2',
    bookingId: 'booking-2',
    rideId: 'ride-2',
    driverName: 'Duha Alul Bariq',
    origin: 'Jl. Veteran',
    destination: 'Kampus Unand Limau Manis',
    tripDate: DateTime(2026, 10, 15, 7, 45),
    tripCompleted: true,
    farePerPerson: 4000,
    paymentStatus: PaymentStatus.pendingConfirmation,
    declaredAt: DateTime(2026, 10, 15, 9, 10),
  ),
  // Selesai dan sudah dikonfirmasi (contoh hasil keputusan backend/admin).
  CostShare(
    id: 'cost-3',
    bookingId: 'booking-3',
    rideId: 'ride-1',
    driverName: 'Taris Rafivdean',
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand Limau Manis',
    tripDate: DateTime(2026, 10, 13, 7, 30),
    tripCompleted: true,
    farePerPerson: 5000,
    paymentStatus: PaymentStatus.confirmed,
    declaredAt: DateTime(2026, 10, 13, 8, 5),
  ),
  // Selesai tetapi ongkos belum diatur penyedia: tidak boleh dianggap gratis.
  CostShare(
    id: 'cost-4',
    bookingId: 'booking-4',
    rideId: 'ride-return',
    driverName: 'Pengemudi contoh',
    origin: 'Kampus Unand Limau Manis',
    destination: 'Jl. Khatib Sulaiman',
    tripDate: DateTime(2026, 10, 14, 16, 0),
    tripCompleted: true,
  ),
  // Pesanan diterima, perjalanan belum berlangsung: ongkos masih estimasi.
  CostShare(
    id: 'cost-5',
    bookingId: 'booking-5',
    rideId: 'ride-1',
    driverName: 'Taris Rafivdean',
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand Limau Manis',
    tripDate: DateTime(2026, 10, 19, 7, 30),
    tripCompleted: false,
    farePerPerson: 5000,
  ),
]);
