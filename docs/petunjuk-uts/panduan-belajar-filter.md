# Panduan Belajar A–Z — Workflow Filter Nebeng Dong

> Versi lengkap dalam satu file, urut sesuai pembuatan kode:
> [Belajar Fitur Filter dari Nol](belajar-filter-dari-nol.md).

Panduan ini untuk persiapan UTS (demo + code review). Ditulis untuk pembaca yang
**belum tahu apa-apa** tentang MVVM. Bacalah berurutan. Potongan kode di sini diambil
dari kode proyek per 14 Oktober 2026 (sebagian dipersingkat, ditandai `...`); buka file
aslinya sambil membaca.

Penjelasan **baris per baris** (termasuk tata bahasa Dart seperti `extends`, `<>`,
`_`, `?`, `late`) ada di dokumen pendamping: [bedah kode Filter](bedah-kode-filter.md).

Daftar isi:

1. [Gambaran besar aplikasi](#1-gambaran-besar-aplikasi)
2. [Dasar Flutter yang perlu diingat](#2-dasar-flutter-yang-perlu-diingat)
3. [Masalah kalau semua ditaruh di satu layar](#3-masalah-kalau-semua-ditaruh-di-satu-layar)
4. [Apa itu MVVM](#4-apa-itu-mvvm)
5. [Peta folder proyek](#5-peta-folder-proyek)
6. [Mesin penghubung: ViewModel, publish, ListenableBuilder](#6-mesin-penghubung-viewmodel-publish-listenablebuilder)
7. [Workflow Filter langkah demi langkah](#7-workflow-filter-langkah-demi-langkah)
8. [Lima tahap UTS di workflow ini](#8-lima-tahap-uts-di-workflow-ini)
9. [Kenapa begini, bukan begitu?](#9-kenapa-begini-bukan-begitu)
10. [Batasan yang harus dijelaskan jujur](#10-batasan-yang-harus-dijelaskan-jujur)
11. [Latihan "Coba ubah…"](#11-latihan-coba-ubah)
12. [Kamus istilah](#12-kamus-istilah)

---

## 1. Gambaran besar aplikasi

Nebeng Dong mempertemukan mahasiswa yang **searah** ke kampus. Alur utama penumpang:

```text
Login → Cari Tebengan → Hasil Pencarian ⇄ Filter Pencarian → Detail Tebengan
```

- **Cari Tebengan**: pilih titik **Dari** dan **Ke**.
- **Hasil Pencarian**: daftar tebengan yang jalurnya melewati titik Dari lalu Ke.
- **Filter Pencarian**: saring hasil menurut jam cabut, minimal kursi, dan batas ongkos.
- **Detail Tebengan**: info lengkap satu tebengan.

Workflow yang didemokan untuk UTS: **Hasil ⇄ Filter**. Pengguna menekan Filter,
memilih syarat, menekan Terapkan, lalu kembali ke Hasil dengan daftar yang sudah disaring.

---

## 2. Dasar Flutter yang perlu diingat

| Istilah | Arti singkat |
|---|---|
| **Widget** | Semua yang tampil di layar adalah widget: teks, tombol, kolom, layar. |
| **StatelessWidget** | Widget yang tampilannya tidak berubah sendiri. |
| **StatefulWidget** | Widget yang punya data berubah (state) dan bisa digambar ulang. |
| **build()** | Fungsi yang "menggambar" layar berdasarkan data saat itu. |
| **State** | Data yang bisa berubah, mis. jam yang sedang dipilih. |
| **setState()** | Cara paling sederhana memberi tahu Flutter: "data berubah, gambar ulang." (Module 4) |

Kunci utama Flutter: **layar = gambar dari data**. Kalau data berubah dan Flutter
diberi tahu, `build()` dijalankan lagi dan layar ikut berubah.

---

## 3. Masalah kalau semua ditaruh di satu layar

Cara paling sederhana (seperti contoh di Module 4) adalah menaruh semuanya di layar:

```dart
// Contoh gaya "semua di layar" — BUKAN kode proyek kita.
class _FilterState extends State<FilterScreen> {
  DepartureWindow? window;           // data
  void pilihJam(DepartureWindow w) { // aturan
    setState(() => window = w);      // gambar ulang
  }
  String? cekOngkos(String v) { /* aturan validasi di sini juga */ }
  Widget build(...) { /* tampilan */ }
}
```

Untuk layar kecil ini **tidak salah**. Tapi saat aplikasi tumbuh, muncul masalah:

1. **Campur aduk.** Tampilan, data, dan aturan bercampur di satu file panjang.
2. **Sulit diuji.** Untuk menguji aturan ongkos, harus menyalakan layar dulu.
3. **Sulit dipakai bersama.** Filter yang dipilih harus dibawa ke layar lain (Hasil, Cari).

MVVM adalah cara memisahkan ketiganya supaya rapi, mudah diuji, dan mudah diubah.
Module 3 (slide "A Simple MVVM Mental Model") mengajarkan pola ini.

---

## 4. Apa itu MVVM

MVVM = **Model – View – ViewModel**. Analogi restoran:

| Bagian | Analogi | Tugas di kode | Contoh di proyek |
|---|---|---|---|
| **View** | Pelayan | Menampilkan layar, menerima ketukan/ketikan, pindah layar | `ride_filter_screen.dart` |
| **ViewModel** | Kepala dapur | Menyimpan state, menjalankan aturan (validasi), memberi tahu View kalau ada perubahan | `ride_filter_view_model.dart` |
| **Model** | Resep & bahan | Bentuk data dan aturan dasar data | `ride_filter.dart` (`RideFilter`, `DepartureWindow`) |

Aturan pembagian tugas di proyek ini:

- **View boleh**: widget, `TextEditingController`, `GlobalKey<FormState>`, `Navigator`, `SnackBar`.
- **ViewModel tidak boleh**: mengenal widget, `BuildContext`, `Navigator`, `TextEditingController`.
  ViewModel hanya berisi data dan aturan. Ada tes otomatis (`test/architecture/`) yang
  gagal kalau aturan ini dilanggar.
- **Model**: data murni dan aturan yang melekat pada data (mis. "apakah tebengan ini lolos filter").

Kenapa ViewModel tidak boleh memegang `Navigator`/`context`? Supaya ViewModel bisa diuji
**tanpa** menyalakan layar, dan supaya urusan tampilan tetap di satu tempat (View).

---

## 5. Peta folder proyek

```text
lib/
  main.dart                    titik awal aplikasi
  core/
    view_model.dart            induk semua ViewModel (publish, dispose)
    di/                        "penyedia" repository & layanan peta untuk seluruh app
  features/                    satu folder per fitur (bukan per orang)
    auth/                      Login
    ride_search/               MODUL MIKAIL: Cari, Hasil, Filter
      data/                    sumber data (repository, data latihan)
      models/                  RideFilter, DepartureWindow, RideSearchRequest
      utils/                   pencocokan rute (RouteMatcher, matchPassengerRides)
      viewmodels/              HomeViewModel, RideResultsViewModel, RideFilterViewModel
      views/                   HomeScreen, RideResultsScreen, RideFilterScreen
      widgets/                 kartu tebengan, navigasi bawah
    booking/ costs/ reputation/  modul teman (sebagian besar belum dibuat)
  shared/                      dipakai banyak fitur: model Ride, Detail, peta, widget umum
  routes/app_routes.dart       daftar semua route (alamat layar)
  theme/                       warna, jarak, gaya teks (token dari Figma)
test/                          tes otomatis, susunannya mengikuti lib/
```

Untuk workflow Filter, cukup kuasai **6 file**:

| File | Peran |
|---|---|
| `features/ride_search/models/ride_filter.dart` | Model: bentuk filter + aturan "tebengan ini lolos?" |
| `features/ride_search/viewmodels/ride_filter_view_model.dart` | ViewModel layar Filter |
| `features/ride_search/views/ride_filter_screen.dart` | View layar Filter |
| `features/ride_search/viewmodels/ride_results_view_model.dart` | ViewModel layar Hasil |
| `features/ride_search/views/ride_results_screen.dart` | View layar Hasil |
| `routes/app_routes.dart` | Menghubungkan alamat `/ride-filter` ke layar Filter |

---

## 6. Mesin penghubung: ViewModel, publish, ListenableBuilder

Bagaimana View tahu kalau data di ViewModel berubah? Lewat tiga potong kode ini.

### 6.1 Induk semua ViewModel — `lib/core/view_model.dart`

```dart
abstract class ViewModel extends ChangeNotifier {
  bool _disposed = false;
  bool get isDisposed => _disposed;

  @protected
  void publish() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
```

- `ChangeNotifier` adalah kelas bawaan Flutter yang bisa "berteriak" ke pendengarnya.
- `publish()` = berteriak "datanya berubah!" (memanggil `notifyListeners()`).
- Ada pengaman `_disposed`: kalau layar sudah ditutup, tidak berteriak lagi (mencegah error).

### 6.2 View mendengarkan — `ListenableBuilder`

```dart
@override
Widget build(BuildContext context) => ListenableBuilder(
  listenable: _viewModel,
  builder: (context, _) => Scaffold( /* seluruh layar */ ),
);
```

`ListenableBuilder` = "telinga". Setiap kali ViewModel memanggil `publish()`, bagian
`builder` dijalankan ulang dan layar digambar ulang dengan data terbaru.

### 6.3 Perbandingan dengan `setState` (Module 4)

| `setState` (slide) | Proyek kita |
|---|---|
| `setState(() { selectedIndex = index; });` | `_viewModel.selectWindow(window);` → di dalamnya `_window = value; publish();` |
| Data disimpan di `State` layar | Data disimpan di ViewModel |
| Flutter menggambar ulang layar itu | `ListenableBuilder` menggambar ulang |

**Intinya sama: Event → ubah State → umumkan → UI digambar ulang.** Bedanya hanya di
mana data disimpan. `setState` tetap dipakai di proyek ini untuk state yang murni urusan
tampilan, mis. `lib/shared/maps/widgets/open_street_map_view.dart` (gagal memuat peta).

---

## 7. Workflow Filter langkah demi langkah

### 7.1 Model — bentuk data filter (`ride_filter.dart`)

```dart
enum DepartureWindow {
  early('06.00–07.00', 360, 420),
  morning('07.00–08.00', 420, 480),
  lateMorning('08.00–09.00', 480, 540),
  midday('Siang 09.00–15.00', 540, 900),
  afternoon('Sore 15.00–19.00', 900, 1140);

  const DepartureWindow(this.label, this.startMinute, this.endMinute);
  final String label;
  final int startMinute;
  final int endMinute;
}
```

- `enum` = daftar pilihan yang tetap. Setiap pilihan membawa **label** (teks di tombol)
  dan rentang **menit** sejak tengah malam (07.00 = 7 × 60 = 420).
- Pakai menit supaya membandingkan jam cukup dengan angka biasa.

```dart
class RideFilter {
  const RideFilter({this.window, this.minimumSeats = 1, this.maximumFare});

  final DepartureWindow? window;   // null = semua jam
  final int minimumSeats;          // minimal kursi kosong
  final int? maximumFare;          // null = semua ongkos

  bool get isActive =>
      window != null || minimumSeats != 1 || maximumFare != null;

  bool matches(Ride ride) {
    if (ride.seatsAvailable < minimumSeats || ride.isFull) return false;
    if (maximumFare != null &&
        (ride.farePerPerson == 0 || ride.farePerPerson > maximumFare!)) {
      return false;
    }
    final selected = window;
    if (selected == null) return true;
    final minute = parseDepartureMinute(ride.departureTime);
    return minute != null &&
        minute >= selected.startMinute &&
        minute < selected.endMinute;
  }
}
```

Logika `matches` dibaca dari atas ke bawah — tebengan **gugur** jika:

1. kursi kosongnya kurang dari minimal, atau sudah penuh;
2. ada batas ongkos, dan ongkosnya belum diatur (0) atau melebihi batas;
3. ada jam yang dipilih, dan jam cabutnya di luar rentang.

Kalau lolos semua → `true` (ditampilkan). Tanda `?` berarti boleh `null` (null safety, Module 2).
Semua field `final` dan konstruktor `const` → filter **tidak bisa diubah** setelah dibuat (immutable).

### 7.2 ViewModel layar Filter (`ride_filter_view_model.dart`)

```dart
class RideFilterViewModel extends ViewModel {
  static const seatOptions = [1, 2, 3];          // pilihan tombol kursi

  RideFilterViewModel({RideFilter initialFilter = const RideFilter()})
    : _window = initialFilter.window,             // mulai dari filter lama
      _seats = initialFilter.minimumSeats;
  DepartureWindow? _window;                       // STATE: jam terpilih (sementara)
  int _seats;                                     // STATE: kursi terpilih (sementara)
  DepartureWindow? get window => _window;         // View hanya boleh MEMBACA
  int get seats => _seats;

  void selectWindow(DepartureWindow? value) {     // EVENT dari tombol jam
    _window = value;
    publish();                                    // umumkan → layar digambar ulang
  }

  void selectSeats(int value) {                   // EVENT dari tombol kursi
    _seats = value;
    publish();
  }

  void reset() {                                  // EVENT dari Atur Ulang
    _window = null;
    _seats = 1;
    publish();
  }

  String? validateFare(String? value) {           // VALIDASI ongkos
    if (value?.trim().isEmpty ?? true) return null;          // kosong = boleh
    final fare = parseFare(value!);
    if (fare == null) return 'Isi rupiah bulat, contoh 10.000';
    if (fare <= 0) return 'Batas ongkos harus lebih dari Rp0';
    return null;                                              // null = valid
  }

  RideFilter? apply(String fare) => validateFare(fare) != null
      ? null                                      // tidak valid → tidak ada hasil
      : RideFilter(                               // valid → buat filter baru
          window: _window,
          minimumSeats: _seats,
          maximumFare: fare.trim().isEmpty ? null : parseFare(fare),
        );
}
```

Hal penting:

- Garis bawah `_window` = **privat**. View tidak bisa mengubahnya langsung, hanya lewat
  fungsi `selectWindow`. Ini menjaga aturan tetap di satu tempat.
- Konvensi validator Flutter: **kembalikan `null` kalau valid**, kembalikan **teks pesan**
  kalau tidak valid (sama seperti slide "Form Validation" Module 4).
- `apply` memanggil `validateFare` lagi. Jadi walaupun `apply` dipanggil tanpa form,
  filter yang salah **tidak mungkin** dibuat (pengaman lapis kedua).

### 7.3 View layar Filter (`ride_filter_screen.dart`)

**a. Persiapan dan pembersihan**

```dart
final _formKey = GlobalKey<FormState>();
late final RideFilterViewModel _viewModel;
late final TextEditingController _fare;

@override
void initState() {
  super.initState();
  _viewModel = RideFilterViewModel(initialFilter: widget.initialFilter);
  final fare = widget.initialFilter.maximumFare;
  _fare = TextEditingController(
    text: fare == null ? '' : formatThousands(fare),   // 10000 → "10.000"
  );
}

@override
void dispose() {
  _viewModel.dispose();
  _fare.dispose();
  super.dispose();
}
```

- `initState` dijalankan **sekali** saat layar dibuka: membuat ViewModel dan controller,
  diisi filter yang sedang berlaku (dikirim dari layar Hasil).
- `dispose` dijalankan saat layar ditutup: membersihkan agar tidak bocor memori
  (slide TextEditingController Module 4: "Remember to dispose").
- `GlobalKey<FormState>` = "remote" untuk memerintahkan semua kolom form memvalidasi.

**b. Pilihan jam dan kursi (Input/Event)**

```dart
Widget _windowChoice(DepartureWindow window) => _choice(
  window.label,
  _viewModel.window == window,                      // terpilih? → warna berbeda
  () => _viewModel.selectWindow(_viewModel.window == window ? null : window),
);
```

Ketuk jam yang sedang terpilih sekali lagi → dikirim `null` → pilihan batal.
Tombol-tombolnya dibuat otomatis dari data:

```dart
for (var i = 0; i < DepartureWindow.values.length; i += 2) ...[  // 2 per baris
  ...
]
for (final seats in RideFilterViewModel.seatOptions) ...[         // 1, 2, 3
  ...
]
```

Jadi menambah pilihan jam/kursi cukup mengubah **data** (enum atau `seatOptions`),
layar menyesuaikan sendiri.

**c. Kolom ongkos**

```dart
AppTextField(
  label: 'Ongkos paling mahal',
  hint: 'Contoh: 10.000',
  controller: _fare,
  keyboardType: TextInputType.number,
  onFieldSubmitted: (_) => _apply(),
  validator: _viewModel.validateFare,          // aturan dari ViewModel
),
```

**d. Tombol Terapkan dan Atur Ulang**

```dart
void _apply() {
  if (!_formKey.currentState!.validate()) return;   // 1. validasi; gagal → berhenti
  final result = _viewModel.apply(_fare.text);       // 2. buat RideFilter baru
  if (result != null) Navigator.pop(context, result); // 3. tutup layar + kirim hasil
}

void _reset() {
  _formKey.currentState!.reset();   // hapus pesan error
  _fare.clear();                    // kosongkan kolom ongkos
  _viewModel.reset();               // kosongkan jam & kursi
}
```

- Kalau validasi gagal, `return` membuat pengguna **tetap di form**, pesan error tampil.
- **Atur Ulang tidak menutup layar**; hasil baru berubah setelah Terapkan.

### 7.4 Navigasi — mengirim dan menerima data

**Mengirim (layar Hasil → Filter)** — `ride_results_screen.dart`:

```dart
Future<void> _openFilter() async {
  final result = await Navigator.pushNamed<RideFilter>(
    context,
    AppRoutes.rideFilter,            // alamat '/ride-filter'
    arguments: _viewModel.filter,    // KIRIM filter yang sedang berlaku
  );
  if (mounted && result != null) _viewModel.applyFilter(result);  // TERIMA hasil
}
```

- `pushNamed` = buka layar baru di atas tumpukan (navigation stack, Module 4).
- `await` = tunggu sampai layar Filter ditutup, lalu ambil hasilnya.
- `<RideFilter>` = jenis data yang diharapkan kembali.
- `result` **null** kalau pengguna menekan kembali tanpa Terapkan → filter lama dipakai.
- `mounted` = memastikan layar Hasil masih ada sebelum dipakai (aman setelah `await`).

**Router menerima alamat** — `app_routes.dart`:

```dart
case rideFilter:
  final args = settings.arguments;
  if (args != null && args is! RideFilter) return null;   // tipe salah → 404
  return MaterialPageRoute<RideFilter>(
    settings: settings,
    builder: (_) => RideFilterScreen(
      initialFilter: args as RideFilter? ?? const RideFilter(),
    ),
  );
```

Router memeriksa tipe data dulu. Kalau benar, layar Filter dibuat dan datanya diteruskan
lewat **konstruktor** (`initialFilter`), sesuai slide "Passing Data Between Screens".

**Mengembalikan (Filter → Hasil)**: `Navigator.pop(context, result)` di `_apply`
(sama seperti slide "Passing and Returning Data": `Navigator.pop(context, true)`).

### 7.5 Layar Hasil memakai filter baru (`ride_results_view_model.dart`)

```dart
void applyFilter(RideFilter filter) {
  if (isDisposed) return;
  _filter = filter;                                          // simpan filter baru
  _results = matchPassengerRides(_rides, request, _filter);  // hitung ulang daftar
  publish();                                                 // umumkan → layar berubah
}
```

`matchPassengerRides` (`utils/ride_search_matcher.dart`) mengambil setiap tebengan, lalu:

1. buang yang tidak lolos `filter.matches(ride)` (kursi, ongkos, jam — §7.1);
2. buang yang tidak punya data jalur;
3. cek **searah** dengan `RouteMatcher.match`: titik Dari dan Ke masing-masing ≤ 500 m
   dari jalur, dan jemput terjadi **sebelum** turun di sepanjang jalur;
4. urutkan dari yang paling dekat dengan jalur.

### 7.6 Feedback di layar Hasil (`ride_results_screen.dart`)

```dart
'${_viewModel.results.length} tebengan searah'                 // jumlah hasil
_viewModel.filter.isActive ? 'Filter aktif' : 'Filter'          // label tombol
'Belum ada yang searah'                                         // kalau kosong
LoadingView(message: 'Nyari tebengan dulu...')                 // saat memuat
```

Semua teks ini dibaca dari ViewModel. Karena `applyFilter` memanggil `publish()`,
`ListenableBuilder` menggambar ulang dan teksnya langsung berganti.

### 7.7 Ringkasan alur dalam satu gambar

```text
[Hasil] tombol Filter
   │ pushNamed('/ride-filter', arguments: filter lama)
   ▼
[Router] cek tipe → buat RideFilterScreen(initialFilter)
   ▼
[Filter] ketuk jam/kursi → ViewModel.selectX → publish → layar berubah warna
         ketik ongkos → controller
         Terapkan → validate() ──gagal──▶ pesan error, tetap di form
                         └─lolos─▶ ViewModel.apply → RideFilter baru
                                    → Navigator.pop(context, filter baru)
   ▼
[Hasil] result != null → ViewModel.applyFilter → hitung ulang → publish
         → jumlah hasil, "Filter aktif", ringkasan berubah
```

---

## 8. Lima tahap UTS di workflow ini

| Tahap | Di workflow Filter | Di kode |
|---|---|---|
| **Input / Event** | Tekan Filter, ketuk jam/kursi, ketik ongkos, tekan Terapkan/Atur Ulang | `_openFilter`, `_windowChoice`, `selectSeats`, `_fare`, `_apply`, `_reset` |
| **State** | Pilihan sementara; filter yang berlaku; daftar hasil | `_window`, `_seats` (Filter VM); `_filter`, `_results` (Hasil VM) |
| **Validation** | Ongkos harus rupiah bulat > 0 atau kosong | `validateFare` + `_formKey.currentState!.validate()` |
| **Feedback** | Pesan error, warna pilihan, jumlah hasil, "Filter aktif", tampilan kosong | validator, `_choice`, teks di Hasil |
| **Navigation / Result** | Kirim filter lama, kembalikan filter baru | `pushNamed<RideFilter>(arguments:)`, `Navigator.pop(context, result)` |

---

## 9. Kenapa begini, bukan begitu?

**Kenapa pakai ViewModel, bukan `setState` saja?**
Karena filter dipakai lintas layar (Filter → Hasil → Cari) dan aturannya perlu diuji
tanpa layar. Dengan ViewModel, aturan bisa dites dengan tes unit biasa
(`test/regression/view_model_test.dart`). `setState` tetap cocok untuk state tampilan kecil.

**Kenapa pilihan di Filter tidak langsung mengubah Hasil?**
Supaya pengguna bisa coba-coba lalu **batal**. Pilihan disimpan sebagai draft di ViewModel
Filter; baru menjadi filter yang berlaku setelah Terapkan.

**Kenapa validasi ongkos dijalankan dua kali?**
Pertama oleh form (untuk menampilkan pesan di kolom). Kedua di `apply` (supaya
ViewModel tidak pernah menghasilkan filter salah walau dipanggil dari tempat lain).

**Kenapa teks ongkos disimpan di `TextEditingController`, bukan di ViewModel?**
Controller adalah objek tampilan (ikut kursor, keyboard). Aturan proyek: View yang
memegang controller, ViewModel cukup menerima teksnya saat dibutuhkan (`apply(_fare.text)`).

**Kenapa `onGenerateRoute`, bukan `routes: {}` seperti slide?**
Agar tipe data yang dikirim **diperiksa** dulu. Dengan `routes: {}` + `ModalRoute.of(context)`
datanya berupa `Map` dan bisa salah tanpa ketahuan. Di sini, data salah → halaman 404.

**Kenapa hasil Filter dikembalikan lewat `pop`, bukan disimpan di variabel global?**
Lebih jelas alurnya: "layar Filter menjawab layar yang membukanya". Tidak ada data
tersembunyi yang bisa diubah dari mana saja.

**Kenapa `RideFilter` immutable (tidak bisa diubah)?**
Supaya filter yang sedang dipakai layar Hasil tidak bisa berubah diam-diam saat
pengguna masih mengutak-atik layar Filter. Perubahan = membuat objek baru.

**Kenapa jam pakai `enum`, bukan jam bebas?**
Lebih sederhana untuk pengguna (cukup ketuk) dan aman dari input salah. Batasannya: jam
tidak bisa dipilih persis (lihat §10).

---

## 10. Batasan yang harus dijelaskan jujur

- **Data latihan, bukan backend.** Tebengan berasal dari `data/fixtures/demo_rides.dart`
  lewat `LocalRideRepository` (pura-pura memuat 2 detik). Backend belum ada.
- **Filter tidak tersimpan permanen.** Hilang saat aplikasi ditutup.
- **Jam berupa rentang tetap** 06.00–19.00 (5 pilihan). Di luar itu, kosongkan pilihan jam.
- **"Searah" = ≤ 500 m dari jalur**, dihitung garis lurus, bukan jarak jalan kaki.
  Penumpang yang lebih jauh bisa menaruh pin di jalan yang dilewati.
- **Asal–tujuan minimal 50 m** (garis lurus).
- **Saran tempat** dari layanan Photon gratis kadang lambat; ada **saran cepat** lokal
  (Khatib, Veteran, Unand) yang langsung muncul tanpa internet.
- **"Nunggu di-ACC" di Detail** hanya tampilan; pesanan adalah Modul 2 (Taris).

---

## 11. Latihan "Coba ubah…"

Lakukan satu per satu. Setelah selesai, kembalikan kode dengan `git restore .`.
Jika perubahan tidak muncul setelah hot reload (`r`), tekan **hot restart (`R`)**.

**Latihan 1 — Tambah pilihan 4 kursi.**
Di `ride_filter_view_model.dart`, ubah `static const seatOptions = [1, 2, 3];`
menjadi `[1, 2, 3, 4]`. Layar Filter otomatis menampilkan tombol "4 kursi".

**Latihan 2 — Batas ongkos maksimal Rp50.000.**
Di `validateFare`, sebelum `return null;` tambahkan:

```dart
if (fare > 50000) return 'Batas ongkos maksimal Rp50.000';
```

Coba ketik `60000` → muncul pesan, tetap di form.

**Latihan 3 — Tambah jam Malam.**
Di enum `DepartureWindow`, tambahkan setelah `afternoon`:

```dart
evening('Malam 19.00–22.00', 1140, 1320),
```

(ubah `;` di akhir `afternoon(...)` menjadi `,`). Tombol baru muncul otomatis.

**Latihan 4 — Pesan "Filter diterapkan".**
Di `_openFilter` (`ride_results_screen.dart`), ganti baris terakhir menjadi:

```dart
if (mounted && result != null) {
  _viewModel.applyFilter(result);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Filter diterapkan')),
  );
}
```

Kenapa di View, bukan ViewModel? Karena `SnackBar` butuh `context`, dan ViewModel
dilarang memegang `context`.

**Contoh prompt AI (struktur Module 2):**

> **Konteks:** Aplikasi Flutter Nebeng Dong, pola MVVM (ChangeNotifier + ListenableBuilder).
> **Tujuan:** Tambah batas ongkos maksimal Rp50.000 di layar Filter.
> **Lokasi:** `validateFare` di `lib/features/ride_search/viewmodels/ride_filter_view_model.dart`.
> **Batasan:** Jangan ubah file lain; ViewModel tidak boleh memakai BuildContext.
> **Output:** Kode yang diubah + penjelasan per baris.
> **Pengujian:** Contoh input yang ditolak dan yang diterima, plus satu tes unit.

Setelah AI menjawab, uji dengan **5 pertanyaan Module 1**: kode ini melakukan apa? kenapa
cara ini? bagaimana cara kerjanya? apa risikonya? bagaimana mengujinya?

---

## 12. Kamus istilah

| Istilah | Arti |
|---|---|
| **MVVM** | Pola pemisahan Model (data), View (tampilan), ViewModel (state + aturan). |
| **ChangeNotifier** | Kelas Flutter yang bisa memberi tahu pendengarnya saat data berubah. |
| **notifyListeners / publish** | "Berteriak" bahwa data berubah. `publish` adalah versi aman milik proyek. |
| **ListenableBuilder** | Widget yang menggambar ulang bagiannya setiap kali dengar perubahan. |
| **Immutable** | Tidak bisa diubah setelah dibuat; perubahan = buat objek baru. |
| **enum** | Daftar pilihan tetap, mis. 5 rentang jam. |
| **Validator** | Fungsi pemeriksa input: `null` = valid, teks = pesan error. |
| **GlobalKey&lt;FormState&gt;** | Kunci untuk memerintahkan seluruh form memvalidasi/mereset. |
| **TextEditingController** | Objek untuk membaca/mengubah isi kolom teks. Wajib di-`dispose`. |
| **Navigator.pushNamed** | Buka layar lewat nama alamat (route). |
| **arguments** | Data yang dikirim ke layar tujuan. |
| **Navigator.pop(context, hasil)** | Tutup layar dan kirim hasil ke layar sebelumnya. |
| **await** | Tunggu proses selesai (mis. layar tujuan ditutup) sebelum lanjut. |
| **mounted** | Apakah layar masih ada; dicek setelah `await` sebelum memakai `context`. |
| **Repository** | Sumber data (sekarang data latihan, nanti backend). |
| **Hot reload / hot restart** | `r` = terapkan perubahan tanpa mengulang app; `R` = ulang dari awal. |
