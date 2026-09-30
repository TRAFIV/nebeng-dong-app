import '../models/ride.dart';
import 'sample_rides.dart';

class RideRepository {
  Future<List<Ride>> fetchRides({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return sampleRides;
  }
}
