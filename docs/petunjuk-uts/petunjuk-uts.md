# Petunjuk UTS — Demo, Code Review, dan Tanya Jawab

Sumber: instruksi dosen yang diberikan pengguna pada 6 Oktober 2026, serta [Practical Challenge — Tugas Individu](practical-challenge-tugas-individu.md).

## Ketentuan code review dan tanya jawab

Pada Pertemuan ke-7, setelah demo tugas/workflow, dilakukan code review dan tanya jawab langsung.

Dosen menanyakan kode yang dibuat, terutama berdasarkan materi yang sudah dipelajari. Mahasiswa dapat diberi instruksi sederhana seperti “Coba ubah…” pada bagian program, lalu harus menjelaskan atau menunjukkan perubahan tersebut.

Mahasiswa juga diberi situasi/permasalahan dan diminta menunjukkan cara menyusun prompt yang tepat agar AI membantu menghasilkan atau memperbaiki kode.

- Tidak ada file yang perlu dikumpulkan.
- Penilaian dilakukan langsung saat tanya jawab setelah demo.
- Pertanyaan dan instruksi bersifat spontan; tidak perlu menyiapkan jawaban atau kode khusus sebelumnya.
- Materi tetap berdasarkan perkuliahan yang telah diberikan.
- Mahasiswa harus memahami kode yang dibuat, bukan sekadar menjalankan aplikasi.
- Bawa laptop pengembangan dengan source code dan environment/tools untuk menjalankan dan memodifikasi aplikasi. Membawa aplikasi terpasang atau APK saja tidak diperkenankan.

## Cakupan proyek yang direvisi — 8 Oktober 2026

[PRD 1.1](../prd/prd-nebeng-dong-kel-4.md) menargetkan satu role penumpang berdasarkan masukan pembimbing yang disampaikan pengguna. Instruksi asli dosen di atas tetap sama; bagian berikut pemetaan proyek, bukan tambahan ketentuan ujian.

Target demo Mikail setelah migrasi: **Login → Cari Tebengan → pilih Dari/Ke dari saran/pin → Filter → Terapkan → Hasil Pencarian → Detail**. Tunjukkan input/event, state ViewModel, validasi lokasi/ongkos, feedback loading/invalid/kosong/sukses, serta navigasi/result MapLocation/RideFilter/Ride.

Figma Mikail sudah direvisi dan ditinjau menjadi Cari/Hasil/Filter serta loading/kosong/error (8 Oktober 2026). **Source struktur/role sudah dimigrasikan ke feature-first penumpang**, hasil masih di Home dan semua state Figma belum diport; prototype Figma bukan bukti workflow Flutter siap ujian. Hasil 100 tes/build 6 Oktober adalah baseline, bukan bukti target baru siap ujian. Driver menyediakan data melalui backend/admin; tidak perlu demo Posting/ACC sebagai penumpang. Fixture jalan nyata tersimpan untuk demo koordinat; data latihan bukan backend. Contoh arsip lama tanpa geometry tetap tidak cocok. Rencana rinci: [rencana penumpang](../progress/rencana-aplikasi-penumpang.md).

## Pemetaan kode saat ini untuk penilaian kesiapan

Bagian ini adalah hasil pemeriksaan proyek, bukan ketentuan tambahan dari dosen.

Workflow yang tersedia: **pilih tebengan → Detail → Tulis Catatan → isi dan simpan → kembali ke Detail dengan catatan dan feedback sukses**.

| Tahap | Implementasi yang perlu dipahami |
|---|---|
| Input / Event | Tombol `Tulis Catatan`, `TextEditingController`, dan tombol `Simpan`. |
| State | Controller input di View; catatan disimpan dalam `RideDetailViewModel.note`, dan UI mengikuti ChangeNotifier melalui ListenableBuilder. |
| Validation | `CatatanFormViewModel.validate` memakai `Validators.minLength(value, 5, fieldName: 'Catatan')`; View memanggil `FormState.validate()`. Command save memvalidasi ulang. Input kosong/pendek menahan pengguna di form. |
| Feedback | Pesan error field dan SnackBar `Catatan berhasil disimpan`. |
| Navigation / Result | Home mengirim `Ride` ke Detail lewat named route; form mengembalikan String melalui `Navigator.pop`; Detail menunggu hasil `Navigator.pushNamed<String>`. |

Source terkait:

- `lib/features/ride_search/views/home_screen.dart`: pencarian asal/tujuan dan pengiriman objek `Ride`.
- `lib/routes/app_routes.dart`: named routes, pemeriksaan tipe arguments, dan fallback route.
- `lib/shared/views/ride_detail_screen.dart`: penerimaan `Ride`, pembukaan form, penerimaan result, pembaruan state, dan feedback.
- `lib/features/booking/views/catatan_form_screen.dart`: input, validasi, dan pengembalian result.
- `lib/features/booking/viewmodels/catatan_form_view_model.dart`, `lib/shared/viewmodels/ride_detail_view_model.dart`: aturan validasi/result, state catatan/permintaan dan commands.
- `lib/shared/utils/validators.dart`: aturan validasi reusable.
- `test/integration/passenger_workflow_test.dart`: pengujian alur serta validasi.

Catatan disimpan dalam state layar, sehingga hilang ketika layar Detail dibuat ulang. Login dan repository data masih simulasi lokal; belum ada autentikasi server atau penyimpanan permanen. Petunjuk UTS tidak mewajibkan backend, tetapi batasan ini harus dapat dijelaskan.

## Perbedaan UTS dengan target modul kelompok Mikail

Modul Mikail tetap Rute & Tebengan (FR-01–FR-04); usulan layar menjadi Cari Tebengan, Hasil Pencarian, Filter. FR-01 berarti menampilkan rute backend, bukan posting penumpang; FR-04 menampilkan kuota backend yang dialokasikan setelah approval, bukan ketika request dikirim. Pembagian rinci masih perlu konfirmasi tim.

Workflow Catatan yang telah tersedia di atas tetap kandidat UTS satu role: input → validasi → simpan result → kembali ke Detail dengan feedback. Catatan/session lokal harus dijelaskan sebagai batas, bukan penyimpanan backend.

Workflow Filter yang sudah ada: **Beranda → Filter → ubah draft jam/kursi/ongkos → validasi → Terapkan → result RideFilter → hasil berubah**; batal tidak menerapkan draft. Ini dapat digunakan untuk memahami lima unsur workflow tanpa role pengemudi.

Workflow pin yang sudah ada: **saran atau pilih pin → ketuk/pindah → alamat otomatis/alias → konfirmasi → result MapLocation ke Dari/Ke**. Pahami state LocationPickerViewModel, validasi pin/alamat, loading/error/retry, guard hasil lama dan pembatalan. Saran/geocode/tile memerlukan internet. Peta manual bukan GPS/live tracking.

FR-03 aktual memakai geometry OSRM, koridor 500 m dan urutan jemput sebelum turun. Belum ada detour/akses jalan kaki atau matcher backend. Domain kuota lokal teruji tetapi belum dihubungkan ke approval/backend. Permintaan pending tidak mengurangi kursi. Detail: [peta](../progress/peta-dan-lokasi.md) dan [baseline Modul 1](../progress/modul-1-implementasi.md).

Arsitektur [MVVM](../architecture/mvvm.md): View menangani input/controller/feedback/navigasi; HomeViewModel menangani pencarian/filter/matcher; RideFilterViewModel menangani draft/validasi/apply; repository/service menangani data/jaringan; core adalah lifecycle/DI. Untuk perubahan aturan filter, mulai dari RideFilterViewModel/model RideFilter; untuk tampilan dari theme/View. Pahami ChangeNotifier/ListenableBuilder, dependency injection, dispose dan guard async. Ini pemetaan source, bukan kewajiban baru dosen.

### Workflow pengemudi legacy — bukan demo utama PRD 1.1

Posting Rute/Rute Saya masih ada pada source baseline 6 Oktober dan pernah memenuhi unsur workflow lokal, tetapi tidak sesuai target penumpang baru. Catatan historis source/tes tetap tersedia di implementasi Modul 1 dan PROGRESS. Driver di lib/legacy/driver sekarang diblokir oleh router/UI penumpang. Jangan menjadikan posting pengemudi sebagai demo app aktif.

## Persiapan laptop

Hasil pemeriksaan **baseline 6 Oktober 2026**, bukan pemeriksaan baru atau validasi migrasi satu role:

- Branch aktif: `Latihan2-2411523016`.
- `flutter analyze --no-pub`: lulus, tidak ada masalah.
- Source sudah dimigrasikan ke MVVM dan build APK debug/release terbaru berhasil di laptop (release arm64 17,8 MB). APK migrasi belum dipasang/diuji di HP; jangan menyamakan build sukses dengan verifikasi demo Android.
- `flutter test --no-pub`: seluruh 100 test lulus setelah migrasi MVVM: 71 regresi lama ditambah 29 tes ViewModel/batas arsitektur, termasuk commit cancel sebelum dispose dan edit ketika kuota berubah saat request berjalan. Test memakai fake dan tanpa tile jaringan. APK debug pada HP masih versi sebelum migrasi, dengan Masuk cepat (Dev); migrasi source/build tidak otomatis berarti APK HP diperbarui. Gunakan Gas Masuk biasa saat menjelaskan validasi login.
- Flutter 3.47.0, Dart 3.13.0, Android SDK 36, dan JDK Temurin 21 terdeteksi; lisensi Android diterima.
- HP Infinix X6855 terdeteksi dan build awal berhasil terpasang/terbuka. Versi final APK debug dibangun di laptop; pengguna meminta uji HP lanjutan ditunda karena HP sedang digunakan. Demo interaksi lengkap versi final dan hot reload belum diverifikasi.
- Flutter doctor mencatat Visual Studio belum terpasang (untuk target Windows, bukan prasyarat Android), serta dua binary ADB di PATH. Untuk pemeriksaan perangkat, gunakan ADB dari Android SDK bila terjadi konflik.
- Perubahan lokal pada tombol Daftar menuju route `/tidak-ada` sudah ada sebelum pemeriksaan ini dan tidak diubah. Login tetap simulasi lokal.

Penilaian terbaru 8 Oktober: kode baseline menyediakan Catatan/Filter/pin yang dapat dijelaskan sebagai workflow penumpang; source sudah penumpang/MVVM feature-first, namun hasil belum layar terpisah dan semua state Figma belum diport. **Belum dinyatakan siap demo final**: fixture bergeometri tersedia, verifikasi refactor baru dicatat di PROGRESS; tetap perlu APK yang sesuai, uji interaksi Android/hot reload dan pemahaman mahasiswa. Signing masih key debug lokal; backend/persistensi/sinkronisasi/approval belum selesai. UTS satu workflow tidak otomatis mewajibkan seluruh PRD selesai, tetapi simulasi harus dijelaskan jujur. GPS/live tracking tidak diwajibkan eksplisit FR-01–04.

- Buka repository dan pastikan branch yang berisi workflow tersedia (`Latihan2-2411523016` saat pemeriksaan).
- Pastikan Flutter/Dart, Android SDK, JDK, editor, serta AI coding assistant dapat dipakai.
- Jalankan `flutter analyze`, `flutter test`, dan aplikasi pada HP/emulator sebelum ujian.
- Pastikan HP terdeteksi, USB debugging aktif, dan hot reload dapat dilakukan.
- Untuk demo login lokal gunakan email kampus `nama@student.unand.ac.id` dan password minimal 8 karakter.
- Pahami hubungan event, state, validasi, feedback, dan navigasi pada kode; dokumen ini bukan kumpulan jawaban untuk pertanyaan spontan.
