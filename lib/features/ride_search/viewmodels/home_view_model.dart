import 'package:praktikum_mobile/core/app_clock.dart';
import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

/// Form state only. Fetch/matching/loading belong to RideResultsViewModel.
class HomeViewModel extends ViewModel {
  MapLocation? _originPlace;
  MapLocation? _destinationPlace;
  RideFilter _filter = const RideFilter();
  RideSearchRequest? _request;
  int _swapCount = 0;
  DateTime _date = AppClock.today();
  int? _time;
  MapLocation? get originPlace => _originPlace;

  /// Tanggal berangkat; bawaan hari ini. Bisa dipilih sampai [maxDaysAhead].
  DateTime get date => _date;

  /// Jam berangkat (menit-dalam-hari); `null` = semua jam.
  int? get time => _time;

  static const maxDaysAhead = 7;

  /// Pilihan tanggal: hari ini sampai 7 hari ke depan.
  List<DateTime> get dateOptions {
    final today = AppClock.today();
    return [
      for (var i = 0; i <= maxDaysAhead; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
  }

  /// Berapa kali Dari/Ke ditukar; View memutar ikon tukar setengah putaran
  /// tiap kali.
  int get swapCount => _swapCount;
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

  void setDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final options = dateOptions;
    if (day.isBefore(options.first) || day.isAfter(options.last)) return;
    _date = day;
    publish();
  }

  void setTime(int? minuteOfDay) {
    if (minuteOfDay != null && (minuteOfDay < 0 || minuteOfDay >= 24 * 60)) {
      return;
    }
    _time = minuteOfDay;
    publish();
  }

  /// Dipakai saat ViewModel dibuat ulang (repository berganti).
  void restoreWhen(DateTime date, int? time) {
    _date = date;
    _time = time;
  }

  void swapLocations() {
    final origin = _originPlace;
    _originPlace = _destinationPlace;
    _destinationPlace = origin;
    _swapCount++;
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
      date: _date,
      time: _time,
    );
    return null;
  }
}
