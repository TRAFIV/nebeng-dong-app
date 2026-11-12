# Server Nebeng Dong

REST API dan panel admin untuk aplikasi Nebeng Dong: Laravel 13, Sanctum (token
login), Filament 5 (panel admin), MySQL 8.4, dijalankan dengan Docker.

- Kontrak API: [`../docs/api/kontrak-api.md`](../docs/api/kontrak-api.md)
- Sisi aplikasi Flutter: [`../docs/architecture/panduan-backend-flutter.md`](../docs/architecture/panduan-backend-flutter.md)

Semua data aplikasi disimpan di database server ini, bukan di layanan pihak
ketiga. Tindakan pengemudi (posting rute, terima/tolak, selesaikan perjalanan,
konfirmasi pembayaran) dilakukan admin di panel `/admin`.

## 1. Menjalankan di laptop

Butuh: Docker Desktop (menyala) dan Git. Tidak perlu memasang PHP/Composer.

```bash
cd server
cp .env.example .env
# Isi DB_PASSWORD, DB_ROOT_PASSWORD dan ADMIN_PASSWORD di .env (bebas, asal tidak kosong).

docker compose up -d                                  # pertama kali ±1 menit (composer install otomatis)
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate --seed    # tabel + admin + data demo
```

| Alamat | Isi |
|---|---|
| http://localhost:8000/up | cek server hidup |
| http://localhost:8000/api/v1/rides | daftar rute (JSON) |
| http://localhost:8000/admin | panel admin — masuk dengan `ADMIN_EMAIL` / `ADMIN_PASSWORD` |

Akun penumpang demo: `mikail@student.unand.ac.id` / `nebengdong`.

Perintah yang sering dipakai:

```bash
docker compose exec app php artisan test        # tes server
docker compose exec app php artisan migrate     # setelah ada migrasi baru dari teman
docker compose exec app composer install        # setelah composer.json berubah
docker compose logs -f app                      # melihat log
docker compose down                             # mematikan (data tetap tersimpan)
```

## 2. Menyambungkan aplikasi Flutter

Server di laptop memakai `http://`. Build **debug** aplikasi sudah diizinkan
memakai `http://`; build rilis tetap wajib HTTPS.

Dengan HP tersambung kabel USB:

```bash
adb reverse tcp:8000 tcp:8000
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Tanpa `API_BASE_URL`, aplikasi tetap memakai data latihan. Di layar Hasil, tulisan
"Data latihan" hilang bila data datang dari server.

## 3. Menambah endpoint modulmu

Ikuti contoh modul Rute. Urutannya:

| Langkah | Contoh Rute | Perintah pembuat |
|---|---|---|
| 1. Tabel | `database/migrations/*_create_rides_table.php` | `php artisan make:migration create_bookings_table` |
| 2. Model + factory | `app/Models/Ride.php`, `database/factories/RideFactory.php` | `php artisan make:model Booking -f` |
| 3. Bentuk JSON (sesuai kontrak) | `app/Http/Resources/RideResource.php` | `php artisan make:resource BookingResource` |
| 4. Controller | `app/Http/Controllers/Api/RideController.php` | `php artisan make:controller Api/BookingController` |
| 5. Alamat | `routes/api.php` (di dalam grup `auth:sanctum` bila butuh login) | — |
| 6. Panel admin | `app/Filament/Resources/Rides/` | `php artisan make:filament-resource Booking --generate` |
| 7. Tes | `tests/Feature/Api/RideApiTest.php`, `tests/Feature/Admin/RideAdminTest.php` | `php artisan make:test Api/BookingApiTest` |

Jalankan perintah pembuat di dalam container, misalnya
`docker compose exec app php artisan make:model Booking -f`.

Aturan bersama:

- Pesan error untuk pengguna dalam Bahasa Indonesia. Validasi menulis pesan
  sendiri (lihat `AuthController::login`); format `{message, errors}` sudah diatur
  di `bootstrap/app.php`.
- Data milik penumpang hanya boleh dibaca pemiliknya: ambil lewat
  `$request->user()`, jangan dari ID yang dikirim aplikasi.
- Data pribadi (nomor HP pengemudi, email orang lain) tidak dikirim ke aplikasi.
- Setiap endpoint punya tes: satu jawaban benar, satu isian salah, satu tanpa
  login/bukan pemilik.

## 4. Memasang di VPS

Butuh: VPS Linux dengan Docker + Docker Compose, Git, dan **domain/subdomain**
yang mengarah ke IP VPS (untuk HTTPS gratis dari Let's Encrypt).

```bash
git clone https://github.com/TRAFIV/nebeng-dong-app.git
cd nebeng-dong-app/server
cp .env.example .env
```

Ubah `.env`:

```text
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.namadomain.com
API_DOMAIN=api.namadomain.com
APP_PORT=127.0.0.1:8000
DB_PASSWORD=<acak, panjang>
DB_ROOT_PASSWORD=<acak, panjang>
ADMIN_EMAIL=<email admin>
ADMIN_PASSWORD=<kuat>
```

Lalu:

```bash
docker compose --profile https up -d
docker compose exec app php artisan key:generate --force
docker compose exec app php artisan migrate --seed --force    # production: hanya akun admin
docker compose exec app php artisan db:seed --class=DemoSeeder --force   # opsional: data demo
```

Buka port 80 dan 443 di firewall VPS. API tersedia di
`https://api.namadomain.com/api/v1` dan aplikasi dijalankan dengan
`--dart-define=API_BASE_URL=https://api.namadomain.com/api/v1`.

Memperbarui server setelah ada perubahan di GitHub:

```bash
git pull
docker compose exec app composer install --no-dev --optimize-autoloader
docker compose exec app php artisan migrate --force
docker compose exec app php artisan optimize
```

Jangan pernah menyimpan `.env` di Git; file itu berisi kata sandi.
