import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';
import 'package:praktikum_mobile/features/costs/models/payment_status.dart';

/// Repository palsu untuk demo: menyimpan data di memori dan meniru
/// jeda jaringan. Bukan integrasi backend sungguhan.
class LocalCostRepository implements CostRepository {
  LocalCostRepository({
    CostBreakdown? initialBreakdown,
    this.delay = const Duration(milliseconds: 800),
  }) : _breakdown = initialBreakdown ?? demoBreakdown();

  static const demoTripId = 'trip-demo-1';

  /// Data uji: Rp15.000 dibagi 2 penumpang (Rp7.500 per orang). Pembulatan
  /// sisa rupiah dites terpisah di `cost_models_test.dart`.
  static CostBreakdown demoBreakdown() => CostBreakdown.split(
    tripId: demoTripId,
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand Limau Manis',
    departureLabel: 'Kamis, 1 Okt · 07.30',
    driverName: 'Taris Rafivdean',
    totalFare: 15000,
    passengerNames: ['Shiddiq', 'Dimas Saputra'],
    currentUserIndex: 0,
    initialStatuses: {1: PaymentStatus.menungguKonfirmasi},
  );

  /// Jeda palsu supaya status "lagi ngirim" sempat terlihat.
  final Duration delay;

  /// Saklar demo: kalau `true`, pengiriman berikutnya gagal satu kali
  /// lalu saklar mati sendiri, jadi "Coba Lagi" bisa berhasil.
  bool failNextDeclaration = false;

  CostBreakdown _breakdown;

  @override
  Future<CostBreakdown> fetchBreakdown(String tripId) async {
    await Future<void>.delayed(delay);
    if (tripId != _breakdown.tripId) {
      throw const CostRepositoryException('Perjalanan tidak ditemukan.');
    }
    return _breakdown;
  }

  @override
  Future<CostBreakdown> declarePayment({
    required String tripId,
    required int amount,
  }) async {
    await Future<void>.delayed(delay);
    if (failNextDeclaration) {
      failNextDeclaration = false;
      throw const CostRepositoryException(
        'Gagal ngirim konfirmasi. Cek koneksi kamu, terus coba lagi.',
      );
    }
    if (tripId != _breakdown.tripId) {
      throw const CostRepositoryException('Perjalanan tidak ditemukan.');
    }

    // Server tetap memeriksa ulang, walaupun aplikasi sudah memvalidasi.
    final myShare = _breakdown.myShare;
    if (!myShare.status.canDeclarePayment) {
      throw const CostRepositoryException(
        'Pembayaran ini udah pernah ditandai.',
      );
    }
    if (amount != myShare.amount) {
      throw const CostRepositoryException(
        'Nominal tidak sama dengan bagianmu.',
      );
    }

    _breakdown = _breakdown.withMyStatus(PaymentStatus.menungguKonfirmasi);
    return _breakdown;
  }
}
