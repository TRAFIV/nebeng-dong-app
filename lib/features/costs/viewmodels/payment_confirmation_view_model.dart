import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';

/// State, validasi, dan command layar Konfirmasi Pembayaran (FR-10, FR-11).
class PaymentConfirmationViewModel extends ViewModel {
  PaymentConfirmationViewModel({
    required this._repository,
    required this._breakdown,
  });

  static const unconfirmedMessage = 'Centang dulu ya, kalau udah bayar';

  final CostRepository _repository;
  CostBreakdown _breakdown;

  /// `true` kalau penumpang sudah mencentang "udah bayar".
  bool isPaidChecked = false;

  /// Pesan validasi centang; `null` kalau tidak ada masalah.
  String? validationError;

  /// `true` selama data sedang dikirim (untuk spinner & tombol nonaktif).
  bool isSubmitting = false;

  /// Pesan error dari pengiriman terakhir; `null` kalau tidak ada.
  String? errorMessage;

  CostBreakdown get breakdown => _breakdown;
  CostShare get myShare => _breakdown.myShare;

  /// Tombol kirim aktif hanya kalau belum pernah ditandai dan
  /// tidak sedang mengirim.
  bool get canSubmit => myShare.status.canDeclarePayment && !isSubmitting;

  /// INPUT: penumpang mencentang atau melepas centang "udah bayar".
  void setPaidChecked(bool value) {
    if (isDisposed || !canSubmit) return;
    isPaidChecked = value;
    validationError = null;
    publish();
  }

  /// VALIDATION: penumpang wajib mencentang sebelum mengirim.
  /// Mengembalikan `true` kalau valid; kalau tidak, [validationError] diisi.
  bool validate() {
    validationError = isPaidChecked ? null : unconfirmedMessage;
    publish();
    return isPaidChecked;
  }

  /// Mengirim deklarasi "udah bayar" sebesar bagian milik penumpang.
  /// Mengembalikan rincian terbaru kalau berhasil, `null` kalau gagal
  /// (validasi atau pengiriman).
  Future<CostBreakdown?> submit() async {
    if (isDisposed || !canSubmit) return null;
    // Command memvalidasi input-nya sendiri, tidak hanya mengandalkan View.
    if (!validate()) return null;

    isSubmitting = true;
    errorMessage = null;
    publish();
    try {
      final updated = await _repository.declarePayment(
        tripId: _breakdown.tripId,
        amount: myShare.amount,
      );
      if (isDisposed) return null;
      _breakdown = updated;
      return updated;
    } on CostRepositoryException catch (error) {
      if (isDisposed) return null;
      errorMessage = error.message;
      return null;
    } finally {
      if (!isDisposed) {
        isSubmitting = false;
        publish();
      }
    }
  }
}
