# Panduan Menyambungkan Modul ke Server

Untuk setiap anggota. Fondasinya sudah tersedia; kamu cukup membuat pembaca
JSON dan repository Remote untuk modulmu, mengikuti contoh modul Rute.

## 1. Yang sudah tersedia (jangan dibuat ulang)

| File | Gunanya |
|---|---|
| `lib/core/network/api_config.dart` | alamat server dari `--dart-define=API_BASE_URL`, batas waktu 15 detik |
| `lib/core/network/api_client.dart` | `get/post/put/patch/delete`; header JSON, token, timeout, buka `{"data": ...}`, ubah kegagalan jadi `ApiException` |
| `lib/core/network/api_exception.dart` | satu jenis error; `message` sudah ramah dan boleh ditampilkan, `fieldErrors` untuk pesan per kolom (422) |
| `lib/core/network/json_reader.dart` | `read<T>`, `readDouble`, `readMap`, `readMapList`, `parseResponse` — kolom salah langsung jadi `invalidResponse` |
| `lib/core/network/token_store.dart` | simpan/baca/hapus token login |
| `lib/core/di/api_client_scope.dart` | menyediakan `ApiClient` (atau `null` bila server tidak diisi) |
| `docs/api/kontrak-api.md` | konvensi, daftar endpoint, contoh JSON |

**Contoh lengkap:** `lib/features/ride_search/data/ride_json.dart`,
`remote_ride_repository.dart`, tesnya di
`test/features/ride_search/remote_ride_repository_test.dart`, dan provider di
`lib/core/di/ride_repository_scope.dart`.

## 2. Aturan pembagian lapisan

```text
View  →  ViewModel  →  Repository (kontrak)  →  RemoteXxxRepository  →  ApiClient  →  server
                              └──────────────→  LocalXxxRepository (data latihan)
```

- View dan ViewModel **tidak boleh** memakai `http` atau `ApiClient`; dijaga tes
  `test/architecture/architecture_test.dart`.
- Pembaca JSON ada di folder `data/` modul, bukan di model.
- Versi lokal tetap disimpan: dipakai tes dan saat server belum diisi.

## 3. Langkah untuk modulmu

1. **Isi kontrak** di `docs/api/kontrak-api.md` bagian 4: contoh JSON dan tabel
   kolom endpoint modulmu. Minta persetujuan tim.
2. **Pembaca JSON** `lib/features/<modul>/data/<nama>_json.dart`:

   ```dart
   import 'package:praktikum_mobile/core/network/json_reader.dart';

   Booking bookingFromJson(Object? value) {
     final json = asJsonMap(value);
     return Booking(
       id: json.read<Object>('id').toString(),
       pickupLocation: json.read<String>('pickup_location'),
       note: json.readOrNull<String>('note'),
       // ... kolom lain sesuai kontrak
     );
   }

   List<Booking> bookingsFromJson(Object? value) =>
       asJsonMapList(value).map(bookingFromJson).toList();
   ```

3. **Repository Remote** `lib/features/<modul>/data/remote_<nama>_repository.dart`:

   ```dart
   class RemoteBookingRepository extends BookingRepository {
     RemoteBookingRepository(this._api);
     final ApiClient _api;
     List<Booking> _bookings = const [];

     @override
     bool get isSimulation => false;

     @override
     Future<List<Booking>> fetchBookings({bool simulateError = false}) async {
       final json = await _api.get('bookings');
       _bookings = List.unmodifiable(parseResponse(json, bookingsFromJson));
       notifyListeners(); // layar yang mendengarkan ikut diperbarui
       return _bookings;
     }

     @override
     Future<Booking> createBooking({...}) async {
       final json = await _api.post('bookings', body: {
         'ride_id': ride.id,
         'pickup_location': pickupLocation,
         if (note != null) 'note': note,
       });
       // ...
     }
   }
   ```

   Jangan menangkap error di repository; biarkan `ApiException` naik ke
   ViewModel.
4. **ViewModel** menampilkan pesannya:

   ```dart
   } catch (error) {
     _errorMessage = error is ApiException ? error.message : 'Pesan umum';
     // untuk form: error.fieldErrors['pickup_location']
   }
   ```

5. **Provider** di `lib/core/di/<modul>_repository_scope.dart`: buat repository
   bawaan di `didChangeDependencies` dan pilih Remote bila
   `ApiClientScope.maybeOf(context)` tidak `null` — salin pola
   `ride_repository_scope.dart`.
6. **Tes** dengan `MockClient` dari `package:http/testing.dart` — salin pola
   `remote_ride_repository_test.dart`: satu tes JSON benar, satu tes kolom
   wajib hilang.

## 4. Hal yang perlu diputuskan pemilik modul

Beberapa anggota kontrak repository dibuat untuk data latihan dan perlu
disesuaikan saat pindah ke server:

| Modul | Anggota kontrak | Catatan |
|---|---|---|
| Pesanan (Taris) | `sampleRideForSimulation` | khusus simulasi; dengan server, form pesanan menerima `Ride` dari hasil pencarian |
| Pesanan (Taris) | `getBookingById` (sinkron) | cukup dari daftar yang sudah dimuat, atau ganti `GET /bookings/{id}` |
| Ongkos (Shiddiq) | `declarePayment` | 409/422 dari server menggantikan `CostRepositoryException` |
| Rating (Duha) | parameter `userId`, `resetDemo` | dengan login, server tahu penggunanya dari token; `resetDemo` hanya untuk demo |
| Semua | `simulateError` | hanya untuk latihan lokal; Remote mengabaikannya |

## 5. Menjalankan dengan server

```text
flutter run --dart-define=API_BASE_URL=https://alamat-server/api/v1
```

- Tanpa `API_BASE_URL`, aplikasi memakai data latihan seperti biasa.
- Android menolak `http://` biasa. Pakai **HTTPS**; bila server uji hanya HTTP,
  bahas dulu konfigurasi khusus debug, jangan dimatikan untuk rilis.
- Token login disimpan dengan SharedPreferences (belum terenkripsi). Ganti ke
  penyimpanan aman sebelum rilis; cukup buat implementasi `TokenStore` baru.
