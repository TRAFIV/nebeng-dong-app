import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

class MyRoutesViewModel extends ViewModel {
  MyRoutesViewModel({required this.repository}) {
    repository.addListener(publish);
  }
  final LegacyDriverRepository repository;
  bool _managing = false;
  bool get managing => _managing;
  List<Ride> get rides => repository.ownedRides;

  void toggleManaging() {
    _managing = !_managing;
    publish();
  }

  String delete(Ride ride) {
    try {
      repository.deleteOwned(ride.id);
      return 'Rute berhasil dihapus';
    } on StateError catch (error) {
      return error.message;
    }
  }

  @override
  void dispose() {
    repository.removeListener(publish);
    super.dispose();
  }
}
