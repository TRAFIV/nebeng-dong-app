/// Status pembayaran sisi penumpang (FR-10, FR-11).
///
/// Penumpang hanya bisa memindahkan [unreported] → [pendingConfirmation]
/// lewat deklarasi "Sudah bayar". Perpindahan ke [confirmed] adalah otoritas
/// backend/admin; di data latihan nilainya berasal dari fixture.
enum PaymentStatus {
  unreported('Belum dilaporkan'),
  pendingConfirmation('Menunggu konfirmasi'),
  confirmed('Terkonfirmasi');

  const PaymentStatus(this.label);
  final String label;
}

/// Tahap angka ongkos yang ditampilkan di Rincian Ongkos (FR-09).
enum FareStage {
  /// Perjalanan belum selesai; angka masih bisa berubah.
  estimate('Estimasi'),

  /// Perjalanan selesai; angka sudah dikunci.
  finalized('Final'),

  /// Penyedia belum mengatur ongkos. Bukan berarti gratis.
  unset('Belum diatur');

  const FareStage(this.label);
  final String label;
}

/// Bagian ongkos milik satu penumpang untuk satu perjalanan
/// (entitas CostShare pada PRD 2.5).
///
/// Keputusan tim (Okt 2026): ongkos memakai tarif tetap per penumpang dari
/// rute (`Ride.farePerPerson`), jadi bagian penumpang sama dengan tarif itu.
/// Nilai disalin saat pesanan dibuat supaya riwayat tidak ikut berubah bila
/// tarif rute diubah kemudian.
class CostShare {
  const CostShare({
    required this.id,
    required this.bookingId,
    required this.rideId,
    required this.driverName,
    required this.origin,
    required this.destination,
    required this.tripDate,
    required this.tripCompleted,
    this.farePerPerson,
    this.paymentStatus = PaymentStatus.unreported,
    this.declaredAt,
  });

  final String id;

  /// Kunci pesanan dari Modul 2 (Pemesanan). Kontrak final menyusul Taris.
  final String bookingId;
  final String rideId;
  final String driverName;
  final String origin;
  final String destination;
  final DateTime tripDate;
  final bool tripCompleted;

  /// Ongkos per penumpang dalam rupiah; `null` berarti belum diatur.
  final int? farePerPerson;
  final PaymentStatus paymentStatus;

  /// Waktu penumpang menekan "Sudah bayar".
  final DateTime? declaredAt;

  bool get isFareSet => farePerPerson != null && farePerPerson! > 0;

  FareStage get fareStage {
    if (!isFareSet) return FareStage.unset;
    return tripCompleted ? FareStage.finalized : FareStage.estimate;
  }

  CostShare copyWith({PaymentStatus? paymentStatus, DateTime? declaredAt}) =>
      CostShare(
        id: id,
        bookingId: bookingId,
        rideId: rideId,
        driverName: driverName,
        origin: origin,
        destination: destination,
        tripDate: tripDate,
        tripCompleted: tripCompleted,
        farePerPerson: farePerPerson,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        declaredAt: declaredAt ?? this.declaredAt,
      );
}
