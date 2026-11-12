import 'dart:async';

import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

/// Autocomplete state independent of TextEditingController and navigation.
class LocationSearchViewModel extends ViewModel {
  factory LocationSearchViewModel({
    required MapService service,
    MapLocation? selected,
    List<MapLocation> quickPlaces = const [],
  }) => LocationSearchViewModel._(service, selected, quickPlaces);
  LocationSearchViewModel._(this._service, this._selected, this._quickPlaces);
  MapService _service;

  /// Tempat yang sudah dikenal aplikasi. Dicocokkan langsung tanpa internet,
  /// jadi tetap bisa dipilih walau layanan peta sedang lambat.
  final List<MapLocation> _quickPlaces;
  String _query = '';
  Timer? _debounce;
  int _generation = 0;
  MapLocation? _selected;
  List<MapLocation> _suggestions = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;
  MapLocation? get selected => _selected;
  List<MapLocation> get suggestions => List.unmodifiable(_suggestions);
  bool get loading => _loading;
  String? get error => _error;
  bool get searched => _searched;

  /// Saran cepat yang nama atau alamatnya memuat teks ketikan; semua jika kosong.
  List<MapLocation> get quickMatches {
    final query = _query.toLowerCase();
    return List.unmodifiable(
      _quickPlaces.where(
        (place) =>
            place.label.toLowerCase().contains(query) ||
            place.address.toLowerCase().contains(query),
      ),
    );
  }

  void clearSearch() {
    _debounce?.cancel();
    _generation++;
    _suggestions = [];
    _loading = false;
    _error = null;
    _searched = false;
    publish();
  }

  void setService(MapService service) {
    _service = service;
    clearSearch();
  }

  void syncSelection(MapLocation? place) {
    _selected = place;
    clearSearch();
  }

  void queryChanged(String text) {
    if (isDisposed) return;
    _selected = null;
    _query = text.trim();
    clearSearch();
    final query = _query;
    if (query.length < 3) return;
    final generation = _generation;
    _debounce = Timer(
      const Duration(milliseconds: 700),
      () => _search(query, generation),
    );
  }

  Future<void> searchNow(String text) async {
    if (isDisposed) return;
    clearSearch();
    await _search(text.trim(), _generation);
  }

  Future<void> _search(String query, int generation) async {
    if (isDisposed || generation != _generation || query.length < 3) return;
    _loading = true;
    publish();
    try {
      final result = await _service.searchPlaces(query);
      if (isDisposed || generation != _generation) return;
      _suggestions = List.of(result);
      _searched = true;
      _loading = false;
    } catch (error) {
      if (isDisposed || generation != _generation) return;
      _error = error is MapServiceException
          ? error.message
          : 'Pencarian tempat gagal. Coba lagi.';
      _loading = false;
    }
    publish();
  }

  void choose(MapLocation place) {
    _selected = place;
    clearSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _generation++;
    super.dispose();
  }
}
