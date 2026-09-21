# PRD_Nebeng Dong_Kel 4

## Halaman 1

PROJECT PRD
Product Requirements Document

Project Name Nebeng Dong: Aplikasi Nebeng & Berbagi Tebengan Antar Mahasiswa

Team • Taris Rafivdean (2411523013)
• Mikail Samyth Habibillah (2411523016)
• M Shiddiq Maihendra (2411523035)
• Duha Alul Bariq (2411523036)

Course Mobile Programming

Version 1.0

Date 13 – 09 - 2026

Tujuan Dokumen
PRD ini menjelaskan apa yang akan dibangun, untuk siapa, mengapa produk dibutuhkan, dan kebutuhan
utama produk. PRD tidak menjelaskan detail implementasi kode.

1. Problem & Users

1.1 Problem Statement
Mahasiswa yang tinggal berjauhan dari kampus sering menempuh rute yang sama pada jam yang sama,
namun berangkat sendiri-sendiri. Akibatnya biaya transportasi membengkak bagi yang berkendara,
sementara mahasiswa tanpa kendaraan kesulitan mencari tumpangan yang aman dan searah.

1.2 Target Users
Mahasiswa aktif yang rutin bepergian ke dan dari kampus, terbagi dalam dua peran yang dapat dijalankan
oleh orang yang sama pada waktu berbeda:

● Pemberi tebengan: mahasiswa yang memiliki kendaraan dan memiliki rute perjalanan rutin ke
kampus.
● Pencari tebengan: mahasiswa yang tidak memiliki kendaraan atau ingin menghemat biaya dengan
menumpang di rute yang searah.

1.3 User Needs / Pain Points
● Biaya transportasi harian (bensin, ojek daring, angkutan umum) terasa berat bagi kantong
mahasiswa.
● Sulit menemukan orang yang benar-benar searah, bukan sekadar bertujuan sama tetapi melewati
jalur berbeda.
● Kekhawatiran soal keamanan ketika menumpang atau memberi tumpangan kepada orang yang
tidak dikenal.
● Pembagian biaya perjalanan sering tidak tercatat dan mengandalkan ingatan, sehingga rawan
menimbulkan kecanggungan.

1.4 Project Goal
Menyediakan aplikasi yang mempertemukan mahasiswa dengan rute perjalanan searah agar dapat berbagi
tumpangan secara aman dan hemat, sekaligus mencatat pembagian biaya perjalanan secara transparan.

## Halaman 2

2. Product Requirements

2.1 Functional Requirements
Ditulis dari sudut pandang pengguna dan dapat diuji. Dikelompokkan mengikuti empat modul aplikasi (satu
modul per anggota tim, sesuai aturan project).

Modul 1 — Rute & Tebengan

Kode Functional Requirement

FR-01 Pemberi tebengan dapat memposting rute rutin berisi titik asal, tujuan, jam berangkat, dan
jumlah kursi tersedia.

FR-02 Pencari dapat mencari tebengan berdasarkan lokasi asal dan tujuannya.

FR-03 Sistem dapat mencocokkan rute pencari dengan rute yang diposting dan menandai tebengan
yang searah, bukan sekadar bertujuan sama.

FR-04 Sistem dapat mengurangi kuota kursi otomatis saat ada yang bergabung dan menutup
tebengan ketika kursi penuh.

Modul 2 — Pemesanan & Koordinasi

Kode Functional Requirement

FR-05 Pencari dapat mengajukan permintaan bergabung ke sebuah tebengan, dan pemberi dapat
menyetujui atau menolaknya.

FR-06 Pencari dapat menandai titik jemput yang diinginkan di sepanjang rute.

FR-07 Sistem dapat menyinkronkan status permintaan antar-perangkat sehingga pencari dan
pemberi melihat pembaruan tanpa memuat ulang manual.

FR-08 Salah satu pihak dapat membatalkan, dan sistem mengembalikan kuota kursi serta memberi
tahu pihak lain.

Modul 3 — Berbagi Ongkos

Kode Functional Requirement

FR-09 Sistem dapat menghitung pembagian biaya perjalanan kepada penumpang yang bergabung.

FR-10 Pengguna dapat mencatat status pembayaran ongkos (sudah/belum) per perjalanan.

FR-11 Kedua pihak dapat mengonfirmasi pelunasan ongkos secara dua arah.

FR-12 Pengguna dapat melihat riwayat pembagian ongkos per perjalanan.

Modul 4 — Reputasi & Riwayat

Kode Functional Requirement

FR-13 Pengguna dapat memberi penilaian (rating) dua arah setelah perjalanan selesai.

FR-14 Pengguna dapat melihat riwayat perjalanan yang pernah diikuti atau diberikan.

FR-15 Sistem dapat menampilkan rekap aktivitas pengguna (jumlah perjalanan dan ongkos yang
dibagi).

FR-16 Sistem dapat menyusun ringkasan periodik dan mengirimkannya sebagai notifikasi.

## Halaman 3

Registrasi & Keamanan (berlaku lintas modul)

Kode Functional Requirement

FR-17 Pengguna hanya dapat mendaftar menggunakan email berdomain kampus, dan wajib
melakukan verifikasi email sebelum akun aktif.

FR-18 Sistem menampilkan nama pengguna kepada pengguna lain, tetapi tidak menampilkan
email atau data pribadi lain tanpa otorisasi.

2.2 Non-functional Requirements

Kode Non-functional Requirement

NFR-01 Hasil pencocokan rute dapat ditampilkan dalam waktu wajar pada kondisi jaringan normal.
(Angka target = ≤3 detik (belum pasti))

NFR-02 Antarmuka dapat digunakan dengan mudah oleh mahasiswa tanpa panduan khusus.

NFR-03 Aplikasi dapat berjalan pada perangkat Android yang ditentukan tim.

NFR-04 Kata sandi disimpan dalam bentuk ter-hash, tidak dalam teks polos.

NFR-05 Data lokasi hanya diambil saat dibutuhkan untuk pencocokan/perjalanan, tidak dilacak
terus-menerus.

NFR-06 Data pengguna tidak ditampilkan kepada pengguna lain tanpa otorisasi.

2.3 Core Features
Empat fitur inti selaras dengan empat modul di atas.

No. Core Feature Purpose / Value

1 Rute & Tebengan Mempertemukan pengguna melalui pencocokan rute yang
benar-benar searah, bukan sekadar tujuan sama.

2 Pemesanan & Koordinasi Mengatur permintaan gabung, titik jemput, dan sinkronisasi
status antar-perangkat secara langsung.

3 Berbagi Ongkos Mencatat dan membagi biaya perjalanan secara transparan
sehingga tidak lagi mengandalkan ingatan.

4 Reputasi & Riwayat Membangun rasa aman melalui rating dua arah serta
menyediakan riwayat dan rekap perjalanan.

2.4 User Flow
Alur utama pencari tebengan:

Buka aplikasi → Masuk (email kampus) → Masukkan tujuan → Lihat tebengan searah → Ajukan gabung
& tandai titik jemput → Menunggu konfirmasi pemberi → Perjalanan berlangsung → Catat & lunasi
ongkos → Beri rating.

Alur utama pemberi tebengan:

Buka aplikasi → Masuk → Posting rute rutin & kuota kursi → Terima permintaan gabung → Setujui
penumpang → Perjalanan berlangsung → Terima konfirmasi ongkos → Beri rating.

2.5 Data Requirements

Data / Entity Key Information Purpose

User id, nama, email kampus, status verifikasi, Identitas pengguna dan dasar
rating rata-rata verifikasi serta reputasi.

## Halaman 4

Data / Entity Key Information Purpose

Route (Tebengan) id, pemberi, titik asal, titik tujuan, jalur, jam, Menyimpan tebengan yang
kuota kursi diposting untuk dicocokkan.

Booking id, route, pencari, titik jemput, status Mencatat permintaan gabung dan
statusnya.

Trip id, route, tanggal, daftar penumpang, status Merepresentasikan perjalanan yang
selesai benar-benar berlangsung.

CostShare id, trip, pengguna, nominal bagian, status Mencatat pembagian dan pelunasan
bayar ongkos per orang.

Rating id, trip, penilai, dinilai, skor Menyimpan penilaian dua arah
untuk reputasi.

2.6 Constraints & Assumptions
● Platform Android, dibangun dengan Flutter.
● Data disimpan pada server sendiri (REST API)
● Aplikasi tidak memproses pembayaran; perpindahan uang dilakukan di luar aplikasi dan hanya
dicatat statusnya.
● Verifikasi terbatas pada kepemilikan email kampus; tidak menjamin status keaktifan mahasiswa
maupun kecocokan identitas.
● Asumsi: pengguna memiliki koneksi internet saat mencari/memesan tebengan, dan mengaktifkan
izin lokasi saat dibutuhkan.

2.7 Success Criteria
● Pencari dapat menemukan tebengan searah dan menyelesaikan permintaan gabung hingga
dikonfirmasi.
● Status permintaan tersinkron dan terlihat benar pada dua perangkat berbeda.
● Pembagian ongkos suatu perjalanan tercatat dan dapat dikonfirmasi lunas oleh kedua pihak.

3. Scope

3.1 In Scope
● Pencocokan rute searah berbasis lokasi.
● Permintaan gabung, titik jemput, dan sinkronisasi status antar-perangkat.
● Pencatatan dan pembagian ongkos perjalanan.
● Rating dua arah, riwayat, dan rekap perjalanan.
● Registrasi dengan email kampus dan verifikasi email.

3.2 Out of Scope
● Pemrosesan pembayaran di dalam aplikasi (transfer dilakukan di luar aplikasi).
● Verifikasi identitas tingkat lanjut (KTP, KTM, atau pengecekan ke basis data kampus).
● Navigasi belok-per-belok seperti aplikasi peta khusus.
● Penggunaan oleh non-mahasiswa / masyarakat umum (menjadi potensi pengembangan lanjutan).

4. AI Prompt Context

## Halaman 5

Nebeng Dong adalah aplikasi mobile (Flutter, Android) untuk mahasiswa yang mempertemukan pengguna
dengan rute perjalanan searah agar dapat berbagi tumpangan secara aman dan hemat. Target pengguna adalah
mahasiswa aktif dengan dua peran: pemberi dan pencari tebengan. Tujuannya menghemat biaya transportasi,
mempermudah menemukan tumpangan yang benar-benar searah, serta mencatat pembagian ongkos secara
transparan.

Fitur inti: (1) pencocokan rute searah, (2) pemesanan dan koordinasi antar-perangkat, (3) berbagi ongkos, (4)
reputasi dan riwayat. Batasan: backend dibangun sendiri tanpa layanan siap pakai, aplikasi tidak memproses
pembayaran, dan verifikasi hanya melalui email kampus. Bantuan AI diminta untuk hal-hal seperti
perancangan struktur data, logika pencocokan rute, dan penulisan kode modul — dengan pemahaman bahwa
setiap anggota wajib dapat menjelaskan kodenya sendiri.

☑ Problem statement jelas dan berfokus pada pengguna.

☑ Target users spesifik.

☑ Project goal menjawab masalah yang diidentifikasi.

☑ Core features berjumlah sekitar 4–6 dan relevan.

☑ User flow utama sudah dituliskan.

☑ Data utama sudah diidentifikasi.

☑ Constraints dan assumptions sudah dicatat.

☑ Success criteria dapat digunakan untuk menilai hasil project.

☑ In Scope dan Out of Scope sudah jelas.

☑ Functional requirements menjelaskan perilaku/fungsi yang harus dilakukan aplikasi.

☑ Non-functional requirements menjelaskan kualitas atau batasan sistem dan, jika memungkinkan, dapat diukur.

☑ Functional requirements konsisten dengan core features.

☑ Non-functional requirements tidak ditulis sebagai fitur baru.
