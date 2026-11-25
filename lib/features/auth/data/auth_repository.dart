import 'package:praktikum_mobile/features/auth/models/auth_user.dart';

/// Kontrak login penumpang (FR-17).
///
/// Versi server memakai `POST /auth/login`, `GET /me`, `POST /auth/logout`
/// (docs/api/kontrak-api.md). Versi lokal dipakai saat server tidak diisi.
abstract class AuthRepository {
  /// `true` bila login diperiksa server (token tersimpan).
  bool get usesServer;

  /// Melempar `ApiException` bila server menolak (mis. 422 kata sandi salah).
  Future<AuthUser> login({required String email, required String password});

  /// Sesi yang masih berlaku dari token tersimpan; `null` bila tidak ada.
  Future<AuthUser?> restore();

  /// Mencabut token di server (bila bisa) dan menghapusnya dari HP.
  Future<void> logout();
}

/// Tanpa server: nama diambil dari email, tidak ada sesi tersimpan.
/// Bukan autentikasi; hanya untuk latihan dan tes.
class LocalAuthRepository implements AuthRepository {
  const LocalAuthRepository();

  @override
  bool get usesServer => false;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final local = email.trim().split('@').first.split('.').first;
    final name = local.isEmpty
        ? 'Kamu'
        : local[0].toUpperCase() + local.substring(1);
    return AuthUser(name: name, email: email.trim());
  }

  @override
  Future<AuthUser?> restore() async => null;

  @override
  Future<void> logout() async {}
}
