# Workflow: Ajukan Tebengan (Modul 2 — FR-05, FR-06)

> Dokumen ini menjelaskan **satu alur lengkap** dari memilih tebengan hingga
> permintaan terkirim dan daftar pesanan diperbarui.  
> Nama file, kelas, dan fungsi di bawah adalah yang **sebenarnya ada di repo**,
> bukan nama contoh.

---

## Peta File

```
lib/
├── features/booking/
│   ├── models/booking.dart               — Booking, BookingStatus, BookingTimeline
│   ├── data/
│   │   ├── booking_repository.dart       — abstract BookingRepository
│   │   ├── local_booking_repository.dart — LocalBookingRepository (fake/in-memory)
│   │   └── fixtures/demo_bookings.dart   — data awal simulasi
│   ├── viewmodels/
│   │   ├── ajukan_tebengan_view_model.dart  — AjukanTebenganViewModel
│   │   └── pesanan_saya_view_model.dart     — PesananSayaViewModel
│   └── views/
│       ├── ajukan_tebengan_screen.dart      — AjukanTebenganScreen
│       └── pesanan_saya_screen.dart         — PesananSayaScreen
├── shared/views/ride_detail_screen.dart  — entry point pertama ke alur ini
└── routes/app_routes.dart               — named route & return type
test/features/booking/
├── booking_repository_test.dart
├── booking_view_models_test.dart
└── booking_widgets_test.dart
```

---

## Lima Tahap Alur

### Tahap 1 — Event (Pemicu)

**Pengguna menekan tombol "Minta Tebengan" di `RideDetailScreen`.**

```
lib/shared/views/ride_detail_screen.dart
  └── _RideDetailScreenState._requestToJoin()    ← dipanggil oleh ElevatedButton
```

`_requestToJoin()` memanggil `_viewModel.requestToJoin(_pickupController.text)`
dari `RideDetailViewModel` (Modul 1/shared — bukan milik Modul 2).  
Jika lolos validasi awal, baru push ke layar Ajukan Tebengan:

```dart
// ride_detail_screen.dart  _requestToJoin()
final result = await Navigator.pushNamed<Object?>(
  context,
  AppRoutes.ajukanTebengan,   // '/ajukan-tebengan'
  arguments: _viewModel.ride, // objek Ride dikirim sebagai argumen
);
```

---

### Tahap 2 — State (Data yang Mengalir ke Layar)

`AppRoutes.onGenerateRoute` membaca argumen dan membangun layar:

```dart
// lib/routes/app_routes.dart
case ajukanTebengan:
  final arguments = settings.arguments;
  if (arguments is Ride) {
    return MaterialPageRoute<Booking>(   // ← return type Booking untuk pop
      builder: (_) => AjukanTebenganScreen(ride: arguments),
    );
  }
```

Di dalam `AjukanTebenganScreen`, ViewModel dibuat dengan repository dari DI:

```dart
// lib/features/booking/views/ajukan_tebengan_screen.dart
// _AjukanTebenganScreenState.didChangeDependencies()
_viewModel = AjukanTebenganViewModel(ride: widget.ride, repository: _repository);
```

`AjukanTebenganViewModel` menyimpan:
- `ride` — data tebengan yang dipilih
- `_isSubmitting` → getter `isSubmitting` — status loading
- `_errorMessage` → getter `errorMessage` — pesan error terakhir

Tidak ada `BuildContext` atau controller di ViewModel.

---

### Tahap 3 — Validation (Aturan Bisnis)

Validasi dilakukan di ViewModel, **bukan** di View:

```dart
// lib/features/booking/viewmodels/ajukan_tebengan_view_model.dart

String? validatePickup(String? value) {
  if (value == null || value.trim().isEmpty) return 'Titik jemput wajib diisi';
  if (value.trim().length < 3) return 'Titik jemput minimal 3 karakter';
  return null;
}

String? validateNote(String? value) {
  if (value != null && value.trim().isNotEmpty && value.trim().length < 3)
    return 'Catatan minimal 3 karakter bila diisi';
  return null;
}
```

View hanya memanggil `_formKey.currentState?.validate()` yang secara otomatis
memanggil validator di setiap `TextFormField` (yang diteruskan dari VM):

```dart
// lib/features/booking/views/ajukan_tebengan_screen.dart
// _buildPickupField()
validator: _viewModel.validatePickup,
```

---

### Tahap 4 — Feedback (UI saat Proses Berlangsung)

Pengguna menekan tombol **"Kirim Permintaan!"** → `_submit()` dipanggil:

```dart
// lib/features/booking/views/ajukan_tebengan_screen.dart
Future<void> _submit() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;  // ← validasi dulu

  final booking = await _viewModel.submitBooking(
    pickup: _pickupController.text,
    note: _noteController.text,
  );
  ...
}
```

Di dalam `AjukanTebenganViewModel.submitBooking()`:

```dart
// lib/features/booking/viewmodels/ajukan_tebengan_view_model.dart
_isSubmitting = true;   // ← tombol nonaktif, teks berubah "Mengirim..."
publish();              // ← ListenableBuilder di View rebuild
try {
  final booking = await repository.createBooking(...);
  return booking;
} catch (e) {
  _errorMessage = e.toString().replaceFirst('Exception: ', '');
  return null;
} finally {
  _isSubmitting = false;
  publish();
}
```

Di View, tombol merespons `_viewModel.isSubmitting`:

```dart
// lib/features/booking/views/ajukan_tebengan_screen.dart
// _buildSubmitButton()
AppButton(
  onPressed: _viewModel.isSubmitting ? null : _submit,  // nonaktif saat loading
  label: _viewModel.isSubmitting ? 'Mengirim...' : 'Kirim Permintaan!',
)
```

**Jika gagal** (repository melempar Exception):
```dart
// _submit() setelah await
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(
      _viewModel.errorMessage ?? 'Gagal mengirim. Coba lagi ya.'
    )),
  );
  // User tetap di form
}
```

---

### Tahap 5 — Navigation / Result (Alur Kembali)

**Jika berhasil**, `_submit()` memanggil `Navigator.pop` dengan objek booking:

```dart
// lib/features/booking/views/ajukan_tebengan_screen.dart  _submit()
Navigator.pop(context, booking);   // ← tutup AjukanTebengan, kirim Booking ke pemanggil
```

**Pemanggil dari `RideDetailScreen`** menerima result dan:
1. Tampilkan SnackBar `'Permintaan terkirim! Tunggu kabar ya.'`
2. `pushNamedAndRemoveUntil` ke `PesananSaya`

```dart
// lib/shared/views/ride_detail_screen.dart  _requestToJoin()
if (result != null) {
  ScaffoldMessenger.of(context).showSnackBar(...);
  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.pesananSaya, (r) => false);
}
```

**Pemanggil dari `PesananSayaScreen`** (jalur `initialRide`) menerima result dan:
```dart
// lib/features/booking/views/pesanan_saya_screen.dart  _ajukanTebengan()
if (result != null) {
  _viewModel.markNewBooking(result.id);   // ← VM publish, ListenableBuilder rebuild
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Permintaan terkirim! Tunggu kabar ya.')),
  );
}
```

`PesananSayaViewModel.markNewBooking()` menyimpan ID ke `_newBookingId` dan
memanggil `publish()`. View membaca `_viewModel.isNew(booking.id)` di
`ListenableBuilder` — **tanpa `setState`**, sesuai aturan arsitektur MVVM.

---

## Cara Memicu Jalur Gagal Kirim

Buka file berikut dan ubah **satu baris**:

```dart
// lib/features/booking/data/local_booking_repository.dart
// Di dalam LocalBookingRepository — constructor default:
//   simulateSendError: false  ← ini kondisi normal

// Untuk demo jalur gagal, buat instance dengan:
LocalBookingRepository(simulateSendError: true)
```

Atau ubah nilai default di constructor:
```dart
this.simulateSendError = false,  // ← ubah ke true, simpan, hot reload
```

Akibatnya: `createBooking()` melempar `Exception('Gagal mengirim...')`,
yang ditangkap `AjukanTebenganViewModel.submitBooking()` dan diisi ke
`errorMessage`. View menampilkan SnackBar `'Gagal mengirim. Coba lagi ya.'`
dan user **tetap di form**.

---

## Lima Latihan "Coba Ubah…"

Latihan berikut dirancang agar singkat, targetnya jelas, dan bisa dijelaskan
dalam 2–3 kalimat saat demo.

### 1. Ubah pesan SnackBar sukses
**File:** `lib/features/booking/views/pesanan_saya_screen.dart`  
**Fungsi:** `_ajukanTebengan()`  
Cari `'Permintaan terkirim! Tunggu kabar ya.'` dan ganti dengan pesan lain.
Tekan tombol Kirim — SnackBar ikut berubah.  
*Pelajaran: pesan UI disimpan di View, bukan di ViewModel.*

### 2. Nonaktifkan tombol Kirim sama sekali (bukan hanya saat loading)
**File:** `lib/features/booking/viewmodels/ajukan_tebengan_view_model.dart`  
**Fungsi:** `AjukanTebenganViewModel` — tambah getter `bool get canSubmit`  
Tambahkan kondisi (misalnya panjang pickup > 10), lalu di View ganti `onPressed`
menjadi `_viewModel.canSubmit && !_viewModel.isSubmitting ? _submit : null`.  
*Pelajaran: logika aktif/nonaktif tombol ada di ViewModel, View hanya membaca.*

### 3. Ubah batas minimal karakter alamat jemput
**File:** `lib/features/booking/viewmodels/ajukan_tebengan_view_model.dart`  
**Fungsi:** `validatePickup()`  
Ganti angka `3` menjadi nilai lain (misalnya `10`). Isi form dengan < 10 karakter
dan tekan Kirim — error validasi muncul.  
*Pelajaran: aturan validasi terisolasi di ViewModel, mudah diubah.*

### 4. Aktifkan simulasi gagal kirim
**File:** `lib/features/booking/data/local_booking_repository.dart`  
**Kelas:** `LocalBookingRepository` — parameter `simulateSendError`  
Ubah `simulateSendError: false` menjadi `true` di tempat repository dibuat
(misalnya di test atau di `main.dart` sementara untuk demo). Tekan Kirim —
SnackBar `'Gagal mengirim. Coba lagi ya.'` muncul dan form tidak ditutup.  
*Pelajaran: perilaku gagal dikontrol di satu tempat di lapisan data.*

### 5. Tambah status "Dijadwalkan" baru
**File:** `lib/features/booking/models/booking.dart`  
**Kelas:** `BookingStatus` (enum)  
Tambahkan nilai `dijadwalkan` dengan `label` dan `tone` yang sesuai. Perhatikan
bahwa kode yang memaksa exhaustive switch (seperti di `simulateStatusChange`)
akan langsung memberikan error compile — bagus, artinya kode aman.  
*Pelajaran: enum + exhaustive switch memaksa kita menangani semua kasus baru.*
