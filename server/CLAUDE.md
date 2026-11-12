# CLAUDE.md — server Nebeng Dong

Server Laravel untuk aplikasi Nebeng Dong. Baca juga `../CLAUDE.md`,
`../docs/progress/PROGRESS.md`, dan `README.md` di folder ini.

- Jalankan semua perintah PHP/Composer/Artisan **di dalam container**:
  `docker compose exec app <perintah>`. Jangan memasang PHP/Composer di mesin
  pengguna.
- Kontrak API ada di `../docs/api/kontrak-api.md`; bentuk JSON Resource harus
  sama dengan kontrak dan dengan pembaca `*_json.dart` di aplikasi.
- Pola acuan: modul Rute (`RideController`, `RideResource`, `RideResource` Filament,
  `RideApiTest`, `RideAdminTest`). Langkah menambah modul: `README.md` bagian 3.
- Aplikasi mobile hanya role penumpang; tindakan pengemudi lewat panel admin.
- Pesan untuk pengguna dalam Bahasa Indonesia; data milik penumpang diambil
  lewat `$request->user()`; data pribadi pengemudi tidak dikirim ke aplikasi.
- Jangan commit `.env`. Setiap perubahan disertai tes dan catatan di PROGRESS.
