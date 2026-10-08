import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/utils/route_matcher.dart';

enum RideViewStatus { loading, success, error }

class HomeViewModel extends ViewModel {
  HomeViewModel({required this.repository, this.simulateError = false}) {
    repository.addListener(refresh);
  }

  final RideRepository repository;
  final bool simulateError;
  RideViewStatus _status = RideViewStatus.loading;
  List<Ride> _allRides = [];
  List<Ride> _results = [];
  String _errorMessage = '';
  int _selectedTab = 0;
  RideFilter _filter = const RideFilter();
  MapLocation? _originPlace;
  MapLocation? _destinationPlace;
  MapLocation? _appliedOrigin;
  MapLocation? _appliedDestination;
  String _appliedOriginText = '';
  String _appliedDestinationText = '';
  int _loadGeneration = 0;

  RideViewStatus get status => _status;
  List<Ride> get allRides => List.unmodifiable(_allRides);
  List<Ride> get results => List.unmodifiable(_results);
  String get errorMessage => _errorMessage;
  int get selectedTab => _selectedTab;
  RideFilter get filter => _filter;
  MapLocation? get originPlace => _originPlace;
  MapLocation? get destinationPlace => _destinationPlace;
  bool get geographicSearch =>
      _appliedOrigin != null && _appliedDestination != null;

  void selectTab(int index) {
    _selectedTab = index;
    publish();
  }

  void selectOrigin(MapLocation? place) {
    _originPlace = place;
    publish();
  }

  void selectDestination(MapLocation? place) {
    _destinationPlace = place;
    publish();
  }

  void setLocations(MapLocation? origin, MapLocation? destination) {
    _originPlace = origin;
    _destinationPlace = destination;
    publish();
  }

  String? search({required String origin, required String destination}) {
    if (_originPlace == null || _destinationPlace == null) {
      return 'Pilih saran atau pin untuk asal dan tujuan agar bisa mencocokkan jalur.';
    }
    if (_originPlace != null &&
        _originPlace!.point.distanceTo(_destinationPlace!.point) < 50) {
      return 'Asal dan tujuan minimal 50 meter';
    }
    _appliedOrigin = _originPlace;
    _appliedDestination = _destinationPlace;
    _appliedOriginText = origin;
    _appliedDestinationText = destination;
    _results = _filtered(_allRides);
    publish();
    return null;
  }

  void applyFilter(RideFilter value) {
    _filter = value;
    _results = _filtered(_allRides);
    publish();
  }

  void refresh() {
    if (isDisposed) return;
    _allRides = repository.rides;
    _results = _filtered(_allRides);
    publish();
  }

  List<Ride> _filtered(List<Ride> rides) {
    if (!geographicSearch) {
      return _filter.apply(
        rides,
        origin: _appliedOriginText,
        destination: _appliedDestinationText,
      );
    }
    final matches = <(Ride, RouteMatch)>[];
    for (final ride in rides) {
      if (!_filter.matches(ride) || ride.geography == null) continue;
      final match = RouteMatcher.match(
        ride.geography!.route,
        _appliedOrigin!.point,
        _appliedDestination!.point,
      );
      if (match != null) matches.add((ride, match));
    }
    matches.sort((a, b) => a.$2.totalDeviation.compareTo(b.$2.totalDeviation));
    return matches.map((match) => match.$1).toList();
  }

  Future<void> load() async {
    if (isDisposed) return;
    final generation = ++_loadGeneration;
    _status = RideViewStatus.loading;
    _errorMessage = '';
    publish();
    try {
      final rides = await repository.fetchRides(simulateError: simulateError);
      if (isDisposed || generation != _loadGeneration) return;
      _allRides = rides;
      _results = _filtered(rides);
      _status = RideViewStatus.success;
    } catch (error) {
      if (isDisposed || generation != _loadGeneration) return;
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      _status = RideViewStatus.error;
    }
    publish();
  }

  @override
  void dispose() {
    repository.removeListener(refresh);
    super.dispose();
  }
}
