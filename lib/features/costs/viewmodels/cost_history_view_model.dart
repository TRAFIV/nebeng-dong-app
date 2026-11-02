import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';

enum CostViewStatus { loading, success, error }

/// State layar Ongkos: Riwayat Ongkos (FR-12) dan perjalanan yang akan datang.
class CostHistoryViewModel extends ViewModel {
  CostHistoryViewModel({required this.repository, this.simulateError = false}) {
    repository.addListener(_refresh);
  }

  final CostRepository repository;
  final bool simulateError;

  CostViewStatus _status = CostViewStatus.loading;
  String _errorMessage = '';
  List<CostShare> _history = const [];
  List<CostShare> _upcoming = const [];
  int _loadGeneration = 0;

  CostViewStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isSimulation => repository.isSimulation;

  /// Perjalanan selesai, terbaru dulu.
  List<CostShare> get history => _history;

  /// Perjalanan diterima tapi belum selesai; ongkosnya masih estimasi.
  List<CostShare> get upcoming => _upcoming;

  bool get isEmpty => _history.isEmpty && _upcoming.isEmpty;

  Future<void> load() async {
    if (isDisposed) return;
    final generation = ++_loadGeneration;
    _status = CostViewStatus.loading;
    _errorMessage = '';
    publish();
    try {
      final shares = await repository.fetchCostShares(
        simulateError: simulateError,
      );
      if (isDisposed || generation != _loadGeneration) return;
      _split(shares);
      _status = CostViewStatus.success;
    } catch (error) {
      if (isDisposed || generation != _loadGeneration) return;
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      _status = CostViewStatus.error;
    }
    publish();
  }

  void _refresh() {
    if (isDisposed || _status != CostViewStatus.success) return;
    _split(repository.costShares);
    publish();
  }

  void _split(List<CostShare> shares) {
    final history = shares.where((share) => share.tripCompleted).toList()
      ..sort((a, b) => b.tripDate.compareTo(a.tripDate));
    final upcoming = shares.where((share) => !share.tripCompleted).toList()
      ..sort((a, b) => a.tripDate.compareTo(b.tripDate));
    _history = List.unmodifiable(history);
    _upcoming = List.unmodifiable(upcoming);
  }

  @override
  void dispose() {
    repository.removeListener(_refresh);
    super.dispose();
  }
}
