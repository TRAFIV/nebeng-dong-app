import 'package:flutter/material.dart';

/// Palet warna, sama dengan variabel Figma `color/...`.
abstract final class AppColors {
  static const brand = Color(0xFF0F766E); // color/bg/brand
  static const brandSubtle = Color(0xFFCCFBF1); // color/bg/brand-subtle
  static const accent = Color(0xFFF59E0B); // color/accent/default
  static const textPrimary = Color(0xFF102A2A); // color/text/primary
  static const textSecondary = Color(0xFF64748B); // color/text/secondary
  static const onBrand = Color(0xFFFFFFFF); // color/text/on-brand
  static const border = Color(0xFFE2E8F0); // color/border/default
  static const background = Color(0xFFFFFFFF); // color/bg/default
  static const cardShadow = Color(0x1A0F2929); // Elevation/Card (10%)
}
