# Panduan Desain Figma — Nebeng Dong

Jawaban **Instruksi Prompt 2: Panduan Design Figma** (Modul 1, Bagian E) berdasarkan PRD Nebeng Dong.

## 3 Layar Utama

| Layar | Alasan (PRD) |
|---|---|
| 1. Login | FR-17 — masuk dengan email kampus |
| 2. Home (Cari Tebengan) | FR-02, FR-03 — cari tebengan searah berdasarkan asal & tujuan |
| 3. Detail Tebengan | FR-04, FR-05, FR-06, FR-09 — lihat kursi, ongkos, tandai titik jemput, ajukan gabung |

## Dasar (sesuai variabel & style di Figma)

- **Frame:** Android 360 × 800
- **Font:** Roboto
- **Warna:**

| Variabel Figma | Hex | Pemakaian |
|---|---|---|
| `color/bg/brand` | `#0F766E` | tombol utama, ikon aktif |
| `color/bg/brand-subtle` | `#CCFBF1` | badge kursi, avatar |
| `color/accent/default` | `#F59E0B` | rating/highlight |
| `color/text/primary` | `#102A2A` | judul & isi |
| `color/text/secondary` | `#64748B` | subjudul, keterangan |
| `color/border/default` | `#E2E8F0` | garis input & kartu |
| `color/bg/default` | `#FFFFFF` | latar layar, kartu |

- **Spacing:** `spacing/sm` 8 · `spacing/md` 16 · `spacing/lg` 24
- **Radius:** `radius/md` 12
- **Bayangan kartu:** `Elevation/Card` (y 4, blur 12, 10%)

## 1. Auto Layout

| Gunakan | Kapan |
|---|---|
| **Vertical (Column)** | Susunan layar dari atas ke bawah, isi form, isi kartu, daftar kartu |
| **Horizontal (Row)** | Elemen berdampingan: avatar + nama, bottom navigation, badge kursi + ongkos, tombol kembali + judul |

Per layar:

- **Login** — Frame Vertical. Header (Vertical: logo, judul, subjudul) → Form (Vertical: Input Email, Input Kata Sandi) → Button Masuk → Row "Belum punya akun? Daftar".
- **Home** — Frame Vertical. Header (Horizontal: sapaan + avatar) → Kartu Pencarian (Vertical: Input Asal, Input Tujuan, Button Cari) → Judul "Tebengan searah" → Daftar Ride Card (Vertical) → Bottom Navigation (Horizontal, 4 item).
- **Detail Tebengan** — Frame Vertical. Top Bar (Horizontal: kembali + judul) → Kartu Pemberi (Horizontal: avatar + Vertical nama/rating) → Kartu Rute (Vertical: asal, tujuan, jam) → Row Info (kursi tersisa | ongkos per orang) → Input Titik Jemput → Button Ajukan Gabung.

## 2. Spacing & Padding

| Bagian | Nilai |
|---|---|
| Padding tepi layar | 16 (Login: 24) |
| Jarak antar-bagian | 24 |
| Jarak antar-elemen dalam bagian / antar-kartu | 16 |
| Jarak label ↔ input, avatar ↔ nama | 8 |
| Padding dalam kartu & input | 16 |
| Tinggi tombol & input | 48 (target sentuh minimum) |

## 3. Hierarki Teks (Roboto)

| Text style Figma | Ukuran / Tebal | Contoh |
|---|---|---|
| Judul — `Heading/Large` | 28 / Bold | "Nebeng Dong", "Hai, Mikail!" |
| Subjudul — `Heading/Medium` | 22 / Bold | "Yang searah sama kamu", "Info Tebengan" |
| Isi besar — `Body/Large` | 16 / Regular | deskripsi di bawah judul |
| Isi — `Body/Medium` | 14 / Regular | alamat rute, placeholder, keterangan |
| Label — `Label/Large` | 14 / Medium | teks tombol, label input, nama |

## 4. Komponen Reusable (dibuat terlebih dahulu)

| Komponen | Varian / Properti | Dipakai di |
|---|---|---|
| **Button** | Type = Primary, Secondary · teks Label | Login, Home, Detail |
| **Input Field** | teks Label, Placeholder | Login, Home, Detail |
| **Ride Card** | Driver, Meta, Origin, Destination, Seats, Fare | Home |
| **Bottom Navigation** | Beranda, Riwayat, Ongkos, Profil | Home |

## Alur Prototype

Login —(tap Masuk)→ Home —(tap Ride Card)→ Detail Tebengan —(tap Kembali)→ Home
