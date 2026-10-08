import 'dart:async';

import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

class LocationPickerViewModel extends ViewModel {
  LocationPickerViewModel({required this.service, MapLocation? initialLocation})
    : _selected = initialLocation,
      _address = initialLocation?.address ?? '',
      _label = initialLocation?.label ?? '';

  final MapService service;
  Timer? _reverseDebounce;
  int _generation = 0;
  bool _resolving = false;
  String? _addressError;
  MapLocation? _selected;
  String _address;
  String _label;
  MapLocation? get selected => _selected;
  String get address => _address;
  String get label => _label;
  bool get resolving => _resolving;
  String? get addressError => _addressError;
  bool get canConfirm =>
      _selected != null && !_resolving && _address.trim().isNotEmpty;

  void _invalidate() {
    _reverseDebounce?.cancel();
    _generation++;
  }

  void placePin(GeoPoint point) {
    if (isDisposed) return;
    _invalidate();
    final generation = _generation;
    _selected = MapLocation.pin(point);
    _address = '';
    _resolving = true;
    _addressError = null;
    publish();
    _reverseDebounce = Timer(
      const Duration(milliseconds: 650),
      () => _resolveAddress(point, generation),
    );
  }

  Future<void> _resolveAddress(GeoPoint point, int generation) async {
    try {
      final place = await service.reverseGeocode(point);
      if (isDisposed || generation != _generation) return;
      _resolving = false;
      if (place == null || place.address.trim().isEmpty) {
        _addressError =
            'Alamat belum ditemukan. Geser pin atau isi alamatnya sendiri.';
      } else {
        _selected = MapLocation(
          label: place.label,
          address: place.address,
          point: point,
          sourceId: place.sourceId,
        );
        _address = place.address;
      }
    } catch (error) {
      if (isDisposed || generation != _generation) return;
      _resolving = false;
      _addressError = error is MapServiceException
          ? error.message
          : 'Alamat gagal dimuat. Isi alamat atau coba lagi.';
    }
    publish();
  }

  void selectPlace(MapLocation place) {
    _invalidate();
    _selected = place;
    _label = place.label;
    _address = place.address;
    _addressError = null;
    _resolving = false;
    publish();
  }

  void setAddress(String value) {
    _invalidate();
    _address = value;
    _resolving = false;
    _addressError = null;
    publish();
  }

  void setLabel(String value) {
    _label = value;
    publish();
  }

  void retry() {
    if (_selected != null) placePin(_selected!.point);
  }

  MapLocation? confirm() {
    if (isDisposed || !canConfirm) return null;
    return MapLocation(
      label: _label.trim().isEmpty ? _address.trim() : _label.trim(),
      address: _address.trim(),
      point: _selected!.point,
      sourceId: _selected!.sourceId,
    );
  }

  @override
  void dispose() {
    _invalidate();
    super.dispose();
  }
}
