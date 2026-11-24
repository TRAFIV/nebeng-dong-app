import 'package:flutter/widgets.dart';
import 'package:praktikum_mobile/core/di/api_client_scope.dart';
import 'package:praktikum_mobile/features/auth/data/auth_repository.dart';
import 'package:praktikum_mobile/features/auth/data/remote_auth_repository.dart';

/// Menyediakan [AuthRepository]: server bila [ApiClientScope] berisi klien,
/// selain itu versi lokal. Repository suntikan milik pemanggilnya.
class AuthRepositoryProvider extends StatefulWidget {
  const AuthRepositoryProvider({
    super.key,
    this.repository,
    required this.child,
  });

  final AuthRepository? repository;
  final Widget child;

  @override
  State<AuthRepositoryProvider> createState() => _AuthRepositoryProviderState();
}

class _AuthRepositoryProviderState extends State<AuthRepositoryProvider> {
  AuthRepository? _owned;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.repository == null) _owned ??= _createDefault();
  }

  AuthRepository _createDefault() {
    final api = ApiClientScope.maybeOf(context);
    final tokens = ApiClientScope.tokenStoreOf(context);
    return api == null || tokens == null
        ? const LocalAuthRepository()
        : RemoteAuthRepository(api, tokens);
  }

  @override
  Widget build(BuildContext context) => AuthRepositoryScope(
    repository: widget.repository ?? _owned!,
    child: widget.child,
  );
}

class AuthRepositoryScope extends InheritedWidget {
  const AuthRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final AuthRepository repository;

  static AuthRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AuthRepositoryScope>()
      ?.repository;

  @override
  bool updateShouldNotify(AuthRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
