import 'package:flutter/widgets.dart';

/// Aturan gerak bersama.
///
/// Gerak sekali jalan (kartu muncul, tukar Dari/Ke) cukup memakai durasi di
/// sini. Gerak berulang (Si Titik berkedip, jalan raya mini, loading) hanya
/// berjalan bila [ambientOf] true: tidak saat pengguna mematikan animasi di
/// pengaturan HP, dan tidak di tes (lihat `test/flutter_test_config.dart`),
/// karena animasi tanpa akhir membuat `pumpAndSettle` tidak pernah selesai.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 450);

  /// Sakelar global untuk gerak berulang. Tes mematikannya.
  static bool ambientEnabled = true;

  /// Pengguna mematikan animasi (Aksesibilitas → Hapus animasi).
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Boleh menjalankan gerak berulang di [context].
  static bool ambientOf(BuildContext context) =>
      ambientEnabled && !reduced(context);
}
