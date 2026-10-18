import 'package:praktikum_mobile/features/costs/models/cost_share.dart';

/// Aturan kapan penumpang boleh melapor "Sudah bayar" (FR-10).
///
/// Dipakai dua kali: ViewModel untuk mengaktifkan tombol, dan repository
/// sebagai pemeriksa terakhir (perannya nanti diambil alih backend).
abstract final class PaymentRules {
  /// Mengembalikan alasan penolakan, atau `null` bila deklarasi boleh dikirim.
  static String? declareBlocker(CostShare share) {
    switch (share.paymentStatus) {
      case PaymentStatus.pendingConfirmation:
        return 'Pembayaranmu udah dilaporin, tinggal tunggu konfirmasi ya.';
      case PaymentStatus.confirmed:
        return 'Pembayaran ini udah terkonfirmasi.';
      case PaymentStatus.unreported:
        break;
    }
    if (!share.tripCompleted) {
      return 'Lapor bayar bisa setelah perjalanan selesai, ya.';
    }
    if (!share.isFareSet) {
      return 'Ongkos belum diatur penyedia, jadi belum bisa lapor bayar.';
    }
    return null;
  }
}
