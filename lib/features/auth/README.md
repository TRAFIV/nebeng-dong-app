# Autentikasi bersama (FR-17) — pemilik: Mikail

Login lewat `AuthRepository`: versi server (`RemoteAuthRepository`: `POST /auth/login`, `GET /me`, `POST /auth/logout`, token di `TokenStore`) dipakai bila `API_BASE_URL` diisi; selain itu versi lokal (nama dari email, bukan autentikasi). Sesi tersimpan dipulihkan saat Login dibuka. Token ditolak server (401) → token dihapus dan aplikasi kembali ke Login. Keluar ada di menu ⋮ tab Profil.

"Masuk cepat (Dev)" hanya di build debug (server: akun demo di `server/README.md`). Pendaftaran akun belum ada: akun dibuat admin. Token masih di SharedPreferences; ganti dengan penyimpanan aman sebelum rilis. Jangan menyimpan password atau membuat akses driver.
