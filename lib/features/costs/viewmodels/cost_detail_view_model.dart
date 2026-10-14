import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';

enum CostDetailStatus { loading, ready, error }

/// State layar Rincian Ongkos (FR-09).
class CostDetailViewModel extends ViewModel {
  CostDetailViewModel({required this._repository, required this.tripId});

  final CostRepository _repository;
  final String tripId;

  CostDetailStatus status = CostDetailStatus.loading;
  CostBreakdown? breakdown;
  String? errorMessage;

  /// Tombol "Konfirmasi Pembayaran" aktif hanya kalau status masih
  /// belum bayar.
  bool get canOpenConfirmation =>
      breakdown?.myShare.status.canDeclarePayment ?? false;

  Future<void> load() async {
    status = CostDetailStatus.loading;
    errorMessage = null;
    publish();
    try {
      final result = await _repository.fetchBreakdown(tripId);
      if (isDisposed) return;
      breakdown = result;
      status = CostDetailStatus.ready;
    } on CostRepositoryException catch (error) {
      if (isDisposed) return;
      errorMessage = error.message;
      status = CostDetailStatus.error;
    }
    publish();
  }

  /// Menerima RESULT yang dikirim balik dari layar Konfirmasi Pembayaran.
  void applyResult(CostBreakdown updated) {
    if (isDisposed) return;
    breakdown = updated;
    publish();
  }
}
