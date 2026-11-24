/// Sumber jam bersama untuk fitur yang bergantung pada hari/jam sekarang
/// (pilihan "Hari ini", "Berangkat sebentar lagi", label "Pagi ini").
///
/// Tes mematoknya di `test/flutter_test_config.dart` agar hasil tidak
/// bergantung pada kapan tes dijalankan (mis. hari Minggu).
abstract final class AppClock {
  static DateTime Function() now = DateTime.now;

  /// Tanggal hari ini tanpa jam.
  static DateTime today() {
    final current = now();
    return DateTime(current.year, current.month, current.day);
  }
}
