# Arsitektur MVVM — Nebeng Dong

Migrasi MVVM awal: 6 Oktober 2026. Refactor feature-first dan penumpang: 8 Oktober 2026,
atas instruksi pengguna “perbaiki, lalu push”. Tidak menambah dependency/framework.
MVVM dipertahankan, bukan diganti dengan Clean Architecture lengkap.

## Struktur aktif

```text
lib/
  main.dart
  core/di/               lifecycle dan injeksi repository/layanan
  features/
    auth/                login bersama: views + viewmodels
    ride_search/         Mikail: views + viewmodels + models + data + utils
    booking/             Taris: catatan baseline; batas integrasi pesanan
    costs/               Shiddiq: views + viewmodels + models + data + utils
    reputation/          Duha: workflow lokal riwayat + rating pengemudi
  shared/                models, views, viewmodels, widgets, utils
    maps/                services, models, views, viewmodels, widgets
  routes/                named routes penumpang dan fallback 404
  theme/                 token bersama tetap di lokasi semula
test/                    architecture/, core/, features/, integration/,
                         shared/, regression/, visual/, support/
docs/                    sumber Markdown dan log
```

| Area | Pemilik / tanggung jawab |
|---|---|
| auth | Login bersama, validasi lokal, shortcut dev hanya debug; bukan auth server. |
| ride_search | Mikail, FR-01–04: rute/read, pencarian tempat/pin, matcher, filter dan kuota tampilan. |
| booking | Taris, FR-05–08; saat ini hanya Catatan baseline. Pesanan/status/cancel/sync belum dibuat. |
| costs | Shiddiq, FR-09–12: Riwayat/Rincian/Status Pembayaran, CostRepository sesi + fixture lokal. Konfirmasi tetap backend; detail di README modul. |
| reputation | Duha: workflow lokal FR-13/14 riwayat + rating pengemudi; profil/rekap FR-15/16 dan backend pending. |
| shared/maps | Picker/autocomplete, peta/tile, service Photon/reverse/OSRM dan model lokasi. |
| shared | Detail Tebengan/VM lintas modul, model Ride, UI/validator/formatter reusable. |

Nama folder berdasarkan fitur, bukan anggota. Pembagian rinci rekan tetap usulan yang perlu
kesepakatan tim; refactor ini tidak mengimplementasikan modul rekan sepihak. Theme tetap
`lib/theme/`, routes tetap `lib/routes/`. Export DI lama `lib/widgets/map_service_scope.dart`
dihapus; semua import menunjuk satu implementasi `core/di`.

## Batas MVVM

- View: widget/layout, controller/Form/focus, dialog/SnackBar, navigasi typed dan disposal.
  Tidak memanggil fetch/CRUD/searchPlaces/reverse/routeBetween langsung.
- ViewModel: state, validasi dan commands. Tidak mengimpor View/widget/routes/theme,
  memakai BuildContext/Navigator/controller, atau bergantung pada VM lain.
- Model: immutable Ride, MapLocation/GeoPoint/RoadRoute, RideFilter dan RideSearchRequest. Query tidak membawa repository; RideResultsArguments adalah kontrak navigasi di routes/.
- Repository: kontrak baca rute dan sumber kebenaran bersama. Data mengalir
  repository → VM → View, event View → command VM.
- Service peta: adapter jaringan yang sudah ada dipertahankan dengan cache/antrian/rate limit.
  Pemisahan internal MapRepository tambahan tidak diperlukan untuk refactor ini.
- Core: lifecycle ViewModel dan dependency/lifetime injection, bukan logika fitur.

ChangeNotifier + ListenableBuilder bawaan Flutter. Login/Catatan command sinkron tanpa state
mutable tidak memerlukan builder. State tile-error/retry di widget peta adalah presentasi
lokal, bukan bisnis; setState tersebut tidak memindahkan pencarian/geocode/matcher ke View.

## Repository dan lifetime

`features/ride_search/data/ride_repository.dart` adalah abstract read contract
(`rides`, `fetchRides`, `isSimulation`), **tanpa** post/updateOwned/deleteOwned/acceptBooking.
`LocalRideRepository` menyediakan fixture deterministik immutable. Parameter simulateError
adalah hook praktikum/test eksplisit, bukan parameter endpoint backend.

Root `NebengDongApp` memasang `RideRepositoryProvider` dan `MapServiceProvider`.
Default dimiliki provider; instance injected dimiliki caller dan tidak didispose provider/Home.
Home dan Hasil meminjam repository sesi. Home mengirim snapshot query + repository yang sama
melalui route arguments; hanya Hasil memasang listener/fetch. Ketika dependency Hasil berganti,
VM lama melepas listener sebelum VM baru dibuat. Standalone/test dapat menginjeksi repository;
fallback lokal dimiliki/ditutup layar pembuatnya. VM tidak menutup dependensi bersama.

Adapter REST **belum dibuat** karena kontrak backend belum tersedia. Tidak mengarang endpoint,
auth, schema status, atau menganggap fixture sebagai server. Keputusan booking, alokasi
kursi, pembatalan, konfirmasi ongkos dan eligibility rating tetap otoritas backend/admin.

## Penumpang dan arsip

Halaman pengemudi lama (Posting Rute/Rute Saya) sudah dihapus 14 Oktober 2026; alamat
/post-route dan /my-routes tidak dikenal router sehingga berakhir di 404. Home tanpa role switch/CTA driver.
Navigasi bawah bersama ada di `shared/widgets/passenger_navigation.dart`: tab Cari, Pesanan (Modul 2) dan
Ongkos (Modul 3) aktif; Profil nonaktif sampai fiturnya ada, bukan aksi kosong seolah bekerja.

Arsip pengemudi beserta tesnya tersedia di riwayat git (commit `addae89`), bukan di source.
Memberikan hasil pending tidak mengurangi kuota.
Detail request/note masih presentasi lokal dan hilang ketika VM dibuat ulang.

## Async, lokasi dan data latihan

- HomeViewModel: form Dari/Ke, swap, filter tersimpan dan validasi/snapshot request; tidak fetch.
- RideResultsViewModel: fetch, matcher pure di utils/ride_search_matcher.dart, filter dan
  status loading/success/error; generation/isDisposed mencegah respons lama/ditutup menimpa state.
- Autocomplete: minimal 3 karakter, debounce 700 ms, generation; clear/swap/pilihan
  membatalkan hasil lama. Perubahan kursor/parent echo tidak merusak pilihan.
- Picker: debounce reverse 650 ms, point/generation tepat, retry/manual, alamat lengkap
  terpisah dari alias. Confirm menunggu pin + alamat dan tidak sedang resolving.
- Cari memerlukan kedua lokasi dipilih lewat saran/pin; teks tanpa koordinat ditolak,
  titik terlalu dekat (<50 m) ditolak. Filter validasi/apply/cancel tetap.
- Fixture aplikasi: empat rute bergeometry jalan nyata, disimpan dari tiga respons
  OSRM/FOSSGIS tanggal 8 Oktober. Tanpa routing semua seed saat startup.
  Provenance/atribusi di README fixture; geometry sintetis hanya untuk tes terisolasi.
- UI menyatakan data latihan. Bukan backend/approval/persistensi/GPS/live tracking.

Hasil sudah layar terpisah. Field lokasi membuka PlaceSearchScreen; panah kanan membuka pin
langsung. Result MapLocation hanya diterapkan setelah memilih hasil/konfirmasi; batal aman.
Filter draft dibatalkan tanpa perubahan, Terapkan memperbarui hasil, Atur Ulang mereset draft.
Hasil mengembalikan applied RideFilter saat AppBar/system back; pencarian berikutnya memakainya.
Peta interaktif native memakai tile OSM, bukan skema/bitmap Figma. Review screenshot/state
utama tidak berarti seluruh contoh prototype identik piksel atau backend/rekan selesai.

## Pengujian

`test/architecture/` memindai seluruh Dart **rekursif**: batas VM/View, kontrak repository penumpang tanpa mutasi driver, dan lokasi core.
`test/core/di/` memeriksa instance bersama, rebinding, ownership/disposal dan app injection.
`test/features/ride_search/` memeriksa deny route driver, UI/menu nonaktif dan fixture
searah/terbalik/penuh/tidak cocok dan workflow selector/pin/filter/retry/back/loading.
Hasil/Filter/Places diuji pada 320 px dengan skala teks OS 2x. Regresi async lama ada di `test/regression/`; peta/widget
di `test/shared/maps/`; catatan/login/workflow penumpang di `test/integration/`.
Guard struktural bukan bukti formal seluruh arsitektur.

Jalankan format/analyzer/seluruh test/build setelah perubahan. Hasil nyata berada di
[PROGRESS](../progress/PROGRESS.md); instalasi/uji Android/hot reload tetap menunggu izin HP.
Referensi: [Flutter architecture](https://docs.flutter.dev/app-architecture/guide),
[Flutter recommendations](https://docs.flutter.dev/app-architecture/recommendations).

## Integrasi workflow Duha — 11 Oktober 2026

`main_rating.dart` menginjeksi satu `LocalRatingRepository` ke demo riwayat.
Riwayat dan form meminjam instance yang sama; Views memiliki ViewModel dan
melakukan disposal/rebinding. ViewModel memakai lifecycle `core/ViewModel`,
menangani validasi, loading/error, filter dan perintah repository. View memiliki
controller, konfirmasi reset, Snackbar dan typed navigation `TripRating`.

Kontrak `RatingRepository` terpisah dari adapter SharedPreferences. Fixture
memuat passengerId/driverId tanpa role pengemudi aplikasi. Adapter mengecek
perjalanan kanonis milik penumpang dan sudah selesai sebelum menyimpan;
state sukses diterapkan setelah write berhasil. Simpan ganda/reset bersamaan
ditolak. Penyimpanan v2 terpisah dari demo dua role v1 yang dipertahankan.

Entry demo belum menjadi tab Pesanan/Profil, tidak mengubah modul rekan.
Backend/auth dan otoritas eligibility server belum tersedia.
