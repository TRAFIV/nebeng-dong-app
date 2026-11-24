import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/auth/data/auth_repository.dart';

/// Keluar dari akun (FR-17). Navigasi ke Login diurus View.
class SessionViewModel extends ViewModel {
  SessionViewModel({required this.repository});

  final AuthRepository repository;

  bool _loggingOut = false;
  bool get loggingOut => _loggingOut;

  /// Selalu berakhir keluar di HP, walau server tidak bisa dihubungi.
  Future<void> logout() async {
    if (isDisposed || _loggingOut) return;
    _loggingOut = true;
    publish();
    try {
      await repository.logout();
    } finally {
      _loggingOut = false;
      publish();
    }
  }
}
