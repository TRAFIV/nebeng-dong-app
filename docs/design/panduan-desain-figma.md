# Panduan Desain Figma — Nebeng Dong

Jawaban **Instruksi Prompt 2: Panduan Design Figma** (Modul 1, Bagian E) berdasarkan PRD Nebeng Dong.

Revisi 8 Oktober 2026: acuan [PRD 1.1](../prd/prd-nebeng-dong-kel-4.md) dan [rencana penumpang](../progress/rencana-aplikasi-penumpang.md). Target mobile hanya penerima/pencari tebengan. Figma bagian Mikail sudah direvisi dan ditinjau; node aktif dan arsip tercatat di JSON. Pada refactor source berikutnya tanggal 8 Oktober, struktur/role Flutter menjadi feature-first penumpang; hasil masih di Home dan seluruh rincian visual Figma belum diport. Bagian Figma bersama/rekan tetap baseline. Pernyataan source tidak diubah pada revisi Figma di bawah adalah riwayat tahap desain, bukan status setelah refactor kode.

## 3 Layar Utama (layar bersama)

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

Referensi gambar baru boleh dipakai untuk bentuk/susunan, bukan otomatis mengganti palet. Input lokasi tetap putih dengan border cloud, radius 20; titik asal/aksi coral, titik tujuan hijau. Tidak menambah lavender/pink di luar token bersama. Tidak ada selector Cari/Beri atau CTA pengemudi pada target baru; perbedaan status pesanan memakai label dan ikon, tidak hanya warna.

## Target UI satu role

Tiga layar Mikail yang sudah dibuat di Figma: **Cari Tebengan · Hasil Pencarian · Filter Pencarian**. Login dan Detail Tebengan tetap layar bersama; pembagian rinci perlu konfirmasi tim. Desain Posting Rute/Rute Saya lama adalah legacy, bukan target penumpang.

- Cari: field Dari/Ke bertumpuk, rail titik/garis, swap dan aksi pin rata kanan; alamat pin otomatis langsung terisi, alias tidak menggantikan alamat lengkap.
- Hasil: ringkasan lokasi, aksi Filter dan daftar Ride Card; ikon kursi/jam/ongkos, state loading/kosong/error/retry.
- Filter: jam, minimal kursi, batas ongkos, Terapkan/Atur Ulang; membatalkan draft tidak mengubah hasil.
- Detail: pengemudi sebagai informasi publik, rute/jadwal/kursi/ongkos, titik jemput/catatan dan Ajukan; tidak ada ACC atau edit rute.
- Target bottom navigation: **Cari · Pesanan · Ongkos · Profil**. Riwayat di Pesanan; rekap di Profil. Menu belum tersedia tidak dibuat seolah berfungsi.
- Status menunggu/diterima/ditolak berasal dari backend atau simulasi yang dijelaskan; tidak auto-ACC penumpang. Status bayar membedakan deklarasi dan konfirmasi penyedia.

## 1. Auto Layout

| Gunakan | Kapan |
|---|---|
| **Vertical (Column)** | Susunan layar dari atas ke bawah, isi form, isi kartu, daftar kartu |
| **Horizontal (Row)** | Elemen berdampingan: avatar + nama, bottom navigation, badge kursi + ongkos, tombol kembali + judul |

Per layar:

- **Login** — Frame Vertical. Header (Vertical: logo, judul, subjudul) → Form (Vertical: Input Email, Input Kata Sandi) → Button Masuk → Row "Belum punya akun? Daftar".
- **Cari** — Frame Vertical: sapaan/avatar → Kartu Pencarian Dari/Ke/swap/pin → Button Cari → Bottom Navigation.
- **Hasil Pencarian** — Top Bar → ringkasan pencarian + Filter → daftar Ride Card atau state kosong/error.
- **Filter** — Top Bar → form jam/kursi/ongkos → aksi Atur Ulang/Terapkan; scroll dan safe area.
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
| **M1/Location Input** (`121:58`) | Label, Address, Endpoint Icon, Place Name, Show Place Name; nama/alias terpisah dari alamat, pin kanan | 09 | Target adaptasi `LocationField`/`RouteEndpoints` |
| **M1/Passenger Navigation** (`121:69`) | Cari, Pesanan, Ongkos, Profil | 09 | Target adaptasi `NavigationBar` |
| **M1/Passenger Ride Card** (`121:94`) | Driver, Meta, Origin, Destination, Fare; ikon jam/kursi/ongkos | 09 | Target adaptasi `RideCard` |
| **M1/Place Result** (`147:28`) | Title, Address; hasil tempat dapat ditekan | 09 | Target hasil autocomplete |
| **M1/Place Search** (`147:38`) | Query; ikon pencarian | 09 | Target input pencarian lokasi |
| **M1/Map Preview** (`147:43`) | Ilustrasi peta editable, bukan data geospasial nyata | 09 | Target visual `OpenStreetMapView`, bukan aset peta produksi |

Ketiga layar di halaman `07 Product Screens` sudah tersusun dari komponen ini, bukan elemen lepas.
Komponen baru dibuat di halaman `09 Komponen Tambahan` agar bisa dipakai semua anggota.

## Desain dan prototype Mikail — selesai 8 Oktober 2026

Buka [section Mikail v1.1](https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum?node-id=124-239) pada halaman `08 Tugas Tim`.

| Layar/state | Node aktif |
|---|---|
| Cari Tebengan | `124:240` |
| Hasil Pencarian | `124:241` |
| Filter Pencarian | `124:242` |
| Loading / Kosong / Error | `130:403` / `130:507` / `130:614` |

Prototype utama **Cari → Hasil ↔ Filter** memiliki aksi Cari, Filter, Terapkan dan dua tombol kembali. Flow `Mikail · Penumpang v1.1` tetap tersedia dari Cari terisi. Flow pertama sekarang `Mikail · Mulai pilih Dari/Ke`, dimulai di form kosong `148:475`. State kosong menyediakan Ubah Pencarian; error menyediakan Coba Lagi menuju state loading. Feedback adalah contoh tampilan, bukan panggilan jaringan atau penerapan filter sesungguhnya.

Dari/Ke membuka pemilih tempat, pin kanan membuka peta, hasil tempat/konfirmasi pin kembali ke form, dan swap contoh asal–tujuan sudah tersambung. Pilihan chip, Atur Ulang, kartu → Detail dan tab modul rekan **belum interaktif**. Shared Detail berada di halaman lain dan tidak diubah; integrasi antarlayar bersama menunggu koordinasi, bukan dianggap selesai.

Komponen khusus M1 dan 12 ikon berada di area `121:4` pada halaman `09 Komponen Tambahan`, menggunakan variabel/text style bersama tanpa mengubah main component lama. Enam frame utama/feedback ditinjau pada revisi awal; rincian berikut menambah 18 frame pendukung 360×800, dengan pemeriksaan struktur semua frame tambahan dan screenshot kondisi representatif setelah perbaikan. Font Roboto, tanpa bitmap UI, placeholder ikon atau aksi pengemudi pada frame aktif. Bagian Taris/Shiddiq/Duha tetap.

Desain pengemudi asli `31:13`, `31:17`, `31:21` dipertahankan di section **Arsip PRD 1.0 — UI pengemudi (tidak aktif)** (`124:238`). Jangan gunakan arsip sebagai target implementasi baru.

Alur kelompok berikut tetap **target belum selesai**: Login → Cari → Hasil ↔ Filter → Detail → Titik Jemput → Status Permintaan. Keputusan status berasal dari backend, bukan layar pengemudi. Flutter/backend/HP tidak diubah pada revisi Figma ini.

## Rincian interaksi Dari/Ke dan pin — selesai 8 Oktober 2026

Buka [section Pemilih Lokasi & Pin](https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum?node-id=148-474), lalu Present dari [form kosong](https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum?node-id=148-475). Ini state pendukung **tiga layar utama Mikail**, bukan penambahan modul/role.

### Saat Dari atau Ke ditekan

1. Area field membuka **Pilih Dari** atau **Pilih Ke**; ikon kanan membuka **Pin Dari/Pin Ke** langsung.
2. Pemilih berisi tombol kembali, penjelasan asal/tujuan, kolom “Cari tempat atau alamat”, petunjuk minimal 3 karakter, hasil dengan **nama tempat + alamat lengkap**, serta tombol “Pilih langsung di peta”.
3. Menekan kolom dalam prototype membuka contoh hasil Khatib Sulaiman atau Universitas Andalas. Dalam implementasi Flutter, teks bebas dicari melalui Photon dengan debounce dan pengamanan respons lama; prototype bukan mesin pencarian.
4. Tekan hasil → kembali ke Cari. Nama tempat/alias dan alamat lengkap tampil terpisah; alamat tidak diganti hanya dengan nama pendek.
5. Dari dulu → form hanya asal; Ke dulu → form hanya tujuan. Tombol Cari tetap nonaktif sampai keduanya ada. Mengubah satu titik dari form terisi mempertahankan titik lainnya pada skenario contoh.
6. Tidak ditemukan → pesan kosong, “Coba nama lain” atau pilih peta. Kembali membatalkan pilihan yang belum dikonfirmasi.

### Saat memilih di peta

1. Peta menampilkan pencarian tempat, pin, area alamat, nama pin opsional, dan “Gunakan Pin Ini” di bawah. Tidak meminta GPS/lokasi perangkat.
2. Belum memilih titik → alamat kosong dan konfirmasi nonaktif. Ketuk salah satu titik contoh → pin muncul. Alur Dari menunjukkan “Mencari alamat pin…” sebelum alamat siap.
3. Alamat siap tampil **lengkap**. Nama pin opsional, misalnya “Gerbang utama”, tidak menghapus alamat atau koordinat.
4. Ketuk titik contoh lain → pin berpindah. Target Flutter menghitung ulang alamat untuk koordinat terbaru; respons lama tidak boleh menimpa pin baru.
5. Alamat gagal → “Coba lagi” atau “Isi alamat manual”. Contoh layar manual menyediakan alamat lengkap dan alias, lalu konfirmasi. Implementasi harus memvalidasi alamat dan mempertahankan koordinat yang dipilih.
6. “Gunakan Pin Ini” → kembali ke field yang dibuka, langsung menampilkan nama/alamat. Kembali tanpa konfirmasi tidak menerapkan draft.
7. Swap menukar **seluruh pasangan nama + alamat + koordinat** pada target Flutter, bukan teks saja. Prototype menukar contoh rute terisi; arah terbalik dicontohkan menuju hasil kosong, bukan janji setiap rute balik selalu kosong.

### Frame pendukung yang tersedia

| State | Node |
|---|---|
| Form kosong | `148:475` |
| Pilih Dari — awal / hasil tempat | `148:476` / `148:477` |
| Pin Dari — belum dipilih / mencari alamat / siap | `148:478` / `148:479` / `148:480` |
| Form hanya asal | `148:481` |
| Pilih Ke — awal / hasil tempat | `148:482` / `148:483` |
| Pin Ke — belum dipilih / siap | `148:484` / `148:485` |
| Form lokasi ditukar | `148:486` |
| Tempat tidak ditemukan / alamat pin gagal | `148:487` / `148:488` |
| Pin Dari / Ke dipindah | `148:489` / `158:474` |
| Form hanya tujuan | `168:920` |
| Isi alamat pin manual | `168:940` |

Flow terpisah tersedia untuk Ke lebih dulu, tempat tidak ditemukan, dan alamat pin gagal. Tujuh aksi pilih/konfirmasi menggunakan dua flag BOOLEAN private di koleksi **M1 Prototype Only**; 14 cabang tujuan diperiksa dari struktur aksi yang tersimpan. Flag hanya mengatur contoh prototype, **bukan** state aplikasi, kontrak backend, atau token Flutter.

### Batas prototype dan implementasi

- Peta adalah **ilustrasi skematis editable**, bukan tile OSM, koordinat nyata atau geocoding. Titik/nama/alamat hanya contoh; jangan digunakan sebagai fixture geospasial.
- Mengetik bebas, keyboard, edit alias bebas, pan/zoom bebas, GPS dan live tracking tidak berjalan di Figma. Aksi contoh hasil/pin/kembali/konfirmasi tersambung; tidak ada eksekusi pencarian/filter/backend nyata.
- Target aplikasi tetap `flutter_map` + OpenStreetMap, Photon autocomplete/reverse dan OSRM untuk geometry jalan, mengikuti [panduan layanan peta](../progress/peta-dan-lokasi.md) dan [kebijakan tile OSM](https://operations.osmfoundation.org/policies/tiles/) untuk atribusi/cache. Tidak ada tile publik diunduh untuk desain ini.
- Source Flutter, backend, APK/HP, layar bersama dan bagian rekan **tidak diubah** dalam tahap ini. Migrasi UI/state/named route tetap pekerjaan berikutnya bila diminta.
