import 'package:flutter/services.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Memuat font aplikasi (Plus Jakarta Sans) dan ikon Material ke mesin tes,
/// agar tes gambar (golden/screenshot) sama dengan tampilan aplikasi asli.
/// Tanpa ini, tes memakai font kotak-kotak bawaan.
Future<void> loadAppFonts() async {
  final app = FontLoader(AppTextStyles.fontFamily);
  for (final weight in ['regular', 'medium', 'semibold', 'bold', 'extrabold']) {
    app.addFont(rootBundle.load('assets/fonts/plusjakartasans-$weight.ttf'));
  }
  await app.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}
