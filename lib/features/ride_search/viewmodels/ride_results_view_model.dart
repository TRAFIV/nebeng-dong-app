import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/core/network/api_exception.dart';
import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_schedule.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_search_matcher.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

enum SearchResultsStatus { loading, success, error }

/// Urutan hasil yang bisa dipilih penumpang.
enum RideSort {
  earliest('Paling cepat'),
  cheapest('Termurah'),
  mostSeats('Kursi terbanyak');

  const RideSort(this.label);
  final String label;
}

class RideResultsViewModel extends ViewModel {
  RideResultsViewModel({
    required this.repository,
    required this.request,
    this.simulateError = false,
  }) : _filter = request.filter {
    // Kalau data repository berubah (misalnya pembaruan dari backend nanti,
    // FR-07), hasil dihitung ulang tanpa memuat ulang layar.
    repository.addListener(refresh);
  }
  final RideRepository repository;
  final RideSearchRequest request;
  final bool simulateError;
  RideFilter _filter;
  SearchResultsStatus _status = SearchResultsStatus.loading;
  List<Ride> _rides = [];
  List<MatchedRide> _matches = [];
  RideSort _sort = RideSort.earliest;
  String _errorMessage = '';
  int _generation = 0;
  RideFilter get filter => _filter;
  SearchResultsStatus get status => _status;
  RideSort get sort => _sort;

  /// Hasil beserta perkiraan jam lewat dan jarak jalan kaki, sudah diurutkan.
  List<MatchedRide> get matches => List.unmodifiable(_matches);
  List<Ride> get results =>
      List.unmodifiable(_matches.map((item) => item.ride));
  String get errorMessage => _errorMessage;

  void applyFilter(RideFilter filter) {
    if (isDisposed) return;
    _filter = filter;
    _rematch();
    publish();
  }

  void setSort(RideSort sort) {
    if (isDisposed || sort == _sort) return;
    _sort = sort;
    _matches = _sorted(_matches);
    publish();
  }

  void refresh() {
    if (isDisposed) return;
    _rides = repository.rides;
    _rematch();
    publish();
  }

  /// Toleransi jam pilihan penumpang terhadap perkiraan jam lewat.
  static const timeToleranceMinutes = 15;

  void _rematch() {
    final date = request.date;
    final time = request.time;
    final matches = matchPassengerRideDetails(_rides, request, _filter).where((
      item,
    ) {
      if (date != null && !rideRunsOn(item.ride, date)) return false;
      if (time == null) return true;
      final minute =
          item.pickupEtaMinute ?? parseDepartureMinute(item.ride.departureTime);
      return minute != null && (minute - time).abs() <= timeToleranceMinutes;
    }).toList();
    _matches = _sorted(matches);
  }

  /// Urutan stabil: yang setara tetap memakai urutan kecocokan jalur.
  List<MatchedRide> _sorted(List<MatchedRide> items) {
    final indexed = items.indexed.toList();
    int byEarliest(MatchedRide a, MatchedRide b) {
      final ma =
          a.pickupEtaMinute ?? parseDepartureMinute(a.ride.departureTime);
      final mb =
          b.pickupEtaMinute ?? parseDepartureMinute(b.ride.departureTime);
      // Jam yang tidak terbaca ditaruh paling akhir.
      if (ma == null || mb == null) {
        return (ma == null ? 1 : 0) - (mb == null ? 1 : 0);
      }
      return ma.compareTo(mb);
    }

    // Ongkos 0 = belum diatur, ditaruh paling akhir.
    int fareKey(MatchedRide m) =>
        m.ride.farePerPerson == 0 ? 1 << 30 : m.ride.farePerPerson;
    indexed.sort((x, y) {
      final order = switch (_sort) {
        RideSort.earliest => byEarliest(x.$2, y.$2),
        RideSort.cheapest => fareKey(x.$2).compareTo(fareKey(y.$2)),
        RideSort.mostSeats => y.$2.ride.seatsAvailable.compareTo(
          x.$2.ride.seatsAvailable,
        ),
      };
      return order != 0 ? order : x.$1.compareTo(y.$1);
    });
    return [for (final entry in indexed) entry.$2];
  }

  Future<void> load() async {
    if (isDisposed) return;
    final generation = ++_generation;
    _status = SearchResultsStatus.loading;
    _errorMessage = '';
    publish();
    try {
      final rides = await repository.fetchRides(simulateError: simulateError);
      if (isDisposed || generation != _generation) return;
      _rides = List.of(rides);
      _rematch();
      _status = SearchResultsStatus.success;
    } catch (error, stackTrace) {
      if (isDisposed || generation != _generation) return;
      // Detail teknis untuk debugging; pengguna hanya melihat pesan ramah.
      debugPrint('Gagal memuat tebengan: $error\n$stackTrace');
      _status = SearchResultsStatus.error;
      final reason = error is ApiException
          ? error.message
          : 'Periksa koneksi internet, lalu coba lagi.';
      _errorMessage = '$reason Lokasi dan filtermu tetap tersimpan.';
    }
    publish();
  }

  @override
  void dispose() {
    _generation++;
    repository.removeListener(refresh);
    super.dispose();
  }
}
