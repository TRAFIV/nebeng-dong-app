# PRD — Nebeng Dong (Kelompok 4)

| Informasi | Nilai |
|---|---|
| Produk | Nebeng Dong: Aplikasi Pencari Tebengan Antar Mahasiswa |
| Mata kuliah | Mobile Programming |
| Versi aktif | 1.1 — aplikasi penumpang saja |
| Tanggal awal | 13 September 2026 |
| Revisi | 8 Oktober 2026 |
| Dasar perubahan | Masukan dosen pembimbing tentang satu role, disampaikan pengguna; revisi dokumentasi diminta pengguna |

| Anggota | NIM |
|---|---|
| Taris Rafivdean | 2411523013 |
| Mikail Samyth Habibillah | 2411523016 |
| M Shiddiq Maihendra | 2411523035 |
| Duha Alul Bariq | 2411523036 |

Dokumen ini menjelaskan target produk, bukan klaim fitur sudah selesai. Markdown versi 1.1 menjadi acuan aktif; PDF PRD tetap arsip versi 1.0 yang memuat dua role. Instruksi asli modul dan UTS tidak diubah.

## 0. Keputusan cakupan dan status

- Aplikasi Flutter saat ini ditargetkan hanya untuk penerima/pencari tebengan (penumpang). Tidak ada pemilih role, Beri Tebengan, Posting Rute, Rute Saya milik pengemudi, permintaan masuk/ACC, atau konfirmasi pembayaran oleh pengemudi di aplikasi ini.
- Pengemudi tetap entitas data penyedia tebengan. Backend/admin yang berwenang menyediakan rute dan melakukan tindakan sisi pengemudi; mekanisme seed/admin dan backend yang digunakan perlu dikonfirmasi bersama tim. Aplikasi pengemudi terpisah adalah pengembangan mendatang.
- Empat modul dan penanggung jawab tetap dipertahankan. Perubahan layar rinci adalah usulan koordinasi tim, bukan klaim persetujuan seluruh anggota.
- Dokumentasi direvisi; Figma bagian Mikail sudah diperbarui dan ditinjau pada 8 Oktober 2026: Cari Tebengan, Hasil Pencarian, Filter serta feedback loading/kosong/error. Source masih baseline dua intent; desain rekan dan layar bersama belum direvisi. Backend REST aplikasi belum tersedia di repo ini; backend di luar repo belum dikonfirmasi.
- Rencana migrasi dan kriteria penerimaan: [rencana aplikasi penumpang](../progress/rencana-aplikasi-penumpang.md). Status aktual: [PROGRESS](../progress/PROGRESS.md).

## 1. Problem & Users

### 1.1 Problem Statement

Mahasiswa yang menempuh jalur dan jam yang sama sering berangkat sendiri-sendiri. Mahasiswa tanpa kendaraan sulit menemukan tumpangan aman yang benar-benar searah, sementara biaya perjalanan dan pembagian ongkos belum tercatat dengan jelas.

### 1.2 Target Users

Pengguna aplikasi mobile adalah mahasiswa aktif yang mencari dan menerima tebengan. Mahasiswa pemilik kendaraan adalah penyedia dalam data sistem, bukan role yang dipilih pada aplikasi mobile ini. Operator backend/admin memiliki kewenangan tersendiri di luar UI penumpang.

### 1.3 User Needs

Penumpang perlu mencari lokasi asal/tujuan berdasarkan nama tempat atau pin, memilih tebengan searah sesuai jam/kursi/ongkos, menentukan titik jemput, mengikuti status pemesanan, mencatat pembayaran di luar aplikasi, dan melihat riwayat serta reputasi pengemudi.

### 1.4 Project Goal

Memudahkan mahasiswa memperoleh tebengan searah dengan informasi penyedia yang jelas, koordinasi pemesanan, serta pencatatan biaya dan riwayat perjalanan yang transparan.

## 2. Product Requirements

### 2.1 Functional Requirements

Kode FR-01–FR-18 dipertahankan untuk keterlacakan versi 1.0; cakupan aktor dan perilakunya direvisi. Semua baris adalah target, bukan status implementasi.

#### Modul 1 — Rute & Tebengan (Mikail)

| Kode | Kebutuhan yang dapat diuji |
|---|---|
| FR-01 | Penumpang dapat melihat tebengan yang disediakan backend, berisi pengemudi, asal/tujuan beserta koordinat dan alamat, geometry jalur jalan, jadwal, kapasitas/sisa kursi, serta informasi ongkos. Posting/edit/hapus rute dilakukan di sisi backend/admin, bukan aplikasi penumpang. |
| FR-02 | Penumpang dapat mencari berdasarkan asal/tujuan melalui saran nama tempat atau pin peta, dan menyaring hasil berdasarkan jam, jumlah kursi tersedia, serta batas ongkos. |
| FR-03 | Sistem mencocokkan asal dan tujuan penumpang dengan jalur tebengan yang searah; posisi jemput harus sebelum posisi turun sepanjang jalur. Geometry jalan valid wajib tersedia pada rute yang dicocokkan secara geografis. Heuristik koridor lokal tidak boleh diklaim sebagai perhitungan detour atau akses berjalan kaki sebenarnya. |
| FR-04 | Backend mengalokasikan kursi saat booking disetujui dan menutup tebengan penuh. Permintaan pending belum mengurangi kursi. Approval harus idempotent, tidak overbooking, dan hasil kuota backend menjadi acuan aplikasi. |

#### Modul 2 — Pemesanan & Koordinasi (Taris)

| Kode | Kebutuhan yang dapat diuji |
|---|---|
| FR-05 | Penumpang dapat mengajukan permintaan, lalu melihat status menunggu, diterima atau ditolak. Keputusan dilakukan oleh backend/admin berwenang yang mewakili penyedia, bukan tombol ACC penumpang dan bukan otomatis diterima setelah submit. |
| FR-06 | Penumpang dapat menentukan dan menyimpan titik jemput yang berada di sepanjang/dekat jalur tebengan, beserta koordinat, alamat dan catatan. Pin pencarian belum menjadi booking sampai permintaan dikirim. |
| FR-07 | Status permintaan diperbarui dari backend ke aplikasi penumpang tanpa mewajibkan aplikasi pengemudi kedua. Metode sinkronisasi disepakati tim; tampilkan loading/error/retry tanpa mengarang keberhasilan sinkronisasi. |
| FR-08 | Penumpang dapat membatalkan sesuai kebijakan status; pembatalan dari penyedia/backend juga terlihat. Backend memberi pemberitahuan dan mengembalikan kursi hanya jika sebelumnya dialokasikan, paling banyak sekali. Kebijakan waktu/status pembatalan perlu disepakati. |

#### Modul 3 — Berbagi Ongkos (Shiddiq)

| Kode | Kebutuhan yang dapat diuji |
|---|---|
| FR-09 | Penumpang dapat melihat pembagian biaya dari perhitungan Modul 3/backend. Rumus perlu disepakati; bedakan estimasi dengan ongkos final dan jangan menganggap ongkos belum diatur sebagai gratis. |
| FR-10 | Penumpang dapat mencatat bahwa ia telah membayar di luar aplikasi. Deklarasi ini bukan otomatis konfirmasi pelunasan oleh penyedia. |
| FR-11 | Penumpang dapat melihat konfirmasi pembayaran dari backend/admin yang berwenang mewakili penyedia. Dua pihak tercatat di sistem, tetapi UI mobile tetap hanya penumpang. |
| FR-12 | Penumpang dapat melihat riwayat ongkosnya per perjalanan, bukan mengelola pembayaran seluruh penumpang sebagai pengemudi. |

#### Modul 4 — Reputasi & Riwayat (Duha)

| Kode | Kebutuhan yang dapat diuji |
|---|---|
| FR-13 | Penumpang dapat memberi rating pengemudi setelah perjalanan yang diikutinya selesai; backend memvalidasi kelayakan dan mencegah rating ganda. Rating pengemudi terhadap penumpang ditunda ke pengembangan mendatang. |
| FR-14 | Penumpang dapat melihat riwayat perjalanan yang diikutinya, bukan riwayat rute yang ia tawarkan. |
| FR-15 | Penumpang dapat melihat rekap perjalanan dan ongkos pribadi. |
| FR-16 | Sistem dapat memberikan ringkasan berkala kepada penumpang sesuai data perjalanan. Mekanisme notifikasi disepakati tim; fitur belum diklaim tersedia. |

#### Registrasi & keamanan — lintas modul

| Kode | Kebutuhan yang dapat diuji |
|---|---|
| FR-17 | Mahasiswa dapat mendaftar/masuk dengan email kampus yang diverifikasi backend, tanpa memilih role pengemudi. Domain kampus perlu dikonfirmasi; validasi format lokal bukan verifikasi kepemilikan email atau autentikasi server. |
| FR-18 | Penumpang melihat nama/profil publik pengemudi yang relevan, bukan email atau data privatnya. Backend membatasi akses booking, ongkos, riwayat dan rating sesuai akun; menyembunyikan tombol bukan otorisasi. |

### 2.2 Non-Functional Requirements

| Kode | Target |
|---|---|
| NFR-01 | Pencarian merespons dalam waktu wajar; target awal 3 detik perlu diukur dalam kondisi uji yang disepakati, bukan jaminan layanan peta publik. |
| NFR-02 | UI satu role mudah dipahami, responsif, dan memiliki state loading, kosong, error/retry, serta sukses yang jelas. |
| NFR-03 | Target utama Android dengan Flutter. |
| NFR-04 | Autentikasi/penyimpanan password ditangani backend secara aman; password tidak disimpan plaintext dalam aplikasi atau log. |
| NFR-05 | Lokasi dipakai hanya untuk pencarian/jemput yang diperlukan; pemilihan pin manual tetap tersedia. Tidak ada kewajiban pelacakan terus-menerus. |
| NFR-06 | Kewenangan backend/admin terpisah dari penumpang; data pribadi dan transaksi hanya dapat diakses pihak berwenang. |

### 2.3 Core Features

1. Pencarian dan pencocokan tebengan searah.
2. Pemesanan, titik jemput, status dan pembatalan dari sisi penumpang.
3. Pembagian serta pencatatan ongkos, bukan pemrosesan pembayaran.
4. Rating pengemudi, riwayat dan rekap penumpang.

### 2.4 User Flow dan UI

Login → Dari/Ke (saran tempat atau pin) → cari/filter → hasil searah → Detail Tebengan → titik jemput/catatan → kirim permintaan → menunggu keputusan backend → status perjalanan → ongkos → rating/riwayat.

Target navigasi bawah: **Cari · Pesanan · Ongkos · Profil**; riwayat perjalanan berada di Pesanan, rekap pada Profil. Menu yang belum terimplementasi tidak dibuat seolah sudah berfungsi. Tidak ada role switch atau CTA pengemudi.

Di luar aplikasi: backend/admin menyediakan rute, menentukan keputusan permintaan, mengelola status perjalanan/kuota dan mengonfirmasi pembayaran. Seed rute tidak sama dengan implementasi approval/sinkronisasi backend.

### 2.5 Data Entities

| Entitas | Tanggung jawab data |
|---|---|
| User | Akun penumpang, identitas publik dan kredensial yang dikelola backend. |
| Driver | Profil publik penyedia, kendaraan dan reputasi; bukan role mobile aktif. |
| Route | ID pengemudi, asal/tujuan, nama/alamat/koordinat, geometry jalan, jadwal, kapasitas/sisa kursi, status dan informasi ongkos. |
| Booking | Route, penumpang, titik jemput/koordinat/alamat, catatan, status dan waktu permintaan/keputusan/pembatalan. |
| Trip | Perjalanan aktual beserta tanggal, peserta dan status selesai; dibedakan dari rute rutin. |
| CostShare | Bagian ongkos penumpang, deklarasi pembayaran dan konfirmasi penyedia/backend yang terpisah. |
| Rating | Penumpang penilai, pengemudi, perjalanan selesai, nilai dan ulasan. |

Skema/endpoint final perlu disepakati tim. Geometry seed harus jalur jalan nyata yang sudah disiapkan dan disimpan; jangan menggantinya dengan garis lurus atau menghitung semua contoh melalui OSRM setiap aplikasi dibuka. Contoh tanpa geometry tidak valid untuk demo pencarian koordinat.

### 2.6 Constraints & Dependencies

- Flutter Android memakai MVVM yang sudah ada; tidak menambah framework atau aplikasi pengemudi dalam revisi ini.
- Backend REST aplikasi adalah target integrasi, belum tersedia di repo. Kepastian backend eksternal, akun/admin, endpoint, status, persistensi dan cara sinkronisasi perlu dikonfirmasi.
- Sampai integrasi tersedia, fixture/fake harus jelas sebagai simulasi, deterministik, dan tidak disebut server sungguhan atau siap produksi.
- Peta tetap OpenStreetMap, pencarian/alamat Photon, jalur OSRM sesuai [panduan peta](../progress/peta-dan-lokasi.md). Layanan publik bukan jaminan gratis tanpa batas; perlu internet, atribusi dan pembatasan penggunaan.
- Pembayaran berlangsung di luar aplikasi. Rumus ongkos, kebijakan pembatalan dan protokol konfirmasi belum final.
- GPS lokasi saat ini dapat dibahas kemudian; live tracking dan navigasi belok-per-belok bukan kewajiban Modul 1.

## 3. Scope

### 3.1 In Scope

Aplikasi penumpang: masuk, cari/filter tebengan, detail penyedia/rute/kursi/ongkos, pin jemput, permintaan/status/pembatalan, riwayat ongkos, rating dan rekap. Integrasi backend diperlukan agar target booking/kuota/status/pembayaran konsisten; bukan berarti integrasinya sudah dibuat.

### 3.2 Out of Scope

Role dan UI pengemudi pada aplikasi ini; aplikasi pengemudi terpisah; dashboard admin baru tanpa instruksi; payment gateway; verifikasi KTP; pengguna nonmahasiswa; live tracking dan navigasi belok-per-belok. Backend/admin harus tetap menyediakan tindakan penyedia, tetapi pembangunan UI admin baru tidak otomatis diizinkan.

## 4. Acceptance Criteria

- Pencarian lokasi/filter valid menghasilkan rute bergeometri yang searah; arah terbalik, rute penuh dan ongkos belum diatur ditangani sesuai aturan.
- Tidak ada fitur pengemudi yang bisa diakses lewat UI maupun named route aplikasi penumpang.
- Pengiriman request tidak otomatis menjadi diterima atau mengurangi kursi. Keputusan, persistensi dan kuota berasal dari backend, atau dilabeli simulasi secara jujur bila integrasi belum tersedia.
- Approval dan pembatalan aman dari callback ganda/overbooking; kuota mutakhir konsisten setelah sinkronisasi.
- Deklarasi pembayaran dibedakan dari pelunasan terkonfirmasi; rating hanya untuk perjalanan milik penumpang yang selesai.
- Satu workflow UTS dapat didemokan dan dijelaskan dengan input/event, state, validasi, feedback, navigasi/result. Kesiapan ujian tidak sama dengan kelengkapan semua FR.

## 5. Acuan AI dan riwayat revisi

Baca versi Markdown, [panduan desain](../design/panduan-desain-figma.md), [MVVM](../architecture/mvvm.md), dan [rencana migrasi](../progress/rencana-aplikasi-penumpang.md). Perubahan dokumentasi tidak memberi izin otomatis mengubah source, Figma, backend atau HP.

| Versi | Tanggal | Perubahan |
|---|---|---|
| 1.0 | 13 September 2026 | PRD asli dua role; PDF dipertahankan sebagai arsip. |
| 1.1 | 8 Oktober 2026 | Target mobile penumpang saja; tindakan pengemudi dialihkan ke backend/admin, FR-01–FR-18 dan UI diselaraskan. Dokumen bukan bukti implementasi. |
