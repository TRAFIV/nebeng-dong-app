import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';

/// Hierarki teks dengan huruf Plus Jakarta Sans.
///
/// Layar baru cukup memakai tiga ukuran: [title] (14), [bodyMedium] (13–14)
/// dan [caption] (11); ukuran heading untuk judul halaman.
abstract final class AppTextStyles {
  static const fontFamily = 'PlusJakartaSans';

  static const headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    height: 34 / 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Judul bagian dan nama penting (mis. "Tempat tujuan").
  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Keterangan kecil abu-abu (jam, rating, kursi).
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 15 / 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// Label kecil huruf besar: DARI / KE.
  static const overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.7,
    color: AppColors.textSecondary,
  );
}
