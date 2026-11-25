/// Alamat server REST kelompok, diisi saat menjalankan aplikasi:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://server-kelompok/api/v1
/// ```
///
/// Tanpa nilai itu aplikasi memakai repository lokal (data latihan), sehingga
/// demo dan tes tetap jalan walaupun server belum siap.
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get isConfigured => baseUrl.isNotEmpty;

  /// Batas tunggu satu permintaan sebelum dianggap gagal.
  static const timeout = Duration(seconds: 15);
}
