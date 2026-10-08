# AGENTS.md

Instruksi untuk AI apa pun (Codex, Claude, dll.) yang bekerja di repo ini:

1. Baca `docs/progress/PROGRESS.md` terlebih dahulu — berisi rencana, status, dan log perubahan terakhir.
2. Ikuti aturan kerja di `CLAUDE.md`.
3. Untuk pekerjaan UI Flutter, pakai prompt di `docs/prompts/prompt-implementasi-ui-flutter.md` (bagian B).
4. Kerjakan hanya sesuai tugas modul (`docs/modul/modul-1-pemrograman-mobile.md`); jangan menambah cakupan.
5. Setelah setiap perubahan (kode, Figma, dokumen), perbarui `docs/progress/PROGRESS.md`: centang rencana, perbarui status, dan tambahkan satu baris ke log.
6. Jangan force-push ke `main` repo kelompok.
7. Pada setiap perintah atau masukan pengguna, sarankan reasoning effort (`low`, `medium`, `high`, atau `xhigh` sesuai ketersediaan) dan alasan singkat berdasarkan kompleksitas; ikuti panduan di `CLAUDE.md`. Utamakan kualitas, lanjutkan pekerjaan yang sudah diizinkan, dan jangan mengklaim setting effort telah berubah hanya karena memberi rekomendasi.
8. Arsitektur sekarang MVVM: baca `docs/architecture/mvvm.md`. Pertahankan batas View/ViewModel/repository; jangan mengembalikan logika data ke `setState` atau memasukkan `BuildContext` ke ViewModel.
9. Target aktif PRD 1.1 (8 Oktober 2026): aplikasi penumpang saja. Baca `docs/progress/rencana-aplikasi-penumpang.md` dan PRD Markdown; PDF v1.0 arsip dua role. Pengemudi data backend, bukan role/layar mobile. Source aktif sudah feature-first MVVM penumpang; driver di `lib/legacy/driver/` tidak diimpor app dan named routes diblokir. Repository read-only satu sesi di core/di, fixture jalan nyata untuk latihan (bukan backend). Hasil masih di Home; migrasi penuh visual/picker Figma dan integrasi rekan/backend tetap pending. Figma Mikail v1.1 selesai di section `124:239`, state di `130:402`; frame driver diarsipkan di `124:238`. Bagian rekan dan layar bersama tetap baseline. Baca node aktif/arsip dalam JSON, jangan memulihkan desain driver. Revisi desain bukan izin migrasi Flutter/backend/HP. Jika migrasi diminta, blokir akses driver lewat UI dan named routes, pertahankan MVVM, siapkan rute bergeometri valid, dan jangan menyebut seed/fake sebagai backend. Pembagian layar baru perlu koordinasi tim.
