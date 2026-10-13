import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

/// Form state only. Fetch/matching/loading belong to RideResultsViewModel.
class HomeViewModel extends ViewModel {
  HomeViewModel({required this.repository});
  final RideRepository repository;
  MapLocation? _originPlace;
  MapLocation? _destinationPlace;
  RideFilter _filter = const RideFilter();
  RideSearchRequest? _request;
  MapLocation? get originPlace => _originPlace;
  MapLocation? get destinationPlace => _destinationPlace;
  RideFilter get filter => _filter;
  RideSearchRequest? get searchRequest => _request;
  bool get canSearch => _originPlace != null && _destinationPlace != null;

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

  void applyFilter(RideFilter filter) {
    _filter = filter;
    publish();
  }

  String? search() {
    if (isDisposed) return 'Pencarian sudah ditutup.';
    if (!canSearch) {
      return 'Pilih saran atau pin untuk asal dan tujuan agar bisa mencocokkan jalur.';
    }
    if (_originPlace!.point.distanceTo(_destinationPlace!.point) < 50) {
      return 'Asal dan tujuan minimal 50 meter';
    }
    _request = RideSearchRequest(
      origin: _originPlace!,
      destination: _destinationPlace!,
      filter: _filter,
    );
    return null;
  }
}
