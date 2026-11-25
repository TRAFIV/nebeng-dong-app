import 'package:shared_preferences/shared_preferences.dart';

/// Tempat menyimpan token login yang dikirim server.
///
/// [ApiClient] membacanya untuk header `Authorization`; alur Login yang
/// menyimpan dan menghapusnya.
abstract interface class TokenStore {
  Future<String?> read();
  Future<void> save(String token);
  Future<void> clear();
}

/// Untuk tes: token hanya ada selama objek hidup.
class MemoryTokenStore implements TokenStore {
  MemoryTokenStore([this._token]);
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> save(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

/// Token tetap tersimpan setelah aplikasi ditutup.
///
/// SharedPreferences tidak terenkripsi; sebelum rilis, ganti implementasi ini
/// dengan penyimpanan aman (misalnya flutter_secure_storage) tanpa mengubah
/// pemakainya.
class SharedPreferencesTokenStore implements TokenStore {
  static const _key = 'auth_token';

  @override
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  @override
  Future<void> save(String token) async =>
      (await SharedPreferences.getInstance()).setString(_key, token);

  @override
  Future<void> clear() async =>
      (await SharedPreferences.getInstance()).remove(_key);
}
