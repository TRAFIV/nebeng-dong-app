import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/models/saved_place.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan tempat tujuan penumpang. Hanya di HP; tidak ada endpoint server.
abstract class SavedPlacesStore {
  Future<List<SavedPlace>> load();
  Future<void> save(List<SavedPlace> places);
}

/// Isi awal sebelum penumpang menyimpan apa pun: kampus.
final defaultSavedPlaces = List<SavedPlace>.unmodifiable([
  SavedPlace(name: 'Kampus', location: unandPlace),
]);

/// Disimpan sebagai JSON di SharedPreferences.
class LocalSavedPlacesStore implements SavedPlacesStore {
  static const storageKey = 'nebeng_dong_saved_places_v1';

  @override
  Future<List<SavedPlace>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(storageKey);
    if (raw == null) return defaultSavedPlaces;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return defaultSavedPlaces;
      return decoded.map(SavedPlace.fromJson).whereType<SavedPlace>().toList();
    } on FormatException catch (error) {
      // Data rusak tidak boleh membuat Cari gagal; mulai lagi dari isi awal.
      debugPrint('Tempat tersimpan tidak terbaca: $error');
      return defaultSavedPlaces;
    }
  }

  @override
  Future<void> save(List<SavedPlace> places) async {
    final ok = await (await SharedPreferences.getInstance()).setString(
      storageKey,
      jsonEncode([for (final place in places) place.toJson()]),
    );
    if (!ok) throw StateError('Tempat tujuan gagal disimpan');
  }
}

/// Untuk tes dan pratinjau: tersimpan di memori saja.
class MemorySavedPlacesStore implements SavedPlacesStore {
  MemorySavedPlacesStore([List<SavedPlace>? places])
    : _places = List.of(places ?? defaultSavedPlaces);
  List<SavedPlace> _places;

  @override
  Future<List<SavedPlace>> load() async => List.of(_places);

  @override
  Future<void> save(List<SavedPlace> places) async => _places = List.of(places);
}
