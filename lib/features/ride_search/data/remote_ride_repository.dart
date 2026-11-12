import 'package:praktikum_mobile/core/network/api_client.dart';
import 'package:praktikum_mobile/core/network/json_reader.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_json.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

/// Tebengan dari REST API kelompok (`GET /rides`).
///
/// Contoh acuan untuk modul lain: repository cukup memanggil [ApiClient] dan
/// membaca JSON; header, token, batas waktu dan pesan error sudah diurus
/// ApiClient. Kegagalan dilempar sebagai `ApiException` dan ditampilkan
/// ViewModel apa adanya.
class RemoteRideRepository extends RideRepository {
  RemoteRideRepository(this._api);

  final ApiClient _api;
  List<Ride> _rides = const [];

  @override
  bool get isSimulation => false;

  @override
  List<Ride> get rides => _rides;

  /// [simulateError] hanya untuk latihan dengan data lokal dan diabaikan di sini.
  @override
  Future<List<Ride>> fetchRides({bool simulateError = false}) async {
    final json = await _api.get('rides');
    _rides = List.unmodifiable(parseResponse(json, ridesFromJson));
    return _rides;
  }
}
