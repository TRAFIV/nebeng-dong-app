# Modul 1 Pemrograman Mobile

## Halaman 1

MODUL PRAKTIKUM

MATA KULIAH PEMROGRAMAN MOBILE

PERTEMUAN 01

SEMESTER GANJIL

TAHUN AJARAN 2026 - 2027

Disusun oleh:

Aina Hubby Aziira, M.Eng

Nayla Thahira Meldian

Siti Aliani Husnah.F

Kezia Valerina Damanik

Laila Qadriyah

Revin Pahlevi

Ervizon Fariz

Muhammad Afiq Jakhel

DEPARTEMEN SISTEM INFORMASI

FAKULTAS TEKNOLOGI INFORMASI

UNIVERSITAS ANDALAS

TAHUN 2026

## Halaman 2

IDENTITAS PRAKTIKUM

IDENTITAS MATA KULIAH

Kode mata kuliah

Nama mata kuliah Pemograman Mobile

CPMK yang
dibebankan pada
praktikum

Materi Praktikum 1.​ Setup Environment
Pertemuan 3
2.​ Flutter Run

3.​ Desain Prototype dengan Figma

4.​ Import Desain Figma ke Project Flutter

5.​ Menggunakan PRD dengan Bantuan AI Asisten &
Prompting untuk Figma

6.​ Widget Tree

7.​ Layout Constraints

8.​ Implementasi Widget Mobile

9.​ Review dan Debug Frontend Mobile

10.​Setup GitHub dan Collaborator

IDENTITAS DOSEN DAN ASISTEN MAHASISWA

Nama Dosen Pengampu 1.​ Husnil Kamil, M.T.

Nama Asisten Mahasiswa 1.​ 2311521006 - Nayla Thahira Meldian
(Kelas A)
2.​ 2311522006 - Siti Aliani Husnah.F

3.​ 2311522010 - Kezia Valerina Damanik

4.​ 2311522022 - Laila Qadriyah

5.​ 2311522024 - Revin Pahlevi

## Halaman 3

6.​ 2311522025 - Ervizon Fariz

7.​ 2311522035 - Hafiz Muhammad Faqih

8.​ 2311522037 - Farhan Fitrahadi

9.​ 2311523004 - Fachri Akbar

10.​2311523009 - Fathiya Alzhafira

11.​2311523011 - Muhammad Afiq Jakhel

12.​2311523012 - Rahil Akram Hammad

13.​2311523013 - Putri Diva Riyanti

14.​2311523036 - Varissa Anzani Badri

Nama Asisten Mahasiswa 1.​ 2311521006 - Nayla Thahira Meldian
(Kelas B)
2.​ 2311522006 - Siti Aliani Husnah.F

3. 2311522010 - Kezia Valerina Damanik

4. 2311522022 - Laila Qadriyah

5. 2311522024 - Revin Pahlevi

6. 2311522025 - Ervizon Fariz

7. 2311522035 - Hafiz Muhammad Faqih

8. 2311522037 - Farhan Fitrahadi

9. 2311523004 - Fachri Akbar

10. 2311523009 - Fathiya Alzhafira

11. 2311523011 - Muhammad Afiq Jakhel

12. 2311523012 - Rahil Akram Hammad

13. 2311523013 - Putri Diva Riyanti

14. 2311523036 - Varissa Anzani Badri

## Halaman 4

DAFTAR ISI

IDENTITAS PRAKTIKUM....................................................................................................1
IDENTITAS MATA KULIAH.............................................................................................2
IDENTITAS DOSEN DAN ASISTEN MAHASISWA.......................................................2
BAGIAN 1.................................................................................................................................6
SETUP ENVIRONMENT & BASIC FLUTTER WORKFLOW....................................... 6
A. Setup Environment........................................................................................................6
1. Install Git....................................................................................................................6
2. Install VS Code.......................................................................................................... 6
3. Install & Setup Flutter SDK.......................................................................................7
4. Install JDK...............................................................................................................10
5. Install Android SDK (Command-line Tools Only)................................................. 12
5.1 Download & Extract........................................................................................12
5.2 Set Environment Variables..............................................................................12
5.3 Install Komponen SDK................................................................................... 14
5.4 Hubungkan ke Flutter......................................................................................14
5.5 Terima Lisensi Android via Flutter................................................................. 14
6. Verifikasi dengan flutter doctor................................................................................15
7. Membuat & Menjalankan Project Pertama.............................................................. 15
8. Menjalankan di HP Android Fisik........................................................................... 17
8.1 Setup di HP......................................................................................................17
8.2 Hubungkan ke Laptop..................................................................................... 18
8.3 Verifikasi Koneksi...........................................................................................18
8.4 Run ke HP....................................................................................................... 19
9. (Opsional) Emulator Android via Command Line...................................................20
10. (Opsional) Visual Studio untuk Windows Desktop Apps..................................... 21
B. Flutter Run...................................................................................................................22
1. Membuat Project Baru............................................................................................. 22
2. Menjalankan Aplikasi.............................................................................................. 23
3. Build Mode: Debug, Profile, Release.......................................................................23
C. Desain Prototype dengan Figma................................................................................ 23
1. Mengenal Workspace Figma....................................................................................23
2. Membuat Prototype (Interaksi Antar Layar)............................................................24
3. Praktik Baik untuk Praktikum.................................................................................24
D. Import Desain Figma ke Project Flutter...................................................................24
1. Pendekatan Manual via Dev Mode (Direkomendasikan untuk Belajar)..................25
2. Pendekatan Otomatis via Plugin Figma-to-Flutter...................................................25
3. Ringkasan Perbandingan..........................................................................................26
E. Menggunakan PRD dengan Bantuan AI Asisten & Prompting untuk Figma.......26

## Halaman 5

Langkah 1: Menerjemahkan PRD ke Layout & Komponen Figma.............................26
Langkah 3: Mengubah Spesifikasi Design Figma ke Widget Flutter...........................26
BAGIAN 2...............................................................................................................................30
Widget Tree & Basic UI Mobile............................................................................................30
A. Widget Tree................................................................................................................... 30
B. Layout Constraints.........................................................................................................31
C. Implementasi Widget Mobile........................................................................................ 32
D. ⁠Review Dan Debug Frontend Mobile........................................................................... 35
E. ⁠Setup Github dan Collaborator...................................................................................... 36

## Halaman 6

BAGIAN 1

SETUP ENVIRONMENT & BASIC FLUTTER WORKFLOW

A. Setup Environment

Panduan ini berisi langkah instalasi Flutter di Windows dari nol sampai bisa flutter

run ke HP Android fisik, tanpa install Android Studio sebagai aplikasi, semua diatur lewat

command line dan VS Code.

Target akhir: flutter doctor full hijau (kecuali Visual Studio yang memang opsional) dan

project Flutter bisa jalan di Chrome maupun HP Android fisik

Prasyarat:

1.​ Windows 10/11

2.​ Koneksi internet stabil (total download bisa ±2-3 GB)

3.​ Waktu senggang ±1-1.5 jam untuk instalasi awal

1. Install Git

Flutter tool butuh Git untuk mengambil package dan update SDK.

1.​ Download

Dari git-scm.com/downloads/win

2.​ Install

Dengan opsi default

3.​ Cek

Buka Command Prompt (cmd), ketik:

git --version ​

2. Install VS Code

1.​ Download

## Halaman 7

Dari code.visualstudio.com

2.​ Install

Seperti biasa

3.​ Install extension Flutter

Buka Extensions (Ctrl+Shift+X), cari "Flutter" (publisher: Dart Code), klik Install,

sudah otomatis menginstall ekstensi Dart juga

4.​ Restart VS Code

3. Install & Setup Flutter SDK

1.​ Buka halaman resmi

docs.flutter.dev/install/manual, pastikan tab Windows aktif.

2.​ Download SDK bundle (.zip)

## Halaman 8

Klik Custom setup dari halaman utama install jika diarahkan ke sana. Alternatif kalau

tombol download nggak muncul: docs.flutter.dev/install/archive, cari tab Windows di

bagian Stable channel

3.​ Buat folder

C:\src\flutter (jangan di Downloads/Desktop, jangan ada spasi di path)

4.​ Extract

Extract isi zip ke folder tersebut, sampai strukturnya jadi C:\src\flutter\bin,

C:\src\flutter\packages, dst.

## Halaman 9

5.​ Tambahkan ke PATH

Tekan tombol Windows, ketik "env", pilih "Edit environment variables for your

account". Di variabel Path, klik New, ketik C:\src\flutter\bin. Klik OK di semua

jendela

6.​ Restart terminal

Tutup semua jendela Command Prompt yang terbuka, buka yang baru

7.​ Verifikasi

flutter --version ​

## Halaman 10

4. Install JDK

sdkmanager (dipakai di Bagian 5) butuh Java 17+. Karena tidak pakai Android Studio, JDK

harus diinstall terpisah.

1.​ Download

Dari adoptium.net — pilih versi LTS (17 atau 21), Windows, package .msi

2.​ Install

Jalankan installer, pilih opsi default (biasanya otomatis centang "Set JAVA_HOME")

## Halaman 11

3.​ Cek JAVA_HOME

Kalau belum otomatis diset, tambahkan manual: nama JAVA_HOME, value path ke

folder JDK, misal C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot

4.​ Tambahkan ke PATH

%JAVA_HOME%\bin kalau belum otomatis

5.​ Verifikasi

Restart Command Prompt, jalankan:

java -version ​

## Halaman 12

(sesuai versi yang kamu install)

5. Install Android SDK (Command-line Tools Only)

Ini pengganti Android Studio, hanya SDK-nya saja, tanpa IDE-nya.

5.1 Download & Extract

1.​ Buka halaman resmi

developer.android.com/studio, scroll ke bagian "Command line tools only"

2.​ Download zip Windows

Contoh nama file: commandlinetools-win-XXXXXXXX_latest.zip

3.​ Buat folder

C:\Android\cmdline-tools\latest

4.​ Extract

Extract isi zip ke situ

5.2 Set Environment Variables

Tambahkan di "Edit environment variables for your account":

Nama Value

ANDROID_HOME C:\Android

Tambahan di Path C:\Android\cmdline-tools\latest\bin

Tambahan di Path C:\Android\platform-tools

## Halaman 13

Tutup semua Command Prompt yang terbuka, buka yang baru.

## Halaman 14

5.3 Install Komponen SDK

Jalankan di Command Prompt (boleh pakai sdkmanager atau sdkmanager.bat, dua-duanya

jalan di CMD):​

● Kalau muncul prompt lisensi (Accept? (y/N):), ketik y lalu Enter untuk setiap

lisensi yang muncul

● Tunggu sampai semua progress bar 100% dan kembali ke prompt terminal

(jangan tutup terminal di tengah proses)

5.4 Hubungkan ke Flutter

flutter config --android-sdk "C:\Android"

5.5 Terima Lisensi Android via Flutter

flutter doctor --android-licenses ​

Ketik y untuk setiap lisensi yang muncul.

## Halaman 15

​

6. Verifikasi dengan flutter doctor

flutter doctor ​

Target hasil akhir:

Komponen Status

Flutter OK

Windows Version OK

Android toolchain - develop for Android devices OK

Chrome - develop for the web OK

Visual Studio - develop Windows apps Abaikan (lihat Bagian

10)

Connected device OK

Network resources OK

Kalau Android toolchain masih bermasalah dengan pesan versi SDK/build-tools yang

diminta beda dari yang sudah diinstall, install versi spesifik yang diminta pesan errornya,

contoh:

sdkmanager "platforms;android-XX" "build-tools;XX.X.X"

lalu cek ulang flutter doctor.

7. Membuat & Menjalankan Project Pertama

flutter create nama_project

cd nama_project

## Halaman 16

code .

Jalankan ke Chrome (paling cepat, cocok buat tes awal):

## Halaman 17

8. Menjalankan di HP Android Fisik

8.1 Setup di HP

1.​ Aktifkan Developer Options

Buka Settings > About phone, tap "Nomor build" / "Build number" 7 kali

berturut-turut sampai muncul notifikasi "Anda sekarang developer"

2.​ Buka Developer Options

Menu baru di System atau paling bawah Settings

3.​ Aktifkan USB debugging

## Halaman 18

Catatan: Khusus HP Xiaomi/POCO/Redmi (MIUI/HyperOS): ada toggle tambahan

"USB debugging (Security settings)" yang WAJIB diaktifkan juga (biasanya minta login

akun Mi dan konfirmasi via internet). Tanpa ini, HP hanya akan kedetect sebagai

"Portable Devices" biasa di Windows, bukan sebagai perangkat ADB

8.2 Hubungkan ke Laptop

1.​ Colok kabel USB

Pastikan kabel data, bukan cuma charging

2.​ Pilih mode USB

Swipe notifikasi di HP, pilih mode USB "File Transfer" (bukan "Charging only")

3.​ Izinkan debugging

Akan muncul popup "Allow USB debugging?" — centang "Always allow from this

computer", tap Allow

8.3 Verifikasi Koneksi

adb devices

Harusnya muncul serial number dengan status device:

91f4a6e9 ​ device

● Kalau list kosong → cek popup izin di HP, coba kabel lain, cek Device Manager

Windows untuk driver bermasalah

● Kalau statusnya unauthorized → accept popup di HP yang mungkin belum di-tap

## Halaman 19

8.4 Run ke HP

flutter devices

flutter run

Kalau ada lebih dari satu device tersedia, pilih nomor sesuai HP, atau langsung:

flutter run -d <device_id>

## Halaman 20

(device_id didapat dari hasil adb devices di atas)

9. (Opsional) Emulator Android via Command Line

Kalau tidak ada HP fisik dan mau pakai emulator, tanpa Android Studio GUI:

sdkmanager "emulator" "system-images;android-34;google_apis;x86_64"

Tambahkan C:\Android\emulator ke Path, lalu:

avdmanager create avd -n Pixel_Test -k

"system-images;android-34;google_apis;x86_64" - d pixel

(kalau ditanya custom hardware profile, Enter aja / pilih "no")

Nyalakan emulator:

emulator -avd Pixel_Test

## Halaman 21

Setelah emulator terbuka, di jendela Command Prompt lain jalankan flutter run dari folder

project.

Catatan: Performa — pastikan virtualization (VT-x/AMD-V) aktif di BIOS, dan fitur

Windows "Windows Hypervisor Platform" ter-enable (cari lewat "Turn Windows features

on or off"), supaya emulator tidak lag.

10. (Opsional) Visual Studio untuk Windows Desktop Apps

Visual Studio di flutter doctor bukan VS Code ini produk terpisah dari Microsoft,

cuma dibutuhkan kalau mau build aplikasi Windows desktop native. Aman diabaikan

kalau target cuma Android/web.

Kalau tetap mau full hijau:

1.​ Download Visual Studio Community (gratis)

Dari visualstudio.microsoft.com/downlads

2.​ Pilih workload

Saat instalasi, centang workload "Desktop development with C++"

3.​ Install

Bisa 20-40 menit

4.​ Cek ulang

Restart Command Prompt, cek flutter doctor lagi

Troubleshooting - Error yang Umum Ditemui

Error Penyebab Solusi

'sdkmanager' is not PATH belum benar / CMD Cek PATH tersimpan, tutup

recognized as an internal belum di-restart total & buka CMD baru

or external command

Java version 17 or higher Tidak ada JDK terinstall Install JDK terpisah (Bagian

is (biasanya 4)

required bawaan Android Studio)

## Halaman 22

No valid Android SDK build-tools yang berpasangan sdkmanager

platforms found walau belum diinstall "build-tools;XX.X.X"

folder platform ada

Flutter requires Android Versi Flutter butuh Install versi yang diminta

SDK XX dan Build-Tools platform/build-tools pesan error tersebut, tanpa

X.X.X spesifik yang beda dari menghapus yang

yang lama

sudah ada

HP hanya muncul di (Xiaomi/POCO/HyperOS) Aktifkan toggle security

"Portable Devices", tidak "USB debugging (Security settings, pilih mode USB

kedetect adb devices settings)" belum aktif, atau "File Transfer", cabut-colok

mode USB salah ulang

adb devices menunjukkan Popup izin di HP belum Cek layar HP, tap Allow pada

status di-accept popup

unauthorized RSA fingerprint

Folder cmdline-tools dobel Struktur zip Android SDK Pindahkan isi folder dalam ke

nested memang begitu saat satu level di atas

di-extract

B. Flutter Run

Setelah environment siap, langkah berikutnya adalah membuat project baru dan memahami

siklus development Flutter: membuat, menjalankan, dan melakukan perubahan kode secara

cepat.

1. Membuat Project Baru

flutter create nama_project

Struktur folder penting yang dihasilkan:

● lib/main.dart — entry point aplikasi (fungsi main())

● pubspec.yaml — daftar dependency, asset, dan metadata project

## Halaman 23

● android/ dan ios/ — project native untuk masing-masing platform

● test/ — unit/widget test

2. Menjalankan Aplikasi

flutter run

Jika ada lebih dari satu device/emulator aktif, Flutter akan meminta memilih salah satu, atau

bisa langsung ditentukan:

flutter run -d chrome ​ # jalankan di browser Chrome (web)​

flutter run -d <device_id>​ # jalankan di device/emulator tertentu​

flutter devices ​# lihat daftar device yang terdeteksi

3. Build Mode: Debug, Profile, Release

Mode Perintah Kegunaan

Debug (default) flutter run Development sehari-hari —

mendukung hot reload/restart,

ada assertion & debug banner

Profile flutter run --profile Mengukur performa

(mendekati kondisi rilis,

sebagian tooling debug tetap

aktif)

Release flutter run --release Build optimal untuk distribusi

— tanpa hot reload, ukuran

lebih kecil & lebih cepat

C. Desain Prototype dengan Figma

Sebelum coding, tampilan aplikasi dirancang terlebih dahulu dalam bentuk desain visual dan

alur interaksi (prototype) menggunakan Figma, agar developer punya acuan pasti sebelum

implementasi.

1. Mengenal Workspace Figma

●​ Design mode — tempat membuat tampilan (frame, layer, komponen, warna,

tipografi)

## Halaman 24

●​ Dev Mode — mode khusus developer untuk inspect ukuran, warna, spacing, dan

generate snippet kode (dibahas di Bagian 4)

●​ Frame — canvas berukuran tetap yang merepresentasikan satu layar aplikasi

(pilih preset ukuran device, mis. "iPhone 14" atau "Android Large")

●​ Auto Layout — fitur mengatur elemen agar menyesuaikan ukuran otomatis,

mirip konsep Row/Column di Flutter — sangat membantu supaya desain lebih

mudah diterjemahkan ke widget

●​ Components & Variants — elemen reusable (tombol, kartu, dsb.) dengan

beberapa state, mirip konsep custom widget

2. Membuat Prototype (Interaksi Antar Layar)

1.​ Buat beberapa frame yang merepresentasikan tiap layar aplikasi (Splash, Login,

Home, dst.)

2.​ Pindah dari tab Design ke tab Prototype di panel kanan

3.​ Pilih elemen (mis. tombol), lalu tarik konektor panah ke frame tujuan

4.​ Tentukan trigger (On Click/On Tap, On Drag, While Hovering, After Delay, dll.) dan

jenis transisi (Instant, Dissolve, Smart Animate, dll.)

5.​ Klik tombol Present (▶) untuk menjalankan dan menguji alur prototype secara

interaktif

3. Praktik Baik untuk Praktikum

●​ Gunakan Auto Layout sejak awal — memudahkan proses import/translate ke

Flutter di Bagian 4

●​ Konsisten memakai style/warna lewat Local Styles atau Variables agar mudah

dipetakan ke ThemeData Flutter

Beri nama layer & frame yang jelas (bukan "Rectangle 12") supaya mudah dibaca saat

inspect di Dev Mode

D. Import Desain Figma ke Project Flutter

Figma tidak punya fitur "export langsung ke Flutter" resmi (native code generation Figma

Dev Mode hanya mendukung iOS/Android native & CSS/HTML). Ada dua pendekatan yang

umum dipakai:

## Halaman 25

1.​ Pendekatan Manual via Dev Mode (Direkomendasikan untuk Belajar)

Dev Mode menyediakan panel inspect yang menampilkan ukuran, warna (hex), font,

spacing, dan padding persis seperti desain mirip fitur Inspect di DevTools browser.

●​ Buka file Figma, aktifkan Dev Mode (ikon </> di pojok kanan atas)

●​ Klik elemen yang ingin diimplementasikan untuk melihat properti: ukuran

(width/height), warna, font-family, font-size, spacing/padding

●​ Export asset (ikon, gambar) lewat panel Export —pilih format PNG/SVG dan

resolusi (1x/2x/3x untuk berbagai densitas layar)

●​ Terjemahkan properti tersebut menjadi widget Flutter secara manual

(Container, Padding, Row/Column, TextStyle, dst.)

Pendekatan ini lebih lambat tapi menghasilkan struktur widget yang bersih dan

mudah dipelihara — cocok untuk tujuan pembelajaran, karena mahasiswa

benar-benar memahami pemetaan desain ke widget tree.

2.​ Pendekatan Otomatis via Plugin Figma-to-Flutter

Beberapa plugin komunitas di Figma Community dapat men-generate kode Flutter

dari desain, misalnya plugin bertipe "Figma to Flutter" atau "Flutter Color/Variables

Export" untuk design tokens (warna, spacing).

●​ Cara pakai umum: buka file Figma → menu Plugins → cari plugin terkait →

jalankan pada frame/elemen terpilih → salin kode yang dihasilkan ke project

Flutter

●​ Plugin export warna/variable (mis. Flutter Color Variables) cocok untuk

sinkronisasi design token (palet warna, mode terang/gelap) ke file konstanta

Dart

Perhatian: hasil generate dari plugin umumnya berupa widget absolut (SizedBox +

Positioned/Container dengan ukuran tetap), bukan layout responsif

(Row/Column/Expanded). Cocok sebagai referensi awal, tapi sebaiknya tetap

dirapikan ulang secara manual agar layout adaptif di berbagai ukuran layar.

## Halaman 26

3. Ringkasan Perbandingan

Aspek Manual (Dev Mode) Plugin Otomatis

Kecepatan Lebih lambat Lebih cepat

Kualitas struktur widget Bersih, sesuai best practice Sering kaku/absolut, perlu

dirapikan

Cocok untuk Belajar & project produksi Prototipe cepat/referensi awal

E. Menggunakan PRD dengan Bantuan AI Asisten & Prompting untuk Figma

Langkah 1: Menerjemahkan PRD ke Layout & Komponen Figma

Setelah daftar layar diperoleh, gunakan prompt kedua untuk meminta AI menyusun

spesifikasi layout di Figma, mencakup struktur Auto Layout, jarak (spacing), dan hierarki

teks.

Instruksi Prompt 2: Panduan Design Figma

Berdasarkan PRD aplikasi [Nama Aplikasi] di atas, pilihlah 3 layar utama (misal: Login,

Home/Dashboard, Detail Product).

Untuk masing-masing layar, berikan panduan struktur layout di Figma:

1.​ Penggunaan Auto Layout (Kapan menggunakan Direction Horizontal/Row atau

Vertical/Column).

2.​ Rekomendasi Spacing (Jarak antar elemen) dan Padding (Jarak tepi layar).

3.​ Hierarki Teks (Ukuran Font untuk Judul, Subjudul, dan Teks Isian).

4.​ Daftar Komponen Reusable yang harus dibuat terlebih dahulu (misal: Button, Card,

Bottom Bar).

Langkah 3: Mengubah Spesifikasi Design Figma ke Widget Flutter

Saat tahap desain selesai ,klik di layout lalu pilih copy as code dan pilih css (all layer)

## Halaman 27

Instruksi Prompt 3: Konversi ke Widget Flutter

Saya sedang membuat tampilan UI di Flutter berdasarkan desain Figma.​

Berikut spesifikasi elemen:​

- Komponen: Card Produk​

- Dimensi: Lebar Fill Container, Tinggi 120px, Corner Radius 12px​

- Warna Latar: #FFFFFF dengan Shadow Opacity 10%​

- Tata Letak Internal: Horizontal (Row) berisi Gambar Produk (80x80px) di kiri, dan Kolom

Teks (Judul 14px Bold, Harga 12px Medium) di kanan.​

​

Buatkan kode Widget Flutter (StatelessWidget) yang rapi, responsif, dan sesuai dengan best

practice Flutter!

Contoh Prompt :

Kamu adalah AI coding assistant yang bertugas mengimplementasikan UI Flutter

berdasarkan PRD (Product Requirements Document) dan desain Figma yang saya lampirkan.

KONTEKS PROJECT

- Nama project: [ISI NAMA PROJECT]

- Platform target: Flutter (Android [& iOS jika perlu])

- State management: [Provider / Riverpod / Bloc / GetX sesuaikan]

- Struktur folder saat ini: [tempel struktur folder project, misal lib/screens, lib/widgets,

lib/models]

SUMBER DESAIN

## Halaman 28

1. PRD: [lampirkan/tempel isi PRD atau ringkasannya fitur, flow, requirement fungsional]

2. Figma: [tempel link Figma / lampirkan screenshot frame / export design tokens (warna,

spacing, typography)]

TUGAS

Implementasikan screen/komponen berikut sesuai desain Figma dan requirement di PRD:

1.​ [Nama screen 1, misal: "Login Screen"]

2.​ [Nama screen 2, misal: "Dashboard"]

KETENTUAN TEKNIS

1.​ Gunakan widget Flutter native (Material) kecuali desain secara eksplisit butuh custom

widget

2.​ Ekstrak design token dari Figma menjadi:

- Color palette : lib/theme/app_colors.dart

- Typography : lib/theme/app_text_styles.dart

- Spacing/sizing konsisten (gunakan konstanta, jangan hardcode angka di widget)

3.​ Pisahkan UI (widget) dari logic (gunakan [state management pilihan])

4.​ Buat widget reusable jika ada elemen yang berulang (button, card, input field)

5.​ Pastikan responsive untuk berbagai ukuran layar (gunakan MediaQuery /

LayoutBuilder, hindari ukuran fixed px)

6.​ Ikuti null-safety dan best practice Dart terbaru

7.​ Untuk asset gambar, gunakan format WebP dan struktur folder assets/images/2.0x,

3.0x sesuai resolusi

OUTPUT YANG DIHARAPKAN

1.​ Kode Flutter lengkap per screen/komponen (file terpisah, bukan satu file besar)

2.​ Penjelasan singkat struktur widget tree yang dipakai

3.​ Daftar dependency baru (jika ada) yang perlu ditambahkan via flutter pub add

4.​ Catatan jika ada bagian desain Figma yang ambigu/tidak match dengan PRD, agar

saya klarifikasi dulu sebelum lanjut

## Halaman 29

BATASAN

1.​ Jangan generate dummy data acak gunakan struktur data sesuai model/API yang

sudah saya definisikan: [tempel model/API jika ada]

2.​ Jangan ubah struktur folder project yang sudah ada kecuali saya minta

3.​ Jika Figma dan PRD berbeda instruksi, prioritaskan PRD untuk logic/fungsi dan

Figma untuk visual

## Halaman 30

BAGIAN 2

Widget Tree & Basic UI Mobile

A.​ Widget Tree

Pada Flutter, setiap komponen tampilan adalah widget, dan komponen tersebut

disusun dengan cara saling membungkus satu sama lain. Susunan bersarang yang

bertingkat dari elemen terluar hingga elemen terkecil membentuk struktur hierarki

yang disebut Widget Tree (Pohon Widget). Satu widget induk (parent) dapat memiliki

satu atau lebih widget anak (child), sehingga terbentuk struktur pohon (tree).

MaterialApp

└── Scaffold

├── AppBar

│ └── Text('Judul Aplikasi')

└── Center

└── Column

├── Text('Sistem Informasi')

└── ElevatedButton

└── Text('Tekan Saya')

Dapat digambarkan sebagai widget tree berikut:

●​ MaterialApp menjadi root widget (akar pohon).

●​ Scaffold adalah anak dari MaterialApp.

●​ AppBar dan Center merupakan anak dari Scaffold.

●​ Column menjadi anak dari Center, dan seterusnya hingga widget paling dasar

(leaf widget) seperti Text.

Struktur bersarang seperti inilah yang disebut widget tree, jalur dari root

hingga leaf widget menentukan bagaimana tampilan akhirnya dirender ke layar.

## Halaman 31

B.​ Layout Constraints

Penentuan dimensi setiap komponen visual diatur oleh Aturan Layout

Constraints. yaitu Constraints go down. Sizes go up. Parent sets position. Alur

kerjanya mengikuti tiga tahap berikut, dan mengikuti arah widget tree:

●​ Constraints go down (parent → child). Widget induk (parent) menetapkan

rentang batas ukuran (minWidth, maxWidth, minHeight, maxHeight) kepada

widget anak (child).

●​ Sizes go up (child → parent). Widget anak menentukan ukurannya sendiri

berdasarkan isi data/konten, dengan syarat tidak melampaui batas yang

diizinkan oleh induknya.

●​ Parent sets position. Widget induk menempatkan widget anak pada koordinat

visual (x, y) di layar.

Karena hampir semua widget di Flutter dirender lewat objek RenderBox, dan

banyak RenderBox yang hanya meneruskan constraint ke child tunggalnya, secara

umum widget dapat dikelompokkan menjadi tiga jenis perilaku:

Kategori Perilaku Contoh

Sebesar mungkin Mengambil ukuran maksimum Center, ListView
yang diizinkan

Menyesuaikan Ukurannya sama dengan ukuran Transform, Opacity
child child-nya

Ukuran tertentu Ukurannya ditentukan oleh Image, Text
(intrinsik) kontennya sendiri

## Halaman 32

C.​ Implementasi Widget Mobile

Widget merupakan komponen dasar untuk membangun antarmuka pengguna

pada Flutter. Tampilan aplikasi dibentuk dengan menyusun widget secara hierarkis

dalam sebuah Widget Tree. Widget dapat digunakan untuk menampilkan konten

maupun mengatur layout aplikasi. Beberapa widget dasar yang digunakan dalam

implementasi prototype:

1.​ Scaffold

Menyediakan kerangka tata letak visual dasar Material Design untuk sebuah

layar, seperti area bilah atas, badan aplikasi, dan tombol aksi mengambang.

Properti Widget Deskripsi & Fungsi

Scaffold Implementasi

appBar AppBar(...) Menampilkan bilah navigasi di

bagian atas layar untuk judul

halaman, tombol navigasi

kembali, atau ikon aksi/menu.

## Halaman 33

body body(...) Area utama layar tempat seluruh

konten utama aplikasi dirender

dan ditampilkan kepada

pengguna.

drawer Drawer(...) Panel navigasi samping kiri

yang dapat dimunculkan dengan

menggeser (swipe) layar dari

sisi kiri.

endDrawer Drawer(...) Panel navigasi samping kanan

yang dapat ditarik keluar dari

tepi kanan layar untuk opsi atau

filter tambahan.

floatingAction FloatingActionButto Tombol aksi utama yang
Button n(...) posisinya melayang (floating) di

atas konten layar untuk memicu

aksi terpenting (misal: tombol

tambah item).

bottomNaviga BottomNavigationB Bilah navigasi di bagian bawah
tionBar ar(...) atau layar.

BottomAppBar(...)

2.​ Text

Text digunakan untuk menampilkan tulisan pada aplikasi, seperti judul,

deskripsi, nama pengguna, harga, dan informasi lainnya.

const Text(

'Selamat Datang',

style: TextStyle(

fontSize: 24,

fontWeight: FontWeight.bold,

),

## Halaman 34

)

3.​ Image

Image digunakan untuk menampilkan gambar pada aplikasi. Gambar dapat

berasal dari asset lokal maupun internet.

Image.asset(

'assets/images/produk.png',

width: 150,

height: 150,

)

4.​ Icon

Icon digunakan untuk menampilkan simbol atau ikon Material Design bawaan

Flutter.

const Icon(

Icons.home,

size: 30,

)

5.​ Basic Layout

Widget tata letak bertugas mengatur posisi, dimensi, perataan, serta aliran

penyusunan widget lain di dalam pohon widget (widget tree).

Widget Fungsi

## Halaman 35

Column Menyusun kumpulan

widget secara berurutan ke

arah vertikal tegak lurus.

Row Menyusun kumpulan

widget secara mendatar

sejajar dalam satu baris.

Container Membungkus elemen

tunggal untuk mengatur

lebar, tinggi, margin,

padding, warna latar, batas

(border), dan dekorasi

bentuk.

D.​ ⁠Review Dan Debug Frontend Mobile
Proses memastikan tampilan antarmuka berjalan sesuai spesifikasi desain, responsif di

berbagai resolusi layar, dan bebas dari galat tata letak.

1.​ Flutter Inspector: Fitur di VS Code dan Flutter DevTools untuk membedah

pohon widget (widget tree), memeriksa ukuran dimensi elemen secara

langsung, serta mengidentifikasi asal baris kode komponen visual.

2.​ Penanganan Overflow (Garis Hitam-Kuning): Galat visual paling umum di

Flutter (A RenderFlex overflowed by X pixels). Terjadi ketika dimensi anak

melebihi ruang yang dialokasikan induknya (misalnya teks terlalu panjang

## Halaman 36

pada Row atau daftar item melebihi layar pada Column). Solusi: bungkus

widget dengan Expanded, Flexible, atau ganti Column menjadi

SingleChildScrollView/ListView.

3.​ Hot Reload vs Hot Restart :

4.​ Hot reload menyuntikkan perubahan kode ke Dart runtime yang sedang

berjalan tanpa mengulang state aplikasi, sehingga perubahan UI langsung

terlihat dalam hitungan detik. Hot restart mengulang aplikasi dari awal (state

hilang) tapi tetap lebih cepat dari full build ulang.

○​ r → Hot reload (ketik di terminal saat flutter run berjalan)

○​ Shift + R→ Hot restart atau restart app

○​ h → menampilkan daftar semua perintah yang tersedia

○​ q → berhenti (quit)

5.​ Pengujian Responsivitas UI: Menguji tampilan menggunakan emulator dengan

berbagai profil ukuran layar (misal: ponsel standar 6 inci, layar compact 4.7

inci, dan orientasi landscape) atau memanfaatkan widget LayoutBuilder dan

MediaQuery untuk memastikan tata letak adaptif.

E.​ ⁠Setup Github dan Collaborator

1.​ Inisialisasi Git Lokal

Buka terminal pada direktori root proyek Flutter:

git init

2.​ Verifikasi Berkas .gitignore

Flutter secara otomatis menyertakan berkas .gitignore. Pastikan

berkas-berkas build output (seperti folder .dart_tool/, build/, berkas .env, dan

kredensial lokal) tidak terlacak oleh Git.

3.​ Tambahkan Berkas dan Buat Commit Pertama

git add .

git commit -m "inisialisasi struktur awal proyek flutter"

4.​ Atur Branch Utama

## Halaman 37

git branch -M main

5.​ Hubungkan ke Repositori GitHub Kelompok

Buat repositori kosong di akun GitHub (salah satu anggota atau

organisasi kelompok), lalu salin URL repositorinya:

git remote add origin

https://github.com/USERNAME/NAMA-PROJECT-KELOMPOK.git

6.​ Unggah (Push) ke GitHub

Kirim kode lokal ke repositori daring GitHub:

git push -u origin main

7.​ Menambahkan Anggota Tim sebagai Collaborator

●​ Buka halaman repositori proyek di situs GitHub.

●​ Klik menu Settings pada bilah navigasi repositori.

●​ Pada panel samping kiri, pilih menu Collaborators (di bawah bagian

Access).

●​ Klik tombol hijau Add people.

●​ Cari akun anggota kelompok menggunakan Username, Nama

Lengkap, atau Email GitHub mereka, lalu pilih akun yang sesuai.

●​ Klik tombol Add [username] to this repository.
