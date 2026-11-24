import 'dart:async';

import 'package:praktikum_mobile/core/app_clock.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dijalankan Flutter sebelum setiap file tes.
///
/// Gerak berulang (Si Titik, jalan raya mini) dimatikan agar `pumpAndSettle`
/// bisa selesai. Gerak sekali jalan tetap berjalan dan ikut diuji.
/// SharedPreferences diganti tiruan kosong (tes boleh mengisinya sendiri).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppMotion.ambientEnabled = false;
  // Selasa pagi: rute contoh "Senin–Jumat" berjalan, belum ada yang cabut.
  AppClock.now = () => DateTime(2026, 11, 24, 7, 12);
  SharedPreferences.setMockInitialValues({});
  await testMain();
}
