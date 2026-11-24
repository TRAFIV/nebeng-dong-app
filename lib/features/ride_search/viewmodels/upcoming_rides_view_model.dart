import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/core/app_clock.dart';
import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_schedule.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

enum UpcomingStatus { loading, success, error }

/// Satu tebengan yang akan cabut, dengan sisa waktunya.
class UpcomingRide {
  const UpcomingRide(this.ride, this.minutesUntil);
  final Ride ride;
  final int minutesUntil;
}

/// "Berangkat sebentar lagi" di Cari: tebengan hari ini yang belum cabut.
///
/// Terpisah dari HomeViewModel agar form Cari tidak pernah menunggu data
/// rute. Jadwal harian belum dibedakan per tanggal (menunggu server), jadi
/// yang dihitung hanya jam cabut hari ini.
class UpcomingRidesViewModel extends ViewModel {
  UpcomingRidesViewModel({
    required this.repository,
    DateTime Function()? now,
    this.limit = 5,
  }) : _now = now ?? AppClock.now;

  final RideRepository repository;
  final DateTime Function() _now;
  final int limit;

  UpcomingStatus _status = UpcomingStatus.loading;
  List<UpcomingRide> _rides = const [];
  int _generation = 0;

  UpcomingStatus get status => _status;
  List<UpcomingRide> get rides => List.unmodifiable(_rides);

  /// Muat sekali saat bagiannya pertama kali tampil.
  void ensureLoaded() {
    if (_generation == 0) load();
  }

  Future<void> load() async {
    if (isDisposed) return;
    final generation = ++_generation;
    // Status awal sudah loading: tanpa publish, aman dipanggil saat build.
    if (_status != UpcomingStatus.loading) {
      _status = UpcomingStatus.loading;
      publish();
    }
    try {
      final rides = await repository.fetchRides();
      if (isDisposed || generation != _generation) return;
      _rides = upcomingFrom(rides, _now(), limit: limit);
      _status = UpcomingStatus.success;
    } catch (error) {
      if (isDisposed || generation != _generation) return;
      debugPrint('Gagal memuat keberangkatan: $error');
      _status = UpcomingStatus.error;
    }
    publish();
  }

  /// Tebengan yang belum penuh dan cabut setelah [now], urut paling dekat.
  @visibleForTesting
  static List<UpcomingRide> upcomingFrom(
    Iterable<Ride> rides,
    DateTime now, {
    int limit = 5,
  }) {
    final current = now.hour * 60 + now.minute;
    final result = <UpcomingRide>[];
    for (final ride in rides) {
      final minute = parseDepartureMinute(ride.departureTime);
      if (ride.isFull || minute == null || minute <= current) continue;
      if (!rideRunsOn(ride, now)) continue;
      result.add(UpcomingRide(ride, minute - current));
    }
    result.sort((a, b) => a.minutesUntil.compareTo(b.minutesUntil));
    return result.take(limit).toList();
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }
}
