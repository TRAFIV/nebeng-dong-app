# Prompt Implementasi UI Flutter — Nebeng Dong

Revisi 8 Oktober 2026. Bagian A adalah kerangka asli modul, dipertahankan tanpa perubahan. Bagian B adalah prompt target PRD 1.1 penumpang saja, bukan izin otomatis mengimplementasikan semua modul. Bagian C mencatat baseline kode yang belum dimigrasikan ke satu role.

Di Claude Code dapat mengikuti prompt B langsung atau memakai [flutter-ui-implementer](../../.claude/agents/flutter-ui-implementer.md) sesuai aturan lingkungan yang berlaku.

## A. Kerangka prompt (dari modul)

```text
Kamu adalah AI coding assistant yang bertugas mengimplementasikan UI Flutter berdasarkan PRD (Product Requirements Document) dan desain Figma yang saya lampirkan.

## KONTEKS PROJECT
- Nama project: [ISI NAMA PROJECT]
- Platform target: Flutter (Android [& iOS jika perlu])
- State management: [Provider / Riverpod / Bloc / GetX — sesuaikan]
- Struktur folder saat ini: [tempel struktur folder project, misal lib/screens, lib/widgets, lib/models]

## SUMBER DESAIN
1. PRD: [lampirkan/tempel isi PRD atau ringkasannya — fitur, flow, requirement fungsional]
2. Figma: [tempel link Figma / lampirkan screenshot frame / export design tokens (warna, spacing, typography)]

## TUGAS
Implementasikan screen/komponen berikut sesuai desain Figma dan requirement di PRD:
- [Nama screen 1, misal: "Login Screen"]
- [Nama screen 2, misal: "Dashboard"]

## KETENTUAN TEKNIS
1. Gunakan widget Flutter native (Material) kecuali desain secara eksplisit butuh custom widget
2. Ekstrak design token dari Figma menjadi:
   - Color palette → `lib/theme/app_colors.dart`
   - Typography → `lib/theme/app_text_styles.dart`
   - Spacing/sizing konsisten (gunakan konstanta, jangan hardcode angka di widget)
3. Pisahkan UI (widget) dari logic (gunakan [state management pilihan])
4. Buat widget reusable jika ada elemen yang berulang (button, card, input field)
5. Pastikan responsive untuk berbagai ukuran layar (gunakan MediaQuery / LayoutBuilder, hindari ukuran fixed px)
6. Ikuti null-safety dan best practice Dart terbaru
7. Untuk asset gambar, gunakan format WebP dan struktur folder assets/images/2.0x, 3.0x sesuai resolusi

## OUTPUT YANG DIHARAPKAN
1. Kode Flutter lengkap per screen/komponen (file terpisah, bukan satu file besar)
2. Penjelasan singkat struktur widget tree yang dipakai
3. Daftar dependency baru (jika ada) yang perlu ditambahkan via `flutter pub add`
4. Catatan jika ada bagian desain Figma yang ambigu/tidak match dengan PRD, agar saya klarifikasi dulu sebelum lanjut

## BATASAN
- Jangan generate dummy data acak — gunakan struktur data sesuai model/API yang sudah saya definisikan: [tempel model/API jika ada]
- Jangan ubah struktur folder project yang sudah ada kecuali saya minta
- Jika Figma dan PRD berbeda instruksi, prioritaskan PRD untuk logic/fungsi dan Figma untuk visual
```

---

## B. Prompt aktif — PRD 1.1, aplikasi penumpang

```text
Kamu mengembangkan Nebeng Dong, Flutter Android, package praktikum_mobile.
Aplikasi mobile hanya penerima/pencari tebengan. Pengemudi adalah data backend,
bukan role yang dapat dipilih pada app ini.

BACA DAHULU (Markdown, bukan PDF)
- docs/progress/PROGRESS.md, CLAUDE.md, AGENTS.md
- docs/prd/prd-nebeng-dong-kel-4.md (versi 1.1)
- docs/progress/rencana-aplikasi-penumpang.md
- docs/progress/pembagian-tugas.md (usulan layar perlu konfirmasi tim)
- docs/design/panduan-desain-figma.md dan docs/architecture/mvvm.md
- docs/progress/peta-dan-lokasi.md untuk geometry/layanan/pin
PDF PRD v1.0 arsip dua role. Source sudah feature-first MVVM penumpang;
driver di legacy, named routes ditolak. Hasil masih di Home; pemisahan layar
Hasil/pemilih Figma penuh, backend dan modul rekan belum selesai.

CAKUPAN
Kerjakan hanya tahap yang secara eksplisit diminta pengguna.
Target layar Mikail: Cari Tebengan, Hasil Pencarian, Filter Pencarian.
Login dan Detail Tebengan adalah layar bersama yang sudah ada.
Jika diminta migrasi satu role, hilangkan akses driver dari UI DAN named routes:
tidak ada Beri Tebengan, Posting/Edit/Hapus Rute, Rute Saya pengemudi,
Permintaan Masuk/ACC, konfirmasi pelunasan oleh pengemudi.
Isolasi kode legacy yang perlu reuse; jangan menghapus perubahan pengguna.
Jangan membangun aplikasi pengemudi atau dashboard admin tanpa instruksi.
Integrasi modul rekan mengikuti kontrak dan pembagian yang disepakati.

ALUR DAN UI TARGET
Login -> Cari (Dari/Ke) -> Hasil <-> Filter -> Detail -> jemput/catatan
-> permintaan -> status backend -> perjalanan -> ongkos -> rating/riwayat.
Bottom navigation target: Cari, Pesanan, Ongkos, Profil; riwayat di Pesanan.
Tidak semua menu selesai dalam sprint Mikail; jangan membuat aksi palsu.
Cari memakai saran nama tempat atau pin OSM, swap nama+koordinat atomik.
Aksi pilih/ubah pin rata kanan. Alamat lengkap hasil reverse langsung terisi;
alias terpisah, alamat ikut tersimpan/ditampilkan. Ikon kursi/jam/ongkos/jemput.
Filter memiliki draft, validasi, Terapkan/Atur Ulang dan result immutable;
back/cancel tidak menerapkan draft. Asynchronous UI: loading, kosong, error/retry,
sukses; tangani respons lama, navigasi balik, keyboard dan skala teks.

DESAIN
Figma: https://www.figma.com/design/8N2dvFV6aO7NJkAnFSbNRq/Praktikum
Node aktif Mikail di JSON: Cari 124:240, Hasil 124:241, Filter 124:242;
section 124:239, feedback loading/kosong/error di 130:402.
Rincian lokasi section 148:474: 18 state pendukung; mulai form kosong 148:475.
Baca panduan untuk pilih Dari/Ke, nama+alamat, pin, retry/manual dan batal.
M1 Location Input juga punya Place Name dan Show Place Name; alamat tetap terpisah.
Frame driver 31:13/31:17/31:21 berada di arsip 124:238, bukan target baru.
Desain Mikail ditinjau; struktur/role source sudah migrasi. Semua state visual
belum diport; jangan menyebut parity Figma atau fitur rekan selesai.
Prototype utama Cari -> Hasil <-> Filter dan contoh pemilih tempat/pin,
konfirmasi/batal, Ke lebih dulu dan swap tersedia. Peta/query/alias adalah
contoh statis, bukan interaksi bebas. Chip/reset/tab rekan masih visual;
kartu belum tersambung ke shared Detail antarpages.
Jangan menganggap prototype sebagai implementasi peta/filter/backend sungguhan.
Gunakan token/komponen yang sudah ada. Jangan memulihkan UI driver dari frame lama.
Token lib/theme: bg #F6F7FB, surface #FFFFFF, coral #F2603F/#D9491F,
brand-subtle #FFE9E2, success #DCF3E8/#0F7A52, hijau #22A06B, kuning #FFC542,
text #1B2440/#7A8299, on-brand #FFFFFF, border cloud #E7E9F2.
Roboto: heading 28/22 bold, body 16/14, label 14 medium.
Spacing 8/16/24, radius 20, shadow kartu y6/blur16/navy8%, tanpa border kartu.
Field lokasi putih/border cloud; asal coral dan tujuan hijau, bukan lavender.
Bahasa santai: Gas Masuk!, Cariin Tebengan!, Ikut Nebeng!.
Material/reusable widget; target sentuh >=48, responsif 320px dan teks 2x,
safe area/scroll. Aset WebP assets/images/2.0x dan 3.0x.

ARSITEKTUR
Pertahankan MVVM ChangeNotifier + ListenableBuilder tanpa framework baru.
features/<feature>/views dan shared/**/views/widgets: UI/controller/Form/focus/
dialog/SnackBar/navigasi bertipe. viewmodels di feature/shared: state, validasi,
commands; tanpa BuildContext/Navigator/controller
atau ketergantungan ke ViewModel lain. Inject repository/service lewat constructor.
shared/models, shared/maps/models, ride_search/models: entitas immutable.
ride_search/data: kontrak abstract baca + LocalRideRepository/fixtures jalan nyata.
shared/maps/services: adapter peta. core/di: satu repository sesi, ownership/dispose.
Tidak import legacy dari source aktif; mutasi driver hanya archive/test.
lib/core: lifecycle/DI bersama; lib/theme: token; lib/routes: named routes.
Dispose listener/resource, guard generation/lifecycle pada async.
Jangan mengembalikan operasi data/state bisnis ke setState di View.

DATA DAN BATAS SERVER
FR-01: baca rute backend; CRUD rute sisi admin, bukan penumpang.
FR-02/03: pencarian/filter dan matcher jalur berarah.
FR-04: kuota otoritatif backend saat approval, bukan saat request pending.
FR-05/07/08: request, keputusan backend, sinkronisasi dan cancel konsisten.
FR-10/11: deklarasi sudah bayar bukan pelunasan terkonfirmasi.
FR-13: rating hanya trip sendiri yang selesai; FR-17/18: auth/otorisasi backend.
REST aplikasi belum tersedia di repo, backend eksternal belum dikonfirmasi.
Jangan mengarang endpoint final atau mengklaim seed sebagai backend sungguhan.
Jika diminta simulasi, fixture deterministik dan batasnya harus dijelaskan.
Model Ride existing dipertahankan/diadaptasi secara terarah; koordinat/alamat
dan geometry jalan wajib valid untuk seed pencarian geografis.
Sample lama tanpa geometry tidak cocok pada search koordinat.
Jangan gunakan garis lurus palsu atau hitung semua seed lewat OSRM tiap startup.
OSM/Photon/OSRM tetap dengan atribusi/cache/rate limit dan error/retry.
Tidak menambah GPS/live tracking/payment gateway, API key berbayar,
dependency atau persistensi tanpa kebutuhan dan instruksi yang relevan.

OUTPUT DAN VERIFIKASI
Laporkan file berubah, alur/ViewModel/repository, dependency bila perlu,
batas simulasi/integrasi dan konflik Figma lama vs target baru.
Untuk perubahan Flutter: format, analyze, tests relevan dan build.
Uji driver named routes terblokir, fixture searah/terbalik/penuh/kosong,
filter/result/pin, stale async dan status/kuota bila diintegrasikan.
HP hanya dipakai setelah izin pengguna; jangan klaim tes/build/demo lulus
tanpa menjalankannya. Perbarui PROGRESS dan JSON hanya jika Figma benar diubah.
Jangan commit/push/merge atau mengubah PDF/instruksi asli dosen tanpa permintaan.
```

## C. Baseline historis 6 Oktober — sebelum refactor feature-first

Pada 6 Oktober 2026, Login/Home/Detail, Posting Rute/Rute Saya/Filter, Catatan dan picker sudah tersedia dengan sembilan ViewModel. Home masih dua intent Cari/Beri. Repository/login/booking masih lokal; belum ada autentikasi/persistensi/approval server.

Peta sudah OSM, Photon autocomplete/reverse dan geometry OSRM; FR-03 bukan lagi sekadar pencarian teks, tetapi matcher koridor berarah lokal. Rute contoh tanpa geometry tetap tidak cocok untuk pencarian koordinat. Heuristik belum menghitung detour atau akses berjalan kaki.

Dependency peta existing: flutter_map, latlong2, http, url_launcher; migrasi MVVM tidak menambah dependency state-management. Pada baseline 6 Oktober, tema native coral dan pin/alamat belum disinkronkan ke Figma. Revisi Figma Mikail 8 Oktober kini memakai susunan Dari/Ke/pin kanan dan tema bersama; rincian picker/pin Mikail kini tersedia sebagai prototype ilustratif. Detail/layar rekan tidak direvisi. Source tetap baseline. Kotak ND masih aset sementara.

Hasil baseline: 100 tes lulus dan build debug/release MVVM berhasil pada 6 Oktober, belum dipasang/diuji di HP. Revisi dokumen 8 Oktober tidak menjalankan ulang Flutter gates dan tidak mengubah source. Lihat [PROGRESS](../progress/PROGRESS.md), [implementasi baseline](../progress/modul-1-implementasi.md), [arsitektur](../architecture/mvvm.md).
