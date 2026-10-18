# Demo Duha — Riwayat penumpang dan rating pengemudi

Disesuaikan dengan PRD Markdown v1.1 dan main 3d001be. Satu workflow FR-13/14,
bukan seluruh Modul 4. Profil/rekap, pemesanan, ongkos dan backend belum diintegrasikan.

## Jalankan dari terminal VS Code

```powershell
$env:FLUTTER_WINDOWS='false'
$env:FLUTTER_LINUX='false'
flutter pub get
flutter devices
flutter run -d <id-hp> -t lib/main_rating.dart
```

Dua variabel di atas hanya berlaku di terminal tersebut agar demo Android tidak
memerlukan symlink plugin desktop. Launcher dan konfigurasi F5 sudah mengaturnya.

Atau pilih **Duha — Workflow Rating** pada Run and Debug, lalu F5.
Entry aplikasi kelompok tetap `lib/main.dart`. Navigasi Pesanan/Profil milik tim
belum disambungkan: demo ini langsung membuka riwayat penumpang Duha.

## Alur demo

1. Buka Riwayat Perjalanan (dua perjalanan contoh sebagai penumpang).
2. Tekan **Nilai Pengemudi, Yuk!** pada perjalanan selesai.
3. Kirim tanpa bintang: validasi muncul dan tidak menyimpan.
4. Pilih 1–5 bintang, isi komentar opsional maksimal 200 karakter.
5. Kirim: tombol/input terkunci selama menyimpan.
6. Kembali otomatis ke Riwayat; kartu yang sama menampilkan **Sudah dinilai**,
   bintang yang kamu berikan, angka /5 dan komentar. Filter kembali ke Semua.
7. Tutup/buka aplikasi: rating lokal tetap ada; perjalanan tidak bisa dinilai ganda.

Simulasi gagal simpan: `flutter run -t lib/main_rating.dart --dart-define=SIMULATE_RATING_FAILURE=true`.
Draft tetap ada dan pengiriman berikutnya bisa dicoba. Menu **Ulangi demo rating**
meminta konfirmasi sebelum menghapus rating demo penumpang di perangkat.

## Cara kerja MVVM

- `features/reputation/views`: tampilan, controller, dialog, Snackbar, navigasi bertipe.
- `viewmodels`: pilihan bintang, filter, validasi, loading/error dan perintah simpan.
- `data/rating_repository.dart`: kontrak riwayat/rating yang diinjeksi.
- `data/local_rating_repository.dart`: fixture milik penumpang dan SharedPreferences.
- `models`: perjalanan dengan passengerId/driverId dan rating immutable.
- Warna, tema, input, tombol dan avatar memakai komponen bersama dari main terbaru.

Data tetap simulasi, tanpa autentikasi atau sinkronisasi server. Validasi lokal
menolak trip milik orang lain, trip belum selesai, pengemudi tak valid dan rating
ganda; backend tetap perlu memvalidasi aturan itu secara otoritatif nanti.

## Pelestarian versi lama

Source sebelum migrasi disalin ke folder saudara `TB-rating-backup-20261011`
dan disimpan di Git stash berlabel `Duha rating workflow before passenger MVVM integration 2026-10-11`.
Jangan menerapkan stash itu langsung ke source baru; struktur lama berbeda.
Penyimpanan baru memakai key `nebeng_dong_duha_passenger_rating_demo_v2`.
Key lama v1 tetap utuh; rating dua role tidak otomatis dianggap rating pengemudi.
Identitas Android demo dipertahankan agar aplikasi kelompok tidak tertimpa.
Figma belum direvisi; penyesuaian desain tim masih perlu disepakati.

## Verifikasi 11 Oktober 2026

Pub get, format 82 file, analyzer dan seluruh 123 tes lulus. Tiga capture riwayat,
form dan hasil bintang ditinjau. APK debug di `build/app/outputs/flutter-apk/app-debug.apk`
berhasil dibuat. Pada 11 Oktober 2026 demo juga dipasang dan dibuka pada
Infinix X6885; tampilan tanpa badge peran dikonfirmasi lewat screenshot.
Ini pemeriksaan peluncuran/tampilan, bukan uji otomatis seluruh alur pada perangkat.
