/// Jenis kegagalan permintaan ke server, agar ViewModel bisa memilih reaksi
/// (misalnya kembali ke Login saat [unauthorized]) tanpa membaca kode HTTP.
enum ApiErrorKind {
  /// Tidak ada koneksi atau server tidak bisa dihubungi.
  network,

  /// Server tidak menjawab dalam [ApiConfig.timeout].
  timeout,

  /// 401: belum masuk atau token kedaluwarsa.
  unauthorized,

  /// 403: sudah masuk tetapi tidak berhak.
  forbidden,

  /// 404: data tidak ditemukan.
  notFound,

  /// 409: bentrok dengan keadaan data, misalnya kursi sudah penuh.
  conflict,

  /// 422: isian ditolak aturan server; detail per kolom di [ApiException.fieldErrors].
  validation,

  /// 5xx atau kode lain yang tidak dikenali.
  server,

  /// Jawaban server tidak sesuai kontrak (bukan JSON atau kolom hilang).
  invalidResponse,
}

/// Satu-satunya jenis error dari lapisan jaringan.
///
/// [message] sudah ramah pengguna dan boleh langsung ditampilkan di layar.
class ApiException implements Exception {
  const ApiException(
    this.kind,
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
    this.debugDetail,
  });

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;

  /// Pesan per kolom isian dari server, misalnya `{'pickup_location': '...'}`.
  final Map<String, String> fieldErrors;

  /// Detail teknis untuk log developer, bukan untuk ditampilkan di layar.
  final String? debugDetail;

  /// Pesan bawaan bila server tidak mengirim pesan sendiri.
  static String defaultMessage(ApiErrorKind kind) => switch (kind) {
    ApiErrorKind.network => 'Tidak bisa terhubung ke server. Periksa koneksi internet, lalu coba lagi.',
    ApiErrorKind.timeout => 'Server terlalu lama menjawab. Coba lagi sebentar.',
    ApiErrorKind.unauthorized => 'Sesi kamu berakhir. Silakan masuk lagi.',
    ApiErrorKind.forbidden => 'Kamu tidak punya akses ke data ini.',
    ApiErrorKind.notFound => 'Data tidak ditemukan.',
    ApiErrorKind.conflict => 'Data sudah berubah. Muat ulang, lalu coba lagi.',
    ApiErrorKind.validation => 'Periksa kembali isianmu.',
    ApiErrorKind.server => 'Server sedang bermasalah. Coba lagi nanti.',
    ApiErrorKind.invalidResponse =>
      'Jawaban server tidak dikenali. Coba lagi nanti.',
  };

  @override
  String toString() => message;
}
