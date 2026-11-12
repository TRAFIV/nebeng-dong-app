# Kontrak REST API Nebeng Dong — DRAF

> Status: **draf untuk disepakati tim**. Konvensi umum, Akun dasar dan Rute
> sudah dibuat di server (`server/`, Laravel) dan aplikasi (`lib/core/network/`,
> `RemoteRideRepository`). Bagian modul lain masih kerangka; pemilik modul
> mengisi bentuk JSON-nya lalu tim menyetujui sebelum server dan aplikasi dibuat.
> Cara menjalankan server dan menambah endpoint: `server/README.md`.

Keputusan dasar (PROGRESS 3 November 2026):

- Server milik kelompok sendiri, REST + JSON. Data **tidak** dikelola di layanan
  pihak ketiga (Supabase/Firebase dsb.).
- Aplikasi mobile hanya role **penumpang**. Tindakan pengemudi (posting rute,
  terima/tolak, selesaikan perjalanan, konfirmasi pembayaran) dilakukan **admin**
  lewat panel admin di server.
- **FCM hanya untuk notifikasi.** Isi notifikasi cukup jenis dan ID; aplikasi
  mengambil data terbarunya dari REST API.

## 1. Konvensi umum (berlaku untuk semua endpoint)

| Hal | Aturan |
|---|---|
| Alamat dasar | `https://<server>/api/v1`, diisi lewat `--dart-define=API_BASE_URL=...` |
| Format | JSON UTF-8, nama kolom `snake_case` |
| ID | dikirim sebagai angka atau teks; aplikasi menyimpannya sebagai teks |
| Waktu | tanggal-waktu ISO 8601 (`2026-11-12T07:30:00+07:00`); jam cabut rute boleh teks `HH.mm` |
| Uang | rupiah bulat (`int`), tanpa desimal |
| Koordinat | objek tempat memakai `lat`/`lng`; garis jalur memakai urutan GeoJSON `[lng, lat]` |
| Login | header `Authorization: Bearer <token>` dari `POST /auth/login` |
| Sukses | `{"data": ...}`; kode 200/201, atau 204 tanpa isi |
| Gagal | `{"message": "Pesan untuk pengguna", "errors": {"kolom": ["pesan"]}}` |

Kode status dan artinya di aplikasi (`ApiErrorKind`):

| Kode | Arti | Contoh |
|---|---|---|
| 401 | `unauthorized` — belum masuk / token kedaluwarsa | aplikasi kembali ke Login |
| 403 | `forbidden` — bukan datanya | membuka pesanan orang lain |
| 404 | `notFound` | pesanan sudah dihapus |
| 409 | `conflict` — bentrok dengan keadaan data | kursi sudah penuh, rating ganda |
| 422 | `validation` — isian ditolak; detail di `errors` | titik jemput kosong |
| 5xx | `server` | server bermasalah |

`message` sebaiknya kalimat Bahasa Indonesia yang ramah, karena aplikasi
menampilkannya apa adanya.

## 2. Endpoint per modul

| Modul (pemilik) | Metode & alamat | Keterangan |
|---|---|---|
| Akun (Duha) | `POST /auth/login` | **sudah ada (dasar)**: `{email, password}` → `{token, user: {id, name, email, role}}`; salah → 422 |
| | `POST /auth/logout` | **sudah ada**: mencabut token, 204 |
| | `GET /me` | **sudah ada**: profil penumpang yang masuk |
| | `POST /devices` | `{fcm_token}`; mendaftarkan HP untuk notifikasi |
| Rute (Mikail) | `GET /rides` | **sudah ada**: tebengan aktif yang belum penuh, boleh tanpa login — **bagian 3** |
| Pesanan (Taris) | `GET /bookings` | pesanan milik penumpang |
| | `GET /bookings/{id}` | detail satu pesanan |
| | `POST /bookings` | `{ride_id, pickup_location, note?}` |
| | `POST /bookings/{id}/cancel` | batal sesuai aturan status |
| Ongkos (Shiddiq) | `GET /cost-shares` | ongkos milik penumpang |
| | `POST /cost-shares/{id}/declare-payment` | "Sudah bayar"; idempotent |
| Rating (Duha) | `GET /trips?status=completed` | riwayat perjalanan selesai |
| | `POST /trips/{id}/rating` | `{score: 1..5, comment}`; 409 bila sudah dinilai |
| Admin (server) | panel web | posting rute, terima/tolak, selesaikan perjalanan, konfirmasi bayar — tidak dipakai aplikasi mobile |

Daftar status yang disepakati:

- pesanan: `waiting`, `accepted`, `rejected`, `cancelled`
- pembayaran: `unreported`, `awaiting_confirmation`, `confirmed`
- perjalanan: `scheduled`, `completed`

## 3. Rute — `GET /rides` (sudah dipakai aplikasi)

Mengembalikan tebengan aktif yang belum penuh. Pencocokan "searah" untuk saat
ini tetap dihitung di aplikasi (`RouteMatcher`), jadi server cukup mengirim jalur
lengkap tiap rute.

```json
{
  "data": [
    {
      "id": 7,
      "driver": { "name": "Taris Rafivdean", "rating": 4.8, "trip_count": 32 },
      "origin": {
        "label": "Jl. Khatib Sulaiman",
        "address": "Jalan Khatib Sulaiman, Ulak Karang Utara, Padang",
        "lat": -0.9099249,
        "lng": 100.3548088
      },
      "destination": {
        "label": "Kampus Unand Limau Manis",
        "address": "Universitas Andalas, Limau Manis, Padang",
        "lat": -0.9148733,
        "lng": 100.4627099
      },
      "schedule": "Senin–Jumat",
      "departure_time": "07.30",
      "seat_capacity": 3,
      "seats_available": 2,
      "fare_per_person": 5000,
      "route": {
        "distance_m": 13400,
        "duration_s": 1500,
        "coordinates": [[100.3548088, -0.9099249], [100.4627099, -0.9148733]]
      }
    }
  ]
}
```

| Kolom | Tipe | Wajib | Catatan |
|---|---|---|---|
| `id` | angka/teks | ya | |
| `driver.name`, `driver.rating`, `driver.trip_count` | teks, angka, bulat | ya | profil publik saja, tanpa email/HP |
| `origin`, `destination` | objek tempat | ya | `address` boleh tidak ada |
| `schedule` | teks | ya | contoh `Senin–Jumat` |
| `departure_time` | teks `HH.mm` | ya | dipakai filter jam |
| `seat_capacity`, `seats_available` | bulat | ya | sisa kursi dihitung server (FR-04) |
| `fare_per_person` | bulat | ya | `0` = ongkos belum diatur, bukan gratis |
| `route.coordinates` | daftar `[lng, lat]` | ya | minimal 2 titik |
| `route.distance_m`, `route.duration_s` | angka | ya | jarak > 0 |

Pembaca JSON-nya: `lib/features/ride_search/data/ride_json.dart`.

## 4. Pesanan, Ongkos, Akun, Rating — diisi pemilik modul

Untuk setiap endpoint di bagian 2, pemilik menuliskan contoh JSON dan tabel
kolom seperti bagian 3, termasuk pesan error yang mungkin (422/409). Setelah
disetujui, bentuk ini menjadi acuan server dan `*_json.dart` di aplikasi.

## 5. Notifikasi (FCM)

Server mengirim notifikasi saat admin mengubah status. Isi data cukup:

```json
{ "type": "booking", "id": "123" }
```

`type`: `booking`, `cost_share`, `trip`. Aplikasi lalu memuat ulang repository
terkait dari REST API. Tidak ada data aplikasi lain yang dikirim lewat FCM.
