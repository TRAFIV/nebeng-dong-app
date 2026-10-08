# Rencana Aplikasi Penumpang — Nebeng Dong

Tanggal: 8 Oktober 2026. Acuan: [PRD 1.1](../prd/prd-nebeng-dong-kel-4.md).
Keputusan satu role berasal dari masukan pembimbing yang disampaikan pengguna. Revisi dokumen selesai. Atas instruksi berikutnya, Figma bagian Mikail sudah direvisi dan ditinjau; refactor source feature-first/penumpang dan repository sesi sudah dilakukan. Hasil masih di Home; migrasi penuh susunan Figma dan integrasi backend/rekan belum selesai.

## 1. Arah produk

Mobile hanya untuk penerima/pencari tebengan. Tidak ada role selector, Beri Tebengan, posting/edit/hapus rute pengemudi, Rute Saya pengemudi, ACC permintaan, atau konfirmasi pelunasan oleh pengemudi.

Pengemudi tetap data profil/rute/kendaraan/reputasi. Backend/admin berwenang menjalankan tindakan penyedia; aplikasi pengemudi terpisah mungkin dikembangkan nanti. Jangan membangun dashboard admin baru tanpa instruksi.

## 2. Batas rencana, kode dan desain

| Area | Status 8 Oktober 2026 |
|---|---|
| PRD/panduan/aturan | Direvisi untuk target penumpang saja. |
| Flutter | Feature-first MVVM penumpang: driver UI dihapus, named routes ditolak, source driver di legacy. Kontrak baca/adapter lokal dan DI sesi tersedia, fixture jalan nyata tersimpan. Hasil masih di Home; seluruh UI Figma belum diport. |
| Figma | Mikail selesai: Cari/Hasil/Filter (`124:240`–`124:242`), loading/kosong/error (`130:402`), prototype utama dan 18 state pemilih Dari/Ke/pin (`148:474`), termasuk Ke lebih dulu, alamat loading/gagal/manual dan swap contoh. Arsip driver (`124:238`) dipertahankan. Layar bersama/bagian rekan tetap baseline. |
| Backend | REST aplikasi tidak ada di repo; backend eksternal belum dikonfirmasi. Data lokal bukan backend. |
| Tes/build | Hasil 100 tes/build 6 Oktober adalah baseline. Verifikasi refactor baru dicatat di PROGRESS; jangan mengasumsikan tes lama membuktikan migrasi baru. |
| HP | APK sebelum migrasi MVVM; uji workflow terbaru dan hot reload belum dilakukan. Tidak membuka HP tanpa izin. |

## 3. Alur dan UI target

Login → Cari Tebengan (Dari/Ke) → saran nama tempat atau pin → cari → Hasil Pencarian ↔ Filter → Detail Tebengan → Titik Jemput/catatan → Ajukan → Status Permintaan → perjalanan → ongkos → rating/riwayat.

| Bagian | Isi dan aksi penumpang |
|---|---|
| Cari | Sapaan, field Dari/Ke, swap, saran tempat, aksi pin rata kanan, tombol Cariin Tebengan!. |
| Hasil | Ringkasan pencarian, Filter, kartu pengemudi/jalur/jam/kursi/ongkos; loading, kosong dan error/retry. |
| Filter | Jam, minimal kursi, batas ongkos; Terapkan/Atur Ulang, draft batal tidak mengubah hasil. |
| Detail | Profil publik pengemudi, peta jalur, alamat, jadwal, kursi/ongkos; pin jemput dan catatan sebelum permintaan. |
| Pesanan | Permintaan menunggu/diterima/ditolak/dibatalkan, detail status, pembatalan sesuai aturan; riwayat perjalanan. |
| Ongkos | Rincian, deklarasi telah membayar di luar app, menunggu konfirmasi penyedia/backend, riwayat ongkos. |
| Profil | Profil penumpang dan rekap; rating pengemudi dari perjalanan selesai. |

Target bottom navigation: **Cari · Pesanan · Ongkos · Profil**. Navigasi lengkap adalah target bersama, bukan empat fitur yang otomatis selesai pada sprint Mikail. Jangan membuat aksi kosong seolah berfungsi.

Visual mempertahankan tema coral/cloud/putih/hijau, Roboto, radius 20 dan token bersama. Susunan input mengikuti referensi pengguna, bukan warna lavender. Rail titik/garis, ikon kursi/jam/ongkos, alamat otomatis hasil pin, alias, dan swap koordinat dipertahankan. Tidak perlu mode teks/debug di UI produksi.

## 4. Usulan pembagian tim

| Anggota | Modul tetap | Tiga layar target yang diusulkan |
|---|---|---|
| Mikail | Rute & Tebengan, FR-01–04 | Cari Tebengan · Hasil Pencarian · Filter Pencarian |
| Taris | Pemesanan & Koordinasi, FR-05–08 | Pesanan Saya/Status Permintaan · Titik Jemput · Detail Pesanan |
| Shiddiq | Berbagi Ongkos, FR-09–12 | Rincian Ongkos · Status Pembayaran · Riwayat Ongkos |
| Duha | Reputasi & Riwayat, FR-13–16 | Riwayat Perjalanan · Beri Rating · Profil & Rekap |

Ini usulan; konfirmasikan batas Detail Tebengan/Detail Pesanan, integrasi komponen bersama dan endpoint dengan tim sebelum mengubah bagian rekan. Login/Detail Tebengan yang sudah ada tetap layar bersama. FR-17/18 lintas modul, bukan dianggap tuntas hanya karena Login lokal tersedia.

Shiddiq tetap membuat modul ongkos sisi penumpang, bukan role pengemudi: rincian biaya (FR-09), deklarasi sudah bayar (FR-10), tampilan konfirmasi backend (FR-11), dan riwayat biaya sendiri (FR-12). Tidak membutuhkan payment gateway; lihat [rincian pembagian Shiddiq](pembagian-tugas.md#apa-bagian-shiddiq-setelah-ui-pengemudi-dihapus). Konfirmasi otoritatif/rumus dan integrasi tetap perlu kesepakatan tim.

Untuk Mikail: FR-01 menjadi konsumsi daftar rute backend, bukan posting mobile. FR-02/03 tetap pencarian/filter/matcher. FR-04 menampilkan kuota backend dan menyembunyikan rute penuh; alokasi kursi adalah transaksi backend pada approval Modul 2.

## 5. Data dan keputusan backend

- Rute harus memuat ID, driver, nama/alamat/koordinat asal-tujuan, geometry jalan, jadwal, kapasitas/sisa kursi, ongkos/status.
- Fixture awal harus deterministik, memakai jalur jalan nyata yang disiapkan/disimpan, dan memiliki kasus searah, arah terbalik, penuh, serta tidak cocok. Sample lama tanpa geometry tidak muncul dalam pencarian koordinat; mengganti peran tanpa menyiapkan data ini akan membuat hasil demo kosong.
- Jangan mengganti geometry dengan garis lurus atau memanggil OSRM untuk semua seed setiap peluncuran aplikasi. Perhitungan jalur seed dilakukan saat persiapan/backend, bukan disembunyikan sebagai startup mobile.
- Keputusan booking, kuota, persistensi, pembatalan, konfirmasi pembayaran dan kelayakan rating adalah otoritas backend. Penumpang tidak dapat mengubahnya sendiri.
- Pending tidak mengurangi kursi. Approval idempotent, tidak melebihi kapasitas; pembatalan mengembalikan kursi hanya jika telah dialokasikan, sekali saja.
- Deklarasi penumpang “sudah bayar” bukan pelunasan terkonfirmasi. Pembayaran tetap di luar app.
- Seed saja belum cukup untuk menyelesaikan booking. Jika belum ada backend, nyatakan simulasi fixture/fake dengan jelas, jangan otomatis menerima request dan menyebutnya integrasi server.

Kontrak yang perlu disepakati: endpoint/auth, schema geometry/urutan lon-lat, status/jadwal perjalanan, arti kursi/fare, aturan cancel, rumus ongkos, notifikasi/sinkronisasi, akun seed dan mekanisme operator/admin. Nama endpoint dan status final belum ditetapkan.

## 6. Tahapan implementasi berikutnya

1. **Konfirmasi dependensi:** inventaris backend yang tersedia dan sepakati pembagian tim/kontrak. Ini tidak menghalangi perencanaan atau UI, tetapi integrasi tidak bisa dinyatakan selesai tanpa backend.
2. **Desain:** tiga layar Mikail serta feedback sudah selesai dan ditinjau, memakai token bersama dan komponen M1 di halaman 09. Prototype Cari → Hasil ↔ Filter tersedia. Pemilih Dari/Ke, hasil tempat, pin/konfirmasi/batal dan swap contoh sudah tersambung dengan 18 state tambahan; baca [rincian interaksi](../design/panduan-desain-figma.md#rincian-interaksi-darike-dan-pin--selesai-8-oktober-2026). Peta dan query bersifat simulasi tetap. Login/Detail dan bagian rekan belum direvisi; chip/reset/tab rekan masih visual, kartu belum tersambung ke shared Detail antarpages. Node aktif/arsip tercatat di JSON.
3. **Migrasi struktur/role Mikail selesai:** Home penumpang, Filter/peta/pin dipertahankan; driver tanpa akses UI/named route, source di legacy. MVVM feature-first dan repository sesi terinjeksi. Pemisahan Hasil dari Home serta port seluruh picker/state visual Figma masih pending.
4. **Data lokal tersedia:** adapter fixture immutable dengan geometry jalan nyata disimpan; UI menyatakan data latihan. Kontrak abstract baca siap diinjeksi, tetapi adapter API belum dibuat karena endpoint/auth belum disepakati. State/validasi/commands tetap ViewModel.
5. **Integrasi kelompok:** hubungkan permintaan/status/kuota, ongkos, riwayat/rating sesuai kontrak. Jangan memasukkan modul rekan secara sepihak ke sprint Mikail.
6. **Verifikasi:** format/analyzer/tests, tes named route driver terblokir, arah jalur, loading/kosong/error, filter/result, quota/idempotensi dan respons async lama; build dan uji HP/hot reload setelah izin pengguna.

Selain desain Mikail yang sudah selesai, tahapan ini tetap rencana, bukan bukti migrasi mobile/integrasi selesai. Saran effort: high untuk migrasi UI/workflow Mikail; xhigh bila tersedia untuk integrasi lintas modul/backend.

## 7. Demo UTS Mikail yang ditargetkan

Login → Cari Tebengan → pilih Dari/Ke melalui saran/pin → Filter → Terapkan → Hasil Pencarian → Detail.

Tunjukkan event/input, state ViewModel, validasi lokasi/ongkos, feedback invalid/loading/kosong/sukses, serta navigasi/result RideFilter/MapLocation/Ride. Ubah satu aturan/tampilan saat diminta dan jelaskan pemisahan View–ViewModel–repository. Tidak perlu menyiapkan jawaban khusus untuk pertanyaan spontan.

Workflow Catatan yang sudah ada tetap kandidat satu workflow UTS dari sisi penumpang. Posting Rute/Rute Saya adalah legacy dua role, bukan demo utama target baru. Kesiapan final memerlukan uji perangkat dan pemahaman kode; referensi [petunjuk UTS](../petunjuk-uts/petunjuk-uts.md).

## 8. Kriteria selesai migrasi

- UI dan semua jalur navigasi hanya penumpang, bukan sekadar menyembunyikan tombol driver.
- Alur Cari → Filter → Hasil → Detail berjalan dengan data yang cocok dan geometry valid; error/kosong/cancel/stale response aman.
- Token/UI peta/alamat konsisten antara Figma dan Flutter; desain baru benar-benar ditinjau.
- Integrasi server diuji atau batas simulasi dinyatakan eksplisit; tidak ada klaim backend/approval otomatis palsu.
- Tests/analyzer/build lulus pada source baru; workflow Android/hot reload diuji setelah izin.
- PRD, pembagian tugas, prompt, UTS dan PROGRESS mencerminkan status nyata. Commit/push hanya atas instruksi pengguna (sudah diminta untuk refactor ini); akses/uji HP tetap memerlukan izin tersendiri.
