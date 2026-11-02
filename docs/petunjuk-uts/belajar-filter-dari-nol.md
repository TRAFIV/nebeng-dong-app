# Belajar Fitur Filter dari Nol

Satu file berisi semuanya: masalah yang diselesaikan, arti setiap folder, MVVM,
urutan pembuatan kode, penjelasan **baris per baris**, alasan setiap pilihan,
batasan, latihan, dan bekal tanya jawab UTS.

Ditulis untuk pembaca yang **belum tahu apa-apa**. Bacalah dari atas ke bawah,
jangan meloncat. Setiap bab memakai istilah yang sudah dijelaskan di bab
sebelumnya. Kode di sini sama persis dengan file aslinya per 15 Oktober 2026,
dan nomor barisnya juga sama. Buka file aslinya di VS Code sambil membaca.

## Daftar isi

1. [Masalah yang mau diselesaikan](#1-masalah-yang-mau-diselesaikan)
2. [Bekal dasar: Flutter dan Dart secukupnya](#2-bekal-dasar-flutter-dan-dart-secukupnya)
3. [Kenapa kodenya dipisah-pisah (MVVM)](#3-kenapa-kodenya-dipisah-pisah-mvvm)
4. [Peta folder: siapa tinggal di mana](#4-peta-folder-siapa-tinggal-di-mana)
5. [Urutan pembuatan, dan kenapa urutannya begitu](#5-urutan-pembuatan-dan-kenapa-urutannya-begitu)
6. [Langkah 0 — Fondasi yang sudah ada](#6-langkah-0--fondasi-yang-sudah-ada)
7. [Langkah 1 — Model: `ride_filter.dart`](#7-langkah-1--model-ride_filterdart)
8. [Langkah 2 — ViewModel: `ride_filter_view_model.dart`](#8-langkah-2--viewmodel-ride_filter_view_modeldart)
9. [Langkah 3 — View: `ride_filter_screen.dart`](#9-langkah-3--view-ride_filter_screendart)
10. [Langkah 4 — Route: `app_routes.dart`](#10-langkah-4--route-app_routesdart)
11. [Langkah 5 — Menyambungkan ke layar Hasil](#11-langkah-5--menyambungkan-ke-layar-hasil)
12. [Langkah 6 — Tes: bukti kodenya benar](#12-langkah-6--tes-bukti-kodenya-benar)
13. [Alur lengkap saat aplikasi dipakai](#13-alur-lengkap-saat-aplikasi-dipakai)
14. [Kenapa begini, bukan begitu?](#14-kenapa-begini-bukan-begitu)
15. [Batasan yang harus diakui jujur](#15-batasan-yang-harus-diakui-jujur)
16. [Latihan "Coba ubah…"](#16-latihan-coba-ubah)
17. [Bekal tanya jawab dosen](#17-bekal-tanya-jawab-dosen)
18. [Kamus tata bahasa Dart](#18-kamus-tata-bahasa-dart)

---

## 1. Masalah yang mau diselesaikan

**Nebeng Dong** mempertemukan mahasiswa yang punya kendaraan (pemberi tebengan)
dengan mahasiswa yang butuh tumpangan (penumpang). Modul 1 milik Mikail adalah
"Rute & Tebengan": penumpang mencari tebengan yang searah.

Alurnya dari sisi penumpang:

1. Di **Beranda**, penumpang memilih **Dari** (mis. Khatib Sulaiman) dan **Ke**
   (mis. Unand), lalu menekan **Cariin Tebengan!**
2. Layar **Hasil Pencarian** menampilkan tebengan yang searah, mis. "2 tebengan searah".
3. Hasilnya bisa terlalu banyak atau tidak cocok. Penumpang mungkin cuma mau
   yang berangkat jam 07.00–08.00, butuh 2 kursi untuk dirinya dan temannya,
   atau tidak mau membayar lebih dari Rp10.000.
4. Karena itu ada tombol **Filter**. Tombol ini membuka layar **Filter Pencarian**
   dengan tiga pilihan: **jam cabut**, **minimal kursi**, dan **batas ongkos**.
5. Penumpang menekan **Terapkan**. Layar Filter tertutup, dan layar Hasil
   langsung menampilkan tebengan yang lolos, misalnya "1 tebengan searah",
   dengan tombol berubah menjadi **Filter aktif**.

Inilah **workflow** yang didemokan saat UTS:
**Input → Event → State → Validation → Feedback → Navigation/Result.**
Bab 13 menunjukkan letak keenam tahap itu di kode.

---

## 2. Bekal dasar: Flutter dan Dart secukupnya

### 2.1 Dart dan Flutter

- **Dart** adalah bahasa pemrogramannya, seperti bahasa Indonesia sebagai bahasanya.
- **Flutter** adalah kumpulan alat untuk membuat tampilan aplikasi dengan Dart,
  seperti kotak perkakas berisi tombol, teks, dan daftar yang sudah jadi.

### 2.2 Kelas dan objek

**Kelas (class)** adalah **cetakan**. **Objek** adalah **barang hasil cetakan**.

Analogi: cetakan kue berbentuk bintang adalah kelas. Setiap kue bintang yang
keluar dari cetakan adalah objek. Satu cetakan bisa menghasilkan banyak kue,
dan isi tiap kue boleh berbeda (rasa cokelat, rasa keju).

```dart
class RideFilter {            // cetakan "filter"
  final int minimumSeats;     // data yang dibawa setiap filter
}

const filterA = RideFilter(minimumSeats: 2);  // kue pertama
const filterB = RideFilter(minimumSeats: 3);  // kue kedua
```

Kelas berisi dua hal:

- **field**: data yang dibawa, misalnya `minimumSeats`.
- **method**: hal yang bisa dikerjakan, misalnya `matches(ride)` untuk memeriksa
  apakah sebuah tebengan lolos filter.

### 2.3 Pewarisan: `extends`

`class B extends A` artinya **B mewarisi semua kemampuan A, lalu menambah
kemampuannya sendiri**.

Analogi: kamu mewarisi warna mata dari orang tuamu, tapi kamu juga punya
keahlian sendiri. `RideFilterViewModel extends ViewModel` artinya
RideFilterViewModel otomatis bisa melakukan semua yang bisa dilakukan
`ViewModel` (misalnya `publish()`), ditambah kemampuannya sendiri
(misalnya `selectSeats()`).

### 2.4 Tanda `< >` (generic)

Isi `< >` selalu berupa **tipe data**. Artinya: "wadah atau kelas ini dipakai
untuk tipe itu".

- `List<Ride>` artinya daftar yang isinya Ride.
- `GlobalKey<FormState>` artinya kunci yang menunjuk ke FormState.
- `State<RideFilterScreen>` artinya State milik RideFilterScreen.
- `Navigator.pushNamed<RideFilter>(...)` artinya buka layar yang nanti
  **mengembalikan** sebuah RideFilter.

Analogi: kotak bekal bertuliskan "untuk nasi". Kotaknya sama, labelnya yang
memberi tahu isinya. Kalau kamu memasukkan sepatu, Dart langsung protes sebelum
aplikasi dijalankan. Itulah gunanya: **kesalahan ketahuan lebih awal**.

### 2.5 Widget

Semua yang tampil di layar Flutter adalah **widget**: teks, tombol, jarak,
baris, kolom, sampai satu layar penuh. Widget disusun bertumpuk seperti
**kotak di dalam kotak**:

```text
Scaffold (kerangka layar)
├── AppBar (bilah atas)  →  Text('Filter Pencarian')
└── body: ListView (daftar yang bisa digulir)
      ├── Text(...)
      ├── Row → [tombol jam, tombol jam]
      └── AppTextField (kolom ongkos)
```

Setiap widget punya fungsi **`build`**, yaitu resep yang menjawab "aku terlihat
seperti apa?". Flutter memanggil `build` setiap kali layar perlu digambar ulang.

### 2.6 StatelessWidget dan StatefulWidget

| | StatelessWidget | StatefulWidget |
|---|---|---|
| Arti | widget yang tidak menyimpan apa pun | widget yang punya **teman pendamping** (objek `State`) untuk menyimpan hal yang harus bertahan |
| Analogi | papan nama: tulisannya tetap | papan tulis kelas: tulisannya bisa dihapus dan ditulis ulang |
| Contoh di proyek | `AppTextField`, `AppButton` | `RideFilterScreen`, `RideResultsScreen` |

Kenapa StatefulWidget butuh dua kelas? Flutter sering **membuang dan membuat
ulang** widget, ratusan kali selama aplikasi berjalan. Kalau controller kolom
isian disimpan di widget, isinya ikut hilang setiap kali widget dibuat ulang.
Karena itu, hal yang harus bertahan disimpan di objek **State**, yang hidup
selama layar terbuka.

### 2.7 State

**State** adalah **keadaan yang bisa berubah dan memengaruhi tampilan**.
Contoh: jam mana yang sedang dipilih, berapa kursi yang dipilih, dan apakah
data sedang dimuat. Kalau state berubah, layar harus digambar ulang supaya
tampilannya sesuai.

### 2.8 `context`

`context` adalah **alamat sebuah widget di dalam pohon widget**. Navigator
membutuhkannya untuk tahu "layar mana yang sedang aktif, dan ke mana layar
baru ditumpuk". Analogi: alamat rumah saat memesan ojek.

### 2.9 Navigator: tumpukan layar

Layar-layar di aplikasi tersusun seperti **tumpukan piring**:

- `Navigator.pushNamed(...)` menaruh piring (layar) baru di atas tumpukan.
- `Navigator.pop(context, hasil)` mengambil piring teratas, dan boleh sekalian
  **menitipkan hasil** ke layar di bawahnya.

```text
push Filter:       [Beranda] [Hasil] [Filter]   ← Filter di paling atas
pop dengan hasil:  [Beranda] [Hasil]            ← Hasil menerima RideFilter
```

Tata bahasa Dart lainnya (`?`, `!`, `??`, `late`, `final`, `=>`, dan lain-lain)
dijelaskan saat pertama kali muncul di kode. Rangkumannya ada di
[Bab 18](#18-kamus-tata-bahasa-dart).

---

## 3. Kenapa kodenya dipisah-pisah (MVVM)

### 3.1 Masalah kalau semua ditaruh di satu layar

Bayangkan semua kode filter ditulis di satu file layar: tampilan tombol,
aturan "jam 07.30 masuk rentang mana", validasi ongkos, dan penyaringan
tebengan. Akibatnya:

1. **Satu file sangat panjang.** Mencari bagian tertentu jadi sulit.
2. **Aturan tidak bisa dites tanpa membuka layar.** Untuk mengecek "apakah ongkos
   0 ditolak", kita harus menggambar seluruh layar dulu.
3. **Aturan tidak bisa dipakai ulang.** Kalau layar lain butuh aturan yang sama,
   kodenya terpaksa disalin, dan salinan mudah berbeda satu sama lain.
4. **Mengubah tampilan berisiko merusak aturan.** Keduanya bercampur di satu tempat.

### 3.2 Solusinya: bagi tugas seperti di restoran

**MVVM** singkatan dari **Model – View – ViewModel**. Ini cara membagi kode
menjadi tiga peran, mirip pembagian tugas di restoran:

| Peran | Di restoran | Di aplikasi | File filter |
|---|---|---|---|
| **Model** | **buku resep dan aturan menu**: apa itu "nasi goreng", bahannya apa | bentuk data dan aturan dasarnya. Tidak tahu soal layar sama sekali. | `models/ride_filter.dart` |
| **ViewModel** | **pelayan**: mencatat pesanan sementara, mengecek "menu ini tersedia?", lalu menyerahkan pesanan final | menyimpan **state** layar, memeriksa isian, menyiapkan hasil. Tidak menggambar apa pun. | `viewmodels/ride_filter_view_model.dart` |
| **View** | **meja dan buku menu yang dilihat tamu** | menggambar tampilan dan meneruskan ketukan pengguna ke ViewModel | `views/ride_filter_screen.dart` |

Arah komunikasinya:

```text
Pengguna mengetuk
      │
      ▼
   VIEW  ──(memanggil aksi: selectSeats(2))──▶  VIEWMODEL  ──(memakai)──▶  MODEL
      ▲                                              │
      └──────(publish(): "state berubah!")───────────┘
   View menggambar ulang
```

- View **boleh** memanggil ViewModel.
- ViewModel **tidak boleh** menyentuh View. Ia tidak tahu tombol, warna, atau
  Navigator. Ia cukup mengumumkan "state-ku berubah", dan View yang mendengar
  akan menggambar ulang.

### 3.3 Aturan proyek ini dijaga oleh tes

Supaya aturan MVVM tidak dilanggar tanpa sengaja,
[test/architecture/architecture_test.dart](../../test/architecture/architecture_test.dart)
memeriksa bahwa file ViewModel **tidak** memakai `BuildContext`, `Navigator`,
`TextEditingController`, `GlobalKey`, atau `package:flutter/material.dart`.
Kalau ada yang melanggar, tes gagal.

### 3.4 Batas MVVM yang perlu diketahui

- Kode jadi **lebih banyak file**. Untuk layar yang sangat sederhana, pemisahan
  ini bisa terasa berlebihan.
- Ada "jembatan" yang tetap tinggal di View: controller kolom isian, `GlobalKey`
  form, dan `Navigator`. Semuanya objek tampilan, jadi memang tempatnya di View.

---

## 4. Peta folder: siapa tinggal di mana

Semua kode Dart aplikasi ada di folder `lib/`. Proyek ini memakai susunan
**feature-first**: kode dikelompokkan **per fitur dulu**, baru per peran
(model, viewmodel, view).

Analogi: sekolah yang dibagi **per kelas** (kelas 1, kelas 2), dan di dalam
setiap kelas ada meja guru, papan tulis, dan lemari. Bukan sekolah yang semua
meja gurunya dikumpulkan di satu ruangan dan semua papan tulisnya di ruangan lain.
Hasilnya, semua yang berhubungan dengan "cari tebengan" ada di satu tempat.

```text
lib/
├── main.dart                 Pintu masuk aplikasi. Mendaftarkan router dan tema.
├── core/                     Fondasi yang dipakai semua fitur.
│   ├── view_model.dart       Induk semua ViewModel (punya publish()).
│   └── di/                   "Penyalur" repository dan layanan peta ke layar.
├── features/                 Satu folder per fitur.
│   └── ride_search/          Fitur cari tebengan (Modul 1 – Mikail).
│       ├── models/           DATA dan ATURAN: RideFilter, RideSearchRequest.
│       ├── viewmodels/       STATE layar: RideFilterViewModel, dll.
│       ├── views/            LAYAR: RideFilterScreen, RideResultsScreen, HomeScreen.
│       ├── widgets/          Potongan tampilan khusus fitur ini (kartu tebengan).
│       ├── data/             SUMBER DATA: repository dan data contoh (fixtures).
│       └── utils/            Hitungan bantu: apakah rute searah, penyaring hasil.
├── routes/
│   └── app_routes.dart       Daftar alamat layar ("/ride-filter") dan pembuat rutenya.
├── shared/                   Dipakai lebih dari satu fitur.
│   ├── models/ride.dart      Data satu tebengan (Ride).
│   ├── widgets/              Komponen dari Figma: AppButton, AppTextField.
│   ├── utils/                Alat kecil: formatRupiah, formatThousands.
│   ├── maps/                 Peta, pencarian tempat, rute jalan.
│   └── views/                Layar umum: halaman 404, detail tebengan.
└── theme/                    Warna, jarak, ukuran, gaya teks (token Figma).
```

Kenapa `Ride` ada di `shared/` dan bukan di `ride_search/`? Karena `Ride`
dipakai oleh banyak fitur: cari tebengan, detail, pemesanan, dan nanti fitur
teman setim. Sebaliknya, `RideFilter` hanya dipakai fitur cari tebengan, jadi
tempatnya di `features/ride_search/models/`.

> Catatan: folder kosong `lib/models`, `lib/screens`, `lib/utils`,
> `lib/viewmodels`, `lib/widgets`, dan `lib/data` hanyalah sisa susunan lama.
> Folder itu tidak berisi apa pun dan tidak ikut tersimpan di git.

---

## 5. Urutan pembuatan, dan kenapa urutannya begitu

Prinsipnya: **buat dulu bagian yang tidak bergantung pada bagian lain**.
Urutan ini mengikuti arah `import`. File yang di-import harus sudah ada
sebelum file yang meng-import-nya.

Analogi membangun rumah: **fondasi → dinding → atap → cat dan pintu**. Atap
tidak bisa dipasang sebelum ada dindingnya.

```text
Langkah 0  Fondasi (sudah ada):  Ride, ViewModel induk, tema, AppButton, AppTextField
    │
Langkah 1  MODEL       ride_filter.dart            ← hanya butuh Ride
    │                  "Apa itu filter? Kapan sebuah tebengan lolos?"
Langkah 2  VIEWMODEL   ride_filter_view_model.dart ← butuh Model + ViewModel induk
    │                  "Apa yang sedang dipilih? Isian ongkos benar?"
Langkah 3  VIEW        ride_filter_screen.dart     ← butuh ViewModel + Model + widget
    │                  "Seperti apa tampilannya? Apa yang terjadi saat diketuk?"
Langkah 4  ROUTE       app_routes.dart             ← butuh View
    │                  "Alamat '/ride-filter' membuka layar apa?"
Langkah 5  SAMBUNGAN   ride_results_screen.dart + ride_results_view_model.dart
    │                  "Layar Hasil membuka Filter dan memakai hasilnya."
Langkah 6  TES         memastikan Langkah 1–5 benar
```

**Kenapa Model dulu, bukan ViewModel?** Dugaanmu "yang dibuat duluan adalah
aturan" sudah benar, hanya saja aturan dasarnya tinggal di **Model**. Ada dua
macam aturan:

| Jenis aturan | Contoh | Tempatnya |
|---|---|---|
| **Aturan data** (berlaku di mana saja) | "tebengan lolos kalau kursinya cukup dan jamnya masuk rentang" | **Model** (`RideFilter.matches`) |
| **Aturan isian layar** (berlaku saat mengisi form) | "kolom ongkos harus rupiah bulat dan lebih dari 0" | **ViewModel** (`validateFare`) |

ViewModel **menghasilkan** sebuah `RideFilter`. Jadi kelas `RideFilter` harus
ada dulu. Kalau belum ada, ViewModel tidak punya "cetakan" untuk membuat hasilnya.

---

## 6. Langkah 0 — Fondasi yang sudah ada

Sebelum fitur filter dibuat, tiga hal ini sudah tersedia.

### 6.1 Data tebengan — `lib/shared/models/ride.dart`

Model `Ride` menggambarkan **satu tebengan**. Filter nanti memeriksa
field-field ini:

```dart
13      required this.departureTime,
...
15      required this.seatsAvailable,
16      required this.farePerPerson,
...
30    /// Jam berangkat, misalnya "07.30".
31    final String departureTime;
32    final int seatCapacity;
33    final int seatsAvailable;
34
35    /// Ongkos per penumpang dalam rupiah.
36    final int farePerPerson;
37    final RideGeography? geography;
38
39    bool get isFull => seatsAvailable <= 0;
```

- `departureTime`: jam berangkat, berupa **teks**, misalnya `"07.30"`.
- `seatsAvailable`: kursi yang masih kosong.
- `farePerPerson`: ongkos per orang dalam rupiah. *Fare* artinya ongkos. Di data
  contoh, `0` berarti **ongkos belum diatur**, bukan gratis.
- `geography`: jalur jalan tebengan, dipakai untuk mengecek searah atau tidak.
  Bertipe `RideGeography?`. Tanda **`?`** berarti boleh **kosong (`null`)**.
- `isFull`: **getter**, yaitu nilai yang dihitung saat dibaca. Isinya `true`
  kalau kursi kosong ≤ 0.
  - `get` artinya "terlihat seperti field, tapi dihitung".
  - `=>` artinya "hasilnya adalah…" (fungsi satu baris).

### 6.2 Induk semua ViewModel — `lib/core/view_model.dart`

```dart
 1  import 'package:flutter/foundation.dart';
 2
 3  /// Shared lifecycle for presentation state. No widgets, navigation or context.
 4  abstract class ViewModel extends ChangeNotifier {
 5    bool _disposed = false;
 6    bool get isDisposed => _disposed;
 7
 8    @protected
 9    void publish() {
10      if (!_disposed) notifyListeners();
11    }
12
13    @override
14    void dispose() {
15      _disposed = true;
16      super.dispose();
17    }
18  }
```

**Kenapa file ini ada?** Semua ViewModel butuh dua kemampuan yang sama:
mengumumkan perubahan, dan dibuang dengan aman saat layar ditutup. Daripada
menulisnya berulang di setiap ViewModel, keduanya ditulis sekali di sini lalu
**diwariskan**.

**Kenapa di `core/`?** Karena dipakai semua fitur, bukan hanya cari tebengan.

- **Baris 1**: memakai `foundation.dart`, yaitu bagian Flutter yang **tanpa
  widget**. Di sinilah `ChangeNotifier` berada. Karena tidak meng-import
  `material.dart`, ViewModel memang tidak bisa menggambar apa pun.
- **Baris 3**: `///` adalah komentar dokumentasi: "status layar bersama; tanpa
  widget, navigasi, atau context".
- **Baris 4**:
  - `abstract class`: kelas yang **tidak dipakai langsung**, hanya untuk
    diwarisi. Tidak ada yang menulis `ViewModel()`; yang dibuat selalu anaknya,
    misalnya `RideFilterViewModel()`.
  - `extends ChangeNotifier`: mewarisi kemampuan **pemberi kabar** milik
    Flutter. ChangeNotifier punya daftar pendengar (`addListener`) dan tombol
    "kabari semua pendengar" (`notifyListeners`).
  - Analogi: grup WhatsApp kelas. Siapa saja bisa bergabung (mendengar), dan
    admin bisa mengirim pengumuman ke semua anggota.
- **Baris 5**: `_disposed` mencatat "apakah ViewModel ini sudah dibuang?".
  Awalnya `false`. Nama yang diawali **`_`** berarti **privat**: hanya bisa
  dipakai di file ini.
- **Baris 6**: getter publik supaya file lain bisa **membaca** `_disposed`
  tanpa bisa mengubahnya.
- **Baris 8**: `@protected` adalah penanda bahwa fungsi di bawahnya hanya boleh
  dipanggil oleh **kelas turunan** (ViewModel anak), bukan oleh layar. Kalau
  layar memanggilnya, analyzer memberi peringatan.
  - **Kenapa bukan `_publish`?** Kalau privat, ViewModel anak di file lain
    tidak bisa memanggilnya.
- **Baris 9–11**: `publish()` artinya "umumkan bahwa state berubah". Fungsi ini
  hanya memanggil `notifyListeners()` kalau belum dibuang. Tanda `!` di depan
  `_disposed` artinya "tidak". Tanpa pengaman ini, mengirim kabar setelah
  dibuang akan menyebabkan error.
  - `void` artinya fungsi ini tidak mengembalikan nilai.
- **Baris 13**: `@override` adalah penanda bahwa fungsi ini **menimpa** fungsi
  induk yang namanya sama.
- **Baris 14–17**: saat layar ditutup, `dispose()` dipanggil. Baris 15 menandai
  ViewModel sudah dibuang, lalu baris 16 (`super.dispose()`) menjalankan
  pembersihan milik induk (ChangeNotifier). `super` artinya "induk saya".

### 6.3 Tema dan komponen

- `lib/theme/`: warna (`AppColors`), jarak (`AppSpacing.sm = 8`, `md = 16`,
  `lg = 24`), sudut (`AppRadius`), ukuran sentuh (`AppSizes.touchTarget = 48`),
  dan gaya teks (`AppTextStyles`). Semuanya disalin dari variabel Figma supaya
  aplikasi sama dengan desain. Kalau warna brand diganti di satu tempat, semua
  layar ikut berubah.
- `lib/shared/widgets/`: `AppButton` (tombol) dan `AppTextField` (kolom isian
  berlabel), masing-masing pasangan komponen Figma.
- `lib/shared/utils/rupiah_format.dart`: `formatThousands(10000)` menghasilkan
  `"10.000"`.

---

## 7. Langkah 1 — Model: `ride_filter.dart`

**Lokasi:** `lib/features/ride_search/models/ride_filter.dart`

**Folder `models/`** berisi **bentuk data dan aturan dasarnya**. File di sini
tidak tahu apa pun soal layar: tidak ada tombol, warna, atau Navigator. Karena
itu file model bisa dites tanpa membuka aplikasi.

**File ini berisi:**

1. `DepartureWindow`: daftar pilihan rentang jam cabut.
2. `RideFilter`: satu paket syarat penyaringan, dengan aturan
   `matches(ride)` untuk memeriksa "tebengan ini lolos atau tidak".
3. Dua fungsi pembaca teks: `parseDepartureMinute` dan `parseFare`.

### 7.1 Pilihan jam: `enum DepartureWindow`

```dart
 1  import 'package:praktikum_mobile/shared/models/ride.dart';
 2
 3  /// Rentang jam cabut, bersambung dari 06.00 sampai 19.00.
 4  /// Di luar itu, penumpang cukup tidak memilih jam (semua jam ditampilkan).
 5  enum DepartureWindow {
 6    early('06.00–07.00', 360, 420),
 7    morning('07.00–08.00', 420, 480),
 8    lateMorning('08.00–09.00', 480, 540),
 9    midday('Siang 09.00–15.00', 540, 900),
10    afternoon('Sore 15.00–19.00', 900, 1140);
11
12    const DepartureWindow(this.label, this.startMinute, this.endMinute);
13    final String label;
14    final int startMinute;
15    final int endMinute;
16  }
```

- **Baris 1**: `import` memakai kode dari file lain. Kita butuh `Ride` karena
  nanti `matches` memeriksa sebuah Ride.
- **Baris 5**: `enum` adalah **daftar pilihan yang tetap**. Analogi: ukuran
  baju S, M, L, XL. Pilihannya hanya itu, tidak ada ukuran "agak M".
  - **Kenapa enum, bukan teks bebas?** Kalau teks bebas, orang bisa salah ketik
    ("07.00-0800") dan kode tidak bisa memeriksanya. Dengan enum, pilihannya
    pasti salah satu dari lima, dan Dart menolak nilai lain.
  - **Arti "window":** dalam bahasa Inggris, *time window* berarti **rentang
    waktu**. Jadi `DepartureWindow` = **rentang jam berangkat**, bukan jendela layar.
- **Baris 6–10**: lima pilihan, masing-masing membawa tiga nilai:
  1. **teks tombol** yang dilihat pengguna, misalnya `'07.00–08.00'`;
  2. **menit mulai**, dihitung sejak tengah malam: 07.00 = 7 × 60 = **420**;
  3. **menit selesai**, yang **tidak termasuk**: 08.00 = **480**.
  - **Kenapa disimpan dalam menit?** Membandingkan angka itu mudah dan pasti
    benar (450 ≥ 420 dan 450 < 480). Membandingkan teks "07.30" dengan "07.00"
    lebih rumit dan rawan salah.
  - **Kenapa rentangnya bersambung?** Selesai satu pilihan = mulai pilihan
    berikutnya (420→420, 480→480, …). Tidak ada jam yang jatuh di celah.
    Misalnya jam 12.00 masuk "Siang 09.00–15.00". Hal ini dijaga oleh tes.
  - Nama di kiri (`early`, `morning`) dipakai di kode. Teks di dalam kutip
    adalah yang tampil di layar.
- **Baris 10**: pilihan terakhir diakhiri `;`, bukan `,`, karena setelahnya
  ada bagian lain (konstruktor dan field).
- **Baris 12**: **konstruktor** adalah fungsi pembuat objek. `this.label`
  artinya "nilai pertama langsung masuk ke field `label`". `const` artinya
  nilainya tetap dan diketahui sejak awal.
- **Baris 13–15**: field setiap pilihan. **`final`** artinya **diisi sekali dan
  tidak bisa diganti**. `String` adalah teks, `int` adalah bilangan bulat.

### 7.2 Paket syarat: `class RideFilter`

```dart
18  /// Filter immutable: layar filter mengubah draft, bukan hasil Home langsung.
19  class RideFilter {
20    const RideFilter({this.window, this.minimumSeats = 1, this.maximumFare});
21
22    final DepartureWindow? window;
23    final int minimumSeats;
24    final int? maximumFare;
25
26    bool get isActive =>
27        window != null || minimumSeats != 1 || maximumFare != null;
```

- **Baris 18**: *immutable* artinya **tidak bisa diubah setelah dibuat**.
  Kalau mau mengganti filter, buat `RideFilter` baru.
  - **Kenapa?** Supaya filter yang sedang berlaku di layar Hasil **tidak ikut
    berubah** selama pengguna masih memilih-milih di layar Filter. Kalau
    pengguna menekan kembali tanpa Terapkan, filter lama tetap utuh.
- **Baris 20**: konstruktor dengan **parameter bernama**, ditandai kurung
  kurawal `{ }`. Saat dipakai, nama parameternya ditulis:
  `RideFilter(minimumSeats: 2)`. Ini lebih jelas daripada `RideFilter(null, 2, null)`.
  - Ketiganya **opsional**. Yang tidak diisi akan bernilai `null`, kecuali
    `minimumSeats` yang bawaannya `1`.
  - `const RideFilter()` (tanpa isi) = **filter kosong**, yaitu tidak
    menyaring apa pun selain tebengan penuh.
- **Baris 22**: `window` adalah rentang jam yang dipilih. Tipenya
  `DepartureWindow?`: tanda `?` berarti boleh `null`, dan **`null` artinya
  semua jam**.
- **Baris 23**: `minimumSeats` adalah minimal kursi kosong yang diminta.
- **Baris 24**: `maximumFare` adalah ongkos paling mahal. `null` artinya tidak dibatasi.
- **Baris 26–27**: getter `isActive` bernilai `true` kalau ada **salah satu**
  syarat yang bukan bawaan. `||` artinya "atau", `!=` artinya "tidak sama
  dengan". Dipakai layar Hasil untuk menulis "Filter aktif".

```dart
29    bool matches(Ride ride) {
30      if (ride.seatsAvailable < minimumSeats || ride.isFull) return false;
31      // Nilai 0 pada demo berarti ongkos belum diatur, bukan tebengan gratis.
32      if (maximumFare != null &&
33          (ride.farePerPerson == 0 || ride.farePerPerson > maximumFare!)) {
34        return false;
35      }
36      final selected = window;
37      if (selected == null) return true;
38      final minute = parseDepartureMinute(ride.departureTime);
39      return minute != null &&
40          minute >= selected.startMinute &&
41          minute < selected.endMinute;
42    }
43  }
```

Inilah **aturan inti fitur filter**: "apakah tebengan ini lolos?". Hasilnya
`bool`, yaitu `true` (lolos) atau `false` (gugur). Pemeriksaannya seperti
satpam yang mengecek satu per satu. Begitu ada satu syarat yang gagal,
tebengan langsung ditolak (`return false`) tanpa mengecek sisanya.

- **Baris 30**: gugur kalau kursi kosongnya kurang dari yang diminta,
  **atau** tebengannya sudah penuh.
- **Baris 32–35**: gugur kalau ada batas ongkos (`maximumFare != null`)
  **dan** (`&&`) ongkosnya belum diatur (`== 0`) atau lebih mahal dari batas.
  - **Kenapa ada kurung di dalam kurung?** Di Dart, `&&` dikerjakan **lebih
    dulu** daripada `||`, seperti perkalian sebelum penjumlahan. Tanpa kurung
    dalam, Dart membacanya sebagai `(ada batas && ongkos 0) || ongkos > batas!`.
    Kalau batasnya null, sisi kanan tetap dikerjakan dan `maximumFare!`
    membuat aplikasi crash. Dengan kurung dalam, kalau `maximumFare` null maka
    sisi kiri `&&` sudah `false` dan sisi kanan **tidak dikerjakan sama
    sekali** (*short-circuit*).
  - `maximumFare!`: tanda `!` di belakang artinya "aku jamin ini tidak null".
    Aman, karena baris 32 sudah memastikannya.
  - **Kenapa ongkos 0 ditolak?** Di data contoh, 0 berarti pemberi tebengan
    belum mengisi ongkos. Kalau dianggap gratis, tebengan itu selalu lolos
    filter "maksimal Rp10.000", padahal ongkos aslinya belum diketahui.
- **Baris 36**: salin `window` ke variabel lokal `selected`. Setelah dicek
  tidak null di baris 37, Dart yakin `selected` pasti berisi. `final` di sini
  artinya variabel lokal yang diisi sekali.
- **Baris 37**: tidak memilih jam berarti semua jam lolos. Lolos semua syarat → `true`.
- **Baris 38**: ubah teks jam tebengan ("07.30") menjadi menit (450).
- **Baris 39–41**: lolos kalau menitnya **berhasil dibaca** dan ≥ menit mulai
  dan < menit selesai. Contoh: 07.30 = 450 ada di 420–480, jadi lolos rentang
  `morning`.

### 7.3 Pembaca teks jam dan ongkos

```dart
45  /// Menerima HH.mm atau HH:mm; tidak menerima waktu di luar 24 jam.
46  int? parseDepartureMinute(String value) {
47    final match = RegExp(r'^(\d{1,2})[.:](\d{2})$').firstMatch(value.trim());
48    if (match == null) return null;
49    final hour = int.parse(match[1]!);
50    final minute = int.parse(match[2]!);
51    return hour < 24 && minute < 60 ? hour * 60 + minute : null;
52  }
```

- **Baris 46**: fungsi di **luar** kelas, jadi bisa dipakai siapa saja yang
  meng-import file ini. Hasilnya `int?`: berupa menit, atau `null` kalau
  teksnya bukan jam yang benar.
- **Baris 47**: `RegExp` adalah **pola pencocok teks**. Pola
  `^(\d{1,2})[.:](\d{2})$` dibaca dari kiri:
  - `^` = awal teks,
  - `(\d{1,2})` = 1–2 angka (jam), dan kurung menandai bagian yang mau diambil,
  - `[.:]` = titik atau titik dua,
  - `(\d{2})` = tepat 2 angka (menit),
  - `$` = akhir teks.
  - Jadi `"07.30"` dan `"7:30"` cocok, sedangkan `"jam tujuh"` tidak.
  - `r'...'` artinya teks mentah, supaya `\d` tidak dianggap karakter khusus.
  - `.trim()` membuang spasi di awal dan akhir.
- **Baris 48**: tidak cocok pola → `null`.
- **Baris 49–50**: ambil bagian ke-1 (jam) dan ke-2 (menit), lalu ubah teks
  menjadi angka dengan `int.parse`.
- **Baris 51**: `kondisi ? A : B` artinya "kalau kondisi benar, hasilnya A;
  kalau salah, B". Jam < 24 dan menit < 60 menghasilkan total menit;
  selain itu `null` (misalnya "25.00").

```dart
54  /// Rupiah bulat, baik 10000 maupun 10.000. Kosong berarti tanpa batas.
55  int? parseFare(String value) {
56    final text = value.trim();
57    if (!RegExp(r'^(\d+|\d{1,3}(\.\d{3})+)$').hasMatch(text)) return null;
58    return int.tryParse(text.replaceAll('.', ''));
59  }
```

- **Baris 57**: pola: **angka saja** (`\d+`, misalnya 10000) **atau** (`|`)
  1–3 angka diikuti kelompok "titik + 3 angka" (10.000, 1.500.000). Teks
  seperti `"10,5"`, `"1.5"`, atau `"Rp10.000"` tidak cocok. Tanda `!` di depan
  artinya "kalau **tidak** cocok".
- **Baris 58**: buang titik (`"10.000"` → `"10000"`), lalu ubah menjadi angka.
  `tryParse` menghasilkan `null` kalau angkanya terlalu besar, bukan error.
- **Kenapa pembaca ini ada di Model?** Karena aturan "bentuk rupiah yang sah"
  adalah aturan data. Aturan ini dipakai ViewModel saat memvalidasi dan saat
  membuat filter.

---

## 8. Langkah 2 — ViewModel: `ride_filter_view_model.dart`

**Lokasi:** `lib/features/ride_search/viewmodels/ride_filter_view_model.dart`

**Folder `viewmodels/`** berisi **otak layar**. File di sini menyimpan
**state** layar (pilihan yang sedang aktif), memeriksa isian, dan menyiapkan
hasil. Ia tidak menggambar apa pun dan tidak tahu Navigator.

**`RideFilterViewModel` dipakai untuk:** menyimpan pilihan **sementara (draft)**
di layar Filter, yaitu jam dan kursi yang sedang dipilih. Ia juga memeriksa
kolom ongkos dan membuat `RideFilter` final saat Terapkan.

Analogi: **pelayan yang mencatat pesanan di buku kecilnya**. Selama tamu masih
berpikir, pesanan hanya ada di catatan pelayan (draft). Pesanan baru dikirim
ke dapur saat tamu bilang "oke, itu saja" (Terapkan). Kalau tamu batal dan
pergi, catatannya dibuang dan dapur tidak tahu apa-apa.

### 8.1 Bagian atas: pilihan kursi dan state

```dart
 1  import 'package:praktikum_mobile/core/view_model.dart';
 2  import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
 3
 4  class RideFilterViewModel extends ViewModel {
 5    /// Pilihan minimal kursi di layar Filter. Tambah angka di sini untuk
 6    /// menambah pilihan; layar membuat tombolnya otomatis.
 7    static const seatOptions = [1, 2, 3];
 8
 9    RideFilterViewModel({RideFilter initialFilter = const RideFilter()})
10      : _window = initialFilter.window,
11        _seats = initialFilter.minimumSeats;
12    DepartureWindow? _window;
13    int _seats;
14    DepartureWindow? get window => _window;
15    int get seats => _seats;
```

- **Baris 1–2**: hanya meng-import **induk ViewModel** dan **Model**. Tidak
  ada `material.dart`, jadi ViewModel ini memang tidak bisa menyentuh tampilan.
  Ini sesuai aturan MVVM.
- **Baris 4**: mewarisi `ViewModel`, sehingga otomatis punya `publish()`,
  `dispose()`, dan kemampuan didengar.
- **Baris 7**: `static const seatOptions` adalah daftar pilihan kursi.
  - `static` artinya **milik kelas**, bukan milik tiap objek. Cara memakainya
    lewat nama kelas: `RideFilterViewModel.seatOptions`. Analogi: jam dinding
    sekolah dipakai bersama, bukan dimiliki setiap murid.
  - `const` artinya nilainya tetap.
  - `[1, 2, 3]` adalah **List** (daftar).
  - **Kenapa di sini, bukan di layar?** Pilihan kursi adalah keputusan aturan
    ("boleh minta 1 sampai 3 kursi"). Layar cukup membuat tombol untuk setiap
    angka. Mau menambah pilihan 4 kursi? Cukup ubah daftar ini.
- **Baris 9**: konstruktor. Parameternya `initialFilter`, yaitu filter yang
  **sedang berlaku** di layar Hasil. Kalau tidak dikirim, dipakai filter kosong.
- **Baris 10–11**: **initializer list**, yaitu bagian setelah `:` yang mengisi
  field sebelum objek selesai dibuat. Isinya: salin jam dan kursi dari filter
  awal, supaya pilihan lama **langsung terlihat** saat layar Filter dibuka lagi.
- **Baris 12**: `_window` adalah **STATE: rentang jam yang sedang dipilih**.
  Tidak `final`, karena memang berubah-ubah. Privat (`_`), supaya layar tidak
  bisa mengubahnya langsung dan harus lewat `selectWindow`.
- **Baris 13**: `_seats` adalah **STATE: kursi yang sedang dipilih**.
- **Baris 14–15**: getter publik. Layar boleh **membaca**, tapi **mengubah**
  harus lewat fungsi di bawah.
  - **Kenapa repot begini?** Supaya setiap perubahan pasti diikuti `publish()`.
    Kalau layar boleh menulis `_seats = 2` langsung, ia bisa lupa
    mengumumkannya, dan tampilan tidak berubah.

### 8.2 Aksi: memilih dan mengatur ulang

```dart
17    void selectWindow(DepartureWindow? value) {
18      _window = value;
19      publish();
20    }
21
22    void selectSeats(int value) {
23      _seats = value;
24      publish();
25    }
26
27    void reset() {
28      _window = null;
29      _seats = 1;
30      publish();
31    }
```

Ketiganya memakai pola yang sama: **ubah state → `publish()`**.

- **Baris 17–20**: dipanggil saat tombol jam diketuk. `value` boleh `null`,
  yang berarti membatalkan pilihan (kembali ke semua jam).
- **Baris 22–25**: dipanggil saat tombol kursi diketuk.
- **Baris 27–31**: dipanggil oleh tombol Atur Ulang. Kembali ke bawaan, yaitu
  semua jam dan 1 kursi.
- `publish()` membuat layar yang mendengar menggambar ulang, sehingga warna
  tombol berubah. Inilah **feedback** untuk pengguna.

### 8.3 Validasi kolom ongkos

```dart
33    /// Kosong berarti tanpa batas. Batas Rp0 ditolak karena tidak ada tebengan
34    /// yang bisa lolos: ongkos 0 berarti belum diatur, bukan gratis.
35    String? validateFare(String? value) {
36      if (value?.trim().isEmpty ?? true) return null;
37      final fare = parseFare(value!);
38      if (fare == null) return 'Isi rupiah bulat, contoh 10.000';
39      if (fare <= 0) return 'Batas ongkos harus lebih dari Rp0';
40      return null;
41    }
```

- **Baris 35**: **validator**. Aturan Flutter untuk validator adalah:
  **kembalikan `null` kalau isian benar, atau kembalikan teks pesan kalau
  salah**. Teks pesan itu otomatis tampil merah di bawah kolom.
  - Parameternya `String?` karena Flutter bisa saja mengirim `null`.
- **Baris 36**: kalau isian kosong, itu valid, artinya ongkos tidak dibatasi.
  Cara membacanya:
  - `value?.trim()`: kalau `value` null, hasilnya ikut null tanpa error. Kalau
    tidak null, spasinya dibuang.
  - `.isEmpty`: apakah teksnya kosong.
  - `?? true`: kalau hasil di kirinya null, pakai `true`.
  - Jadi null atau kosong → `true` → `return null` (valid).
- **Baris 37**: ubah teks menjadi angka (lihat 7.3). `value!` aman karena
  baris 36 sudah memastikan `value` tidak null.
- **Baris 38**: bentuknya bukan rupiah bulat → kembalikan pesan.
- **Baris 39**: nol atau kurang → kembalikan pesan.
- **Baris 40**: lolos semua → `null` (valid).
- **Kenapa validasi ada di ViewModel, bukan di layar?** Supaya aturannya bisa
  **dites tanpa layar** (lihat Bab 12), dan layar tetap fokus menggambar.

### 8.4 Membuat filter final

```dart
43    RideFilter? apply(String fare) => validateFare(fare) != null
44        ? null
45        : RideFilter(
46            window: _window,
47            minimumSeats: _seats,
48            maximumFare: fare.trim().isEmpty ? null : parseFare(fare),
49          );
50  }
```

- **Baris 43**: `apply` menerima teks ongkos dan menghasilkan `RideFilter?`,
  yaitu filter baru, atau `null` kalau isiannya salah. Ia memvalidasi sekali
  lagi sebagai **pengaman lapis kedua**, supaya ViewModel tidak pernah membuat
  filter yang rusak walaupun dipanggil tanpa lewat form.
- **Baris 44**: tidak valid → `null`.
- **Baris 45–49**: valid → buat `RideFilter` **baru** dari pilihan jam, kursi,
  dan ongkos. Ongkos kosong menjadi `null` (tanpa batas); kalau tidak, teks
  diubah menjadi angka.

**Kenapa teks ongkos tidak disimpan sebagai state di ViewModel?** Isi kolom
sudah dipegang oleh `TextEditingController` di layar. Controller adalah objek
tampilan, jadi aturan proyek melarangnya masuk ViewModel. ViewModel cukup
**menerima teksnya** saat dibutuhkan, yaitu saat validasi dan saat Terapkan.

---

## 9. Langkah 3 — View: `ride_filter_screen.dart`

**Lokasi:** `lib/features/ride_search/views/ride_filter_screen.dart`

**Folder `views/`** berisi **layar**: apa yang dilihat dan diketuk pengguna.
Layar membaca state dari ViewModel, menggambarnya, dan meneruskan ketukan ke
ViewModel. Hal yang memang milik tampilan juga tinggal di sini: controller
kolom isian, kunci form, dan Navigator.

**`RideFilterScreen` dipakai untuk:** menampilkan pilihan jam, kursi, dan
ongkos, lalu mengembalikan filter baru ke layar Hasil saat Terapkan ditekan.

### 9.1 Import dan kelas widget

```dart
 1  import 'package:flutter/material.dart';
 2  import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
 3  import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_filter_view_model.dart';
 4  import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
 5  import 'package:praktikum_mobile/shared/widgets/app_button.dart';
 6  import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';
 7  import 'package:praktikum_mobile/theme/app_colors.dart';
 8  import 'package:praktikum_mobile/theme/app_spacing.dart';
 9  import 'package:praktikum_mobile/theme/app_text_styles.dart';
10
11  class RideFilterScreen extends StatefulWidget {
12    const RideFilterScreen({super.key, this.initialFilter = const RideFilter()});
13    final RideFilter initialFilter;
14    @override
15    State<RideFilterScreen> createState() => _RideFilterScreenState();
16  }
```

- **Baris 1**: `material.dart` berisi semua widget Material (Scaffold, Text,
  Row, TextButton, dan lain-lain). Hanya View yang boleh meng-import ini.
- **Baris 2–3**: Model dan ViewModel filter.
- **Baris 4**: `formatThousands`, untuk menulis 10000 sebagai "10.000" di kolom.
- **Baris 5–6**: komponen tombol dan kolom isian milik proyek.
- **Baris 7–9**: token tema: warna, jarak/ukuran/sudut, dan gaya teks.
- **Baris 11**: `RideFilterScreen` adalah **widget layar Filter**. Ia
  `extends StatefulWidget` karena layar ini harus menyimpan hal yang bertahan
  selama layar terbuka (ViewModel dan controller kolom ongkos). Lihat 2.6.
- **Baris 12**: konstruktor.
  - `super.key` meneruskan `key` ke induk. Flutter memakai key untuk mengenali
    widget. Semua widget punya parameter ini, jadi selalu ditulis.
  - `this.initialFilter = const RideFilter()` adalah filter yang dikirim dari
    layar Hasil, dengan bawaan filter kosong.
- **Baris 13**: field `initialFilter`. Isinya tidak berubah (`final`).
- **Baris 15**: `createState()` membuat **pasangan State-nya**,
  `_RideFilterScreenState`. Flutter memanggilnya **sekali** saat layar dibuat.
  - Tipe kembaliannya `State<RideFilterScreen>`. Isi `< >` adalah tipe
    (lihat 2.4): "sebuah State **milik** RideFilterScreen".

### 9.2 State: persiapan dan pembersihan

```dart
18  class _RideFilterScreenState extends State<RideFilterScreen> {
19    final _formKey = GlobalKey<FormState>();
20    late final RideFilterViewModel _viewModel;
21    late final TextEditingController _fare;
22    @override
23    void initState() {
24      super.initState();
25      _viewModel = RideFilterViewModel(initialFilter: widget.initialFilter);
26      final fare = widget.initialFilter.maximumFare;
27      _fare = TextEditingController(
28        text: fare == null ? '' : formatThousands(fare),
29      );
30    }
31
32    @override
33    void dispose() {
34      _viewModel.dispose();
35      _fare.dispose();
36      super.dispose();
37    }
```

- **Baris 18**: kelas State.
  - Diawali `_` karena **privat**: hanya file ini yang perlu tahu.
  - `extends State<RideFilterScreen>` artinya "aku adalah State untuk widget
    RideFilterScreen". Karena tipenya disebut di `< >`, di dalam kelas ini
    `widget` dikenal sebagai `RideFilterScreen`, sehingga `widget.initialFilter`
    bisa dipakai (baris 25 dan 26).
- **Baris 19**: `_formKey` adalah **kunci untuk mengendalikan Form**. Dengan
  kunci ini kita bisa menyuruh form "periksa semua kolom" (`validate`) atau
  "hapus semua pesan error" (`reset`). `GlobalKey<FormState>` artinya kunci
  yang menunjuk ke **state milik Form**. Analogi: remote TV untuk TV tertentu.
- **Baris 20**: `_viewModel`.
  - **`late`** artinya "diisi nanti, tidak di baris ini, tapi pasti sebelum
    dipakai". Kenapa tidak langsung? Karena untuk membuatnya kita butuh
    `widget.initialFilter`, dan `widget` baru bisa dipakai di `initState`.
  - `final` artinya hanya diisi sekali.
- **Baris 21**: `_fare` adalah **controller kolom ongkos**, alat untuk membaca
  (`_fare.text`) dan mengubah (`_fare.clear()`) isi kolom dari kode.
- **Baris 23**: `initState()` dijalankan **sekali** saat layar pertama kali dibuat.
- **Baris 24**: jalankan persiapan milik induk dulu. Ini aturan Flutter.
- **Baris 25**: buat ViewModel, isi dengan filter yang sedang berlaku.
- **Baris 26–29**: buat controller kolom ongkos. Kalau sudah ada batas ongkos,
  kolom langsung terisi "10.000"; kalau belum, kosong.
- **Baris 33**: `dispose()` dijalankan saat layar ditutup.
- **Baris 34–35**: buang ViewModel dan controller. Kalau tidak dibuang,
  keduanya tetap memakan memori walaupun layarnya sudah hilang (*memory leak*).
  Analogi: mematikan lampu sebelum keluar kamar.
- **Baris 36**: pembersihan milik induk dijalankan **terakhir**.

### 9.3 Aksi tombol bawah

```dart
39    void _reset() {
40      _formKey.currentState!.reset();
41      _fare.clear();
42      _viewModel.reset();
43    }
44
45    void _apply() {
46      if (!_formKey.currentState!.validate()) return;
47      final result = _viewModel.apply(_fare.text);
48      if (result != null) Navigator.pop(context, result);
49    }
```

- **Baris 39–43**: tombol **Atur Ulang**.
  - Baris 40: hapus pesan error di form. `currentState!` adalah state Form,
    dan tanda `!` karena form pasti sudah ada di layar.
  - Baris 41: kosongkan kolom ongkos.
  - Baris 42: minta ViewModel mengembalikan jam dan kursi ke bawaan.
  - Layar **tidak ditutup**. Pengguna masih bisa memilih lagi.
- **Baris 45–49**: tombol **Terapkan**. Urutannya **validasi → minta hasil →
  tutup sambil membawa hasil**.
  - Baris 46: `.validate()` menjalankan validator semua kolom (di sini
    `validateFare`). Kalau ada yang salah, pesan merah muncul dan fungsi
    **berhenti** (`return`), jadi pengguna tetap di layar Filter.
  - Baris 47: minta ViewModel membuat filter final dari pilihan dan teks ongkos.
  - Baris 48: `Navigator.pop(context, result)` menutup layar Filter **dan
    menitipkan** `result` ke layar yang membukanya, yaitu layar Hasil.
- **Kenapa `Navigator` di layar, bukan di ViewModel?** Navigator butuh
  `context`, dan `context` adalah milik tampilan. ViewModel cukup memberikan
  hasilnya, lalu layar yang memutuskan untuk menutup diri.

### 9.4 Potongan tampilan yang dipakai berulang

```dart
51    Widget _heading(IconData icon, String title) => Row(
52      children: [
53        Icon(icon, color: AppColors.brandStrong),
54        const SizedBox(width: AppSpacing.sm),
55        Expanded(child: Text(title, style: AppTextStyles.headingMedium)),
56      ],
57    );
58
59    /// Ketuk jam yang sedang terpilih sekali lagi untuk membatalkannya.
60    Widget _windowChoice(DepartureWindow window) => _choice(
61      window.label,
62      _viewModel.window == window,
63      () => _viewModel.selectWindow(_viewModel.window == window ? null : window),
64    );
```

Fungsi-fungsi kecil ini dibuat supaya kode yang sama **tidak ditulis berulang**.

- **Baris 51–57**: `_heading` membuat judul bagian ("Jam cabut", "Minimal
  kursi", "Batas ongkos"): ikon dan teks dalam satu baris (`Row`).
  - `SizedBox(width: 8)` adalah kotak kosong untuk memberi jarak.
  - `Expanded` membuat teks mengisi sisa lebar, supaya teks panjang tidak
    meluap keluar layar.
- **Baris 60**: `_windowChoice(window)` membuat **satu tombol jam**.
  Parameter `window` adalah pilihan jam yang tombolnya mau dibuat.
- **Baris 61**: teks tombol, misalnya "07.00–08.00".
- **Baris 62**: apakah tombol ini sedang terpilih? Bandingkan pilihan di
  ViewModel dengan tombol ini (`==` artinya "sama dengan").
- **Baris 63**: apa yang terjadi saat diketuk. `() => ...` adalah **fungsi
  tanpa nama** yang baru dijalankan **nanti**, saat tombol diketuk. Isinya:
  kalau tombol ini sudah terpilih, kirim `null` (batal pilih); kalau belum,
  kirim `window` (pilih).

```dart
66    Widget _choice(String label, bool selected, VoidCallback onPressed) =>
67        Semantics(
68          selected: selected,
69          child: TextButton(
70            style: TextButton.styleFrom(
71              backgroundColor: selected
72                  ? AppColors.brandSubtle
73                  : AppColors.border,
74              foregroundColor: selected
75                  ? AppColors.brandStrong
76                  : AppColors.textSecondary,
77              minimumSize: const Size.fromHeight(AppSizes.touchTarget),
78              padding: const EdgeInsets.all(AppSpacing.sm),
79              alignment: Alignment.centerLeft,
80              shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
81            ),
82            onPressed: onPressed,
83            child: Text(label),
84          ),
85        );
```

- **Baris 66**: `_choice` adalah **tombol pilihan umum**, dipakai untuk tombol
  jam dan tombol kursi. Ia menerima teks, status terpilih, dan aksi.
  `VoidCallback` adalah tipe untuk "fungsi tanpa parameter yang tidak
  mengembalikan nilai".
- **Baris 67–68**: `Semantics(selected: ...)` memberi tahu pembaca layar
  (fitur aksesibilitas untuk tunanetra) bahwa tombol ini sedang terpilih.
- **Baris 71–76**: warna tergantung `selected`. Terpilih: latar coral muda dan
  teks coral tua. Tidak terpilih: abu-abu. Inilah **feedback visual**.
- **Baris 77**: tinggi minimal 48 piksel, standar supaya mudah disentuh jari.
- **Baris 78–80**: jarak dalam, teks rata kiri, sudut membulat. Semuanya token Figma.
- **Baris 82–83**: aksi dan teks tombol.
- `const` di depan `Size`, `EdgeInsets`, dan `RoundedRectangleBorder` artinya
  nilainya tetap, jadi Flutter cukup membuatnya sekali. Ini lebih hemat.

### 9.5 `build`: menggambar layar

```dart
87    @override
88    Widget build(BuildContext context) => ListenableBuilder(
89      listenable: _viewModel,
90      builder: (context, _) => Scaffold(
91        appBar: AppBar(title: const Text('Filter Pencarian')),
92        body: Form(
93          key: _formKey,
94          child: ListView(
95            padding: const EdgeInsets.all(AppSpacing.md),
96            children: [
```

- **Baris 88**: `build` adalah resep tampilan layar. Isinya dibungkus
  **`ListenableBuilder`**.
- **Baris 89**: `listenable: _viewModel` artinya **dengarkan ViewModel**.
  Setiap kali ViewModel memanggil `publish()`, fungsi `builder` di bawahnya
  dijalankan ulang, sehingga tampilan mengikuti state terbaru.
  - Ini **penghubung** View dan ViewModel. Analogi: kamu bergabung ke grup
    WhatsApp (6.2). Setiap ada pengumuman, kamu membaca ulang informasinya.
- **Baris 90**: `builder: (context, _)` adalah fungsi penggambar. Parameter
  kedua tidak dipakai, jadi diberi nama `_`. `Scaffold` adalah kerangka
  standar satu layar (bilah atas, isi, bilah bawah).
- **Baris 91**: bilah atas berisi judul. Tombol panah kembali muncul otomatis
  karena layar ini ditumpuk di atas layar Hasil.
- **Baris 92–93**: `Form` membungkus kolom isian. `key: _formKey`
  menghubungkannya dengan kunci di baris 19, sehingga `validate()` dan
  `reset()` bekerja pada form ini.
- **Baris 94**: `ListView` adalah daftar yang bisa **digulir**. Di HP kecil
  atau saat keyboard muncul, isinya tidak meluap (overflow), tinggal digulir.
- **Baris 96**: `children: [` adalah isi daftar, dari atas ke bawah.

```dart
 97            Text(
 98              'Sesuaikan tebengan dengan kebutuhanmu.',
 99              style: AppTextStyles.bodyMedium.copyWith(
100                color: AppColors.textSecondary,
101              ),
102            ),
103            const SizedBox(height: AppSpacing.lg),
104            _heading(Icons.access_time_rounded, 'Jam cabut'),
105            const SizedBox(height: AppSpacing.sm),
```

- **Baris 97–102**: teks pengantar. `copyWith(color: ...)` artinya pakai gaya
  teks yang sudah ada dan ganti warnanya saja.
- **Baris 103 dan 105**: jarak vertikal 24 dan 8 piksel.
- **Baris 104**: judul "Jam cabut" dengan ikon jam (`_heading` dari 9.4).

```dart
106            // Dua pilihan per baris, dibuat dari semua nilai DepartureWindow.
107            for (var i = 0; i < DepartureWindow.values.length; i += 2) ...[
108              if (i > 0) const SizedBox(height: AppSpacing.sm),
109              Row(
110                children: [
111                  Expanded(child: _windowChoice(DepartureWindow.values[i])),
112                  const SizedBox(width: AppSpacing.sm),
113                  Expanded(
114                    child: i + 1 < DepartureWindow.values.length
115                        ? _windowChoice(DepartureWindow.values[i + 1])
116                        : const SizedBox.shrink(),
117                  ),
118                ],
119              ),
120            ],
```

Bagian ini membuat **tombol-tombol jam secara otomatis**, dua per baris.

- **Baris 107**: perulangan **di dalam daftar widget**.
  - `var i = 0`: mulai dari 0. `var` artinya biarkan Dart menebak tipenya (int).
  - `i < DepartureWindow.values.length`: selama `i` kurang dari jumlah pilihan
    jam. `DepartureWindow.values` adalah daftar semua pilihan enum (ada 5).
  - `i += 2`: naik 2 setiap putaran. Jadi `i` = 0, 2, 4, yang berarti 3 baris.
  - `...[ ]` (**spread**): setiap putaran menghasilkan **beberapa** widget
    sekaligus (jarak + baris), lalu isinya dituang ke daftar luar.
    Analogi: menuang isi kantong plastik ke keranjang, bukan memasukkan
    kantongnya.
- **Baris 108**: `if` di dalam daftar. Mulai baris kedua, beri jarak dulu.
- **Baris 109–119**: satu `Row` berisi dua tombol. `Expanded` membagi lebar
  sama rata.
- **Baris 111**: tombol kiri adalah pilihan ke-`i`.
- **Baris 114–116**: tombol kanan adalah pilihan ke-`i+1` **kalau ada**.
  Baris terakhir hanya punya satu pilihan ("Sore"), jadi diisi kotak kosong
  `SizedBox.shrink()` supaya tombol kiri tetap selebar setengah.
- **Kenapa tidak ditulis satu per satu?** Kalau nanti ada pilihan jam baru di
  enum, tombolnya **otomatis** muncul tanpa mengubah layar.

```dart
121            const SizedBox(height: AppSpacing.lg),
122            _heading(Icons.event_seat_rounded, 'Minimal kursi'),
123            const SizedBox(height: AppSpacing.sm),
124            Row(
125              children: [
126                for (final seats in RideFilterViewModel.seatOptions) ...[
127                  if (seats != RideFilterViewModel.seatOptions.first)
128                    const SizedBox(width: AppSpacing.sm),
129                  Expanded(
130                    child: _choice(
131                      '$seats kursi',
132                      _viewModel.seats == seats,
133                      () => _viewModel.selectSeats(seats),
134                    ),
135                  ),
136                ],
137              ],
138            ),
```

- **Baris 124**: satu baris berisi semua tombol kursi.
- **Baris 126**: `for (final seats in ...)` artinya untuk setiap angka di
  `seatOptions` (1, 2, 3), buat tombol. Daftarnya diambil dari ViewModel (8.1).
- **Baris 127–128**: beri jarak sebelum setiap tombol **kecuali yang
  pertama**. `.first` adalah isi pertama daftar.
- **Baris 131**: `'$seats kursi'` menyisipkan nilai ke teks, menjadi
  "1 kursi", "2 kursi", dan seterusnya.
- **Baris 132**: tombol terpilih kalau sama dengan pilihan di ViewModel.
- **Baris 133**: saat diketuk, `selectSeats(seats)` dipanggil. State berubah,
  `publish()` berjalan, layar digambar ulang, dan warna tombol berubah.

```dart
139            const SizedBox(height: AppSpacing.lg),
140            _heading(Icons.account_balance_wallet_rounded, 'Batas ongkos'),
141            const SizedBox(height: AppSpacing.sm),
142            AppTextField(
143              label: 'Ongkos paling mahal',
144              hint: 'Contoh: 10.000',
145              controller: _fare,
146              keyboardType: TextInputType.number,
147              textInputAction: TextInputAction.done,
148              onFieldSubmitted: (_) => _apply(),
149              validator: _viewModel.validateFare,
150            ),
```

- **Baris 142**: `AppTextField` adalah kolom isian berlabel milik proyek.
- **Baris 143–144**: label di atas kolom, dan petunjuk abu-abu di dalam kolom.
- **Baris 145**: sambungkan kolom ke controller `_fare`.
- **Baris 146**: tampilkan keyboard angka.
- **Baris 147**: tombol Enter di keyboard bertuliskan "selesai".
- **Baris 148**: menekan "selesai" di keyboard sama dengan menekan Terapkan.
  `(_)` artinya teks yang dikirim tidak dipakai, karena `_apply` membaca
  sendiri dari controller.
- **Baris 149**: validator diambil dari ViewModel. Perhatikan: **tanpa tanda
  kurung `()`**. Kita menyerahkan **fungsinya**, bukan hasilnya. Form yang
  nanti memanggilnya saat `validate()`. Analogi: memberi nomor telepon dokter,
  bukan langsung menelepon dokternya.

```dart
151            const SizedBox(height: AppSpacing.sm),
152            Text(
153              'Kosongkan untuk semua ongkos. Ongkos yang belum diatur tidak dianggap gratis.',
...
159            Text(
160              'Tanpa pilihan jam berarti semua jam, termasuk sebelum 06.00 dan setelah 19.00. Tebengan penuh tidak ditampilkan.',
...
165          ],
166        ),
167      ),
```

- **Baris 152–164**: dua teks petunjuk, supaya pengguna tahu aturannya tanpa
  harus bertanya.
- **Baris 165–167**: penutup daftar, `ListView`, dan `Form`.

```dart
168      bottomNavigationBar: ColoredBox(
169        color: AppColors.surface,
170        child: SafeArea(
171          top: false,
172          child: Padding(
173            padding: const EdgeInsets.all(AppSpacing.md),
174            child: Row(
175              children: [
176                Expanded(
177                  child: AppButton(
178                    label: 'Atur Ulang',
179                    variant: AppButtonVariant.secondary,
180                    onPressed: _reset,
181                  ),
182                ),
183                const SizedBox(width: AppSpacing.md),
184                Expanded(
185                  child: AppButton(label: 'Terapkan', onPressed: _apply),
186                ),
187              ],
188            ),
189          ),
190        ),
191      ),
192    ),
193  );
194  }
```

- **Baris 168**: bilah bawah yang **selalu terlihat** dan tidak ikut tergulir,
  supaya tombol Terapkan mudah dijangkau.
- **Baris 170–171**: `SafeArea` menjaga tombol supaya tidak tertutup garis
  navigasi HP. `top: false` karena bagian atas tidak perlu dijaga.
- **Baris 174–186**: dua tombol berdampingan dengan lebar sama.
- **Baris 179**: `secondary` adalah gaya tombol kedua (tidak penuh warna),
  karena Atur Ulang bukan aksi utama.
- **Baris 180 dan 185**: `_reset` dan `_apply` ditulis **tanpa `()`**, karena
  yang diserahkan adalah fungsinya (lihat penjelasan baris 149).

---

## 10. Langkah 4 — Route: `app_routes.dart`

**Lokasi:** `lib/routes/app_routes.dart`

**Folder `routes/`** berisi **daftar alamat semua layar**. Setiap layar punya
nama alamat, misalnya `/ride-filter`, seperti alamat rumah. Layar lain cukup
menyebut alamatnya, tanpa perlu tahu cara membuat layarnya.

Analogi: **resepsionis gedung**. Tamu cukup bilang "saya mau ke ruang Filter",
dan resepsionis yang mengantar. Kalau ruangannya tidak ada, resepsionis
mengantar ke papan "Halaman tidak ditemukan" (404).

### 10.1 Mendaftarkan router — `lib/main.dart`

```dart
33          child: MaterialApp(
...
37            initialRoute: AppRoutes.login,
38            onGenerateRoute: AppRoutes.onGenerateRoute,
39            onUnknownRoute: AppRoutes.onUnknownRoute,
```

- **Baris 37**: layar pertama saat aplikasi dibuka adalah login.
- **Baris 38**: setiap kali ada `pushNamed`, tanyakan ke
  `AppRoutes.onGenerateRoute` layar mana yang harus dibuat.
- **Baris 39**: kalau `onGenerateRoute` menjawab `null` (tidak kenal), pakai
  `onUnknownRoute`, yaitu halaman 404.

### 10.2 Alamat dan rute layar Filter

```dart
14  abstract final class AppRoutes {
...
19    static const String rideFilter = '/ride-filter';
...
22    static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
23      switch (settings.name) {
...
35        case rideFilter:
36          final args = settings.arguments;
37          if (args != null && args is! RideFilter) return null;
38          return MaterialPageRoute<RideFilter>(
39            settings: settings,
40            builder: (_) => RideFilterScreen(
41              initialFilter: args as RideFilter? ?? const RideFilter(),
42            ),
43          );
```

- **Baris 14**: `abstract final class`: kelas ini hanya wadah konstanta dan
  fungsi `static`. Tidak dibuat objeknya, dan tidak diwarisi.
- **Baris 19**: alamat layar Filter disimpan sebagai **konstanta**. Layar lain
  menulis `AppRoutes.rideFilter`, bukan mengetik `'/ride-filter'` sendiri.
  Kalau salah ketik nama konstanta, Dart langsung protes. Salah ketik teks
  biasa tidak akan ketahuan.
- **Baris 22**: fungsi yang dipanggil setiap kali ada permintaan buka layar.
  `settings` berisi **nama alamat** (`settings.name`) dan **data titipan**
  (`settings.arguments`). Hasilnya `Route?`: rute layar, atau `null` kalau
  tidak dikenal.
- **Baris 23**: `switch` artinya "pilih berdasarkan nama alamat".
- **Baris 35**: kalau alamatnya `/ride-filter`, jalankan blok ini.
- **Baris 36**: ambil data titipan, yaitu filter yang sedang berlaku.
- **Baris 37**: ada data **tapi bukan** `RideFilter` (`is!` artinya "bukan
  bertipe") → `null` → halaman 404. Ini **pengaman**: layar Filter tidak
  pernah dibuka dengan data yang salah.
- **Baris 38**: buat rute halaman. `MaterialPageRoute<RideFilter>` artinya
  rute ini, saat ditutup, akan **mengembalikan sebuah RideFilter**. Inilah
  pasangan dari `Navigator.pop(context, result)` di 9.3.
- **Baris 40–41**: buat layar Filter.
  - `args as RideFilter?`: perlakukan data titipan sebagai RideFilter, yang
    boleh null.
  - `?? const RideFilter()`: kalau null, pakai filter kosong.

**Kenapa memakai named route, bukan langsung membuat layarnya?** Materi
Module 4 meminta named route. Selain itu, semua pemeriksaan data dan halaman
404 terkumpul di satu tempat.

---

## 11. Langkah 5 — Menyambungkan ke layar Hasil

Layar Filter sudah bisa dibuka. Sekarang layar Hasil perlu **membukanya**,
**menerima** hasilnya, dan **memakainya** untuk menyaring tebengan.

### 11.1 Permintaan pencarian membawa filter — `models/ride_search_request.dart`

```dart
 4  /// Immutable snapshot. Editing the form later cannot change an open result page.
 5  class RideSearchRequest {
 6    const RideSearchRequest({
 7      required this.origin,
 8      required this.destination,
 9      this.filter = const RideFilter(),
10    });
11    final MapLocation origin;
12    final MapLocation destination;
13    final RideFilter filter;
14  }
```

- Satu paket berisi **Dari**, **Ke**, dan **filter**, dikirim dari Beranda ke
  layar Hasil.
- `required` artinya parameter bernama yang **wajib** diisi. Pencarian tanpa
  Dari dan Ke tidak masuk akal.

### 11.2 Membuka Filter dan menerima hasilnya — `views/ride_results_screen.dart`

```dart
81    void _leave() => Navigator.pop(context, _viewModel.filter);
82    Future<void> _openFilter() async {
83      final result = await Navigator.pushNamed<RideFilter>(
84        context,
85        AppRoutes.rideFilter,
86        arguments: _viewModel.filter,
87      );
88      if (mounted && result != null) _viewModel.applyFilter(result);
89    }
```

- **Baris 81**: `_leave` artinya keluar dari layar Hasil ke Beranda **sambil
  membawa** filter yang sedang berlaku. Dengan begitu, pencarian berikutnya
  memakai filter yang sama dan pengguna tidak perlu mengatur ulang.
- **Baris 82**: `Future<void>` dan `async`.
  - **`Future`** adalah **janji hasil yang datang nanti**. Analogi: nomor
    antrean di bank. Kamu belum dilayani, tapi pasti dipanggil nanti.
  - **`async`** artinya fungsi ini boleh menunggu sesuatu.
- **Baris 83**: **`await`** artinya **tunggu di sini** sampai layar Filter
  ditutup, lalu simpan hasilnya di `result`.
  - `pushNamed<RideFilter>`: buka layar lewat alamat, dan hasil yang
    diharapkan bertipe RideFilter. Tipe ini harus cocok dengan
    `MaterialPageRoute<RideFilter>` di router (10.2).
- **Baris 84**: `context` adalah alamat layar ini (lihat 2.8).
- **Baris 85**: alamat tujuan `/ride-filter`.
- **Baris 86**: **titipkan** filter yang sedang berlaku. Inilah yang diterima
  router di 10.2 baris 36.
- **Baris 88**: setelah layar Filter tertutup:
  - `mounted` memastikan layar Hasil **masih ada**. Selama menunggu, bisa saja
    layar Hasil sudah ditutup. Memakai layar yang sudah hilang menyebabkan error.
  - `result != null`: pengguna menekan **Terapkan**. Kalau ia menekan tombol
    kembali, hasilnya `null` dan filter lama tetap berlaku.
  - Kalau keduanya benar, serahkan filter baru ke ViewModel Hasil.

### 11.3 Bagian tampilan Hasil yang bereaksi

```dart
157  Widget build(BuildContext context) => PopScope<RideFilter>(
158    canPop: false,
159    onPopInvokedWithResult: (didPop, _) {
160      if (!didPop) _leave();
161    },
162    child: ListenableBuilder(
163      listenable: _viewModel,
164      builder: (context, _) => Scaffold(
165        appBar: AppBar(
166          title: const Text('Hasil Pencarian'),
167          leading: BackButton(onPressed: _leave),
168        ),
...
180                    child: Text(switch (_viewModel.status) {
181                      SearchResultsStatus.loading => 'Mencari tebengan...',
182                      SearchResultsStatus.error => 'Gagal memuat',
183                      SearchResultsStatus.success =>
184                        '${_viewModel.results.length} tebengan searah',
185                    }, style: AppTextStyles.labelLarge),
...
194                    onPressed: _openFilter,
195                    icon: const Icon(Icons.filter_list_rounded),
196                    label: Text(
197                      _viewModel.filter.isActive ? 'Filter aktif' : 'Filter',
198                    ),
```

- **Baris 157–161**: `PopScope` **mencegat tombol kembali bawaan HP**.
  `canPop: false` artinya jangan langsung ditutup; jalankan `_leave` dulu
  supaya filter ikut terbawa ke Beranda.
- **Baris 162–163**: sama seperti layar Filter, layar ini **mendengarkan
  ViewModel-nya**. Setiap `publish()` membuat layar digambar ulang.
- **Baris 167**: tombol panah di bilah atas juga memakai `_leave`.
- **Baris 180–185**: `switch` versi pendek: pilih teks sesuai status.
  Saat berhasil, tampil jumlah hasil, misalnya "1 tebengan searah".
- **Baris 194**: tombol Filter memanggil `_openFilter` (11.2).
- **Baris 197**: teks tombol menjadi "Filter aktif" kalau `isActive` (7.2).

### 11.4 Menerapkan filter — `viewmodels/ride_results_view_model.dart`

**`RideResultsViewModel` dipakai untuk:** memuat tebengan dari repository,
menyimpan filter yang **berlaku**, dan menghitung daftar tebengan yang lolos.

```dart
 9  enum SearchResultsStatus { loading, success, error }
10
11  class RideResultsViewModel extends ViewModel {
12    RideResultsViewModel({
13      required this.repository,
14      required this.request,
15      this.simulateError = false,
16    }) : _filter = request.filter {
...
24    RideFilter _filter;
...
26    List<Ride> _rides = [];
27    List<Ride> _results = [];
...
30    RideFilter get filter => _filter;
...
32    List<Ride> get results => List.unmodifiable(_results);
...
35    void applyFilter(RideFilter filter) {
36      if (isDisposed) return;
37      _filter = filter;
38      _results = matchPassengerRides(_rides, request, _filter);
39      publish();
40    }
```

- **Baris 9**: tiga keadaan layar Hasil: memuat, berhasil, dan gagal.
- **Baris 16**: filter awal diambil dari permintaan pencarian (11.1).
- **Baris 24**: `_filter` adalah **STATE: filter yang berlaku**. Bandingkan
  dengan `_window` dan `_seats` di ViewModel Filter, yang hanya **draft**.
- **Baris 26**: `_rides` adalah semua tebengan dari repository.
- **Baris 27**: `_results` adalah tebengan yang lolos, yaitu yang ditampilkan.
- **Baris 32**: `List.unmodifiable` membuat salinan yang **tidak bisa diubah**
  oleh layar. Layar hanya boleh membaca.
- **Baris 35–40**: `applyFilter`, dipanggil dari 11.2 baris 88.
  - Baris 36: layar sudah ditutup → jangan lakukan apa pun.
  - Baris 37: simpan filter baru.
  - Baris 38: **hitung ulang** daftar yang lolos (11.5). Data tidak diambil
    ulang dari repository, karena semua tebengan sudah ada di `_rides`, jadi
    hasilnya langsung muncul.
  - Baris 39: umumkan perubahan. Layar Hasil menggambar ulang jumlah, tombol
    "Filter aktif", dan daftar kartu.

### 11.5 Menyaring tebengan — `utils/ride_search_matcher.dart`

**Folder `utils/`** berisi **alat hitung bantu** yang bukan state dan bukan
tampilan. Fungsinya bisa dipakai beberapa ViewModel.

```dart
 7  List<Ride> matchPassengerRides(
 8    Iterable<Ride> rides,
 9    RideSearchRequest request,
10    RideFilter filter,
11  ) {
12    final matches = <(Ride, RouteMatch)>[];
13    for (final ride in rides) {
14      if (!filter.matches(ride) || ride.geography == null) continue;
15      final match = RouteMatcher.match(
16        ride.geography!.route,
17        request.origin.point,
18        request.destination.point,
19      );
20      if (match != null) matches.add((ride, match));
21    }
22    matches.sort((a, b) => a.$2.totalDeviation.compareTo(b.$2.totalDeviation));
23    return matches.map((item) => item.$1).toList();
24  }
```

- **Baris 7–11**: fungsi ini menerima semua tebengan, permintaan pencarian, dan
  filter, lalu mengembalikan tebengan yang lolos. `Iterable<Ride>` artinya
  kumpulan Ride yang bisa diperiksa satu per satu.
- **Baris 12**: wadah kosong berisi **pasangan** `(Ride, RouteMatch)`, yaitu
  tebengan dan hasil hitung kedekatannya. Pasangan seperti ini disebut
  **record**.
- **Baris 13**: periksa setiap tebengan.
- **Baris 14**: **di sinilah `RideFilter.matches` (7.2) dipakai.** Kalau tidak
  lolos filter, atau tidak punya data jalur, `continue` melewati tebengan ini
  dan lanjut ke tebengan berikutnya. Filter dicek **lebih dulu** karena
  pemeriksaannya murah. Hitungan jalur yang lebih berat hanya untuk yang lolos.
- **Baris 15–19**: hitung apakah searah: titik Dari dan Ke berjarak ≤ 500 m
  dari jalur, dan Dari dilewati sebelum Ke.
- **Baris 20**: kalau searah, simpan pasangannya.
- **Baris 22**: urutkan dari yang **paling dekat** dengan jalur. `.$2` adalah
  isi kedua pasangan (hasil hitung).
- **Baris 23**: ambil tebengannya saja (`.$1`, isi pertama) dan jadikan daftar.

---

## 12. Langkah 6 — Tes: bukti kodenya benar

**Tes** adalah kode yang **memeriksa kode lain secara otomatis**. Perintah
`flutter test` menjalankan semuanya. Saat ini seluruh tes lulus (104 tes).

Ada dua jenis tes yang menyentuh fitur filter.

### 12.1 Tes ViewModel/Model — `test/regression/view_model_test.dart`

Tes ini berjalan **tanpa menggambar layar**, sehingga cepat. Ini keuntungan
dari memisahkan aturan ke Model dan ViewModel (Bab 3).

```dart
224    test('Draft apply/reset does not change immutable initial filter', () {
225      const initial = RideFilter(
226        window: DepartureWindow.morning,
227        minimumSeats: 2,
228        maximumFare: 15000,
229      );
230      final vm = RideFilterViewModel(initialFilter: initial);
231      addTearDown(vm.dispose);
232      vm.selectWindow(DepartureWindow.afternoon);
233      vm.selectSeats(3);
234      expect(vm.apply('10.000')!.maximumFare, 10000);
235      expect(vm.apply('-1'), isNull);
236      expect(initial.window, DepartureWindow.morning);
237      expect(initial.minimumSeats, 2);
238      vm.reset();
239      final result = vm.apply('')!;
240      expect(result.isActive, isFalse);
```

- `test('nama', () { ... })` adalah satu tes dengan namanya.
- `expect(nilai, harapan)`: kalau `nilai` tidak sama dengan `harapan`, tes gagal.
- Yang dibuktikan:
  - "10.000" dibaca menjadi 10000.
  - "-1" ditolak.
  - Mengubah draft **tidak** mengubah filter awal (immutable).
  - Setelah reset, filter tidak aktif.
- `addTearDown(vm.dispose)` artinya buang ViewModel setelah tes selesai.

Tes lain di file yang sama:

- `'Zero fare limit is rejected; empty still means no limit'`: "0", "000",
  dan "0.000" ditolak; kosong berarti tanpa batas; "1.5" ditolak.
- `'Departure windows are continuous; midday covers noon'`: jam 12.00 masuk
  Siang, jam 15.00 masuk Sore (bukan Siang), dan tidak ada celah antar rentang.

### 12.2 Tes alur di layar — `test/features/ride_search/passenger_search_workflow_test.dart`

Tes ini **menggambar layar di memori** lalu "mengetuk" tombol seperti pengguna sungguhan.

`'Filter cancel, apply, reset and return preserve route state'` memeriksa:

1. Cari → "2 tebengan searah".
2. Buka Filter → pilih 2 kursi → tekan **kembali** → hasil tetap 2 (draft dibuang).
3. Buka Filter → pilih 2 kursi → **Terapkan** → "1 tebengan searah".
4. Kembali ke Beranda → cari lagi → tombol tetap "Filter aktif" dan hasilnya 1
   (filter terbawa).
5. Atur Ulang → Terapkan → kembali ke 2.

`'Zero fare is rejected and a saved fare reopens formatted'` memeriksa bahwa
ongkos 0 menampilkan pesan error dan layar Filter **tidak tertutup**, serta
bahwa ongkos tersimpan tampil lagi sebagai "10.000".

---

## 13. Alur lengkap saat aplikasi dipakai

Contohnya: pengguna memilih **2 kursi**, mengisi ongkos **10.000**, lalu
menekan **Terapkan**.

| # | Yang terjadi | Kode | Tahap UTS |
|---|---|---|---|
| 1 | Di layar Hasil, pengguna mengetuk **Filter** | `onPressed: _openFilter` (hasil:194) | **Input / Event** |
| 2 | Layar Filter dibuka sambil membawa filter sekarang | `pushNamed<RideFilter>(..., arguments: filter)` (hasil:83–86) → router (routes:35–43) | **Navigation** |
| 3 | Layar Filter menyiapkan ViewModel dan kolom ongkos | `initState` (filter:23–30) | |
| 4 | Pengguna mengetuk **2 kursi** | `() => _viewModel.selectSeats(2)` (filter:133) | **Input / Event** |
| 5 | ViewModel menyimpan pilihan | `_seats = 2` (vm:23) | **State** |
| 6 | ViewModel mengumumkan perubahan | `publish()` (vm:24) | |
| 7 | Layar digambar ulang, tombol "2 kursi" berwarna coral | `ListenableBuilder` (filter:88–89), warna (filter:71–76) | **Feedback** |
| 8 | Pengguna mengetik **10.000** | `controller: _fare` (filter:145) | **Input** |
| 9 | Pengguna menekan **Terapkan** | `onPressed: _apply` (filter:185) | **Event** |
| 10 | Kolom ongkos diperiksa | `validate()` (filter:46) → `validateFare` (vm:35–41) | **Validation** |
| 11a | Kalau salah (mis. "0"): pesan merah, tetap di Filter | validator mengembalikan teks pesan | **Feedback** |
| 11b | Kalau benar: buat filter baru | `_viewModel.apply(...)` (filter:47, vm:43–49) | **State** |
| 12 | Layar Filter ditutup, menitipkan hasil | `Navigator.pop(context, result)` (filter:48) | **Navigation / Result** |
| 13 | Layar Hasil menerima hasil | `result` dari `await` (hasil:83), dicek `mounted` (hasil:88) | **Result** |
| 14 | ViewModel Hasil menyimpan filter dan menyaring ulang | `applyFilter` (rvm:35–40) → `matchPassengerRides` → `RideFilter.matches` | **State** |
| 15 | Layar Hasil digambar ulang | "1 tebengan searah", "Filter aktif" (hasil:184, 197) | **Feedback** |

Keterangan: *filter* = `ride_filter_screen.dart`, *vm* =
`ride_filter_view_model.dart`, *hasil* = `ride_results_screen.dart`,
*rvm* = `ride_results_view_model.dart`, *routes* = `app_routes.dart`.

Kalau pengguna menekan **kembali** di layar Filter, `result` bernilai `null`.
Langkah 14–15 tidak terjadi, dan filter lama tetap berlaku.

---

## 14. Kenapa begini, bukan begitu?

**Kenapa tidak pakai `setState` saja?**
`setState` hanya bisa dipanggil dari dalam State sebuah layar. Karena state
filter tinggal di ViewModel (kelas terpisah), ViewModel tidak bisa memanggil
`setState`. Sebagai gantinya, ViewModel memanggil `publish()`, dan layar
mendengarkannya lewat `ListenableBuilder`. Hasilnya sama, yaitu layar
digambar ulang, tetapi aturan tetap terpisah dari tampilan.

**Kenapa ada dua ViewModel (Filter dan Hasil)?**
Tugasnya berbeda. ViewModel Filter memegang **draft** yang bisa dibatalkan.
ViewModel Hasil memegang filter yang **berlaku** dan daftar tebengan. Kalau
digabung, membatalkan filter jadi rumit.

**Kenapa filter dikirim lewat `arguments` dan dikembalikan lewat `pop`, bukan
disimpan di variabel global?**
Variabel global bisa diubah dari mana saja, sehingga sulit dilacak siapa yang
mengubahnya. Dengan `arguments` dan `pop`, alurnya jelas: data masuk lewat
satu pintu dan keluar lewat satu pintu.

**Kenapa `TextEditingController` dan `GlobalKey` ada di layar, bukan di ViewModel?**
Keduanya objek tampilan yang terikat umur widget, dan aturan proyek
(dijaga `architecture_test.dart`) melarang ViewModel memakainya. ViewModel
cukup menerima **teks** dari controller.

**Kenapa validasi dua kali (`validate()` lalu di dalam `apply`)?**
`validate()` menampilkan pesan error ke pengguna. Validasi di dalam `apply`
adalah pengaman supaya ViewModel tidak pernah membuat filter rusak, walaupun
dipanggil dari tempat lain (misalnya dari tes).

**Kenapa jam memakai pilihan rentang, bukan jam bebas?**
Supaya mudah diketuk, tanpa perlu mengetik dan tanpa salah format. Pilihannya
bersambung 06.00–19.00. Di luar itu, jangan pilih jam apa pun, maka semua jam
akan tampil.

**Kenapa ongkos 0 tidak dianggap gratis?**
Di data contoh, 0 berarti belum diatur. Menganggapnya gratis bisa menipu
penumpang.

**Kenapa memeriksa `mounted` setelah `await`?**
Selama menunggu layar Filter, layar Hasil bisa saja sudah ditutup. Memakai
layar yang sudah tidak ada menyebabkan error.

---

## 15. Batasan yang harus diakui jujur

- Data tebengan masih **data contoh lokal** (`demo_rides.dart`), belum dari
  server. Penggantian ke server menunggu kesepakatan tim.
- Rentang jam **tetap** (lima pilihan). Penumpang tidak bisa mengetik jam
  persis, misalnya 12.15.
- Filter **tidak disimpan** setelah aplikasi ditutup. Saat aplikasi dibuka
  lagi, filter kembali kosong.
- Searah dihitung dari jarak ≤ 500 m ke jalur pemberi tebengan. Penumpang
  yang lebih jauh dari itu belum bisa memilih titik jemput di jalur. Ide ini
  sudah dicatat untuk dibahas bersama tim.

---

## 16. Latihan "Coba ubah…"

Lakukan saat `flutter run` berjalan. Ubah kode, simpan, lalu tekan `r` di
terminal (hot reload). Untuk perubahan enum atau `static const`, tekan `R`
(hot restart).

1. **Tambah pilihan 4 kursi.** Ubah `seatOptions` menjadi `[1, 2, 3, 4]`
   (vm:7). Tombol "4 kursi" muncul otomatis, karena layar membuat tombol dari
   daftar ini.
2. **Batas ongkos maksimal Rp50.000.** Di `validateFare`, sebelum
   `return null;` di baris 40, tambahkan:
   `if (fare > 50000) return 'Batas ongkos paling tinggi Rp50.000';`
3. **Tambah rentang malam.** Di enum, ganti `;` di akhir `afternoon` dengan
   `,`, lalu tambahkan `evening('Malam 19.00–22.00', 1140, 1320);`.
   Tombolnya otomatis muncul berpasangan dengan "Sore".
4. **Tampilkan pesan setelah filter diterapkan.** Di `_openFilter`, setelah
   `applyFilter(result)`, tampilkan
   `ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter diterapkan')));`.
   Ingat: karena sekarang ada dua perintah, bungkus isi `if` dengan `{ }`.

Contoh prompt AI yang rapi (struktur Module 2):

> **Konteks:** aplikasi Flutter Nebeng Dong, arsitektur MVVM; state filter di
> `RideFilterViewModel`, layar di `ride_filter_screen.dart`.
> **Tujuan:** tambah pilihan minimal 4 kursi.
> **Batasan:** jangan ubah layar; ViewModel tidak boleh import material.dart.
> **Hasil yang diharapkan:** potongan kode yang diubah dan alasannya.
> **Cara uji:** tombol "4 kursi" muncul dan menyaring tebengan dengan ≥ 4 kursi kosong.

---

## 17. Bekal tanya jawab dosen

**"Di mana state-nya?"**
Pilihan sementara ada di `_window` dan `_seats` di `RideFilterViewModel`
(vm:12–13). Filter yang berlaku ada di `_filter` di `RideResultsViewModel`.

**"Bagaimana layar tahu state berubah?"**
ViewModel memanggil `publish()`, yang memanggil `notifyListeners()`.
`ListenableBuilder` di layar mendengarnya, lalu menggambar ulang.

**"Validasinya di mana?"**
`validateFare` di ViewModel. Fungsi ini dipasang sebagai `validator` kolom
ongkos dan dijalankan oleh `_formKey.currentState!.validate()` saat Terapkan.

**"Bagaimana data dikirim antar layar?"**
Masuk lewat `arguments` di `pushNamed`, dan keluar lewat
`Navigator.pop(context, result)`. Layar Hasil menunggunya dengan `await`.

**"Kalau ditekan kembali tanpa Terapkan?"**
`result` bernilai `null`, sehingga `applyFilter` tidak dipanggil dan filter
lama tetap berlaku. Ini dibuktikan oleh tes widget di 12.2.

**"Kenapa `State<RideFilterScreen>` pakai `< >`?"**
`State` adalah kelas generic. Isi `< >` memberi tahu bahwa State ini milik
`RideFilterScreen`, sehingga `widget.initialFilter` bisa dipakai.

**"Apa itu `@protected`?"**
Penanda bahwa `publish()` hanya boleh dipanggil oleh ViewModel turunan, bukan
oleh layar. Dengan begitu, hanya ViewModel yang mengumumkan perubahan state.

**"Kenapa kurung dalam di `matches`?"**
`&&` dikerjakan sebelum `||`. Kurung dalam memastikan `maximumFare!` hanya
dipakai setelah dipastikan tidak null.

**"Apa yang dibantu AI, dan apa yang kamu periksa sendiri?"**
Jawab jujur. AI membantu menulis dan merapikan kode. Kamu memeriksanya dengan
menjalankan tes (`flutter test`), mencoba di HP, dan memahami setiap baris
lewat dokumen ini.

---

## 18. Kamus tata bahasa Dart

| Tulisan | Arti | Contoh |
|---|---|---|
| `import '...';` | pakai kode dari file lain | `import 'package:flutter/material.dart';` |
| `class A { }` | cetakan objek | `class RideFilter` |
| `extends B` | mewarisi kemampuan B | `RideFilterViewModel extends ViewModel` |
| `abstract class` | kelas yang hanya untuk diwarisi | `abstract class ViewModel` |
| `Tipe<X>` | generic: wadah/kelas untuk tipe X | `List<Ride>`, `State<RideFilterScreen>` |
| `enum` | daftar pilihan tetap | `enum DepartureWindow` |
| `final` | diisi sekali, tidak bisa diganti | `final int minimumSeats;` |
| `const` | nilai tetap sejak awal, dibuat sekali | `const SizedBox(height: 8)` |
| `late` | diisi nanti, pasti sebelum dipakai | `late final TextEditingController _fare;` |
| `var` | variabel, tipenya ditebak Dart | `for (var i = 0; ...)` |
| `static` | milik kelas, bukan objek | `RideFilterViewModel.seatOptions` |
| `_nama` | privat, hanya di file itu | `_window`, `_apply` |
| `@protected` | hanya untuk kelas turunan | `publish()` |
| `@override` | menimpa fungsi milik induk | `void dispose()` |
| `super` | induk | `super.dispose()` |
| `Tipe?` | boleh null | `DepartureWindow? window` |
| `x!` | jaminan x tidak null | `maximumFare!` |
| `a ?? b` | pakai a, kalau null pakai b | `value?.trim().isEmpty ?? true` |
| `a?.b` | ambil b kalau a tidak null | `value?.trim()` |
| `k ? x : y` | kalau k benar x, kalau salah y | `selected ? brandSubtle : border` |
| `&&` / `\|\|` / `!` | dan / atau / tidak | `a && (b \|\| c)` |
| `=>` | fungsi satu baris: "hasilnya adalah…" | `int get seats => _seats;` |
| `get` | getter: dihitung saat dibaca | `bool get isActive` |
| `void` | fungsi tanpa nilai kembali | `void reset()` |
| `{a, b}` | parameter bernama | `RideFilter(minimumSeats: 2)` |
| `required` | parameter bernama wajib | `required this.request` |
| `this.x` | isi field x langsung dari parameter | `const DepartureWindow(this.label, ...)` |
| `: x = ...` | initializer list | `: _window = initialFilter.window` |
| `Future<T>` | hasil yang datang nanti | `Future<void> _openFilter()` |
| `async` / `await` | boleh menunggu / tunggu di sini | `await Navigator.pushNamed(...)` |
| `'$x'` | sisipkan nilai ke teks | `'$seats kursi'` |
| `() => aksi()` | fungsi tanpa nama, dijalankan nanti | `() => _viewModel.selectSeats(2)` |
| `(_)` | parameter yang tidak dipakai | `onFieldSubmitted: (_) => _apply()` |
| `fungsi` tanpa `()` | menyerahkan fungsinya, bukan hasilnya | `onPressed: _apply` |
| `for`/`if` di dalam `[ ]` | membuat isi daftar dengan perulangan/kondisi | tombol jam dan kursi |
| `...[ ]` | spread: tuang isi daftar | `for (...) ...[SizedBox, Row]` |
| `is` / `is!` | cek tipe / bukan tipe | `args is! RideFilter` |
| `as Tipe` | perlakukan sebagai tipe itu | `args as RideFilter?` |
| `switch` | pilih berdasarkan nilai | `switch (settings.name)` |
| `(a, b)`, `.$1`, `.$2` | record: pasangan nilai, isi ke-1, ke-2 | `(ride, match)` |
| `continue` | lewati ke putaran berikutnya | di `matchPassengerRides` |
| `return` | keluar dari fungsi (dengan hasil) | `return false;` |
