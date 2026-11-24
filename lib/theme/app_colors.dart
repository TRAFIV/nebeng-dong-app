import 'package:flutter/material.dart';

/// Palet warna "Garis & Titik" (24 November 2026).
///
/// Oranye utama sama dengan ikon/logo. Peran warna:
/// oranye = aksi dan titik asal, hijau = tujuan dan kursi tersedia,
/// kuning = peringatan saja (mis. "Sisa 1!"), biru tua = teks.
abstract final class AppColors {
  static const background = Color(0xFFF5F6FA); // latar halaman
  static const surface = Color(0xFFFFFFFF); // kartu
  static const brand = Color(0xFFE9461D); // = warna logo
  /// Teks/ikon oranye dan tombol saat ditekan.
  static const brandStrong = Color(0xFFC2380F);
  static const brandSubtle = Color(0xFFFDE7DF); // latar oranye lembut
  static const accent = Color(0xFF22A06B); // hijau
  static const accentWarm = Color(0xFFFFC542); // kuning peringatan
  static const onAccentWarm = Color(0xFF5C3F00); // teks di atas kuning
  static const successSubtle = Color(0xFFDCF3E8);
  static const successText = Color(0xFF0F7A52);
  static const textPrimary = Color(0xFF1B2440);
  static const textSecondary = Color(0xFF687089);
  static const onBrand = Color(0xFFFFFFFF);
  static const border = Color(0xFFE6E8F0);
  static const subtleFill = Color(0xFFF1F2F7); // isian kolom, pill netral
  static const cardShadow = Color(0x141B2440); // Elevation/Card (8%)
  // Alias semantik: kontrol lokasi mengikuti palet bersama.
  static const locationFill = surface;
  static const routeOrigin = brand;
  static const routeDestination = successText;
  static const routeConnector = textSecondary;
}
