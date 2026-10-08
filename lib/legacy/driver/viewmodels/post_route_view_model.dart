import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';

class PostRouteViewModel extends ViewModel {
  PostRouteViewModel({
    required this.repository,
    required this.service,
    required this.driverName,
    this.initialRide,
  }) : _originPlace = initialRide?.geography?.origin,
       _destinationPlace = initialRide?.geography?.destination;

  final LegacyDriverRepository repository;
  final MapService service;
  final String driverName;
  final Ride? initialRide;
  MapLocation? _originPlace;
  MapLocation? _destinationPlace;
  bool _saving = false;
  String? _error;
  int _saveGeneration = 0;
  MapLocation? get originPlace => _originPlace;
  MapLocation? get destinationPlace => _destinationPlace;
  bool get saving => _saving;
  String? get error => _error;
  bool get editing => initialRide != null;

  void selectOrigin(MapLocation? place) {
    if (_saving) return;
    _originPlace = place;
    publish();
  }

  void selectDestination(MapLocation? place) {
    if (_saving) return;
    _destinationPlace = place;
    publish();
  }

  void setLocations(MapLocation? origin, MapLocation? destination) {
    if (_saving) return;
    _originPlace = origin;
    _destinationPlace = destination;
    publish();
  }

  String? _location(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Lokasi wajib diisi';
    if (text.length < 3) return 'Lokasi minimal 3 karakter';
    return null;
  }

  String? validateOrigin(String? value) =>
      _location(value) ??
      (_originPlace == null ? 'Pilih saran tempat atau pin di peta' : null);

  String? validateDestination(String? value, String originText) {
    final invalid = _location(value);
    if (invalid != null) return invalid;
    if (value!.trim().toLowerCase() == originText.trim().toLowerCase() &&
        (_originPlace == null ||
            _destinationPlace == null ||
            _originPlace!.point.distanceTo(_destinationPlace!.point) < 50)) {
      return 'Tujuan harus berbeda dari asal';
    }
    if (_destinationPlace == null) return 'Pilih saran tempat atau pin di peta';
    if (_originPlace != null &&
        _originPlace!.point.distanceTo(_destinationPlace!.point) < 50) {
      return 'Asal dan tujuan minimal 50 meter';
    }
    return null;
  }

  String? validateDeparture(String? value) =>
      parseDepartureMinute(value ?? '') == null
      ? 'Gunakan jam 00.00–23.59'
      : null;

  String? validateSeats(String? value) {
    final seats = int.tryParse(value?.trim() ?? '');
    if (seats == null || seats < 1 || seats > 8) return 'Isi 1–8 kursi';
    final initial = initialRide;
    if (initial != null &&
        seats < initial.seatCapacity - initial.seatsAvailable) {
      return 'Kurang dari kursi terisi';
    }
    return null;
  }

  Future<Ride?> save({
    required String origin,
    required String destination,
    required String departure,
    required String seats,
  }) async {
    if (isDisposed || _saving) return null;
    _error =
        validateOrigin(origin) ??
        validateDestination(destination, origin) ??
        validateDeparture(departure) ??
        validateSeats(seats);
    if (_error != null) {
      publish();
      return null;
    }
    final generation = ++_saveGeneration;
    final from = _originPlace!;
    final to = _destinationPlace!;
    final minute = parseDepartureMinute(departure)!;
    final time =
        '${(minute ~/ 60).toString().padLeft(2, '0')}.'
        '${(minute % 60).toString().padLeft(2, '0')}';
    final capacity = int.parse(seats.trim());
    _saving = true;
    publish();
    try {
      final road = await service.routeBetween(from.point, to.point);
      // Back/dispose cancels the commit, even during a reverse route animation.
      if (isDisposed || generation != _saveGeneration) return null;
      final geography = RideGeography(
        origin: from,
        destination: to,
        route: road,
      );
      final initial = initialRide;
      final Ride result;
      if (initial == null) {
        result = repository.post(
          driverName: driverName,
          origin: origin.trim(),
          destination: destination.trim(),
          departureTime: time,
          capacity: capacity,
          geography: geography,
        );
      } else {
        result = initial.copyWith(
          origin: origin.trim(),
          destination: destination.trim(),
          departureTime: time,
          seatCapacity: capacity,
          geography: geography,
        );
        repository.updateOwned(result);
      }
      _saving = false;
      publish();
      // Repository adjusts availability against the latest occupied seats.
      return repository.rides.firstWhere((ride) => ride.id == result.id);
    } catch (error) {
      if (isDisposed || generation != _saveGeneration) return null;
      _saving = false;
      _error = error is MapServiceException
          ? error.message
          : error is StateError
          ? error.message
          : 'Rute gagal disimpan. Coba lagi.';
      publish();
      return null;
    }
  }

  void cancelSave() {
    _saveGeneration++;
    _saving = false;
    publish();
  }
}
