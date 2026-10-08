import 'package:flutter/foundation.dart';

import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/shared/utils/validators.dart';

/// Local login only: this is not server authentication.
const campusEmailDomain = 'unand.ac.id';

class LoginViewModel extends ViewModel {
  static final _campusPattern = RegExp(
    '^[^@\\s]+@([a-z0-9-]+\\.)*${RegExp.escape(campusEmailDomain)}\$',
    caseSensitive: false,
  );

  String? validateEmail(String? value) {
    final invalid = Validators.email(value);
    if (invalid != null) return invalid;
    if (!_campusPattern.hasMatch(value!.trim())) {
      return 'Pakai email kampus ($campusEmailDomain), ya!';
    }
    return null;
  }

  String? validatePassword(String? value) => Validators.password(value);

  String? login({required String email, required String password}) {
    if (isDisposed ||
        validateEmail(email) != null ||
        validatePassword(password) != null) {
      return null;
    }
    final name = email.trim().split('@').first.split('.').first;
    return name.isEmpty ? 'Kamu' : name[0].toUpperCase() + name.substring(1);
  }

  // Guard both here and in the View: never bypass login in release/profile.
  String? devLogin() => !isDisposed && kDebugMode ? 'Mikail' : null;
}
