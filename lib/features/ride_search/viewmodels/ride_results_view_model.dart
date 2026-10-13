import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_search_matcher.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

enum SearchResultsStatus { loading, success, error }

class RideResultsViewModel extends ViewModel {
  RideResultsViewModel({
    required this.repository,
    required this.request,
    this.simulateError = false,
  }) : _filter = request.filter {
    repository.addListener(refresh);
  }
  final RideRepository repository;
  final RideSearchRequest request;
  final bool simulateError;
  RideFilter _filter;
  SearchResultsStatus _status = SearchResultsStatus.loading;
  List<Ride> _rides = [];
  List<Ride> _results = [];
  String _errorMessage = '';
  int _generation = 0;
  RideFilter get filter => _filter;
  SearchResultsStatus get status => _status;
  List<Ride> get results => List.unmodifiable(_results);
  List<Ride> get allRides => List.unmodifiable(_rides);
  String get errorMessage => _errorMessage;

  void applyFilter(RideFilter filter) {
    if (isDisposed) return;
    _filter = filter;
    _results = matchPassengerRides(_rides, request, _filter);
    publish();
  }

  void refresh() {
    if (isDisposed) return;
    _rides = repository.rides;
    _results = matchPassengerRides(_rides, request, _filter);
    publish();
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
      _results = matchPassengerRides(_rides, request, _filter);
      _status = SearchResultsStatus.success;
    } catch (_) {
      if (isDisposed || generation != _generation) return;
      _status = SearchResultsStatus.error;
      _errorMessage = 'Periksa koneksi internet, lalu coba lagi. Lokasi dan filtermu tetap tersimpan.';
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
