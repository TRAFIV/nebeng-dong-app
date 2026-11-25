import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';

/// Info Tebengan: hanya menampilkan tebengan dan membuka form pengajuan.
///
/// Titik jemput dan catatan diisi di Ajukan Tebengan, jadi layar ini tidak
/// menyimpan isian apa pun.
class RideDetailViewModel extends ViewModel {
  RideDetailViewModel({required this.ride});
  final Ride ride;

  bool _formOpen = false;
  bool _requestSent = false;

  /// True setelah Ajukan Tebengan benar-benar mengirim pesanan.
  bool get requestSent => _requestSent;

  bool get canRequest => !ride.isFull && !_requestSent && !_formOpen;

  String get buttonLabel => ride.isFull
      ? 'Yah, Udah Penuh'
      : _requestSent
      ? 'Nunggu di-ACC...'
      : 'Ikut Nebeng!';

  /// Dipanggil sebelum membuka Ajukan Tebengan. False bila tidak boleh
  /// (penuh, sudah terkirim, atau form sedang terbuka karena ketukan ganda).
  bool startRequest() {
    if (isDisposed || !canRequest) return false;
    _formOpen = true;
    publish();
    return true;
  }

  /// Dipanggil setelah Ajukan Tebengan ditutup. [sent] false berarti pengguna
  /// kembali tanpa mengirim, sehingga tombol bisa dipakai lagi.
  void finishRequest({required bool sent}) {
    if (isDisposed) return;
    _formOpen = false;
    _requestSent = sent;
    publish();
  }
}
