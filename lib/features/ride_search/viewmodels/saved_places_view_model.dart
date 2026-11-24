import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/core/app_clock.dart';
import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/ride_search/data/saved_places_store.dart';
import 'package:praktikum_mobile/features/ride_search/models/saved_place.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

/// Daftar "Tempat tujuan" di Cari: muat, tambah, hapus.
class SavedPlacesViewModel extends ViewModel {
  SavedPlacesViewModel({required this.store});

  final SavedPlacesStore store;

  /// Batas agar baris pintasan tetap muat satu layar.
  static const maxPlaces = 3;
  static const maxNameLength = 20;

  List<SavedPlace> _places = const [];
  bool _loaded = false;
  String? _errorMessage;

  List<SavedPlace> get places => List.unmodifiable(_places);
  bool get loaded => _loaded;
  bool get canAdd => _places.length < maxPlaces;

  /// Pesan bila simpan/hapus gagal; dibaca View untuk SnackBar.
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    try {
      final places = await store.load();
      if (isDisposed) return;
      _places = places.take(maxPlaces).toList();
    } catch (error) {
      debugPrint('Gagal memuat tempat tujuan: $error');
      _places = List.of(defaultSavedPlaces);
    }
    _loaded = true;
    publish();
  }

  /// Label saran sesuai jam: kampus di pagi hari, rumah/kos di sore hari.
  String? hintFor(SavedPlace place) {
    final hour = AppClock.now().hour;
    return switch (place.kind) {
      SavedPlaceKind.campus when hour >= 5 && hour < 12 => 'Pagi ini',
      SavedPlaceKind.home when hour >= 14 && hour < 22 => 'Sore ini',
      _ => null,
    };
  }

  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Kasih nama dulu, mis. Rumah atau Kos';
    if (name.length > maxNameLength) {
      return 'Nama maksimal $maxNameLength karakter';
    }
    final taken = _places.any(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
    if (taken) return 'Nama ini sudah dipakai';
    return null;
  }

  /// `true` bila tersimpan. Gagal validasi atau penyimpanan mengisi
  /// [errorMessage].
  Future<bool> add(String name, MapLocation location) async {
    if (isDisposed || !canAdd || validateName(name) != null) return false;
    final next = [
      ..._places,
      SavedPlace(name: name.trim(), location: location),
    ];
    return _commit(next);
  }

  Future<bool> remove(SavedPlace place) =>
      _commit(_places.where((p) => !identical(p, place)).toList());

  Future<bool> _commit(List<SavedPlace> next) async {
    final previous = _places;
    _places = next;
    _errorMessage = null;
    publish();
    try {
      await store.save(next);
      return true;
    } catch (error) {
      debugPrint('Gagal menyimpan tempat tujuan: $error');
      if (isDisposed) return false;
      _places = previous;
      _errorMessage = 'Tempat belum tersimpan. Coba lagi ya.';
      publish();
      return false;
    }
  }
}
