import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';

/// DATA yang dikirim dari Rincian Ongkos ke Konfirmasi Pembayaran.
class PaymentConfirmationArguments {
  const PaymentConfirmationArguments({
    required this.repository,
    required this.breakdown,
  });

  /// Repository yang sama dengan layar Rincian, supaya datanya satu sumber.
  final CostRepository repository;
  final CostBreakdown breakdown;
}
