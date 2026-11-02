import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip_rating.dart';
import 'rating_repository.dart';
import 'sample_rating_trips.dart';

abstract class RatingStorage {
  Future<String?> read();
  Future<void> write(String value);
}

class LocalRatingStorage implements RatingStorage {
  static const storageKey = 'nebeng_dong_duha_passenger_rating_demo_v2';
  @override
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(storageKey);
  @override
  Future<void> write(String value) async {
    final ok = await (await SharedPreferences.getInstance()).setString(
      storageKey,
      value,
    );
    if (!ok) throw StateError('Penyimpanan lokal gagal');
  }
}

class LocalRatingRepository implements RatingRepository {
  LocalRatingRepository(
    this.storage, {
    this.delay = const Duration(milliseconds: 500),
    this.failNextSave = false,
    List<RatingTrip> trips = sampleRatingTrips,
  }) : _trips = List.unmodifiable(trips);
  final List<RatingTrip> _trips;
  @override
  List<RatingTrip> tripsFor(String userId) =>
      List.unmodifiable(_trips.where((trip) => trip.passengerId == userId));
  final RatingStorage storage;
  final Duration delay;
  bool failNextSave;
  bool _busy = false;
  bool _loaded = false;
  Map<String, TripRating> _ratings = {};

  @override
  Future<void> load() async {
    if (_busy) {
      throw const RatingException('Tunggu sampai penyimpanan selesai.');
    }
    _busy = true;
    try {
      await _read();
    } finally {
      _busy = false;
    }
  }

  Future<void> _read() async {
    final raw = await storage.read();
    final items = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
    final parsed = items.map(
      (e) => TripRating.fromJson(e as Map<String, dynamic>),
    );
    _ratings = {for (final r in parsed) r.key: r};
    _loaded = true;
  }

  @override
  TripRating? forTrip(RatingTrip trip, String userId) =>
      _ratings['${trip.id}/$userId/${trip.driverId}'];

  @override
  Future<TripRating> save({
    required RatingTrip trip,
    required String userId,
    required int score,
    required String comment,
  }) async {
    if (_busy) {
      throw const RatingException(
        'Rating sedang disimpan. Tunggu sebentar, ya.',
      );
    }
    // Only repository-owned trip data can determine local eligibility.
    final matches = _trips.where((item) => item.id == trip.id);
    if (matches.length != 1 ||
        matches.single.passengerId != userId ||
        matches.single.driverId != trip.driverId) {
      throw const RatingException('Perjalanan ini bukan milikmu.');
    }
    trip = matches.single;
    if (!trip.completed) {
      throw const RatingException(
        'Rating baru bisa diberikan setelah perjalanan selesai.',
      );
    }
    if (userId.isEmpty || trip.driverId.isEmpty || userId == trip.driverId) {
      throw const RatingException('Pengemudi perjalanan tidak valid.');
    }
    if (score < 1 || score > 5) {
      throw const RatingException('Pilih bintang dulu, ya!');
    }
    if (comment.trim().length > 200) {
      throw const RatingException('Komentar maksimal 200 karakter.');
    }
    _busy = true;
    try {
      if (!_loaded) await _read();
      if (forTrip(trip, userId) != null) {
        throw const RatingException('Perjalanan ini sudah kamu nilai.');
      }
      await Future<void>.delayed(delay);
      if (failNextSave) {
        failNextSave = false;
        throw StateError('Simulasi kegagalan penyimpanan');
      }
      final rating = TripRating(
        tripId: trip.id,
        raterId: userId,
        targetId: trip.driverId,
        score: score,
        comment: comment.trim(),
      );
      final updated = {..._ratings, rating.key: rating};
      await storage.write(
        jsonEncode(updated.values.map((r) => r.toJson()).toList()),
      );
      // State baru diterapkan setelah penyimpanan benar-benar berhasil.
      _ratings = updated;
      return rating;
    } finally {
      _busy = false;
    }
  }

  @override
  Future<void> resetDemo() async {
    if (_busy) {
      throw const RatingException('Tunggu sampai penyimpanan selesai.');
    }
    _busy = true;
    try {
      await storage.write('[]');
      _ratings = {};
      _loaded = true;
    } finally {
      _busy = false;
    }
  }
}
