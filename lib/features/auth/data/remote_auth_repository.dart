import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/core/network/api_client.dart';
import 'package:praktikum_mobile/core/network/api_exception.dart';
import 'package:praktikum_mobile/core/network/json_reader.dart';
import 'package:praktikum_mobile/core/network/token_store.dart';
import 'package:praktikum_mobile/features/auth/data/auth_repository.dart';
import 'package:praktikum_mobile/features/auth/models/auth_user.dart';

/// Login lewat server; token disimpan di [TokenStore] dan dipakai
/// [ApiClient] untuk header `Authorization`.
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStore _tokens;

  @override
  bool get usesServer => true;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final json = await _api.post(
      'auth/login',
      body: {'email': email.trim(), 'password': password},
    );
    final data = asJsonMap(json);
    final user = parseResponse(data.read<Object>('user'), authUserFromJson);
    await _tokens.save(data.read<String>('token'));
    return user;
  }

  @override
  Future<AuthUser?> restore() async {
    final token = await _tokens.read();
    if (token == null || token.isEmpty) return null;
    try {
      final json = await _api.get('me');
      return parseResponse<AuthUser>(json, authUserFromJson);
    } on ApiException catch (error) {
      // Token kedaluwarsa/dicabut: hapus agar layar Login tampil bersih.
      if (error.kind == ApiErrorKind.unauthorized) await _tokens.clear();
      // Server tidak terjangkau: token disimpan, penumpang masuk lagi nanti.
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post('auth/logout');
    } on ApiException catch (error) {
      // Tetap keluar di HP walau server tidak bisa dihubungi.
      debugPrint('Token belum dicabut di server: ${error.message}');
    } finally {
      await _tokens.clear();
    }
  }
}

/// `{id, name, email, role}` dari `UserResource` server.
AuthUser authUserFromJson(Object? value) {
  final json = asJsonMap(value);
  return AuthUser(
    id: json.read<Object>('id').toString(),
    name: json.read<String>('name'),
    email: json.readOrNull<String>('email'),
  );
}
