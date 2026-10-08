# nebeng-dong-app

**Nebeng Dong** — aplikasi pencari tebengan antar mahasiswa, ditargetkan khusus penumpang.
Project Mobile Programming, Kelompok 4.

Target [PRD 1.1](docs/prd/prd-nebeng-dong-kel-4.md), revisi 8 Oktober 2026: mahasiswa mencari rute searah, mengajukan permintaan, mengikuti status, mencatat ongkos dan memberi rating. Pengemudi adalah data penyedia dari backend/admin, bukan role atau layar pada aplikasi mobile ini. Aplikasi pengemudi terpisah ditunda.

## Tim

| Nama | NIM |
|---|---|
| Taris Rafivdean | 2411523013 |
| Mikail Samyth Habibillah | 2411523016 |
| M Shiddiq Maihendra | 2411523035 |
| Duha Alul Bariq | 2411523036 |

## Tahap saat ini

Source sekarang **MVVM feature-first dan penumpang saja** (8 Oktober 2026): tidak ada Beri Tebengan/Rute Saya; named routes driver ditolak. Driver lama dipertahankan sebagai arsip yang tidak diimpor source aktif. Repository rute read-only diinjeksikan satu sesi dari root aplikasi; implementasi lokal terpisah dari kontraknya.

Pencarian/filter masih menampilkan hasil di Home, belum layar Hasil terpisah seperti target Figma. Pemilih tempat/pin OSM, reverse alamat, swap dan workflow catatan dipertahankan. Navigasi Pesanan/Ongkos/Profil terlihat tetapi nonaktif sampai integrasi modul rekan.

Data aplikasi menggunakan empat **fixture latihan**, bukan tawaran nyata/backend: jalur Khatib/Veteran → Unand, rute penuh dan arah pulang. Geometry jalan nyata OSRM/OpenStreetMap disimpan satu kali, tanpa routing saat startup; asal/provenance ada di [fixture](lib/features/ride_search/data/fixtures/README.md). Login/booking tetap lokal; REST/persistensi/approval dan fitur ongkos/rating belum tersedia. Jangan menyebut app siap produksi atau seluruh PRD selesai.

Figma Mikail tersedia: [Cari/Hasil/Filter](https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum?node-id=124-239) dan [rincian lokasi/pin](https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum?node-id=148-474). Source belum memport seluruh state/susunan Figma. Baca [rencana penumpang](docs/progress/rencana-aplikasi-penumpang.md) dan [status verifikasi](docs/progress/PROGRESS.md). HP tidak diuji atau diinstal ulang pada refactor ini.

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
  core/di/               lifecycle dan injeksi repository/layanan
  features/
    auth/                login bersama: views + viewmodels
    ride_search/         Mikail: views + viewmodels + models + data + utils
    booking/             Taris: catatan baseline; batas integrasi pesanan
    costs/               Shiddiq: README ownership, belum implementasi
    reputation/          Duha: README ownership, belum implementasi
  shared/                models, views, viewmodels, widgets, utils
    maps/                services, models, views, viewmodels, widgets
  legacy/driver/         arsip dua role, tidak diimpor aplikasi aktif
  routes/                named routes penumpang dan fallback 404
  theme/                 token bersama tetap di lokasi semula
test/                    architecture/, core/, features/, integration/,
                         shared/, regression/, legacy/, visual/, support/
docs/                    sumber Markdown dan log
```

## Dokumen

- [PRD 1.1](docs/prd/prd-nebeng-dong-kel-4.md) — acuan aktif penumpang saja; PDF v1.0 adalah arsip dua role.
- [Rencana penumpang](docs/progress/rencana-aplikasi-penumpang.md) — UI, batas backend, tahapan migrasi, demo UTS.
- [Arsitektur MVVM](docs/architecture/mvvm.md) — View/ViewModel/repository, core dan lifecycle; tanpa dependency state-management baru.
- [Modul 1](docs/modul/modul-1-pemrograman-mobile.md) — instruksi praktikum.
- [Panduan Desain Figma](docs/design/panduan-desain-figma.md) — Auto Layout, spacing, tipografi, komponen.
- [Prompt Implementasi UI Flutter](docs/prompts/prompt-implementasi-ui-flutter.md) — kerangka prompt dan versi yang kami isi.
- [Pembagian Tugas](docs/progress/pembagian-tugas.md) — modul per anggota dan usulan layar satu role yang perlu konfirmasi tim.
- Desain Figma: https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum

## Kerja dengan AI

- `CLAUDE.md` — aturan kerja untuk Claude Code.
- `.claude/agents/flutter-ui-implementer.md` — subagent Claude untuk implementasi UI dari PRD + Figma.
- `AGENTS.md` — aturan untuk AI lain (Codex, dll.).
- `docs/progress/PROGRESS.md` — rencana, status, dan log perubahan; dibaca setiap ganti AI.

## Lisensi

Lihat [LICENSE](LICENSE).
