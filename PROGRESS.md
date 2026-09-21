# PROGRESS — Nebeng Dong (Tugas Modul 1)

> File serah-terima antar-AI. **Baca ini dulu sebelum mulai kerja, dan perbarui setelah setiap perubahan.**
> Cakupan: hanya sesuai tugas modul — jangan menambah fitur/halaman di luar itu.
> Semua path di file ini relatif terhadap root repo (folder `praktikum_mobile/` di laptop Mikail).

## Konteks singkat
- Aplikasi: Nebeng Dong (nebeng antar-mahasiswa). PRD: `docs/PRD_Nebeng Dong_Kel 4.md`
- Tugas: `docs/Modul 1 Pemrograman Mobile.md` (bagian C, D, E, dan Bagian 2)
- Repo: https://github.com/TRAFIV/nebeng-dong-app (branch `main`) — root repo = project Flutter
- Figma: https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum (akun `smyth`)
- Aturan kerja: `CLAUDE.md` (Claude) · `AGENTS.md` (AI lain)
- Prompt implementasi UI: `docs/Prompt Implementasi UI Flutter.md` · subagent `.claude/agents/flutter-ui-implementer.md`

## Rencana (sesuai tugas)
- [x] 1. Setup environment + NDK, project jalan di HP
- [x] 2. Pilih 3 layar: **Login**, **Home (cari tebengan)**, **Detail Tebengan**
- [x] 3. Panduan design Figma (Prompt 2) → `docs/Panduan Desain Figma.md`
- [x] 4. Desain 3 layar di Figma + prototype antarlayar (halaman `07 Product Screens`)
- [x] 5. Implementasi Flutter (Prompt 3): tema (`lib/theme/`), model + contoh data, widget reusable, 3 screen
- [ ] 6. Review & debug (overflow, responsif), uji alur lengkap di HP
- [ ] 7. GitHub kelompok + collaborator — repo terhubung & sudah di-push; **collaborator** ditambahkan oleh pemilik repo (TRAFIV/Taris), karena akun `samythh` hanya punya akses WRITE

## Status saat ini
- Langkah aktif: **6 — review & uji di HP**, dan **7 — collaborator** (menunggu pemilik repo)
- Flutter: `lib/theme/` (token = variabel Figma), `lib/models/ride.dart`, `lib/data/sample_rides.dart`
  (contoh data sampai REST API ada), `lib/widgets/` (AppButton, AppTextField, RideCard, UserAvatar),
  `lib/screens/` (login, home, ride_detail). Alur: Login (validasi email `unand.ac.id`) → Home (cari asal/tujuan)
  → Detail (validasi titik jemput, tombol "Ikut Nebeng!"). Tab selain Beranda = "belum tersedia".
- Teks UI gaya santai (Flutter + Figma + test sudah sama).
- `flutter analyze` bersih. ⚠️ `flutter test` diblokir Windows Application Control (`flutter_tester.exe`)
  di laptop Mikail — bukan error kode. Test ada di `test/widget_test.dart`.
- Uji HP (Infinix X6855, Android 16): app terpasang & dipakai tanpa overflow/exception di log.
  Teks santai belum dicek ulang di HP.
- **Logo**: gambar sudah ada (dua mahasiswa bonceng motor + tulisan "Nebeng Dong!") tapi **belum disimpan sebagai file**.
  Rencana: simpan WebP di `assets/images/logo.webp` (+ `2.0x/`, `3.0x/`), daftarkan di `pubspec.yaml`,
  ganti kotak "ND" + judul di Login (Flutter + Figma node 22:2).
- Figma selesai: komponen Button (21:6), Input Field (21:7), Ride Card (21:11), Bottom Navigation (21:24);
  layar Login (22:2), Home (22:22), Detail Tebengan (22:81); prototype Login→Home→Detail→Home.
  Semua ID ada di `docs/design-system-state-nebeng-dong.json`. Token & ukuran di `docs/Panduan Desain Figma.md`.
  Catatan: `get_metadata` tanpa nodeId hanya menampilkan halaman pertama — pakai `use_figma` untuk cek daftar halaman.
- Belum ada: ikon asli di Figma (masih kotak/lingkaran placeholder), foto avatar.

## Keputusan
- 3 layar: Login (email kampus), Home/cari tebengan searah, Detail tebengan + ajukan gabung.
- Font Roboto; teks UI bahasa Indonesia gaya santai.
- State management: `setState` (belum perlu Provider/Riverpod/Bloc).
- Domain email kampus diasumsikan `unand.ac.id` (belum ada di PRD).
- Semua docs (PRD, Modul, PDF) ikut di-push ke repo publik — keputusan Mikail, 2026-09-21.

## Log perubahan
Format: `YYYY-MM-DD — [AI] — apa yang dikerjakan — file/objek yang berubah`

- 2026-09-15 — Codex — Perbaiki NDK 28.2, CMake, Build Tools 36; app jalan di HP; Figma terhubung.
- 2026-09-15 — (AI sebelumnya) — Buat `CLAUDE.md` dan `design-system-state-nebeng-dong.json`.
- 2026-09-15 — Claude — Cek Figma; buat `PROGRESS.md` dan `AGENTS.md`; tambah aturan log di `CLAUDE.md`.
- 2026-09-15 — Claude — Tulis `docs/Panduan Desain Figma.md` (disesuaikan dengan token Figma yang ada).
- 2026-09-15 — Claude — Figma: buat 4 komponen (halaman 03–06), 3 layar + prototype (halaman 07); update state JSON.
- 2026-09-15 — Claude — Implementasi Flutter 3 layar + tema/komponen; ganti test counter dengan test alur. analyze OK, test diblokir Windows.
- 2026-09-15 — Claude — Build debug & install ke HP Infinix X6855 (Android 16) berhasil; app terbuka tanpa error.
- 2026-09-15 — Claude — Semua teks UI diganti gaya santai/tidak formal (Flutter + Figma + test). Contoh: "Gas Masuk!", "Cariin Tebengan!", "Ikut Nebeng!".
- 2026-09-21 — Claude — `docs/`, state Figma, `CLAUDE.md`, `AGENTS.md`, `PROGRESS.md` dipindah ke dalam repo Flutter; tambah `docs/Prompt Implementasi UI Flutter.md` (kerangka + versi terisi), subagent `.claude/agents/flutter-ui-implementer.md`, `README.md` proyek, folder `assets/images/2.0x|3.0x`; hubungkan ke GitHub TRAFIV/nebeng-dong-app dan push.
