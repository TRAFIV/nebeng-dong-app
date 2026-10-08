# Practical Challenge — Build One Complete Workflow

Tugas individu. Sumber: `PRACTICAL CHALLENGE - Tugas Individu.pdf` (3 halaman). Versi Markdown ini mempertahankan isi instruksi dalam struktur yang lebih mudah dibaca.

## 1. Deskripsi tugas

Setiap mahasiswa membuat **1 workflow fitur lengkap dari awal sampai akhir** pada aplikasi mobile. Sangat disarankan memakai fitur dari modul project kelompok agar tugas ikut menjadi bagian project. Jika fitur project belum siap, boleh membuat aplikasi sederhana khusus untuk demonstrasi workflow.

Alur yang harus ditunjukkan:

**Input / Event → State → Validation → Feedback → Navigation / Result**

| Tahap | Yang harus ditunjukkan |
|---|---|
| Input / Event | Aksi pengguna, misalnya menekan tombol, mengisi form, atau memilih item. |
| State | Data atau kondisi yang berubah setelah event. |
| Validation | Input/kondisi yang dianggap tidak valid dan penanganannya. |
| Feedback | Tampilan saat proses berhasil, gagal, atau sedang berlangsung. |
| Navigation / Result | Tujuan navigasi atau hasil yang diterima setelah proses selesai. |

Contoh Tambah Task: tekan Add Task → form terbuka → isi nama → validasi → jika valid, simpan → tampilkan pesan “Task added!” → kembali ke daftar → task baru tampil. Jika input tidak valid, tampilkan error, tolak aksi atau nonaktifkan Add, dan tetap di form agar input dapat diperbaiki.

## 2. Ketentuan

- Setiap mahasiswa membuat 1 workflow lengkap.
- Workflow harus dapat dijalankan, bukan hanya desain UI.
- Awal, proses, dan hasil akhir harus jelas.
- Minimal terdapat 1 validasi.
- Harus ada feedback kepada pengguna.
- Jika berpindah screen, tunjukkan data yang dikirim ke screen berikutnya.
- Jika ada hasil yang dikembalikan, tunjukkan result yang dikirim ke screen sebelumnya.
- Disarankan memakai fitur project kelompok masing-masing.

## 3. Pengumpulan dan demo

Tidak perlu mengumpulkan tugas melalui Ms.Teams. Setiap mahasiswa wajib demo langsung pada Pertemuan ke-7.

| Ketentuan | Jadwal |
|---|---|
| Hari/tanggal | Jumat, 9 Oktober 2026 |
| Kegiatan | Demo Tugas + Code Review |
| Kelas A | 09.00–13.00 WIB |
| Kelas B | 13.00–17.00 WIB |

- Demo dan code review dilakukan satu per satu bersama dosen.
- Tunjukkan aplikasi berjalan sekaligus source code, jelaskan workflow, dan jawab pertanyaan implementasi.
- Dosen memberi perubahan kecil pada fitur untuk dikerjakan langsung dalam kode. Tujuannya menguji pemahaman, bukan membangun fitur besar baru.
- Mahasiswa diminta memakai AI coding assistant untuk membantu perubahan atau masalah sederhana.
- Pertanyaan/pengujian tetap dalam lingkup materi dan kode yang telah dipelajari/dibuat. Modul dan video pembelajaran tersedia di Ms.Teams.

## 4. Ketentuan tambahan

- Jika jadwal ujian lain bersamaan dengan demo, ikuti ujian terlebih dahulu. Demo dapat dilakukan sebelum atau setelah ujian sesuai waktu sesi yang tersedia.
- Penilaian bukan berdasarkan banyaknya fitur atau screen, tetapi kemampuan membangun dan memahami satu workflow secara utuh: event, state, validation, feedback, navigation/result.
- Jika ada ketentuan yang tidak jelas, tanyakan kepada dosen melalui Ms.Teams.

Lihat juga [ketentuan code review dan tanya jawab](petunjuk-uts.md) yang diberikan pengguna.
