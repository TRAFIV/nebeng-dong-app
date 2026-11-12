import 'package:flutter/material.dart';
import 'package:praktikum_mobile/core/di/api_client_scope.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/remote_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';

/// Owns only repositories created here; injected instances belong to callers.
///
/// Tanpa repository suntikan: pakai server bila [ApiClientScope] berisi klien
/// (`API_BASE_URL` diisi), selain itu data latihan lokal.
class RideRepositoryProvider extends StatefulWidget {
  const RideRepositoryProvider({
    super.key,
    this.repository,
    required this.child,
  });
  final RideRepository? repository;
  final Widget child;
  @override
  State<RideRepositoryProvider> createState() => _RideRepositoryProviderState();
}

class _RideRepositoryProviderState extends State<RideRepositoryProvider> {
  RideRepository? _owned;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.repository == null) _owned ??= _createDefault();
  }

  RideRepository _createDefault() {
    final api = ApiClientScope.maybeOf(context);
    return api == null ? LocalRideRepository() : RemoteRideRepository(api);
  }

  @override
  void didUpdateWidget(RideRepositoryProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      if (widget.repository != null) {
        _owned?.dispose();
        _owned = null;
      } else {
        _owned ??= _createDefault();
      }
    }
  }

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RideRepositoryScope(
    repository: widget.repository ?? _owned!,
    child: widget.child,
  );
}

class RideRepositoryScope extends InheritedWidget {
  const RideRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });
  final RideRepository repository;
  static RideRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<RideRepositoryScope>()
      ?.repository;
  @override
  bool updateShouldNotify(RideRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
