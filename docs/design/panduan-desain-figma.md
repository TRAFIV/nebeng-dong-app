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
| `color/bg/default` | `#F6F7FB` | latar layar |
| `color/bg/surface` | `#FFFFFF` | kartu, input, bottom navigation |
| `color/bg/brand` | `#F2603F` | tombol utama (coral) |
| `color/icon/brand` | `#D9491F` | ikon dan teks aksi di latar terang |
| `color/bg/brand-subtle` | `#FFE9E2` | chip, avatar, kotak info |
| `color/bg/success-subtle` | `#DCF3E8` | latar badge sisa kursi |
| `color/text/success` | `#0F7A52` | teks badge sisa kursi |
| `color/accent/default` | `#22A06B` | aksen hijau |
| `color/bg/accent-subtle` | `#FFC542` | aksen kuning |
| `color/text/primary` | `#1B2440` | judul dan isi |
| `color/text/secondary` | `#7A8299` | subjudul dan keterangan |
| `color/text/on-brand` | `#FFFFFF` | teks di atas coral |
| `color/border/default` | `#E7E9F2` | garis input dan kartu |

- **Spacing:** `spacing/sm` 8 · `spacing/md` 16 · `spacing/lg` 24
- **Radius:** `radius/md` 20
- **Bayangan kartu:** `Elevation/Card` (y 6, blur 16, navy 8%) — kartu tanpa garis tepi

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

| Komponen | Varian / Properti | Halaman Figma | Flutter |
|---|---|---|---|
| **Button** | Type = Primary, Secondary · Label | 03 | `AppButton` |
| **Input Field** | Label, Placeholder | 04 | `AppTextField` |
| **Ride Card** | Driver, Meta, Origin, Destination, Fare | 05 | `RideCard` |
| **Bottom Navigation** | 4 menu | 06 | `NavigationBar` |
| **Avatar** | Initial | 09 | `UserAvatar` |
| **Badge** | Type = Success, Brand, Neutral · Label | 09 | `StatusBadge` |
| **Info Tile** | Type = Brand, Success · Label, Value | 09 | `InfoTile` |
| **Top Bar** | Title | 09 | `AppBar` |
| **Section Header** | Title, Action | 09 | `SectionHeader` |

Ketiga layar di halaman `07 Product Screens` sudah tersusun dari komponen ini, bukan elemen lepas.
Komponen baru dibuat di halaman `09 Komponen Tambahan` agar bisa dipakai semua anggota.

## Alur Prototype

Login —(tap Masuk)→ Home —(tap Ride Card)→ Detail Tebengan —(tap Kembali)→ Home
