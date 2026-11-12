# Modul 3 — Berbagi Ongkos

Pemilik: Shiddiq, FR-09–12. Branch kerja: `feat/modul-3-ongkos`.

## Keputusan tim (Oktober 2026)

- Ongkos memakai **tarif tetap per penumpang** dari rute (`Ride.farePerPerson`), jadi bagian penumpang sama dengan tarif itu. Tidak ada pembagian total atau pembulatan.
- Ongkos kosong/0 ditampilkan **Belum diatur**, tidak pernah dianggap gratis.
- Status pembayaran: belum dilaporkan → menunggu konfirmasi → terkonfirmasi.
- "Sudah bayar" hanya bisa setelah perjalanan selesai, dan hanya deklarasi penumpang. Konfirmasi adalah otoritas backend/admin; aplikasi penumpang tidak punya tombol konfirmasi.
- Riwayat Ongkos hanya berisi perjalanan selesai; pesanan batal tidak ditampilkan. Rekap agregat di Profil adalah bagian Modul 4 (Duha).

## Isi folder

| Bagian | File |
|---|---|
| Model | `models/cost_share.dart` — CostShare, PaymentStatus, FareStage |
| Aturan | `utils/payment_rules.dart` — kapan "Sudah bayar" boleh dikirim |
| Data | `data/cost_repository.dart` (kontrak), `data/local_cost_repository.dart` + `data/fixtures/` (data latihan) |
| ViewModel | `viewmodels/cost_history_view_model.dart`, `viewmodels/cost_share_view_model.dart` |
| View | `views/cost_history_screen.dart` (Riwayat), `views/cost_detail_screen.dart` (Rincian), `views/payment_status_screen.dart` (Status) |

Repository sesi dipasang di root lewat `core/di/cost_repository_scope.dart`, jadi deklarasi terlihat sama di ketiga layar.

## Batas dan yang belum

- Data masih fixture lokal; deklarasi hilang saat aplikasi ditutup. Fixture memberi contoh semua status supaya konfirmasi bisa didemokan tanpa backend.
- `bookingId` di fixture adalah contoh. Saat Modul 2 (Taris) punya model pesanan, CostShare dibuat dari pesanan yang diterima/selesai.
- Adapter API belum dibuat karena endpoint/kontrak backend belum disepakati.
