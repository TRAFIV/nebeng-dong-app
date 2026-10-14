/// Status pembayaran ongkos satu penumpang pada satu perjalanan (FR-10, FR-11).
///
/// Alurnya satu arah dan tidak bisa dilompati:
/// belum bayar → menunggu konfirmasi → lunas.
///
/// - belum bayar → menunggu konfirmasi: penumpang menandai "udah bayar"
///   (deklarasi, uangnya dibayar di luar aplikasi).
/// - menunggu konfirmasi → lunas: keputusan sistem/admin, bukan penumpang.
enum PaymentStatus {
  belumBayar('Belum bayar'),
  menungguKonfirmasi('Menunggu konfirmasi'),
  lunas('Lunas');

  const PaymentStatus(this.label);

  /// Teks yang ditampilkan di badge UI.
  final String label;

  /// Status berikutnya dalam alur, atau `null` kalau sudah di akhir.
  PaymentStatus? get next => switch (this) {
    PaymentStatus.belumBayar => PaymentStatus.menungguKonfirmasi,
    PaymentStatus.menungguKonfirmasi => PaymentStatus.lunas,
    PaymentStatus.lunas => null,
  };

  /// `true` hanya kalau [target] adalah langkah tepat berikutnya.
  /// Mundur atau melompat (belum bayar → lunas) selalu ditolak.
  bool canMoveTo(PaymentStatus target) => next == target;

  /// Penumpang hanya boleh menandai "udah bayar" satu kali, saat belum bayar.
  bool get canDeclarePayment => this == PaymentStatus.belumBayar;
}
