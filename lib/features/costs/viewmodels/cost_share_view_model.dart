import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/features/costs/utils/payment_rules.dart';

/// State satu bagian ongkos, dipakai Rincian Ongkos (FR-09) dan
/// Status Pembayaran (FR-10, FR-11).
class CostShareViewModel extends ViewModel {
  CostShareViewModel({required this.repository, required this.costShareId}) {
    repository.addListener(publish);
  }

  final CostRepository repository;
  final String costShareId;

  bool _isSubmitting = false;
  String? _declareError;

  /// `null` bila id tidak ada di data yang sudah dimuat.
  CostShare? get share {
    for (final share in repository.costShares) {
      if (share.id == costShareId) return share;
    }
    return null;
  }

  bool get isSimulation => repository.isSimulation;
  bool get isSubmitting => _isSubmitting;

  /// Pesan kegagalan deklarasi terakhir, untuk banner di Status Pembayaran.
  String? get declareError => _declareError;

  /// Alasan tombol "Sudah bayar" nonaktif, atau `null` bila boleh ditekan.
  String? get declareBlocker {
    final current = share;
    if (current == null) return 'Data ongkos nggak ketemu.';
    return PaymentRules.declareBlocker(current);
  }

  bool get canDeclare => !_isSubmitting && declareBlocker == null;

  /// Mengirim deklarasi "Sudah bayar". Mengembalikan `true` bila berhasil.
  ///
  /// Panggilan saat masih mengirim diabaikan, sehingga ketukan ganda tidak
  /// mengirim dua deklarasi.
  Future<bool> declarePayment() async {
    if (_isSubmitting) return false;
    final blocker = declareBlocker;
    if (blocker != null) {
      _declareError = blocker;
      publish();
      return false;
    }
    _isSubmitting = true;
    _declareError = null;
    publish();
    try {
      await repository.declarePayment(costShareId);
      return true;
    } catch (error) {
      _declareError = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      publish();
    }
  }

  @override
  void dispose() {
    repository.removeListener(publish);
    super.dispose();
  }
}
