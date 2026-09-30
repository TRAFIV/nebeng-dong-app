# Pembagian Tugas — Nebeng Dong

Satu modul PRD per anggota, sesuai aturan project (PRD bagian 2.1).
Placeholder desainnya ada di Figma halaman **08 Tugas Tim**
(https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum), tiga frame kosong per orang.

| Modul | Anggota | NIM | Kebutuhan fungsional | Layar yang didesain |
|---|---|---|---|---|
| 1 — Rute & Tebengan | Mikail Samyth Habibillah | 2411523016 | FR-01 – FR-04 | Posting Rute · Rute Saya · Filter Pencarian — **desain selesai** |
| 2 — Pemesanan & Koordinasi | Taris Rafivdean | 2411523013 | FR-05 – FR-08 | Permintaan Masuk · Titik Jemput · Status Permintaan |
| 3 — Berbagi Ongkos | M Shiddiq Maihendra | 2411523035 | FR-09 – FR-12 | Rincian Ongkos · Konfirmasi Pelunasan · Riwayat Ongkos |
| 4 — Reputasi & Riwayat | Duha Alul Bariq | 2411523036 | FR-13 – FR-16 | Riwayat Perjalanan · Beri Rating · Profil & Rekap |

Registrasi & keamanan (FR-17, FR-18) berlaku lintas modul dan sudah tercakup di layar Login.

Modul 1 bisa dipakai sebagai contoh: ketiga layarnya sudah didesain penuh dari komponen di blok Mikail
(halaman `08 Tugas Tim`), lengkap dengan prototype Rute Saya ↔ Posting Rute.

## Aturan desain bersama

1. Pakai komponen yang sudah ada: halaman `03 Button`, `04 Input`, `05 Ride Card`, `06 Bottom Navigation`,
   dan `09 Komponen Tambahan` (Avatar, Badge, Info Tile, Top Bar, Section Header).
   Komponen baru dibuat di halaman `09` supaya bisa dipakai bersama.
2. Pakai variabel warna/spacing dan text style yang sudah ada — jangan mengetik warna manual.
3. Contoh jadi ada di halaman `07 Product Screens` (Login, Beranda, Detail Tebengan).
4. Ukuran frame 360 × 800; padding tepi 16; jarak antar-bagian 24; tinggi tombol/input 48.
5. Gaya bahasa santai, misalnya "Gas Masuk!", "Cariin Tebengan!", "Ikut Nebeng!".
6. Butuh komponen baru? Buat di halaman `09 Komponen Tambahan` lalu kabari di grup supaya tidak dobel.
7. Tiap blok anggota berupa **Section**, jadi frame layarnya bisa langsung disambung prototype (tab Prototype).

Detail token dan struktur Auto Layout ada di [panduan desain](../design/panduan-desain-figma.md).

## Setelah desain selesai

Implementasi Flutter mengikuti [prompt implementasi UI](../prompts/prompt-implementasi-ui-flutter.md)
bagian B, dan hasilnya dicatat di [PROGRESS.md](PROGRESS.md).
