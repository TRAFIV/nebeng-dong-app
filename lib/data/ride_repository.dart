import '../models/ride.dart';
import 'sample_rides.dart';

// Mengambil data dummy tebengan.
class RideRepository {
  Future<List<Ride>> fetchRides({bool simulateError = false}) async {
    // Simulasi menunggu data dari server.
    await Future<void>.delayed(const Duration(seconds: 2));

    // Simulasi kegagalan untuk pengujian error di Home.
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }

    return sampleRides;
  }
}
