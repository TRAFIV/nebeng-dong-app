import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';

/// Jarak, sama dengan variabel Figma `spacing/...`.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8; // spacing/sm
  static const double ms = 12; // antara sm dan md
  static const double md = 16; // spacing/md
  static const double lg = 24; // spacing/lg
}

/// Sudut membulat: kartu 16, kontrol (kolom, tombol) 12, pill bulat penuh.
abstract final class AppRadius {
  static const double md = 16;
  static const double control = 12;
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius controlAll = BorderRadius.all(
    Radius.circular(control),
  );
  static const BorderRadius pill = BorderRadius.all(Radius.circular(40));
}

/// Ukuran tetap yang dipakai berulang.
abstract final class AppSizes {
  /// Target sentuh minimum untuk tombol dan input.
  static const double touchTarget = 48;
  static const double locationHeight = 64;
  static const double routeRail = 24;
}

/// Dekorasi kartu yang dipakai berulang.
abstract final class AppDecorations {
  /// Kartu dengan bayangan `Elevation/Card`.
  static const card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.mdAll,
    border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
  );

  /// Kartu yang mengambang di atas pita oranye (kartu rute di Cari).
  static const floating = BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.mdAll,
    boxShadow: [
      BoxShadow(
        color: Color(0x261B2440),
        blurRadius: 24,
        offset: Offset(0, 10),
        spreadRadius: -12,
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
