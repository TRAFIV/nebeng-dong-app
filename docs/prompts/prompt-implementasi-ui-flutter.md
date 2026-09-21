# Prompt Implementasi UI Flutter — Nebeng Dong

Dokumen ini mencatat prompt yang kami pakai untuk mengimplementasikan UI Flutter
(Modul 1, Bagian E — Langkah 3). Bagian **A** adalah kerangka asli dari modul,
bagian **B** adalah versi yang sudah kami isi sesuai PRD Nebeng Dong, dan
bagian **C** adalah ringkasan hasilnya.

Di Claude Code, prompt versi B dijalankan lewat subagent
[`flutter-ui-implementer`](../../.claude/agents/flutter-ui-implementer.md).

---

## A. Kerangka prompt (dari modul)

```text
Kamu adalah AI coding assistant yang bertugas mengimplementasikan UI Flutter berdasarkan PRD (Product Requirements Document) dan desain Figma yang saya lampirkan.

## KONTEKS PROJECT
- Nama project: [ISI NAMA PROJECT]
- Platform target: Flutter (Android [& iOS jika perlu])
- State management: [Provider / Riverpod / Bloc / GetX — sesuaikan]
- Struktur folder saat ini: [tempel struktur folder project, misal lib/screens, lib/widgets, lib/models]

## SUMBER DESAIN
1. PRD: [lampirkan/tempel isi PRD atau ringkasannya — fitur, flow, requirement fungsional]
2. Figma: [tempel link Figma / lampirkan screenshot frame / export design tokens (warna, spacing, typography)]

## TUGAS
Implementasikan screen/komponen berikut sesuai desain Figma dan requirement di PRD:
- [Nama screen 1, misal: "Login Screen"]
- [Nama screen 2, misal: "Dashboard"]

## KETENTUAN TEKNIS
1. Gunakan widget Flutter native (Material) kecuali desain secara eksplisit butuh custom widget
2. Ekstrak design token dari Figma menjadi:
   - Color palette → `lib/theme/app_colors.dart`
   - Typography → `lib/theme/app_text_styles.dart`
   - Spacing/sizing konsisten (gunakan konstanta, jangan hardcode angka di widget)
3. Pisahkan UI (widget) dari logic (gunakan [state management pilihan])
4. Buat widget reusable jika ada elemen yang berulang (button, card, input field)
5. Pastikan responsive untuk berbagai ukuran layar (gunakan MediaQuery / LayoutBuilder, hindari ukuran fixed px)
6. Ikuti null-safety dan best practice Dart terbaru
7. Untuk asset gambar, gunakan format WebP dan struktur folder assets/images/2.0x, 3.0x sesuai resolusi

## OUTPUT YANG DIHARAPKAN
1. Kode Flutter lengkap per screen/komponen (file terpisah, bukan satu file besar)
2. Penjelasan singkat struktur widget tree yang dipakai
3. Daftar dependency baru (jika ada) yang perlu ditambahkan via `flutter pub add`
4. Catatan jika ada bagian desain Figma yang ambigu/tidak match dengan PRD, agar saya klarifikasi dulu sebelum lanjut

## BATASAN
- Jangan generate dummy data acak — gunakan struktur data sesuai model/API yang sudah saya definisikan: [tempel model/API jika ada]
- Jangan ubah struktur folder project yang sudah ada kecuali saya minta
- Jika Figma dan PRD berbeda instruksi, prioritaskan PRD untuk logic/fungsi dan Figma untuk visual
```

---

## B. Prompt yang kami gunakan (sudah diisi sesuai PRD)

```text
Kamu adalah AI coding assistant yang bertugas mengimplementasikan UI Flutter berdasarkan PRD (Product Requirements Document) dan desain Figma yang saya lampirkan.

## KONTEKS PROJECT
- Nama project: Nebeng Dong — aplikasi nebeng & berbagi tebengan antar mahasiswa (package Flutter: praktikum_mobile)
- Platform target: Flutter (Android)
- State management: setState bawaan Flutter (StatefulWidget). Belum perlu Provider/Riverpod/Bloc karena state masih lokal per layar; logic ditaruh di method State/model, bukan di build().
- Struktur folder saat ini:
  lib/
    main.dart
    data/        → sample_rides.dart (contoh data sementara sampai REST API ada)
    models/      → ride.dart
    screens/     → login_screen.dart, home_screen.dart, ride_detail_screen.dart
    theme/       → app_colors.dart, app_text_styles.dart, app_spacing.dart, app_theme.dart
    utils/       → rupiah_format.dart
    widgets/     → app_button.dart, app_text_field.dart, ride_card.dart, user_avatar.dart
  assets/images/ → 2.0x/, 3.0x/
  test/          → widget_test.dart

## SUMBER DESAIN
1. PRD (docs/prd/prd-nebeng-dong-kel-4.md), ringkasan:
   - Masalah: mahasiswa searah ke kampus berangkat sendiri-sendiri → ongkos mahal, sulit cari tumpangan aman.
   - Pengguna: mahasiswa aktif, dengan peran pemberi tebengan dan pencari tebengan.
   - Fitur inti: (1) pencocokan rute searah, (2) pemesanan & koordinasi, (3) berbagi ongkos, (4) reputasi & riwayat.
   - Requirement yang dipakai di 3 layar ini:
     FR-17 daftar/masuk hanya dengan email kampus; FR-18 nama tampil, email tidak;
     FR-02 cari tebengan berdasarkan asal & tujuan; FR-03 tandai tebengan searah;
     FR-04 kuota kursi berkurang/tutup saat penuh; FR-05 ajukan permintaan gabung;
     FR-06 tandai titik jemput; FR-09 pembagian ongkos per penumpang.
   - Alur pencari: masuk (email kampus) → masukkan tujuan → lihat tebengan searah → ajukan gabung & titik jemput → tunggu konfirmasi.
   - Batasan: Android + Flutter, backend REST API sendiri, aplikasi tidak memproses pembayaran.
2. Figma: https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum (halaman "07 Product Screens")
   Design token (lihat docs/design/panduan-desain-figma.md):
   - Warna: brand #0F766E, brand-subtle #CCFBF1, accent #F59E0B, text-primary #102A2A,
     text-secondary #64748B, border #E2E8F0, background #FFFFFF
   - Spacing: 8 / 16 / 24; radius 12; bayangan kartu y4 blur12 10%
   - Tipografi Roboto: Heading L 28 Bold, Heading M 22 Bold, Body L 16, Body M 14, Label 14 Medium
   - Komponen: Button (Primary/Secondary), Input Field, Ride Card, Bottom Navigation
   - Gaya bahasa UI: santai, tidak formal (contoh: "Gas Masuk!", "Cariin Tebengan!", "Ikut Nebeng!")

## TUGAS
Implementasikan screen/komponen berikut sesuai desain Figma dan requirement di PRD:
- Login Screen (email kampus + password, validasi domain kampus)
- Home / Cari Tebengan (sapaan, kartu pencarian asal-tujuan, daftar tebengan searah, bottom navigation)
- Detail Tebengan (info pemberi, rute & jadwal, sisa kursi, patungan per orang, titik jemput, tombol ikut nebeng)

## KETENTUAN TEKNIS
1. Gunakan widget Flutter native (Material) kecuali desain secara eksplisit butuh custom widget
2. Ekstrak design token dari Figma menjadi:
   - Color palette → `lib/theme/app_colors.dart`
   - Typography → `lib/theme/app_text_styles.dart`
   - Spacing/sizing konsisten (gunakan konstanta, jangan hardcode angka di widget) → `lib/theme/app_spacing.dart`
3. Pisahkan UI (widget) dari logic (gunakan setState; model di lib/models, format di lib/utils)
4. Buat widget reusable jika ada elemen yang berulang (button, card, input field)
5. Pastikan responsive untuk berbagai ukuran layar (gunakan MediaQuery / LayoutBuilder, hindari ukuran fixed px)
6. Ikuti null-safety dan best practice Dart terbaru
7. Untuk asset gambar, gunakan format WebP dan struktur folder assets/images/2.0x, 3.0x sesuai resolusi

## OUTPUT YANG DIHARAPKAN
1. Kode Flutter lengkap per screen/komponen (file terpisah, bukan satu file besar)
2. Penjelasan singkat struktur widget tree yang dipakai
3. Daftar dependency baru (jika ada) yang perlu ditambahkan via `flutter pub add`
4. Catatan jika ada bagian desain Figma yang ambigu/tidak match dengan PRD, agar saya klarifikasi dulu sebelum lanjut

## BATASAN
- Jangan generate dummy data acak — gunakan struktur data sesuai model yang sudah didefinisikan:
  Ride { id, driverName, driverRating, driverTripCount, origin, destination, schedule,
         departureTime, seatCapacity, seatsAvailable, farePerPerson } (entitas Route di PRD 2.5)
- Jangan ubah struktur folder project yang sudah ada kecuali saya minta
- Jika Figma dan PRD berbeda instruksi, prioritaskan PRD untuk logic/fungsi dan Figma untuk visual
```

---

## C. Hasil

### Widget tree singkat

```text
LoginScreen
└── Scaffold → SafeArea → LayoutBuilder → SingleChildScrollView → Center
    └── Form → Column
        ├── _LoginHeader (logo, judul, subjudul)
        ├── AppTextField (email kampus) · AppTextField (password)
        ├── AppButton ("Gas Masuk!")
        └── Wrap (teks + TextButton "Daftar dulu, yuk")

HomeScreen
└── Scaffold
    ├── body: SafeArea → ListView
    │   ├── _HomeHeader (Row: sapaan + UserAvatar)
    │   ├── _SearchCard (Column: 2 × AppTextField + AppButton)
    │   └── judul + daftar RideCard / teks kosong
    └── bottomNavigationBar: NavigationBar (4 tab)

RideDetailScreen
└── Scaffold
    ├── appBar: AppBar ("Info Tebengan")
    ├── body: SafeArea → Form → ListView
    │   ├── _DriverCard · _RouteCard
    │   ├── Row (2 × _InfoTile: sisa kursi, patungan)
    │   └── AppTextField (titik jemput)
    └── bottomNavigationBar: AppButton ("Ikut Nebeng!")
```

### Dependency baru

Tidak ada. Semua memakai Material bawaan dan font Roboto bawaan Android.

### Catatan Figma vs PRD (perlu klarifikasi)

1. **Domain email kampus** tidak disebut di PRD; diasumsikan `unand.ac.id` (termasuk subdomain).
2. **REST API belum ada** (PRD 2.6), jadi daftar tebengan memakai `lib/data/sample_rides.dart` yang mengikuti model `Ride`, bukan data acak.
3. **FR-03 "searah"** masih disederhanakan menjadi pencocokan teks asal/tujuan; pencocokan jalur butuh backend/lokasi.
4. **FR-06 titik jemput** di PRD "ditandai di sepanjang rute" (peta); desain Figma memakai kolom teks. Visual mengikuti Figma, peta menyusul.
5. **Logo** belum berupa aset; kotak "ND" masih sementara. Logo final disimpan sebagai WebP di `assets/images/` (+ `2.0x/`, `3.0x/`).
