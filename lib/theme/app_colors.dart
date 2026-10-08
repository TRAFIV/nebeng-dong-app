import 'package:flutter/material.dart';

/// Palet warna, sama dengan variabel Figma `color/...`.
/// Tema terang: latar putih keabuan, kartu putih, aksi coral.
abstract final class AppColors {
  static const background = Color(0xFFF6F7FB); // color/bg/default (cloud/100)
  static const surface = Color(0xFFFFFFFF); // color/bg/surface (white/1000)
  static const brand = Color(0xFFF2603F); // color/bg/brand (coral/500)
  static const brandStrong = Color(0xFFD9491F); // color/icon/brand (coral/600)
  static const brandSubtle = Color(0xFFFFE9E2); // color/bg/brand-subtle
  static const accent = Color(0xFF22A06B); // color/accent/default (green/500)
  static const accentWarm = Color(0xFFFFC542); // color/bg/accent-subtle
  static const successSubtle = Color(0xFFDCF3E8); // color/bg/success-subtle
  static const successText = Color(0xFF0F7A52); // color/text/success
  static const textPrimary = Color(0xFF1B2440); // color/text/primary (ink/900)
  static const textSecondary = Color(0xFF7A8299); // color/text/secondary
  static const onBrand = Color(0xFFFFFFFF); // color/text/on-brand
  static const border = Color(0xFFE7E9F2); // color/border/default (cloud/200)
  static const cardShadow = Color(0x141B2440); // Elevation/Card (8%)
  // Semantic aliases only: location controls follow the shared palette.
  static const locationFill = surface;
  static const routeOrigin = brandStrong;
  static const routeDestination = successText;
  static const routeConnector = textSecondary;
}
