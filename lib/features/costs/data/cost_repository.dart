import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';

/// Kontrak sumber data ongkos. Versi sekarang palsu ([LocalCostRepository]);
/// nanti bisa diganti versi REST API tanpa mengubah ViewModel/View.
abstract interface class CostRepository {
  /// Mengambil rincian ongkos satu perjalanan.
  Future<CostBreakdown> fetchBreakdown(String tripId);

  /// Mencatat deklarasi "udah bayar" milik penumpang login.
  /// Mengembalikan rincian terbaru (status menjadi menunggu konfirmasi).
  Future<CostBreakdown> declarePayment({
    required String tripId,
    required int amount,
  });
}

/// Error yang pesannya aman ditampilkan ke pengguna.
class CostRepositoryException implements Exception {
  const CostRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'CostRepositoryException: $message';
}
