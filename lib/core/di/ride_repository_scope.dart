import 'package:flutter/material.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';

/// Owns only repositories created here; injected instances belong to callers.
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
  late RideRepository _repository;
  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalRideRepository();
  }

  @override
  void didUpdateWidget(RideRepositoryProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      if (oldWidget.repository == null) _repository.dispose();
      _repository = widget.repository ?? LocalRideRepository();
    }
  }

  @override
  void dispose() {
    if (widget.repository == null) _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RideRepositoryScope(repository: _repository, child: widget.child);
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
