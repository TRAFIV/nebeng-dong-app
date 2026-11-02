import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';

/// Kontrak data ongkos milik penumpang yang sedang masuk (FR-09–FR-12).
///
/// Sengaja tidak ada perintah konfirmasi pembayaran; itu wewenang backend.
/// Ganti adapter lokal dengan adapter API hanya setelah kontrak disepakati tim.
abstract class CostRepository extends ChangeNotifier {
  bool get isSimulation;

  /// Salinan terakhir yang diketahui; listener diberi tahu saat berubah.
  List<CostShare> get costShares;

  /// Practical-test hook [simulateError], bukan parameter endpoint server.
  Future<List<CostShare>> fetchCostShares({bool simulateError = false});

  /// Mencatat deklarasi "Sudah bayar" di luar aplikasi.
  ///
  /// Mengembalikan data terbaru. Panggilan ulang saat status sudah
  /// menunggu konfirmasi tidak mengubah apa pun (idempotent).
  /// Melempar [CostRepositoryException] bila deklarasi tidak diizinkan.
  Future<CostShare> declarePayment(String costShareId);
}

class CostRepositoryException implements Exception {
  const CostRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
