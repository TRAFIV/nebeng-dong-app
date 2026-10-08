import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

class RideDetailViewModel extends ViewModel {
  RideDetailViewModel({required this.ride});
  final Ride ride;
  bool _requestSent = false;
  String? _note;
  bool get requestSent => _requestSent;
  String? get note => _note;
  bool get canRequest => !ride.isFull && !_requestSent;
  String get buttonLabel => ride.isFull
      ? 'Yah, Udah Penuh'
      : _requestSent
      ? 'Nunggu di-ACC...'
      : 'Ikut Nebeng!';

  String? validatePickup(String? value) => value == null || value.trim().isEmpty
      ? 'Titik jemputnya diisi dulu, ya'
      : null;

  bool requestToJoin(String pickup) {
    if (isDisposed || !canRequest || validatePickup(pickup) != null) {
      return false;
    }
    // Local presentation only; no booking/approval API is available yet.
    _requestSent = true;
    publish();
    return true;
  }

  void saveNote(String value) {
    _note = value;
    publish();
  }
}
