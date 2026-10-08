import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';

import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/legacy/driver/data/sample_rides.dart';

/// Sumber data tebengan sementara sampai REST API tersedia.
class LegacyDriverRepository extends RideRepository {
  LegacyDriverRepository({
    List<Ride> rides = sampleRides,
    this.delay = const Duration(seconds: 2),
  }) : _rides = List<Ride>.of(rides);

  final List<Ride> _rides;
  final Set<String> _ownedIds = {};
  int _nextId = 0;
  final Duration delay;

  @override
  bool get isSimulation => true;

  @override
  List<Ride> get rides => List.unmodifiable(_rides);
  List<Ride> get ownedRides =>
      List.unmodifiable(_rides.where((ride) => _ownedIds.contains(ride.id)));

  Ride post({
    required String driverName,
    required String origin,
    required String destination,
    required String departureTime,
    required int capacity,
    RideGeography? geography,
  }) {
    if (capacity < 1 || capacity > 8) {
      throw ArgumentError('Kuota harus 1–8 kursi');
    }
    String id;
    do {
      id = 'local-${++_nextId}';
    } while (_rides.any((ride) => ride.id == id));
    final ride = Ride(
      id: id,
      driverName: driverName,
      driverRating: 0,
      driverTripCount: 0,
      origin: origin,
      destination: destination,
      schedule: 'Senin–Jumat',
      departureTime: departureTime,
      seatCapacity: capacity,
      seatsAvailable: capacity,
      farePerPerson: 0,
      geography: geography,
    );
    _rides.insert(0, ride);
    _ownedIds.add(id);
    notifyListeners();
    return ride;
  }

  void updateOwned(Ride ride) {
    final index = _rides.indexWhere((item) => item.id == ride.id);
    if (!_ownedIds.contains(ride.id) || index < 0) {
      throw StateError('Rute bukan milik sesi ini');
    }
    final occupied = _rides[index].seatCapacity - _rides[index].seatsAvailable;
    if (ride.seatCapacity < occupied ||
        ride.seatCapacity < 1 ||
        ride.seatCapacity > 8) {
      throw StateError('Kuota tidak boleh kurang dari kursi yang sudah terisi');
    }
    _rides[index] = ride.copyWith(seatsAvailable: ride.seatCapacity - occupied);
    notifyListeners();
  }

  void deleteOwned(String id) {
    if (!_ownedIds.contains(id)) throw StateError('Rute bukan milik sesi ini');
    final ride = _rides.firstWhere((ride) => ride.id == id);
    if (ride.seatsAvailable < ride.seatCapacity) {
      throw StateError('Rute dengan penumpang belum bisa dihapus');
    }
    _ownedIds.remove(id);
    _rides.removeWhere((ride) => ride.id == id);
    notifyListeners();
  }

  /// Dipanggil Modul 2 SETELAH pemberi menyetujui booking, bukan saat meminta.
  /// ID booking membuat callback yang terkirim ulang tidak mengurangi dua kali.
  final Map<String, String> _acceptedBookings = {};
  void acceptBooking({required String routeId, required String bookingId}) {
    if (bookingId.trim().isEmpty) throw ArgumentError('ID booking wajib diisi');
    final previous = _acceptedBookings[bookingId];
    if (previous != null) {
      if (previous != routeId) {
        throw StateError('Booking sudah dipakai rute lain');
      }
      return;
    }
    final index = _rides.indexWhere((ride) => ride.id == routeId);
    if (index < 0) throw StateError('Rute tidak ditemukan');
    final ride = _rides[index];
    if (ride.isFull) throw StateError('Kursi sudah penuh');
    _rides[index] = ride.copyWith(seatsAvailable: ride.seatsAvailable - 1);
    _acceptedBookings[bookingId] = routeId;
    notifyListeners();
  }

  /// Mengambil daftar tebengan dan meniru waktu tunggu dari server.
  @override
  Future<List<Ride>> fetchRides({bool simulateError = false}) async {
    await Future<void>.delayed(delay);
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return rides;
  }
}
