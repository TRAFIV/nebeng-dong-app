# nebeng-dong-app

**Nebeng Dong** — aplikasi nebeng & berbagi tebengan antar mahasiswa.
Project Mobile Programming, Kelompok 4.

Mahasiswa yang searah ke kampus bisa saling berbagi tumpangan: pemberi tebengan
memposting rute, pencari tebengan mencari yang searah, lalu ongkosnya dibagi dan
dicatat dengan jelas.

## Tim

| Nama | NIM |
|---|---|
| Taris Rafivdean | 2411523013 |
| Mikail Samyth Habibillah | 2411523016 |
| M Shiddiq Maihendra | 2411523035 |
| Duha Alul Bariq | 2411523036 |

## Tahap saat ini (Modul 1)

Tiga layar utama dari desain Figma sudah diimplementasikan:

1. **Login** — masuk dengan email kampus (`unand.ac.id`).
2. **Home / Cari Tebengan** — cari berdasarkan lokasi asal dan tujuan.
3. **Detail Tebengan** — sisa kursi, patungan per orang, titik jemput, tombol "Ikut Nebeng!".

Backend (REST API) belum ada, jadi daftar tebengan masih memakai contoh data
di `lib/data/sample_rides.dart`.

## Menjalankan

```bash
flutter pub get
flutter run          # pilih HP Android / emulator
flutter analyze
flutter test
```

## Struktur folder

```text
lib/
  main.dart
  data/       contoh data sementara
  models/     model data (Ride)
  screens/    satu file per layar
  theme/      design token dari Figma (warna, teks, spacing, ThemeData)
  utils/      fungsi bantu (format rupiah)
  widgets/    komponen reusable (AppButton, AppTextField, RideCard, UserAvatar)
assets/images/  aset WebP (1x, 2.0x/, 3.0x/)
docs/           prd/, modul/, design/, prompts/, progress/ (lihat docs/README.md)
test/           widget test
```

## Dokumen

- [PRD](docs/prd/prd-nebeng-dong-kel-4.md) — kebutuhan produk (sumber kebenaran).
- [Modul 1](docs/modul/modul-1-pemrograman-mobile.md) — instruksi praktikum.
- [Panduan Desain Figma](docs/design/panduan-desain-figma.md) — Auto Layout, spacing, tipografi, komponen.
- [Prompt Implementasi UI Flutter](docs/prompts/prompt-implementasi-ui-flutter.md) — kerangka prompt dan versi yang kami isi.
- Desain Figma: https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum

## Kerja dengan AI

- `CLAUDE.md` — aturan kerja untuk Claude Code.
- `.claude/agents/flutter-ui-implementer.md` — subagent Claude untuk implementasi UI dari PRD + Figma.
- `AGENTS.md` — aturan untuk AI lain (Codex, dll.).
- `docs/progress/PROGRESS.md` — rencana, status, dan log perubahan; dibaca setiap ganti AI.

## Lisensi

Lihat [LICENSE](LICENSE).
