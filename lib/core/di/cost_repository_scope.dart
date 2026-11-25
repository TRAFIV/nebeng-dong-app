import 'package:flutter/material.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';

/// Satu repository ongkos per sesi aplikasi, supaya deklarasi "Sudah bayar"
/// terlihat sama di Riwayat, Rincian dan Status Pembayaran.
/// Owns only repositories created here; injected instances belong to callers.
class CostRepositoryProvider extends StatefulWidget {
  const CostRepositoryProvider({
    super.key,
    this.repository,
    required this.child,
  });
  final CostRepository? repository;
  final Widget child;
  @override
  State<CostRepositoryProvider> createState() => _CostRepositoryProviderState();
}

class _CostRepositoryProviderState extends State<CostRepositoryProvider> {
  late CostRepository _repository;
  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalCostRepository();
  }

  @override
  void didUpdateWidget(CostRepositoryProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      if (oldWidget.repository == null) _repository.dispose();
      _repository = widget.repository ?? LocalCostRepository();
    }
  }

  @override
  void dispose() {
    if (widget.repository == null) _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CostRepositoryScope(repository: _repository, child: widget.child);
}

class CostRepositoryScope extends InheritedWidget {
  const CostRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });
  final CostRepository repository;
  static CostRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CostRepositoryScope>()
      ?.repository;
  @override
  bool updateShouldNotify(CostRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
