import '../models/ride.dart';
import 'sample_rides.dart';

/// Sumber data sementara (contoh data). Nanti diganti REST API (PRD 2.6).
class RideRepository {
  const RideRepository();

  /// Mengambil daftar tebengan.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Ride>> fetchRides({bool simulateError = false}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat tebengan. Cek koneksi internet kamu, ya.');
    }
    return sampleRides;
  }
}
