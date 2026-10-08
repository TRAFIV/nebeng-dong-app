# Pembagian Tugas — Nebeng Dong

Revisi 8 Oktober 2026 mengikuti [PRD 1.1](../prd/prd-nebeng-dong-kel-4.md): aplikasi mobile hanya penumpang. Satu modul per anggota tetap; **layar berikut adalah usulan yang perlu dikonfirmasi tim**, bukan klaim rekan sudah menyetujui atau mengimplementasikannya.

| Modul | Anggota | NIM | Requirement | Tiga layar target yang diusulkan |
|---|---|---|---|---|
| 1 — Rute & Tebengan | Mikail Samyth Habibillah | 2411523016 | FR-01–FR-04 | Cari Tebengan · Hasil Pencarian · Filter Pencarian |
| 2 — Pemesanan & Koordinasi | Taris Rafivdean | 2411523013 | FR-05–FR-08 | Pesanan Saya/Status Permintaan · Titik Jemput · Detail Pesanan |
| 3 — Berbagi Ongkos | M Shiddiq Maihendra | 2411523035 | FR-09–FR-12 | Rincian Ongkos · Status Pembayaran · Riwayat Ongkos |
| 4 — Reputasi & Riwayat | Duha Alul Bariq | 2411523036 | FR-13–FR-16 | Riwayat Perjalanan · Beri Rating · Profil & Rekap |

Login dan Detail Tebengan yang sudah ada menjadi layar bersama; sepakati batas Detail Tebengan dengan Detail Pesanan dan alur submit/jemput bersama Taris. FR-17/18 lintas modul; Login lokal belum berarti autentikasi/verifikasi email atau keamanan backend selesai.

Mikail mengonsumsi daftar rute backend dan menampilkan kuota; bukan lagi membuat/mengelola rute pengemudi. Taris menangani permintaan/status penumpang; keputusan ACC ada di backend/admin. Shiddiq memisahkan deklarasi pembayaran penumpang dari konfirmasi backend. Duha menangani rating pengemudi dari penumpang dan riwayat pribadinya.

## Status desain dan implementasi

Figma: https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum.
Bagian Mikail pada `08 Tugas Tim` sudah direvisi: [Cari Tebengan · Hasil Pencarian · Filter](https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum?node-id=124-239) (`124:240`/`124:241`/`124:242`), dengan state loading/kosong/error di `130:402` dan prototype utama tersambung. Frame pengemudi asli disimpan di arsip `124:238`, tidak dihapus. Komponen M1 ada di halaman 09. Rincian [pemilih Dari/Ke dan pin](https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum?node-id=148-474) menambah 18 state pendukung dengan contoh aksi hasil tempat, alamat pin, konfirmasi, batal dan swap; tiga layar utama tetap.

Bagian Taris/Shiddiq/Duha serta layar bersama tidak diubah dan masih baseline; frame Permintaan Masuk/Konfirmasi Pelunasan lama bukan target UI penumpang. **Desain Mikail selesai; source kini feature-first MVVM penumpang dan driver legacy diblokir.** `features/ride_search` milik Mikail; `booking` memuat Catatan baseline, `costs`/`reputation` baru README batas tugas, bukan fitur rekan selesai. Detail tetap shared. Hasil masih di Home; pemisahan layar/port seluruh Figma belum dilakukan. Pembagian/integrasi rekan tetap perlu koordinasi.

## Apa bagian Taris setelah UI pengemudi dihapus?

**Modul 2 — Pemesanan & Koordinasi (FR-05–FR-08) tetap milik Taris.** Alur lama Permintaan Masuk/ACC berorientasi pengemudi; target baru adalah penumpang yang mengajukan dan memantau pesanannya sendiri.

| Layar yang diusulkan | Tugas penumpang | Requirement |
|---|---|---|
| Pesanan Saya/Status Permintaan | Daftar permintaan milik akun sendiri; lihat menunggu, diterima atau ditolak dari backend, dengan loading/kosong/error/retry. | FR-05, FR-07 |
| Titik Jemput | Pilih pin di dekat/sepanjang jalur tebengan, tampilkan dan simpan koordinat, alamat lengkap dan catatan; validasi sebelum mengirim permintaan. | FR-06 |
| Detail Pesanan | Lihat perjalanan, titik jemput dan status; batalkan jika diizinkan kebijakan backend dan tampilkan pembatalan dari penyedia. | FR-08 |

Contoh alur integrasi: hasil pencarian Mikail → Detail Tebengan bersama → pilih titik jemput → kirim permintaan → status menunggu → keputusan backend/admin terlihat di Pesanan Saya. Pin Dari pada pencarian adalah preferensi lokasi; belum otomatis menjadi titik jemput booking tersimpan atau pesanan terkirim.

Batas: **tidak ada tombol ACC/Tolak milik pengemudi dalam aplikasi penumpang**. Backend/admin mengesahkan keputusan dan perubahan kursi; pending tidak mengurangi kuota. Taris menyiapkan UI, model/state, ViewModel, validasi, adapter dan tes pemesanan, bukan diwajibkan membuat aplikasi pengemudi kedua. Metode sinkronisasi, kebijakan pembatalan dan batas Detail Tebengan/Detail Pesanan perlu disepakati tim/backend.

Source `features/booking` sekarang hanya memuat Catatan baseline dan README batas modul; tiga layar serta integrasi backend belum selesai. Figma Taris masih desain lama dan tidak diubah dalam refactor Mikail. Usulan ini perlu persetujuan Taris/tim sebelum implementasi atau revisi desain bagiannya.

## Apa bagian Shiddiq setelah UI pengemudi dihapus?

**Modul 3 — Berbagi Ongkos (FR-09–FR-12) tetap milik Shiddiq.** Yang dihapus adalah UI/role pengemudi pada aplikasi ini, bukan modul biaya atau data pengemudi.

| Layar yang diusulkan | Tugas penumpang | Requirement |
|---|---|---|
| Rincian Ongkos | Lihat perjalanan, dasar pembagian dan bagian ongkos sendiri; bedakan estimasi/final serta ongkos belum diatur. Rumus biaya disepakati tim/backend. | FR-09 |
| Status Pembayaran | Lihat belum dilaporkan/menunggu konfirmasi/terkonfirmasi; tombol “Sudah bayar” mencatat deklarasi pembayaran **di luar app**, lalu menampilkan keputusan backend/admin. Nama status final mengikuti kontrak. | FR-10, FR-11 |
| Riwayat Ongkos | Lihat daftar/detail biaya dan status pembayaran per perjalanan milik akun penumpang; bukan daftar tagihan semua penumpang milik driver. | FR-12 |

Contoh demo: buka Rincian Ongkos dari perjalanan → tekan “Sudah bayar” → tampil menunggu konfirmasi → backend/admin mengonfirmasi → status dan riwayat penumpang diperbarui. Jika backend belum tersedia, perubahan konfirmasi hanya fixture/fake yang dijelaskan, bukan aksi penumpang untuk mengesahkan pembayaran sendiri.

Batas: tidak membuat Posting Rute, ACC pesanan, layar driver Konfirmasi Pelunasan, payment gateway, atau dashboard admin. Shiddiq dapat menyiapkan model ongkos, ViewModel/state/validasi, tiga UI, adapter kontrak dan tesnya; konfirmasi otoritatif tetap backend. Daftar riwayat biaya Modul 3 berbeda dari rekap agregat pribadi Modul 4 (Duha); sepakati integrasinya.

Pembagian rinci ini **usulan PRD 1.1, belum persetujuan akhir tim**. Bagian Figma Shiddiq tidak diubah pada revisi Mikail; desain lama perlu disesuaikan oleh/bersama pemilik modul.

## Aturan desain bersama

1. Pakai komponen yang sudah ada: halaman `03 Button`, `04 Input`, `05 Ride Card`, `06 Bottom Navigation`,
   dan `09 Komponen Tambahan` (Avatar, Badge, Info Tile, Top Bar, Section Header).
   Komponen baru dibuat di halaman `09` supaya bisa dipakai bersama.
2. Pakai variabel warna/spacing dan text style yang sudah ada — jangan mengetik warna manual.
3. Contoh jadi ada di halaman `07 Product Screens` (Login, Beranda, Detail Tebengan).
4. Ukuran frame 360 × 800; padding tepi 16; jarak antar-bagian 24; tinggi tombol/input 48.
5. Gaya bahasa santai, misalnya "Gas Masuk!", "Cariin Tebengan!", "Ikut Nebeng!".
6. Butuh komponen baru? Buat di halaman `09 Komponen Tambahan` lalu kabari di grup supaya tidak dobel.
7. Tiap blok anggota berupa **Section**, jadi frame layarnya bisa langsung disambung prototype (tab Prototype).

Detail token dan struktur Auto Layout ada di [panduan desain](../design/panduan-desain-figma.md).

## Batas peta dan lokasi perjalanan

Modul 1 menangani lokasi asal/tujuan, pencarian/pencocokan rute backend dan tampilan kuota. Saran tempat/pin manual dan alamat otomatis dipertahankan. Data rute perlu geometry jalan valid agar pencarian koordinat tidak kosong; detail [rencana migrasi](rencana-aplikasi-penumpang.md).

GPS lokasi saat ini tidak diwajibkan eksplisit oleh FR-01–04. Live tracking belum dibagi dalam PRD; jangan otomatis menugaskannya ke Mikail/rekan. Sinkronisasi permintaan/titik jemput Modul 2 bukan pelacakan perjalanan. Navigasi belok-per-belok di luar cakupan; NFR-05 membatasi pelacakan yang tidak diperlukan.

## Pelaksanaan berikutnya

Konfirmasikan usulan dan integrasi shared Detail dengan tim/backend. Desain Mikail sudah tersedia dan struktur/role Flutter sudah dimigrasikan; port seluruh layar Figma, integrasi modul dan revisi desain bagian rekan dilakukan setelah instruksi yang sesuai. Gunakan [prompt UI](../prompts/prompt-implementasi-ui-flutter.md) bagian B dan catat hasil nyata di [PROGRESS](PROGRESS.md). Refactor tidak mengimplementasikan modul rekan/backend dan tidak menggunakan HP.
