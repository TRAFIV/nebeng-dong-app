import 'package:flutter/foundation.dart';

import 'package:praktikum_mobile/core/network/api_exception.dart';
import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/auth/data/auth_repository.dart';
import 'package:praktikum_mobile/features/auth/models/auth_user.dart';
import 'package:praktikum_mobile/shared/utils/validators.dart';

/// Domain email kampus yang diterima.
const campusEmailDomain = 'unand.ac.id';

/// Akun penumpang demo di server (server/README.md); hanya untuk
/// "Masuk cepat (Dev)" di build debug.
const _demoEmail = 'mikail@student.unand.ac.id';
const _demoPassword = 'nebengdong';

/// Login penumpang (FR-17): validasi isian, masuk lewat [AuthRepository],
/// dan memulihkan sesi dari token tersimpan.
class LoginViewModel extends ViewModel {
  LoginViewModel({this.repository = const LocalAuthRepository()});

  final AuthRepository repository;

  static final _campusPattern = RegExp(
    '^[^@\\s]+@([a-z0-9-]+\\.)*${RegExp.escape(campusEmailDomain)}\$',
    caseSensitive: false,
  );

  bool _submitting = false;
  bool _restoring = false;
  String? _errorMessage;

  bool get submitting => _submitting;

  /// Sedang memeriksa sesi tersimpan saat aplikasi dibuka.
  bool get restoring => _restoring;
  bool get busy => _submitting || _restoring;

  /// Penolakan dari server (mis. kata sandi salah) atau masalah koneksi.
  String? get errorMessage => _errorMessage;

  String? validateEmail(String? value) {
    final invalid = Validators.email(value);
    if (invalid != null) return invalid;
    if (!_campusPattern.hasMatch(value!.trim())) {
      return 'Pakai email kampus ($campusEmailDomain), ya!';
    }
    return null;
  }

  String? validatePassword(String? value) => Validators.password(value);

  /// `null` bila isian tidak sah atau server menolak ([errorMessage] terisi).
  Future<AuthUser?> login({
    required String email,
    required String password,
  }) async {
    if (isDisposed ||
        busy ||
        validateEmail(email) != null ||
        validatePassword(password) != null) {
      return null;
    }
    return _attempt(() => repository.login(email: email, password: password));
  }

  /// Pintasan khusus debug: di server memakai akun demo, tanpa server
  /// langsung masuk sebagai Mikail. Tidak pernah aktif di rilis.
  Future<AuthUser?> devLogin() async {
    if (isDisposed || busy || !kDebugMode) return null;
    if (!repository.usesServer) return const AuthUser(name: 'Mikail');
    return _attempt(
      () => repository.login(email: _demoEmail, password: _demoPassword),
    );
  }

  /// Sesi dari token tersimpan; `null` bila harus masuk lagi.
  Future<AuthUser?> restoreSession() async {
    if (isDisposed || busy || !repository.usesServer) return null;
    _restoring = true;
    publish();
    try {
      return await repository.restore();
    } catch (error) {
      debugPrint('Sesi tersimpan tidak bisa dipulihkan: $error');
      return null;
    } finally {
      _restoring = false;
      publish();
    }
  }

  Future<AuthUser?> _attempt(Future<AuthUser> Function() action) async {
    _submitting = true;
    _errorMessage = null;
    publish();
    try {
      return await action();
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (error) {
      debugPrint('Login gagal: $error');
      _errorMessage = 'Belum bisa masuk. Coba lagi sebentar ya.';
      return null;
    } finally {
      _submitting = false;
      publish();
    }
  }
}
