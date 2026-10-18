import 'package:praktikum_mobile/core/view_model.dart';

import '../data/rating_repository.dart';
import '../models/trip_rating.dart';

class RatingHistoryViewModel extends ViewModel {
  RatingHistoryViewModel({required this.repository, required this.userId});
  final RatingRepository repository;
  final String userId;
  bool _loading = false;
  bool get loading => _loading;
  bool _onlyUnrated = false;
  bool get onlyUnrated => _onlyUnrated;
  String? _error;
  String? get error => _error;
  List<RatingTrip> get trips => List.unmodifiable(
    repository
        .tripsFor(userId)
        .where(
          (trip) =>
              !_onlyUnrated || (trip.completed && ratingFor(trip) == null),
        ),
  );
  TripRating? ratingFor(RatingTrip trip) => repository.forTrip(trip, userId);

  void filter(bool onlyUnrated) {
    if (isDisposed || _loading) return;
    _onlyUnrated = onlyUnrated;
    publish();
  }

  // Return to Semua so the just-saved stars stay visible on the same trip card.
  void showSavedResult() => filter(false);

  Future<void> load() async {
    if (isDisposed || _loading) return;
    _loading = true;
    _error = null;
    publish();
    try {
      await repository.load();
    } catch (_) {
      _error = 'Riwayat belum bisa dibaca. Coba lagi, ya.';
    } finally {
      _loading = false;
      publish();
    }
  }

  Future<bool> resetDemo() async {
    if (isDisposed || _loading) return false;
    _loading = true;
    publish();
    try {
      await repository.resetDemo();
      _error = null;
      _onlyUnrated = false;
      return !isDisposed;
    } catch (_) {
      return false;
    } finally {
      _loading = false;
      publish();
    }
  }
}
