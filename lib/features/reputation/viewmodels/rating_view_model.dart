import 'package:praktikum_mobile/core/view_model.dart';

import '../data/rating_repository.dart';
import '../models/trip_rating.dart';

class RatingViewModel extends ViewModel {
  RatingViewModel({
    required this.repository,
    required this.trip,
    required this.userId,
  });
  final RatingRepository repository;
  final RatingTrip trip;
  final String userId;
  int _score = 0;
  int get score => _score;
  bool _saving = false;
  bool get saving => _saving;
  String? _error;
  String? get error => _error;

  void selectScore(int value) {
    if (isDisposed || _saving) return;
    if (value < 1 || value > 5) return;
    _score = value;
    _error = null;
    publish();
  }

  Future<TripRating?> submit(String comment) async {
    if (isDisposed || _saving) return null;
    _error = _score < 1 || _score > 5
        ? 'Pilih bintang dulu, ya!'
        : comment.trim().length > 200
        ? 'Komentar maksimal 200 karakter.'
        : null;
    if (_error != null) {
      publish();
      return null;
    }
    _saving = true;
    publish();
    try {
      final result = await repository.save(
        trip: trip,
        userId: userId,
        score: _score,
        comment: comment,
      );
      return isDisposed ? null : result;
    } on RatingException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Rating belum tersimpan. Pilihanmu tetap ada, coba kirim lagi.';
    } finally {
      _saving = false;
      publish();
    }
    return null;
  }
}
