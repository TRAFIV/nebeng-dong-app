import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/data/fixtures/demo_cost_shares.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/features/costs/utils/payment_rules.dart';

/// Adapter in-memory untuk praktikum, bukan backend.
///
/// Deklarasi tersimpan selama sesi aplikasi saja dan tidak pernah berubah
/// sendiri menjadi terkonfirmasi.
class LocalCostRepository extends CostRepository {
  LocalCostRepository({
    List<CostShare>? costShares,
    this.delay = const Duration(seconds: 1),
    DateTime Function()? clock,
  }) : _costShares = List<CostShare>.of(costShares ?? demoCostShares),
       _clock = clock ?? DateTime.now;

  final List<CostShare> _costShares;
  final Duration delay;
  final DateTime Function() _clock;

  @override
  bool get isSimulation => true;

  @override
  List<CostShare> get costShares => List.unmodifiable(_costShares);

  @override
  Future<List<CostShare>> fetchCostShares({bool simulateError = false}) async {
    await Future<void>.delayed(delay);
    if (simulateError) {
      throw const CostRepositoryException(
        'Gagal memuat ongkos. Periksa koneksi internet.',
      );
    }
    return costShares;
  }

  @override
  Future<CostShare> declarePayment(String costShareId) async {
    await Future<void>.delayed(delay);
    final index = _costShares.indexWhere((share) => share.id == costShareId);
    if (index < 0) {
      throw const CostRepositoryException('Data ongkos nggak ketemu.');
    }
    final current = _costShares[index];
    if (current.paymentStatus == PaymentStatus.pendingConfirmation) {
      return current;
    }
    final blocker = PaymentRules.declareBlocker(current);
    if (blocker != null) throw CostRepositoryException(blocker);

    final updated = current.copyWith(
      paymentStatus: PaymentStatus.pendingConfirmation,
      declaredAt: _clock(),
    );
    _costShares[index] = updated;
    notifyListeners();
    return updated;
  }
}
