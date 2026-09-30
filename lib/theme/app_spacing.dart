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
  static const double md = 20;
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
    color: AppColors.surface,
    borderRadius: AppRadius.mdAll,
    boxShadow: [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
  );

  /// Kartu bergaris tepi tanpa bayangan.
  static const outlined = BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.mdAll,
    border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
  );
}
