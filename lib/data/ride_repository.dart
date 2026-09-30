import '../models/ride.dart';
import 'sample_rides.dart';

/// Sumber data tebengan sementara sampai REST API tersedia.
class RideRepository {
  const RideRepository({
    this.rides = sampleRides,
    this.delay = const Duration(seconds: 2),
  });

  final List<Ride> rides;
  final Duration delay;

  /// Mengambil daftar tebengan dan meniru waktu tunggu dari server.
  Future<List<Ride>> fetchRides({bool simulateError = false}) async {
    await Future<void>.delayed(delay);
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return List<Ride>.unmodifiable(rides);
  }
}
