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

| Area | Pemilik / tanggung jawab |
|---|---|
| auth | Login bersama, validasi lokal, shortcut dev hanya debug; bukan auth server. |
| ride_search | Mikail, FR-01–04: rute/read, pencarian tempat/pin, matcher, filter dan kuota tampilan. |
| booking | Taris, FR-05–08; saat ini hanya Catatan baseline. Pesanan/status/cancel/sync belum dibuat. |
| costs | Shiddiq, FR-09–12; README ownership, bukan klaim fitur selesai. |
| reputation | Duha, FR-13–16; README ownership, bukan klaim fitur selesai. |
| shared/maps | Picker/autocomplete, peta/tile, service Photon/reverse/OSRM dan model lokasi. |
| shared | Detail Tebengan/VM lintas modul, model Ride, UI/validator/formatter reusable. |
| legacy/driver | Posting/Rute Saya, VM/repository/harness arsip; tidak boleh diimpor source aktif. |

Nama folder berdasarkan fitur, bukan anggota. Pembagian rinci rekan tetap usulan yang perlu
kesepakatan tim; refactor ini tidak mengimplementasikan modul rekan sepihak. Theme tetap
`lib/theme/`, routes tetap `lib/routes/`. Export DI lama `lib/widgets/map_service_scope.dart`
dihapus; semua import menunjuk satu implementasi `core/di`.

## Batas MVVM

- View: widget/layout, controller/Form/focus, dialog/SnackBar, navigasi typed dan disposal.
  Tidak memanggil fetch/CRUD/searchPlaces/reverse/routeBetween langsung.
- ViewModel: state, validasi dan commands. Tidak mengimpor View/widget/routes/theme,
  memakai BuildContext/Navigator/controller, atau bergantung pada VM lain.
- Model: immutable Ride, MapLocation/GeoPoint/RoadRoute dan RideFilter.
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
Home meminjam repository; saat dependensi berganti VM lama melepas listener sebelum VM baru
dibuat. Standalone/test dapat menginjeksi repository atau data lokal; hanya fallback milik
Home yang ditutup Home. VM meminjam service/repository dan tidak menutup dependensi bersama.

Adapter REST **belum dibuat** karena kontrak backend belum tersedia. Tidak mengarang endpoint,
auth, schema status, atau menganggap fixture sebagai server. Keputusan booking, alokasi
kursi, pembatalan, konfirmasi ongkos dan eligibility rating tetap otoritas backend/admin.

## Penumpang dan arsip

AppRoutes tidak mengimpor legacy dan mengembalikan null untuk /post-route dan /my-routes,
terlepas dari arguments; onUnknownRoute menampilkan 404. Home tanpa role switch/CTA driver.
Pesanan/Ongkos/Profil nonaktif sampai fitur rekan terintegrasi, bukan aksi kosong seolah bekerja.

`LegacyDriverRepository` dan `LegacyDriverRoutes` hanya untuk arsip/regresi. Tes unit
CRUD/quota/idempotensi lama dipertahankan; workflow legacy diuji lewat harness khusus, bukan
membuka kembali driver dari router penumpang. Memberikan hasil pending tidak mengurangi kuota.
Detail request/note masih presentasi lokal dan hilang ketika VM dibuat ulang.

## Async, lokasi dan data latihan

- Home: generation/isDisposed; respons load lama tidak menimpa state terbaru.
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

Hasil masih di Home dan autocomplete inline; pemisahan layar Hasil/pemilih tempat dedicated
sesuai seluruh state Figma adalah tahap berikutnya, bukan klaim selesai karena folder berubah.

## Pengujian

`test/architecture/` memindai seluruh Dart **rekursif**: batas VM/View, larangan import legacy
dari source aktif, kontrak repository penumpang tanpa mutasi driver, dan lokasi core.
`test/core/di/` memeriksa instance bersama, rebinding, ownership/disposal dan app injection.
`test/features/ride_search/` memeriksa deny route driver, UI/menu nonaktif dan fixture
searah/terbalik/penuh/tidak cocok. Regresi async lama ada di `test/regression/`; peta/widget
di `test/shared/maps/`; catatan/login/workflow penumpang di `test/integration/`.
Guard struktural bukan bukti formal seluruh arsitektur.

Jalankan format/analyzer/seluruh test/build setelah perubahan. Hasil nyata berada di
[PROGRESS](../progress/PROGRESS.md); instalasi/uji Android/hot reload tetap menunggu izin HP.
Referensi: [Flutter architecture](https://docs.flutter.dev/app-architecture/guide),
[Flutter recommendations](https://docs.flutter.dev/app-architecture/recommendations).
