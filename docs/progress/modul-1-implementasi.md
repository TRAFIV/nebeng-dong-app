# Modul 1 Mikail — Implementasi Flutter

## Implementasi aktif — 8 Oktober 2026

UI/workflow lokal Mikail mengikuti [PRD 1.1](../prd/prd-nebeng-dong-kel-4.md): **Cari Tebengan → Hasil Pencarian ↔ Filter → shared Detail**. Dedicated pemilih Dari/Ke dan pin terhubung; tidak ada role/aksi pengemudi. Bagian berikut riwayat 6 Oktober dipertahankan, bukan alur aplikasi aktif.

### Apa yang selesai

- Cari tersedia tanpa menunggu data rute; kedua lokasi dipilih dari hasil tempat/pin, bukan teks saja. Ke boleh diisi lebih dulu. Swap menukar seluruh MapLocation; jarak <50 m ditolak.
- Field membuka PlaceSearchScreen (minimal 3 karakter, debounce, loading/hasil/kosong/error/retry); panah kanan langsung ke LocationPickerScreen. Pin menyimpan koordinat tepat, nama/alias dan alamat penuh; reverse otomatis, retry/manual bila gagal. Back tanpa konfirmasi menjaga pilihan sebelumnya.
- Hasil memakai snapshot query immutable dan repository sesi yang sama. Ada summary, count, compact ride card berikon jam/kursi/ongkos, loading/kosong/error/retry. Arah terbalik/penuh/tanpa geometry tidak dimunculkan sebagai kecocokan.
- Filter: pilihan jam/minimal kursi/batas ongkos, validasi, draft batal, Terapkan dan Atur Ulang. Applied filter dipertahankan saat kembali ke Cari/pencarian ulang. Ongkos belum diatur bukan gratis. Batas ongkos kosong berarti tanpa batas; `0` ditolak dengan pesan sendiri (13 Oktober); saat Filter dibuka ulang, batas tersimpan tampil dengan pemisah ribuan.
- Kartu mengirim Ride ke shared Detail; workflow catatan tetap. Tab Pesanan/Ongkos/Profil nonaktif sampai integrasi rekan. Tidak ada perubahan Figma atau dependency baru.

### Pemetaan MVVM dan source

| Bagian | Tanggung jawab |
|---|---|
| HomeScreen / HomeViewModel | View form/navigasi/feedback; VM lokasi/filter/validasi/snapshot RideSearchRequest, bukan fetch. |
| RideResultsScreen / RideResultsViewModel | View kartu/state/typed navigation; VM fetch/matcher/filter/status/generation. Matcher pure di utils/ride_search_matcher.dart. |
| RideFilterScreen / RideFilterViewModel | Draft jam/kursi/fare, validasi dan result RideFilter; batal tidak apply. |
| PlaceSearchScreen / LocationSearchViewModel | Query/hasil/debounce/guard; result MapLocation hanya setelah pilihan. |
| LocationPickerScreen / LocationPickerViewModel | Peta/field/focus; VM reverse/alias/alamat/exact point/retry/manual/konfirmasi. |
| RideRepository / LocalRideRepository | Kontrak baca + fixture latihan immutable; diinjeksikan satu sesi di core/di. |

Source utama di `lib/features/ride_search/{views,viewmodels,models,data,utils,widgets}/`; selector/pin/service di `lib/shared/maps/`; route query arguments di `lib/routes/`. Detail lengkap [MVVM](../architecture/mvvm.md).

### Cara mendemokan bagian Mikail

1. Jalankan `flutter run` pada Android setelah perangkat tersedia. Login biasa: email `mikail@student.unand.ac.id`, password minimal 8 karakter; Masuk cepat (Dev) hanya ada pada debug, bukan release.
2. Ketuk Dari, cari `Khatib Sulaiman` di Padang lalu pilih hasil yang dekat fixture Jalan Khatib Sulaiman. Ketuk Ke, cari `Universitas Andalas` dan pilih kampus Limau Manis. Layanan nyata dapat mengembalikan titik berbeda; gunakan peta bila perlu untuk posisi jalan yang sesuai.
3. Untuk menguji pin langsung, tekan panah kanan. Ketuk jalan/gerbang, tunggu alamat otomatis, isi alias bila perlu lalu Gunakan Pin Ini. Nama/alias dan alamat terlihat terpisah di Cari. Back tanpa konfirmasi tidak mengubah pilihan.
4. Tekan Cariin Tebengan!: Hasil menampilkan data latihan yang searah. Fixture contoh Taris berangkat 07.30, sisa 2 kursi, Rp5.000; ini bukan tawaran nyata/akun server.
5. Buka Filter, pilih minimal 3 kursi lalu Terapkan → hasil kosong. Atur Ulang → Terapkan mengembalikan hasil. Batas ongkos di bawah Rp5.000 juga menyaring contoh itu. Tunjukkan validasi ongkos tidak valid dan batal draft tanpa apply.
6. Kembali ke Cari, swap kedua lokasi lalu cari → rute pulang contoh 16.00; bukan rute pergi yang diputar otomatis. Kartu → Detail mengirim objek Ride. Catatan dapat ditunjukkan sebagai workflow bersama yang sudah ada.
7. Jelaskan lima unsur workflow: input/event, state, validation, feedback, navigation/result. Baca source agar bisa memodifikasi langsung; jangan mengandalkan APK saja.

### Verifikasi source baru

- `flutter pub get` berhasil; pubspec/lockfile tidak berubah, tanpa dependency baru.
- `dart format --output=none --set-exit-if-changed .`: 79 file, 0 perubahan.
- `flutter analyze --no-pub`: tanpa issue.
- `flutter test --no-pub`: **123/123 lulus**; mencakup arsitektur/DI, pencarian/query terpisah, selector/pin/manual/retry, filter/cancel/reset/return, arah/kursi, disposed/stale async, shared workflow dan legacy terisolasi.
- Review capture 16 tampilan asli 360×800 (14 aktif/shared, 2 arsip legacy), termasuk Cari kosong/terisi, Hasil sukses/kosong/error/loading, Filter, tempat awal/hasil/error dan pin siap/gagal/manual. Screenshot representatif diperiksa setelah koreksi footer kursi/ongkos; screenshot map tanpa tile hanya fixture tes, bukan peta aplikasi. Hasil/Filter/Places juga diuji pada 320 px dan skala teks OS 2x; picker/keyboard/Detail tercakup regresi.
- `flutter build apk --release --target-platform android-arm64 --no-pub` berhasil, APK 17,8 MB pada `build/app/outputs/flutter-apk/app-release.apk`. Signing masih debug lokal, bukan paket distribusi produksi.

### Batas yang belum selesai

FR-01 memakai adapter lokal, belum API daftar rute. FR-04 hanya tampilan/saringan kuota; allocation/approval/sync/persistensi otoritatif milik backend. FR-03 koridor berarah 500 m, bukan detour/akses berjalan kaki sebenarnya. Login/request/note masih lokal; tidak ada auth server. Modul Taris/Shiddiq/Duha, GPS/live tracking dan backend tidak diimplementasikan dalam pekerjaan ini. Layanan peta publik tanpa billing bukan jaminan gratis tanpa batas/SLA produksi.

Belum memasang/membuka/menguji HP atau hot reload; kesiapan demo Android menunggu perangkat/izin dan pemahaman mahasiswa. Belum commit/push implementasi ini. Status [PROGRESS](PROGRESS.md), [rencana](rencana-aplikasi-penumpang.md), [UTS](../petunjuk-uts/petunjuk-uts.md).

## Baseline 6 Oktober 2026

Tiga layar lama Figma sudah diimplementasikan sebagai workflow lokal, bukan klaim seluruh PRD selesai. Penjelasan posting/edit/hapus di bawah hanya mencatat legacy dua role, bukan instruksi target baru.

## Alur baseline yang tersedia — termasuk driver legacy

Development: layar login menampilkan **Masuk cepat (Dev)** hanya pada Flutter debug (`kDebugMode`). Satu tap membuka Beranda sebagai Mikail tanpa email/password; tidak membuat akun/server login. Login biasa tetap memvalidasi form. Shortcut tidak tersedia pada profile/release dan handler juga menolak jika bukan debug. Gunakan `flutter run` atau `flutter build apk --debug --no-pub --target-platform android-arm64` untuk versi development; tidak ada flag untuk mengaktifkan shortcut di release. Untuk demo validasi UTS, gunakan Gas Masuk seperti biasa.

Beranda sekarang membedakan Cari Tebengan (penumpang) dan Beri Tebengan (pengemudi). Beri Tebengan → Buat Tebengan membuka posting langsung lalu Rute Saya. Alamat pin dicari otomatis lewat reverse Photon; ikut tersimpan bersama koordinat dalam sesi dan tampil di form/kartu/Detail. GPS saat ini/live tracking belum ditambahkan; lihat [batas pembagian tugas](pembagian-tugas.md).

Login lokal → Beranda → Rute Saya → Bikin Rute Baru → isi form → Posting Rutenya! → kembali ke Rute Saya dengan feedback sukses. Kembali ke Beranda untuk mencari rute tersebut.

Kartu Rute Saya membuka form edit dengan data awal. Tombol Atur menampilkan Edit/Hapus; hapus memerlukan konfirmasi. Rute berpenumpang tidak boleh dihapus agar kuota/booking tidak hilang diam-diam. Kartu milik sendiri di Beranda membuka pengelolaan, bukan permintaan gabung ke diri sendiri.

Beranda → Filter → pilih jam/kursi/ongkos → Terapkan → hasil berubah. Kembali tanpa Terapkan membuang draft. Atur Ulang mereset draft; harus Terapkan agar hasil Beranda ikut berubah.

## Pemetaan requirement baseline versi 1.0 dan peralihan 1.1

| Requirement | Status dan batasan |
|---|---|
| FR-01 | Legacy 1.0: posting/edit/hapus sesi tersedia. Target 1.1: baca daftar rute backend, bukan CRUD penumpang; integrasi dan data bergeometri belum disiapkan. |
| FR-02 Pencarian asal/tujuan | Pencarian tempat Photon atau pin langsung di peta, fallback teks internal pada baseline, serta filter jam/kursi/ongkos. Tebengan penuh disembunyikan. |
| FR-03 Jalur benar-benar searah | Heuristik geografis lokal tersedia: geometry OSRM, koridor 500 m, jemput sebelum turun. Belum memodelkan akses/detour aktual, backend atau sinkronisasi. Rute contoh tanpa geometry tidak ikut hasil geografis. |
| FR-04 Kuota otomatis/penuh | Domain `acceptBooking(routeId, bookingId)` tersedia dan teruji: mengurangi satu kursi setelah approval, idempotent untuk callback booking yang sama, menolak overbooking, dan menutup hasil pencarian saat penuh. Belum terhubung ke UI approval Modul 2 atau backend. Tombol ajukan gabung tidak langsung mengurangi kursi. |

## Aturan data dan validasi baseline

Aturan jam/kuota posting dan kepemilikan di bawah milik driver legacy; tidak menjadi input mobile penumpang baru. Aturan lokasi, filter dan matcher tetap relevan.

- Lokasi wajib diisi, minimal 3 karakter, memilih saran tempat atau pin; dua koordinat minimal 50 m terpisah. Nama sama boleh jika koordinat berbeda dan valid.
- Jam menerima `HH.mm` atau `HH:mm`, rentang 00.00–23.59, disimpan sebagai `HH.mm`.
- Total kursi 1–8; saat edit tidak boleh lebih kecil dari jumlah kursi yang telah terisi.
- Filter jam berbatas akhir eksklusif: 08.00 hanya masuk 08.00–09.00. Sore berarti 15.00–19.00. Tanpa pilihan jam berarti semua jam.
- Ongkos menerima bilangan bulat `10000` atau `10.000`; kosong berarti tanpa batas. Nilai negatif/pecahan/format salah ditolak.
- Rute baru memiliki ongkos belum diatur (`0` sebagai sentinel demo), **bukan gratis**. Rute itu dikecualikan ketika batas ongkos diaktifkan. Pengaturan/pembagian ongkos milik Modul 3.
- Repository dimiliki Home dan dipakai bersama melalui arguments named route. Data hilang saat aplikasi di-restart; tidak ada persistensi/server atau sinkronisasi dua HP. Kepemilikan hanya milik sesi lokal, bukan otorisasi akun server.

## Kode baseline untuk dipahami

PostRoute/MyRoutes adalah legacy yang akan diisolasi dari akses UI/named route penumpang. Home/Filter/Detail/LocationPicker tetap menjadi dasar migrasi. Jangan menganggap API atau ViewModel hasil baru sudah dibuat.

- Arsitektur sekarang [MVVM](../architecture/mvvm.md): ChangeNotifier + ListenableBuilder; state/logika tidak lagi di method State layar.
- `lib/screens/post_route_screen.dart`: controller/Form, binding, focus, PopScope dan navigasi; `lib/viewmodels/post_route_view_model.dart`: validasi, submit/loading/error, jalur, simpan/edit, pembatalan sebelum commit.
- `lib/screens/my_routes_screen.dart`: menunggu `pushNamed<Ride>`, SnackBar/dialog; `lib/viewmodels/my_routes_view_model.dart`: daftar reaktif, mode Atur dan perintah hapus.
- `lib/screens/ride_filter_screen.dart`: controller/Form dan result; `lib/viewmodels/ride_filter_view_model.dart`: draft, reset, validasi ongkos dan apply `RideFilter` immutable.
- `lib/viewmodels/home_view_model.dart`: pemuatan, state, pencarian/filter/matcher, intent/tab dan subscriber repository.
- `lib/core/`: lifecycle ViewModel dan injeksi layanan peta bersama.
- `lib/models/ride_filter.dart`: parse waktu/rupiah dan predikat filter; tidak menjalankan logika UI.
- `lib/data/ride_repository.dart`: penyimpanan sesi, kepemilikan, kuota, dan idempotensi booking.
- `lib/routes/app_routes.dart`: named route bertipe, arguments shared repository, fallback 404.
- `lib/widgets/ride_card.dart`: satu kartu reusable untuk Beranda/Rute Saya, layout adaptif untuk teks besar.

## Verifikasi dan desain baseline — 6 Oktober 2026

Migrasi MVVM diverifikasi dengan analyzer tanpa issue, format/diff bersih, dan 100/100 test (71 regresi + 29 tes ViewModel/arsitektur), diulang setelah cleanup fixture. Build debug serta release arm64 17,8 MB berhasil. APK MVVM baru belum dipasang atau diuji di HP; versi yang terpasang tetap build debug sebelum migrasi. Migrasi tidak mengubah desain atau menambahkan fitur/backend/dependency.

Pembaruan UI dikoreksi ke panduan bersama: input putih/border cloud/radius 20, endpoint coral/hijau dan dotted rail pada Home, Posting/Edit, kartu Rute Saya dan Detail. Panah kanan membuka picker; swap menukar nama beserta koordinat. Kursi/jam/ongkos/jemput memakai ikon Material. Review visual meliputi enam tampilan asli 360×800 termasuk intent pengemudi; Figma tidak diubah pada pembaruan ini.

Tema coral, spacing/radius, dan komponen mengikuti Figma melalui skill design-to-code pada implementasi awal. Penyesuaian native: chip Material dengan target sentuh wajar (bukan instance Figma 100px), form bertumpuk pada layar sempit/teks besar, daftar milik pengguna mulai kosong (tidak mengklaim contoh rute Figma sebagai rute miliknya). Integrasi peta berikutnya menambah `flutter_map`, `latlong2`, `http`, `url_launcher` dan layar pemilih pin sesuai instruksi pengguna; tidak menulis ulang Figma. Detail penggunaan, kode dan batas layanan: [peta dan lokasi](peta-dan-lokasi.md).

```text
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub --target-platform android-arm64
```

Pengujian meliputi posting/edit/search, form invalid/batal, hapus konfirmasi, filter draft/apply/reset, result, boundary waktu, kuota penuh, callback ganda, dan layout 320px pada skala teks 1x/2x. Review widget juga dijalankan pada 360×800, ukuran frame Figma. Capture opt-in:

```text
flutter test --no-pub test/visual_review_test.dart --dart-define=SAVE_SCREENSHOTS=true
```

PNG dihasilkan otomatis di `build/visual-review/`; bukan screenshot HP dan bukan golden test pixel-diff. Font/tema capture disesuaikan hanya untuk mengganti font Ahem milik test. Font fallback simbol pada test runner bisa berbeda dari Android.

Build awal berhasil terpasang/terbuka di Infinix X6855. APK terbaru termasuk peta/pin kini dibangun dan dipasang ulang dengan nama Nebeng Dong (6 Oktober 2026), atas instruksi pengguna, tanpa membuka aplikasi. Uji interaksi lengkap dan hot reload di HP belum dilakukan. Tidak ada commit, push, atau merge pada pengerjaan ini.
