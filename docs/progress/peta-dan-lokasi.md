# Peta, pencarian tempat, dan pin — Nebeng Dong

> Pembaruan 8 Oktober: source aktif sekarang feature-first MVVM penumpang; driver hanya arsip tanpa akses app. Path/penjelasan versi 6 Oktober di bawah merupakan baseline historis. Lihat [MVVM](../architecture/mvvm.md) dan [PROGRESS](PROGRESS.md) untuk struktur/status terbaru. Fixture aplikasi sekarang memiliki geometry jalan nyata; backend/HP belum diintegrasikan/diuji.

Implementasi 6 Oktober 2026 memakai layanan terbuka, tanpa Google Maps SDK, API key, atau akun billing. Ini konfigurasi demo kecil, bukan jaminan layanan gratis tanpa batas untuk produksi.

## Target satu role — revisi dokumen 8 Oktober 2026

Peta tetap dipakai pada Cari/Hasil/Detail dan Titik Jemput penumpang. [PRD 1.1](../prd/prd-nebeng-dong-kel-4.md) tidak lagi menempatkan Posting Rute/Rute Saya pada mobile; penjelasan posting di bawah adalah baseline 6 Oktober, bukan target baru. Source belum dimigrasikan. Figma Mikail 8 Oktober sudah memakai field Dari/Ke beralamat dengan aksi pin/swap kanan; picker peta penuh dan shared Detail tidak diubah. Aksi pin/swap masih visual, bukan interaksi peta di prototype.

Rute sekarang ditargetkan berasal dari backend/admin dengan koordinat, alamat dan geometry jalan yang sudah tersimpan. **Sample lama tanpa geometry tidak cocok saat pencarian menggunakan pin.** Siapkan seed/fixture deterministik bergeometri jalan nyata, termasuk arah benar/terbalik/penuh; jangan memakai garis lurus palsu atau menghitung seluruh seed melalui OSRM setiap startup. Backend eksternal/kontrak belum dikonfirmasi. Seed/fake bukan backend booking yang selesai; batas simulasi harus dijelaskan. Detail: [rencana penumpang](rencana-aplikasi-penumpang.md).

## Komponen

| Kebutuhan | Implementasi |
|---|---|
| Peta interaktif dan pin | `flutter_map` 8.3.2, tile OpenStreetMap standar, `latlong2` 0.9.1 |
| Cari nama tempat/alamat | Photon `https://photon.komoot.io/api/`, bias awal Padang, bukan pembatas wilayah |
| Alamat pin otomatis | Photon `/reverse`, radius 0,2 km, alamat terdekat; koordinat ketukan tetap dipertahankan |
| Geometry jalan | OSRM/FOSSGIS `https://routing.openstreetmap.de/routed-car`, profil mobil |
| Mencocokkan tebengan | `RouteMatcher` lokal: kedua titik dekat geometry jalan, jemput sebelum turun, urutkan deviasi terkecil |

Nominatim publik tidak dipakai untuk autocomplete. OSRM mengembalikan jalan sebenarnya; kegagalan tidak diganti garis lurus palsu. Profil mobil belum menjamin jalan khusus motor atau kondisi lalu lintas aktual.

## Cara memakai pencarian/pin pada baseline

Target penumpang mempertahankan alur Beranda/Cari → saran atau pin → konfirmasi alamat → cari/filter → hasil/detail. Langkah Posting/Edit di bawah hanya berlaku pada source legacy.

1. Di Posting Rute atau Beranda, ketik minimal 3 karakter dan pilih salah satu saran tempat. Nama yang diketik saja tidak dianggap memiliki koordinat.
2. Alternatif: tekan **panah kanan** di kolom Dari/Ke (tooltip: Pilih/Ubah pin di peta), cari tempat atau geser/zoom peta, lalu **ketuk** titik yang diinginkan. Ketukan berikutnya memindahkan pin. Menggeser peta saja tidak memilih titik.
3. Setelah ketuk pin, alamat dicari otomatis dan terisi di **Alamat lokasi**. Tunggu sampai selesai; jika alamat tidak tersedia/gagal, coba ulang atau isi manual. Data OSM tidak menjamin nomor rumah/jalan/kode pos selalu lengkap. Nama pin boleh diubah sebagai alias; alamat tetap ikut dikembalikan, ditampilkan di form/kartu/Detail dan dicatat di geography repository sesi. Tanpa alias, nama field memakai alamat lengkap yang tersedia. Tekan **Gunakan Pin Ini**; tombol kembali membatalkan pilihan baru. Tidak mengambil lokasi GPS HP.
   Tombol **tukar asal dan tujuan** di kanan menukar nama dan koordinat bersamaan. Jam/kursi tidak berubah. Di Beranda, perubahan draft baru memengaruhi hasil setelah menekan Cariin Tebengan; di Posting/Edit, jalur dihitung ulang sesuai arah baru saat menyimpan.
4. Posting memerlukan dua lokasi valid, jarak minimal 50 m, jam, dan kursi. Jalur dihitung saat submit, sebelum rute disimpan. Error internet/layanan mempertahankan form agar bisa diulang.
5. Beranda: pilih koordinat untuk **kedua** field, lalu Cariin Tebengan! Pencocokan memakai titik dalam koridor 500 m dengan urutan minimal 50 m sepanjang jalur. Filter jam/kursi/ongkos tetap berlaku. Istilah mode/internal ini tidak ditampilkan di UI.
6. Jika kedua field tidak memiliki pilihan koordinat, Beranda tetap menyediakan pencarian teks lama. Jika baru satu yang memiliki koordinat, pengguna diminta memilih lokasi satunya. Rute contoh lama tanpa geometry tidak dimasukkan ke hasil geografis.

Data posting/edit tetap repository sesi lokal; restart aplikasi menghapus rute baru. Server, sinkronisasi akun/HP, approval Modul 2, persistensi, dan pencocokan backend belum diimplementasikan. Koridor 500 m bukan jaminan akses berjalan kaki atau tambahan jarak berkendara; heuristik lokal ini dapat menerima titik terpisah sungai/jalan tak terhubung.

**Legacy dua intent, bukan target PRD 1.1:** Di Beranda, **Cari Tebengan / Saya penumpang** membuka pencarian asal/tujuan dan hasil; **Beri Tebengan / Saya pengemudi** membuka aksi Buat Tebengan dan pengelolaan Rute Saya. Ganti pilihan tidak menghapus draft pencarian. Ini pembeda intent, bukan perubahan peran akun permanen.

## Batas layanan dan privasi

- Autocomplete memiliki debounce 700 ms, minimum 3 karakter, maksimum 5 hasil, dan perlindungan respons lama. Mengubah teks membatalkan koordinat sebelumnya; memindahkan kursor tidak membatalkannya.
- Satu service per sesi, antrean terpisah Photon/OSRM dengan jarak kirim minimal 1,1 detik; forward/reverse berbagi antrean Photon. Reverse debounce 650 ms dengan guard respons lama dan cache 40 alamat berhasil (hasil kosong tidak dicache agar retry bekerja), selain cache 40 query dan 20 jalur. Timeout 15 detik, abort koneksi saat service ditutup. Tidak menghitung jalur setiap contoh seed atau setiap ketikan.
- Tile memakai caching HTTP/persisten bawaan `flutter_map`; tidak ada fitur unduh massal/prefetch offline. Client tile dipertahankan saat pin berubah dan dilepas saat layer ditutup. Atribusi OSM serta tautan copyright/perbaikan peta selalu tersedia; geometry diberi atribusi OSRM/FOSSGIS.
- Photon menerima teks pencarian/bias Padang serta koordinat pin saat mencari alamat; OSRM menerima koordinat asal/tujuan; server tile menerima area tampilan peta. Permintaan jaringan memperlihatkan IP ke penyedia. FOSSGIS mencatat permintaan routing. Jangan memasukkan data sensitif tanpa memahami layanan publik ini.
- Aplikasi tidak meminta izin lokasi/GPS/background tracking. Hanya INTERNET ditambahkan ke manifest Android utama. Paket HTTP dan pembuka tautan atribusi adalah dependency tambahan yang diperlukan.
- Layanan publik bisa tidak tersedia atau membatasi akses. Ada pesan error/retry; tidak ada fallback diam-diam ke layanan berbayar.

Ketentuan: [OSM tile policy](https://operations.osmfoundation.org/policies/tiles/), [Photon dan fair use demo server](https://github.com/komoot/photon), [OSRM API](https://project-osrm.org/docs/v5.24.0/api/), [FOSSGIS service terms](https://routing.openstreetmap.de/about.html), [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/).

## Konfigurasi dan kode untuk dipahami

Endpoint dapat diganti saat build melalui `--dart-define=PHOTON_URL=https://...`, `--dart-define=OSRM_URL=https://.../routed-car`, dan `--dart-define=MAP_TILE_URL=https://.../{z}/{x}/{y}.png`. Endpoint search/routing wajib HTTPS dengan API kompatibel; aturan penyedia tile alternatif tetap harus diperiksa. Kredensial privat tidak boleh ditanam di aplikasi.

- `lib/models/map_location.dart`: koordinat GeoJSON `[lon, lat]`, lokasi/pin, geometry immutable.
- `lib/data/open_map_service.dart`: interface, parsing HTTP, cache, rate limit, timeout, dan lifecycle client.
- `lib/widgets/location_field.dart`: controller/listener, binding state dan navigasi/result picker; `lib/viewmodels/location_search_view_model.dart`: debounce, invalidasi koordinat, loading/error/hasil autocomplete dan stale guard.
- `lib/screens/location_picker_screen.dart`: binding UI/controller dan result; `lib/viewmodels/location_picker_view_model.dart`: event tap, state pin, reverse alamat, retry/manual, validasi konfirmasi `MapLocation`.
- `lib/widgets/open_street_map_view.dart`: rendering tile, marker, polyline, atribusi, error/retry.
- `lib/data/osm_tile_provider.dart`: factory provider dengan header HTTP mutable yang dapat dimodifikasi constructor `TileLayer`; tidak menggunakan map `const` untuk headers.
- `lib/utils/route_matcher.dart`: proyeksi kedua titik ke segmen geometry dan pengecekan urutan perjalanan.
- `lib/viewmodels/post_route_view_model.dart`: submit async, validasi, guard duplikasi/cancel/dispose, baru menyimpan geometry setelah OSRM sukses. View `post_route_screen.dart` memberi sinyal cancel dari PopScope.
- `lib/viewmodels/home_view_model.dart`: snapshot pencarian dan gabungan geo/filter, bukan hasil yang berubah diam-diam saat draft diketik; UI di `home_screen.dart`.
- `lib/core/di/map_service_scope.dart`: lifetime client bersama; detail batas layer dan ownership di [MVVM](../architecture/mvvm.md).

## Verifikasi

Setelah migrasi MVVM: 100/100 test lulus dan analyzer bersih, termasuk regresi peta yang sama; fitur/backend/GPS tidak ditambah. APK yang terpasang di HP masih versi debug sebelum migrasi. Hasil build terbaru dan batas uji perangkat dicatat di PROGRESS; catatan release di bawah merupakan riwayat instalasi, bukan klaim APK MVVM sudah terpasang.

Quality gates UI terbaru: format/diff bersih, analyzer tanpa issue dan 68/68 test lulus. APK release arm64 dengan intent Cari/Beri dan alamat pin otomatis berhasil dibangun (17,8 MB) dan dipasang -r ke HP (`Success`), tanpa DEBUGGABLE. Signing masih key debug lokal sesuai konfigurasi awal, belum signing untuk distribusi Play Store.

Error `Unsupported operation: Cannot modify unmodifiable map` berhasil direproduksi dan diperbaiki: constructor `TileLayer` memanggil `headers.putIfAbsent` bahkan saat User-Agent sudah ada. Header lama berupa map const. Factory kini mengalokasikan map mutable baru untuk setiap provider; caching bawaan tidak dimatikan. Dua test regresi memastikan constructor native dan isolasi header antar-provider, tanpa memuat tile jaringan.

UI dirapikan: aksi pilih/ubah pin rata kanan, tidak ada label Mode teks/Mode jalur, catatan contoh lama, koordinat mentah, atau teks Data demo. Status pilihan menjadi Lokasi dipilih/Pin sudah dipilih; pin tanpa nama menjadi Lokasi di peta. Atribusi OSM/OSRM dan penjelasan privasi singkat tetap ada. Data masih repository sesi, bukan persistensi/backend produksi; istilah production-ready di sini tidak berarti semua PRD, autentikasi server atau distribusi sudah selesai.

UI Dari/Ke mengikuti susunan referensi, tetapi warna/radius kembali ke aturan bersama: surface putih/border cloud/radius 20, asal coral, tujuan hijau, swap brand-subtle. Komponen `RouteEndpoints`/`RouteLocationSummary` dipakai pada Beranda, Posting/Edit, kartu rute dan Detail; ikon Material tanpa dependency baru. Cari/Beri dibedakan lewat teks/ikon/peran, bukan hanya warna. Form mempertahankan field mounted agar submit bawah tidak melewatkan validasi.

Implementasi alamat mengikuti [API reverse Photon](https://github.com/komoot/photon/blob/master/docs/api-v1.md). Smoke terbatas: pusat default Padang tidak menemukan alamat radius 200 m; titik hasil pencarian Universitas Andalas berhasil mengembalikan Jalan Limau Manis, Limau Manis, Padang, Sumatera Barat, 25168, Indonesia. Ini endpoint laptop, bukan uji UI HP. Fallback manual wajib tersedia, tidak mengarang alamat.

Test otomatis memakai HTTP tiruan, fake service khusus folder `test/`, dan tile dimatikan melalui dependency injection. Tidak menggunakan server publik atau mengunduh tile selama test. Mencakup lat/lon, parsing/cache/error/timeout, geometri belok, arah berlawanan, koordinat lama, tap/pindah/nama/konfirmasi/batal pin, submit gagal/retry/back, dan layout 320 px/teks 1x–2x/keyboard.

Smoke check jaringan terbatas pada 6 Oktober 2026: Photon menemukan Air Tawar dan Universitas Andalas di Padang; OSRM mengembalikan `Ok`, 511 vertex, 17.638,6 m dan 1.237,5 detik (estimasi profil mobil). Ini pemeriksaan endpoint dari laptop, bukan uji UI Android.

Build Windows awal menemukan error cache Kotlin lintas drive (proyek D:, Pub cache C:). Workaround project `android/gradle.properties`: `kotlin.incremental=false`; build Kotlin bisa lebih lambat, tetapi tidak perlu memindahkan cache atau mengubah ENV komputer. [Dokumentasi Kotlin](https://kotlinlang.org/docs/gradle-compilation-and-caches.html).

`flutter pub get` sudah mengunduh dependency, tetapi menampilkan peringatan symlink Windows/Developer Mode. Build Android dengan `--no-pub` berhasil. Jika peringatan muncul lagi saat setup di Windows, aktifkan Developer Mode sendiri melalui Settings jika diizinkan; tidak diubah otomatis oleh pengerjaan ini. Target Windows desktop bukan target verifikasi tugas.

APK release terbaru dengan fix header tile, UI coral/radius 20, Cari/Beri, alamat pin, swap dan ikon berhasil diinstall -r ke Infinix X6855 dengan nama Nebeng Dong (6 Oktober 2026, updateTime 17:09:11). Tidak ada uninstall/clear data. Aplikasi tidak dibuka; izin smoke UI diminta tetapi belum dijawab, uji workflow HP/hot reload belum dilakukan. Tidak ada commit/push atau perubahan Figma dalam implementasi peta/UI ini.
