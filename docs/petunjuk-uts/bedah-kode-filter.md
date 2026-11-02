# Bedah Kode Baris per Baris — Workflow Filter

> Versi lengkap dalam satu file, urut sesuai pembuatan kode:
> [Belajar Fitur Filter dari Nol](belajar-filter-dari-nol.md).

Lanjutan dari [panduan belajar](panduan-belajar-filter.md). Di sini setiap baris kode
dijelaskan, termasuk tata bahasa Dart-nya. Nomor baris mengikuti file asli per
14 Oktober 2026. Bacalah sambil membuka file yang sama di VS Code.

> Catatan: contoh `class _FilterState extends State<FilterScreen>` di panduan bab 3
> adalah contoh karangan. Kode aslinya bernama `_RideFilterScreenState` dan
> `RideFilterScreen` — dibedah di [Bagian E](#e-layar-filter--viewsride_filter_screendart).

Urutan:

- [A. Kamus tata bahasa Dart](#a-kamus-tata-bahasa-dart)
- [B. Induk ViewModel — `core/view_model.dart`](#b-induk-viewmodel--coreview_modeldart)
- [C. Model filter — `models/ride_filter.dart`](#c-model-filter--modelsride_filterdart)
- [D. ViewModel Filter — `viewmodels/ride_filter_view_model.dart`](#d-viewmodel-filter--viewmodelsride_filter_view_modeldart)
- [E. Layar Filter — `views/ride_filter_screen.dart`](#e-layar-filter--viewsride_filter_screendart)
- [F. Router — `routes/app_routes.dart`](#f-router--routesapp_routesdart)
- [G. Layar Hasil — `views/ride_results_screen.dart`](#g-layar-hasil--viewsride_results_screendart)
- [H. ViewModel Hasil — `viewmodels/ride_results_view_model.dart`](#h-viewmodel-hasil--viewmodelsride_results_view_modeldart)
- [I. Penyaring hasil — `utils/ride_search_matcher.dart`](#i-penyaring-hasil--utilsride_search_matcherdart)

---

## A. Kamus tata bahasa Dart

Simbol dan kata kunci yang muncul di kode workflow ini.

| Tulisan | Arti | Contoh di kode |
|---|---|---|
| `import '...';` | Memakai kode dari file lain. | `import 'package:flutter/material.dart';` |
| `class Nama { }` | Cetakan/blueprint objek: berisi data (field) dan fungsi (method). | `class RideFilter { ... }` |
| `extends Induk` | **Pewarisan**: kelas ini mendapat semua kemampuan `Induk`, lalu menambah sendiri. | `RideFilterViewModel extends ViewModel` |
| `abstract class` | Kelas yang tidak dipakai langsung, hanya jadi induk. | `abstract class ViewModel` |
| `Nama<Tipe>` | **Generic**: "wadah/kelas ini untuk tipe ini". Isi `<>` adalah tipe data. | `List<Ride>` = daftar berisi Ride; `State<RideFilterScreen>` = State milik RideFilterScreen |
| `enum` | Daftar pilihan tetap. | `enum DepartureWindow { early, ... }` |
| `final` | Diisi **sekali**, tidak bisa diganti. | `final int minimumSeats;` |
| `const` | Nilai tetap yang sudah diketahui saat compile; dibuat sekali, hemat memori. | `const SizedBox(height: 8)` |
| `late` | "Diisi nanti" (bukan di baris deklarasi), tapi pasti sebelum dipakai. | `late final TextEditingController _fare;` |
| `var` | Variabel yang tipenya ditebak Dart. | `for (var i = 0; ...)` |
| `static` | Milik **kelas**, bukan milik objek. Dipanggil lewat nama kelas. | `RideFilterViewModel.seatOptions` |
| `_nama` | Diawali garis bawah = **privat**, hanya bisa dipakai di file itu. | `_window`, `_apply`, `_RideFilterScreenState` |
| `Tipe?` | Boleh berisi `null` (kosong). | `DepartureWindow? window` |
| `x!` | "Saya jamin `x` tidak null". Kalau ternyata null → error. | `_formKey.currentState!` |
| `a ?? b` | Pakai `a`, kalau `a` null pakai `b`. | `value?.trim().isEmpty ?? true` |
| `a?.b` | Ambil `b` dari `a` hanya kalau `a` tidak null; kalau null hasilnya null. | `value?.trim()` |
| `kondisi ? x : y` | Kalau kondisi benar → `x`, salah → `y`. | `selected ? AppColors.brandSubtle : AppColors.border` |
| `=> ekspresi` | Fungsi pendek: langsung mengembalikan satu nilai. | `int get seats => _seats;` |
| `{a, b}` di parameter | **Parameter bernama**: dipanggil dengan menyebut namanya. | `RideFilter(window: x, minimumSeats: 2)` |
| `required` | Parameter bernama yang wajib diisi. | `required this.repository` |
| `this.x` di konstruktor | Langsung mengisi field `x` dari parameter. | `const DepartureWindow(this.label, ...)` |
| `: a = ...` setelah konstruktor | **Initializer list**: mengisi field sebelum isi konstruktor jalan. | `: _window = initialFilter.window` |
| `super` | Merujuk ke kelas induk. | `super.dispose();` |
| `@override` | Penanda: "fungsi ini menimpa fungsi milik induk". | `@override void dispose()` |
| `get nama` | **Getter**: terlihat seperti field, tapi dihitung saat dibaca. | `bool get isActive => ...` |
| `void` | Fungsi yang tidak mengembalikan nilai. | `void reset()` |
| `Future<T>` | Hasil yang datang **nanti** (proses tunggu). | `Future<void> _openFilter()` |
| `async` / `await` | `async` = fungsi ini boleh menunggu; `await` = tunggu sampai selesai. | `await Navigator.pushNamed(...)` |
| `'$x'` / `'${a.b}'` | Menyisipkan nilai ke dalam teks. | `'$seats kursi'` → "2 kursi" |
| `() => aksi()` | Fungsi tanpa nama (callback) yang dijalankan **nanti**, mis. saat tombol diketuk. | `() => _viewModel.selectSeats(seats)` |
| `(_)` | Parameter yang tidak dipakai, diberi nama `_`. | `onFieldSubmitted: (_) => _apply()` |
| `[ ..., for (...) x, if (...) y ]` | Membuat daftar dengan perulangan/kondisi di dalamnya. | daftar tombol jam/kursi |
| `...[a, b]` | **Spread**: "tuangkan" isi daftar ke daftar luar. | `for (...) ...[ SizedBox, Row ]` |
| `is` / `is!` | Cek tipe: "apakah ini Tipe?" / "bukan Tipe?". | `args is! RideFilter` |
| `as Tipe` | Anggap nilai ini bertipe Tipe. | `args as RideFilter?` |
| `(a, b)` dan `.$1`, `.$2` | **Record**: pasangan nilai tanpa membuat kelas. `.$1` = isi pertama. | `<(Ride, RouteMatch)>[]` |

---

## B. Induk ViewModel — `core/view_model.dart`

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

- **Baris 1** — memakai `foundation.dart` (bagian Flutter tanpa widget). Di sinilah `ChangeNotifier` berada.
- **Baris 3** — `///` = komentar dokumentasi: "status layar bersama; tanpa widget, navigasi, atau context".
- **Baris 4** — `abstract class ViewModel` = cetakan induk untuk semua ViewModel. `extends ChangeNotifier` = mewarisi kemampuan **memberi tahu pendengar** (`addListener`, `notifyListeners`).
- **Baris 5** — `_disposed` = catatan "apakah ViewModel ini sudah dibuang?". Awalnya `false`.
- **Baris 6** — getter publik untuk membaca `_disposed` dari luar (hanya baca).
- **Baris 8** — `@protected` = fungsi ini sebaiknya hanya dipanggil oleh kelas turunan (ViewModel anak), bukan dari layar.
- **Baris 9–11** — `publish()` = "umumkan perubahan". Hanya memanggil `notifyListeners()` kalau belum dibuang. Tanpa pengaman ini, memberi tahu setelah dibuang akan error.
- **Baris 13–17** — saat layar ditutup, `dispose()` dipanggil: tandai sudah dibuang (baris 15), lalu jalankan pembersihan bawaan induk (`super.dispose()`, baris 16).

---

## C. Model filter — `models/ride_filter.dart`

### C.1 Pilihan jam (`enum`)

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

- **Baris 1** — memakai model `Ride` (data satu tebengan), karena nanti filter memeriksa Ride.
- **Baris 5** — `enum DepartureWindow` = daftar **rentang jam berangkat** yang bisa dipilih. "Window" di sini artinya **jendela waktu / rentang waktu**, bukan jendela layar.
- **Baris 6–10** — lima pilihan. Setiap pilihan membawa 3 nilai: teks tombol, menit mulai, menit selesai. Menit dihitung sejak tengah malam: 06.00 = 6×60 = **360**; 07.00 = **420**; 15.00 = **900**; 19.00 = **1140**. Nama kiri (`early`, `morning`, …) adalah nama di kode; teks di dalam kutip yang tampil di layar.
- **Baris 10** — pilihan terakhir diakhiri `;` (bukan `,`) karena setelahnya ada isi lain (konstruktor).
- **Baris 12** — konstruktor enum: memasukkan 3 nilai tadi ke field. `const` karena nilainya tetap.
- **Baris 13–15** — field tiap pilihan: `label` (teks), `startMinute` (mulai), `endMinute` (selesai, **tidak termasuk**).

### C.2 Kelas `RideFilter`

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

- **Baris 19** — `RideFilter` = satu paket syarat penyaringan.
- **Baris 20** — konstruktor dengan **parameter bernama** di dalam `{}`. Ketiganya opsional: `window` dan `maximumFare` boleh kosong (null); `minimumSeats` kalau tidak diisi = 1. `const` → bisa dibuat sebagai konstanta (`const RideFilter()` = filter kosong).
- **Baris 22** — `window` = **rentang jam yang dipilih**. Tipe `DepartureWindow?`: tanda `?` berarti boleh `null`, dan `null` artinya **semua jam**.
- **Baris 23** — `minimumSeats` = minimal kursi kosong yang diminta (1, 2, atau 3).
- **Baris 24** — `maximumFare` = ongkos paling mahal dalam rupiah. `null` = tidak dibatasi.
- **Baris 22–24** — semuanya `final` → filter tidak bisa diubah setelah dibuat (**immutable**). Mau ganti? Buat `RideFilter` baru.
- **Baris 26–27** — getter `isActive`: `true` kalau ada salah satu syarat yang bukan bawaan. Dipakai untuk menulis tombol "Filter aktif". `||` = "atau".

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

- **Baris 29** — `matches(ride)` menjawab: "apakah tebengan ini lolos filter?" → `bool` (benar/salah).
- **Baris 30** — gugur kalau kursi kosongnya kurang dari minimal, **atau** sudah penuh.
- **Baris 32–35** — kalau ada batas ongkos (`!= null`) **dan** (`&&`) ongkos tebengan belum diatur (0) atau lebih mahal dari batas → gugur. `maximumFare!` = "pasti tidak null" (aman karena baru dicek di baris 32).
- **Baris 36** — salin `window` ke variabel lokal `selected` agar Dart yakin nilainya tidak berubah di tengah pemeriksaan.
- **Baris 37** — tidak memilih jam → semua jam lolos → `true`.
- **Baris 38** — ubah teks jam tebengan ("07.30") menjadi menit (450).
- **Baris 39–41** — lolos kalau menitnya terbaca **dan** ≥ menit mulai **dan** < menit selesai. Contoh: 07.30 = 450 → lolos `morning` (420–480).

### C.3 Fungsi pembaca teks

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

- **Baris 46** — fungsi di luar kelas: menerima teks jam, mengembalikan menit atau `null` kalau tidak valid.
- **Baris 47** — `RegExp` = pola pencocok teks. Polanya `^(\d{1,2})[.:](\d{2})$` dibaca: awal teks `^` → 1–2 angka `(\d{1,2})` → titik atau titik dua `[.:]` → tepat 2 angka `(\d{2})` → akhir teks `$`. Tanda kurung `( )` menandai bagian yang ingin diambil. `r'...'` = teks mentah (backslash tidak diproses).
- **Baris 48** — tidak cocok pola → `null`.
- **Baris 49–50** — ambil bagian ke-1 (jam) dan ke-2 (menit), ubah teks jadi angka dengan `int.parse`.
- **Baris 51** — kalau jam < 24 dan menit < 60 → kembalikan total menit; kalau tidak → `null`.

```dart
54  /// Rupiah bulat, baik 10000 maupun 10.000. Kosong berarti tanpa batas.
55  int? parseFare(String value) {
56    final text = value.trim();
57    if (!RegExp(r'^(\d+|\d{1,3}(\.\d{3})+)$').hasMatch(text)) return null;
58    return int.tryParse(text.replaceAll('.', ''));
59  }
```

- **Baris 56** — `trim()` = buang spasi di awal/akhir.
- **Baris 57** — pola: **angka saja** (`\d+`, mis. 10000) **atau** (`|`) 1–3 angka diikuti kelompok ".3 angka" (mis. 10.000, 1.000.000). Selain itu → `null`. `!` di depan = "tidak cocok".
- **Baris 58** — hapus titik ("10.000" → "10000"), ubah jadi angka. `tryParse` mengembalikan `null` kalau angkanya terlalu besar, bukan error.

---

## D. ViewModel Filter — `viewmodels/ride_filter_view_model.dart`

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

- **Baris 1–2** — memakai induk `ViewModel` (Bagian B) dan model filter (Bagian C).
- **Baris 4** — `RideFilterViewModel` mewarisi `ViewModel`, jadi punya `publish()` dan `dispose()`.
- **Baris 7** — `static const seatOptions` = daftar pilihan kursi, milik kelas (bukan tiap objek), tetap. Layar memanggilnya `RideFilterViewModel.seatOptions`.
- **Baris 9** — konstruktor dengan parameter bernama `initialFilter` (filter yang sedang berlaku, dikirim dari layar Hasil). Kalau tidak dikirim → filter kosong.
- **Baris 10–11** — **initializer list** (setelah `:`): isi `_window` dan `_seats` dari filter awal, supaya pilihan lama langsung terlihat saat layar dibuka.
- **Baris 12** — `_window` = **state**: rentang jam yang sedang dipilih (sementara/draft). Privat (`_`) → layar tidak bisa mengubahnya langsung.
- **Baris 13** — `_seats` = state: kursi yang sedang dipilih.
- **Baris 14–15** — getter publik: layar boleh **membaca** pilihan, tapi mengubahnya harus lewat fungsi di bawah.

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

- **Baris 17–20** — dipanggil saat tombol jam diketuk: simpan pilihan baru (boleh `null` = batal pilih), lalu `publish()` supaya layar menggambar ulang (warna tombol berubah).
- **Baris 22–25** — sama, untuk kursi.
- **Baris 27–31** — Atur Ulang: kembalikan ke bawaan (semua jam, 1 kursi), lalu umumkan.

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

- **Baris 35** — validator: menerima teks kolom ongkos (bisa `null`), mengembalikan **`null` = valid** atau **teks pesan = tidak valid**. Aturan Flutter memang begitu.
- **Baris 36** — dibaca dari kiri: kalau `value` null, `value?.trim()` ikut null, lalu `?? true` membuatnya `true`. Jadi: kosong **atau** null → valid (tanpa batas).
- **Baris 37** — ubah teks jadi angka (Bagian C.3). `value!` aman karena sudah pasti tidak null.
- **Baris 38** — tidak terbaca sebagai rupiah bulat → pesan error.
- **Baris 39** — 0 atau kurang → pesan error.
- **Baris 40** — lolos semua → `null` (valid).

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

- **Baris 43** — `apply` membuat filter final dari pilihan sekarang. Pertama validasi lagi (pengaman lapis kedua).
- **Baris 44** — tidak valid → `null` (tidak ada filter baru).
- **Baris 45–49** — valid → buat `RideFilter` baru dari jam, kursi, dan ongkos (kosong → `null`, kalau tidak → angka).

---

## E. Layar Filter — `views/ride_filter_screen.dart`

### E.1 Import dan kelas widget

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

- **Baris 1** — widget Material (tombol, teks, Scaffold, dll.).
- **Baris 2–3** — model dan ViewModel filter.
- **Baris 4** — `formatThousands` untuk menulis 10000 sebagai "10.000".
- **Baris 5–6** — tombol dan kolom isian milik proyek (komponen dari Figma).
- **Baris 7–9** — token tema: warna, jarak, gaya teks. `AppSizes` (ukuran sentuh) dan `AppRadius` (sudut) juga ada di `app_spacing.dart`.
- **Baris 11** — `RideFilterScreen` adalah **widget layar Filter**. `extends StatefulWidget` karena layar ini punya hal yang harus bertahan selama layar terbuka (ViewModel, controller kolom ongkos).
- **Baris 12** — konstruktor. `super.key` meneruskan `key` ke induk (dipakai Flutter mengenali widget). `initialFilter` = filter yang dikirim dari layar Hasil; kalau tidak ada → kosong.
- **Baris 13** — field `initialFilter` (final: tidak berubah).
- **Baris 15** — `createState()` membuat objek **State** pasangannya, `_RideFilterScreenState`, satu kali.
  - **Kenapa dua kelas?** Widget (`RideFilterScreen`) hanya "kartu identitas" yang sering dibuat ulang oleh Flutter. Hal yang harus **bertahan** (controller, ViewModel) disimpan di State, yang hidup selama layar terbuka.
  - **`State<RideFilterScreen>` — kenapa ada `<>`?** `State` adalah kelas **generic**. Isi `<>` memberi tahu "State ini milik widget `RideFilterScreen`". Hasilnya, di dalam State kita bisa menulis `widget.initialFilter` dan Dart tahu `widget` bertipe `RideFilterScreen`.

### E.2 State: persiapan dan pembersihan

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

- **Baris 18** — kelas State, privat (`_`) karena hanya dipakai file ini. `extends State<RideFilterScreen>` = "aku adalah State untuk widget RideFilterScreen".
- **Baris 19** — `_formKey` = kunci untuk mengendalikan `Form` (memvalidasi/mereset semua kolom). `GlobalKey<FormState>` = kunci yang menunjuk ke **state milik Form**.
- **Baris 20** — `_viewModel`: `late final` = diisi nanti (di `initState`), sekali saja.
- **Baris 21** — `_fare` = controller kolom ongkos, untuk membaca/mengubah isi kolom dari kode.
- **Baris 23** — `initState()` dijalankan **sekali** saat layar dibuat.
- **Baris 24** — jalankan persiapan bawaan induk dulu (wajib).
- **Baris 25** — buat ViewModel, isi dengan filter yang sedang berlaku (`widget.initialFilter`).
- **Baris 26–29** — buat controller kolom ongkos. Kalau sudah ada batas ongkos → tulis "10.000"; kalau belum → kosong.
- **Baris 33** — `dispose()` dijalankan saat layar ditutup.
- **Baris 34–35** — buang ViewModel dan controller supaya tidak bocor memori.
- **Baris 36** — pembersihan bawaan induk (selalu terakhir).

### E.3 Aksi tombol

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

- **Baris 39–43** — tombol **Atur Ulang**: hapus pesan error di form (40), kosongkan kolom ongkos (41), kembalikan jam & kursi ke bawaan (42). Layar **tidak ditutup**.
- **Baris 45** — tombol **Terapkan**.
- **Baris 46** — `_formKey.currentState!` = state Form (pasti ada, maka `!`). `.validate()` menjalankan semua validator kolom; kalau ada yang gagal → pesan muncul dan fungsi **berhenti** (`return`) → pengguna tetap di form.
- **Baris 47** — minta ViewModel membuat filter baru dari pilihan + teks ongkos.
- **Baris 48** — kalau berhasil: `Navigator.pop` menutup layar Filter **dan mengirim** `result` ke layar yang membukanya (Hasil).

### E.4 Potongan tampilan yang dipakai ulang

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

- **Baris 51–57** — `_heading` membuat judul bagian (ikon + teks) dalam satu baris (`Row`). `Expanded` membuat teks mengisi sisa lebar (mencegah teks meluap).
- **Baris 60** — `_windowChoice(window)` membuat satu tombol jam. Parameter `window` = rentang jam yang tombolnya mau dibuat.
- **Baris 61** — teks tombol, mis. "07.00–08.00".
- **Baris 62** — apakah tombol ini sedang terpilih? (`==` membandingkan pilihan di ViewModel dengan tombol ini).
- **Baris 63** — aksi saat diketuk: kalau tombol ini sudah terpilih → kirim `null` (batal); kalau belum → kirim `window` (pilih).

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

- **Baris 66** — `_choice` = tombol pilihan umum (dipakai untuk jam dan kursi). `VoidCallback` = tipe "fungsi tanpa parameter dan tanpa nilai kembali".
- **Baris 67–68** — `Semantics(selected: ...)` = memberi tahu pembaca layar (aksesibilitas) bahwa tombol ini terpilih.
- **Baris 71–76** — warna latar dan teks tergantung `selected` (coral muda jika terpilih, abu jika tidak). Inilah **feedback** visual pilihan.
- **Baris 77** — tinggi minimal 48 piksel agar mudah disentuh jari.
- **Baris 78–80** — jarak dalam, rata kiri, sudut membulat (token dari Figma).
- **Baris 82** — aksi saat diketuk (dikirim dari pemanggil).
- **Baris 83** — teks tombol.

### E.5 `build`: menggambar layar

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

- **Baris 88** — `build` menggambar layar. Isinya dibungkus `ListenableBuilder`.
- **Baris 89** — `listenable: _viewModel` = dengarkan ViewModel. Setiap `publish()` → `builder` dijalankan ulang.
- **Baris 90** — `builder: (context, _)` = fungsi penggambar. Parameter kedua tidak dipakai, maka `_`. `Scaffold` = kerangka layar Material.
- **Baris 91** — bilah atas dengan judul (tombol kembali muncul otomatis).
- **Baris 92–93** — `Form` membungkus kolom isian; `key: _formKey` menghubungkannya dengan kunci di baris 19.
- **Baris 94–96** — `ListView` = daftar yang bisa digulir, supaya tidak meluap di layar kecil (Module 3: masalah overflow). `children: [` = isi daftar dari atas ke bawah.

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

- **Baris 97–102** — teks pengantar. `copyWith(color: ...)` = pakai gaya teks yang ada, ganti warnanya saja.
- **Baris 103, 105** — `SizedBox` kosong = jarak vertikal (token `lg` = 24, `sm` = 8).
- **Baris 104** — judul "Jam cabut" dengan ikon jam.

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

- **Baris 107** — perulangan **di dalam daftar**: `i` mulai 0, naik 2 setiap putaran (`i += 2`), selama `i` < jumlah pilihan jam (5). Jadi `i` = 0, 2, 4 → **3 baris**. `DepartureWindow.values` = daftar semua pilihan enum. `...[ ]` = setiap putaran menuangkan beberapa widget sekaligus.
- **Baris 108** — sebelum baris kedua dan seterusnya, beri jarak.
- **Baris 109–119** — satu baris berisi 2 tombol berdampingan. `Expanded` membagi lebar sama rata.
- **Baris 111** — tombol kiri = pilihan ke-`i`.
- **Baris 114–116** — tombol kanan = pilihan ke-`i+1` **kalau ada**; kalau tidak ada (baris terakhir punya 1 pilihan) → kotak kosong `SizedBox.shrink()` agar tombol kiri tetap setengah lebar.

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

- **Baris 124** — satu baris berisi semua tombol kursi.
- **Baris 126** — untuk setiap angka di `seatOptions` (1, 2, 3) → buat tombol.
- **Baris 127–128** — beri jarak sebelum tombol, kecuali tombol pertama.
- **Baris 131** — teks "1 kursi", "2 kursi", … (sisip nilai `seats`).
- **Baris 132** — terpilih kalau sama dengan pilihan di ViewModel.
- **Baris 133** — saat diketuk → `selectSeats(seats)` → state berubah → `publish()` → warna berubah.

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

- **Baris 142** — kolom isian milik proyek (label + kolom).
- **Baris 143–144** — teks label dan petunjuk abu-abu di dalam kolom.
- **Baris 145** — sambungkan ke controller `_fare` (isi kolom bisa dibaca dengan `_fare.text`).
- **Baris 146** — keyboard angka.
- **Baris 147** — tombol keyboard bertuliskan "selesai".
- **Baris 148** — menekan "selesai" di keyboard = sama dengan menekan Terapkan.
- **Baris 149** — validator diambil dari ViewModel. Perhatikan **tanpa tanda kurung** `()`: kita menyerahkan **fungsinya**, bukan hasilnya. Form yang akan memanggilnya saat `validate()`.

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

- **Baris 152–164** — dua teks petunjuk aturan untuk pengguna.
- **Baris 165–167** — penutup daftar, `ListView`, dan `Form`.

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

- **Baris 168** — bilah bawah yang selalu terlihat (tidak ikut tergulir).
- **Baris 170–171** — `SafeArea` menjaga tombol tidak tertutup bagian bawah HP (garis navigasi); `top: false` karena atasnya tidak perlu.
- **Baris 174–186** — dua tombol berdampingan, lebar sama (`Expanded`).
- **Baris 180** — Atur Ulang memanggil `_reset` (E.3). Ditulis tanpa `()` → menyerahkan fungsi.
- **Baris 185** — Terapkan memanggil `_apply` (E.3).

---

## F. Router — `routes/app_routes.dart`

```dart
19    static const String rideFilter = '/ride-filter';
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

- **Baris 19** — nama alamat layar Filter: `/ride-filter`. Disimpan sebagai konstanta agar tidak salah ketik.
- **Baris 35** — bagian dari `switch` (pilih berdasarkan nama alamat). Kalau alamatnya `/ride-filter` → jalankan blok ini.
- **Baris 36** — ambil data yang dikirim (`arguments`).
- **Baris 37** — ada data **tapi bukan** `RideFilter` → `return null` → Flutter menampilkan halaman 404.
- **Baris 38** — buat rute halaman. `<RideFilter>` = rute ini akan **mengembalikan** `RideFilter` saat ditutup.
- **Baris 40–41** — buat layar Filter. `args as RideFilter?` = anggap data sebagai RideFilter (boleh null); `?? const RideFilter()` = kalau null, pakai filter kosong.

---

## G. Layar Hasil — `views/ride_results_screen.dart`

### G.1 Membuka Filter dan menerima hasilnya

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

- **Baris 81** — `_leave` = keluar dari layar Hasil ke layar Cari **sambil membawa** filter yang berlaku, supaya pencarian berikutnya memakai filter yang sama.
- **Baris 82** — `_openFilter` bertipe `Future<void>` dan `async` karena harus **menunggu** layar Filter ditutup.
- **Baris 83** — `await Navigator.pushNamed<RideFilter>(...)`: buka layar Filter (ditumpuk di atas layar Hasil), lalu tunggu. `<RideFilter>` = yang diharapkan kembali adalah RideFilter. Hasilnya disimpan di `result`.
- **Baris 84** — `context` = posisi layar ini di pohon widget; Navigator butuh ini.
- **Baris 85** — alamat tujuan `/ride-filter` (Bagian F).
- **Baris 86** — **kirim** filter yang sedang berlaku sebagai `arguments`.
- **Baris 88** — setelah layar Filter tertutup: `mounted` = layar Hasil masih ada? `result != null` = pengguna menekan Terapkan (kalau menekan kembali, hasilnya null). Kalau keduanya benar → terapkan filter baru.

### G.2 Bagian tampilan yang bereaksi

```dart
Widget build(BuildContext context) => PopScope<RideFilter>(
  canPop: false,
  onPopInvokedWithResult: (didPop, _) {
    if (!didPop) _leave();
  },
  child: ListenableBuilder(
    listenable: _viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Pencarian'),
        leading: BackButton(onPressed: _leave),
      ),
```

- `PopScope` = mencegat tombol kembali bawaan HP. `canPop: false` = jangan langsung ditutup; jalankan `_leave` dulu supaya filter ikut terbawa ke layar Cari.
- `ListenableBuilder(listenable: _viewModel, ...)` = sama seperti di layar Filter: setiap `publish()` dari ViewModel Hasil → layar digambar ulang.
- `leading: BackButton(onPressed: _leave)` = tombol panah kiri di bilah atas juga memakai `_leave`.

```dart
Text(switch (_viewModel.status) {
  SearchResultsStatus.loading => 'Mencari tebengan...',
  SearchResultsStatus.error => 'Gagal memuat',
  SearchResultsStatus.success =>
    '${_viewModel.results.length} tebengan searah',
}, style: AppTextStyles.labelLarge),
...
FilledButton.icon(
  onPressed: _openFilter,
  icon: const Icon(Icons.filter_list_rounded),
  label: Text(_viewModel.filter.isActive ? 'Filter aktif' : 'Filter'),
),
```

- `switch (status) { A => ..., B => ... }` = pilih teks berdasarkan status: memuat, gagal, atau berhasil (jumlah hasil).
- `${_viewModel.results.length}` = jumlah tebengan yang lolos (berubah setelah filter diterapkan).
- Tombol Filter memanggil `_openFilter` (G.1). Teksnya "Filter aktif" kalau ada filter (`isActive`, Bagian C.2).

---

## H. ViewModel Hasil — `viewmodels/ride_results_view_model.dart`

```dart
 9  enum SearchResultsStatus { loading, success, error }
10
11  class RideResultsViewModel extends ViewModel {
12    RideResultsViewModel({
13      required this.repository,
14      required this.request,
15      this.simulateError = false,
16    }) : _filter = request.filter {
17      // Kalau data repository berubah (misalnya pembaruan dari backend nanti,
18      // FR-07), hasil dihitung ulang tanpa memuat ulang layar.
19      repository.addListener(refresh);
20    }
21    final RideRepository repository;
22    final RideSearchRequest request;
23    final bool simulateError;
24    RideFilter _filter;
25    SearchResultsStatus _status = SearchResultsStatus.loading;
26    List<Ride> _rides = [];
27    List<Ride> _results = [];
28    String _errorMessage = '';
29    int _generation = 0;
30    RideFilter get filter => _filter;
31    SearchResultsStatus get status => _status;
32    List<Ride> get results => List.unmodifiable(_results);
33    String get errorMessage => _errorMessage;
```

- **Baris 9** — tiga keadaan layar Hasil: memuat, berhasil, gagal (Module 4: Loading, Success, Error).
- **Baris 12–16** — konstruktor: wajib menerima `repository` (sumber data tebengan) dan `request` (Dari, Ke, filter awal). `simulateError` hanya untuk latihan/tes. `: _filter = request.filter` = filter awal diambil dari pencarian.
- **Baris 19** — dengarkan repository; kalau datanya berubah → `refresh` (siap untuk backend nanti).
- **Baris 21–23** — data masukan, tidak berubah (`final`).
- **Baris 24** — state: filter yang **berlaku**.
- **Baris 25** — state: status, mulai dari "memuat".
- **Baris 26** — state: semua tebengan dari repository.
- **Baris 27** — state: tebengan yang lolos (yang ditampilkan).
- **Baris 28** — state: pesan error.
- **Baris 29** — nomor urut permintaan muat (lihat `load`).
- **Baris 30–33** — getter baca-saja untuk layar. `List.unmodifiable` = salinan yang tidak bisa diubah layar.

```dart
35    void applyFilter(RideFilter filter) {
36      if (isDisposed) return;
37      _filter = filter;
38      _results = matchPassengerRides(_rides, request, _filter);
39      publish();
40    }
```

- **Baris 35** — dipanggil layar Hasil setelah menerima filter baru (G.1 baris 88).
- **Baris 36** — layar sudah ditutup → jangan lakukan apa-apa.
- **Baris 37** — simpan filter baru.
- **Baris 38** — hitung ulang daftar yang lolos (Bagian I).
- **Baris 39** — umumkan → layar Hasil menggambar ulang (jumlah, "Filter aktif", daftar).

```dart
49    Future<void> load() async {
50      if (isDisposed) return;
51      final generation = ++_generation;
52      _status = SearchResultsStatus.loading;
53      _errorMessage = '';
54      publish();
55      try {
56        final rides = await repository.fetchRides(simulateError: simulateError);
57        if (isDisposed || generation != _generation) return;
58        _rides = List.of(rides);
59        _results = matchPassengerRides(_rides, request, _filter);
60        _status = SearchResultsStatus.success;
61      } catch (error, stackTrace) {
62        if (isDisposed || generation != _generation) return;
          // Detail teknis untuk debugging; pengguna hanya melihat pesan ramah.
          debugPrint('Gagal memuat tebengan: $error\n$stackTrace');
          _status = SearchResultsStatus.error;
          _errorMessage = 'Periksa koneksi internet, lalu coba lagi. ...';
        }
        publish();
      }
```

- **Baris 51** — naikkan nomor urut dan ingat nomor permintaan ini.
- **Baris 52–54** — tampilkan "memuat".
- **Baris 55–60** — `try`: ambil data (`await` = tunggu); kalau berhasil, simpan, saring, status "berhasil".
- **Baris 57** — kalau layar sudah ditutup **atau** sudah ada permintaan yang lebih baru (`generation != _generation`), abaikan hasil lama ini. Mencegah hasil lama menimpa hasil baru.
- **Baris 61** — `catch`: kalau gagal, catat detail untuk developer (`debugPrint`), status "gagal", siapkan pesan ramah untuk pengguna.
- **Baris terakhir** — `publish()` untuk menampilkan hasil akhirnya (berhasil atau gagal).

---

## I. Penyaring hasil — `utils/ride_search_matcher.dart`

```dart
 6  /// Geographic matching shared by presentation models, not by ViewModels.
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

- **Baris 7–11** — fungsi menerima semua tebengan, pencarian (Dari/Ke), dan filter; mengembalikan daftar tebengan yang lolos. `Iterable<Ride>` = kumpulan Ride yang bisa dijelajahi satu per satu.
- **Baris 12** — wadah kosong berisi **pasangan** (record) `(Ride, RouteMatch)`: tebengannya dan hasil hitung kedekatannya.
- **Baris 13** — periksa setiap tebengan.
- **Baris 14** — `continue` = lewati tebengan ini kalau **tidak lolos filter** (Bagian C.2) atau tidak punya data jalur.
- **Baris 15–19** — hitung apakah searah: titik Dari dan Ke dicocokkan dengan jalur tebengan (≤ 500 m dari jalur, jemput sebelum turun).
- **Baris 20** — kalau searah → simpan pasangan (tebengan, hasil hitung).
- **Baris 22** — urutkan dari yang **paling dekat** dengan jalur. `a.$2` = isi kedua pasangan (hasil hitung); `compareTo` membandingkan dua angka.
- **Baris 23** — ambil tebengannya saja (`.$1` = isi pertama) dan jadikan daftar (`toList()`).
