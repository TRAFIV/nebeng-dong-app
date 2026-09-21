import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Jarak, sama dengan variabel Figma `spacing/...`.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8; // spacing/sm
  static const double md = 16; // spacing/md
  static const double lg = 24; // spacing/lg
}

/// Sudut membulat, sama dengan variabel Figma `radius/md`.
abstract final class AppRadius {
  static const double md = 12;
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
}

/// Ukuran tetap yang dipakai berulang.
abstract final class AppSizes {
  /// Target sentuh minimum untuk tombol dan input.
  static const double touchTarget = 48;
}

/// Dekorasi kartu yang dipakai berulang.
abstract final class AppDecorations {
  /// Kartu dengan bayangan `Elevation/Card`.
  static const card = BoxDecoration(
    color: AppColors.background,
    borderRadius: AppRadius.mdAll,
    border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Kartu bergaris tepi tanpa bayangan.
  static const outlined = BoxDecoration(
    color: AppColors.background,
    borderRadius: AppRadius.mdAll,
    border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
  );
}
