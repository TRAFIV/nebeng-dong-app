# Panduan UTS: Workflow Konfirmasi Pembayaran (Modul 3 — Berbagi Ongkos)

Pemilik: **M Shiddiq Maihendra (2411523035)** · Proyek: Nebeng Dong · Tugas: Practical Challenge "Build One Complete Workflow"

> Dokumen ini ditulis ulang dari kode **yang benar-benar ada di repo** (branch `uts-modul3-konfirmasi-pembayaran`). Semua blok kode ditempel otomatis dari file aslinya, jadi harus sama dengan yang ada di editor. Ini menggantikan panduan awal yang berisi rencana (form nominal, dialog "Udah bayar beneran?", saklar demo gagal) dan sudah berubah di bagian itu.

## Status verifikasi (jujur)

| Pemeriksaan | Hasil |
|---|---|
| `dart format --set-exit-if-changed .` | lulus, 0 perubahan |
| `flutter analyze` | No issues found |
| `flutter test` (seluruh proyek) | 129 tes lulus (110 lama + 19 baru di `test/features/costs/`) |
| Dicoba langsung di Chrome oleh pemilik | alur utama dicoba dan dinyatakan OK; belum dicoba di HP |
| Backend sungguhan | **tidak ada**. Data dan "konfirmasi driver" adalah fixture lokal |

Batasan yang perlu kamu ingat saat presentasi:
- Repository memakai data palsu di memori (`LocalCostRepository`). Tidak ada REST API.
- Status "Lunas" tidak bisa dicapai penumpang. Itu keputusan backend/admin (PRD 1.1). Penumpang hanya sampai "Menunggu konfirmasi".
- Tombol **Demo Ongkos** di Beranda hanya jalan saat debug. Itu pintu masuk sementara, bukan fitur akhir.

## Gambaran besar

Penumpang membuka **Rincian Ongkos**, ke **Konfirmasi Pembayaran**, mencentang "udah bayar", lalu kembali ke Rincian dengan status baru.

```
[Beranda] --tap "Demo Ongkos"--> [Rincian Ongkos]
                                     | tap "Konfirmasi Pembayaran"
                                     | (DATA dikirim: rincian ongkos + repository)
                                     v
                             [Konfirmasi Pembayaran]
                               centang "Aku udah bayar ..." → VALIDASI
                               tap "Udah Bayar!" → loading (Lagi ngirim...)
                               gagal → banner error + tombol "Coba Lagi"
                               berhasil → dialog "Konfirmasi driver" → Ok
                                     | Navigator.pop(context, hasil)
                                     | (RESULT dikirim balik)
                                     v
                             [Rincian Ongkos] → snackbar + badge "Menunggu konfirmasi"
```

| Tahap (syarat tugas) | Yang terjadi di aplikasi | Lokasi di kode |
|---|---|---|
| **Input / Event** | Tap "Konfirmasi Pembayaran", centang kotak "Aku udah bayar...", tap "Udah Bayar!", tap "Ok" di dialog | `_openConfirmation()` di `cost_detail_screen.dart`; `CheckboxListTile` dan `_onSubmitPressed()` di `payment_confirmation_screen.dart` |
| **State** | `isPaidChecked`, `validationError`, `isSubmitting`, `errorMessage`; status pembayaran berubah Belum bayar → Menunggu konfirmasi | `PaymentConfirmationViewModel`, `PaymentStatus` |
| **Validation** | Wajib mencentang sebelum kirim; status harus masih "Belum bayar"; repository memeriksa ulang status dan nominal | `validate()`, `canSubmit`, `submit()`, `LocalCostRepository.declarePayment()` |
| **Feedback** | Teks merah jika belum dicentang, loading + teks "Lagi ngirim...", banner error + "Coba Lagi", dialog "Konfirmasi driver", snackbar sukses | `payment_confirmation_screen.dart`, `cost_detail_screen.dart` |
| **Navigation / Result** | Data lewat `arguments`; hasil kembali lewat `Navigator.pop(context, updated)` dan diterima `applyResult()` | `PaymentConfirmationArguments`, `AppRoutes`, `_openConfirmation()` |

Arsitektur MVVM sesuai aturan repo:
- **Model**: data dan aturan murni, tanpa Flutter.
- **Repository**: sumber data. Sekarang palsu, nanti bisa diganti API.
- **ViewModel**: state, validasi, command. Tidak tahu `BuildContext`, `Navigator`, atau widget.
- **View**: tampilan, dialog, snackbar, navigasi. Membaca ViewModel lewat `ListenableBuilder`, tanpa `setState`.

## Daftar file

```
lib/features/costs/
├── models/payment_status.dart
├── models/cost_breakdown.dart
├── utils/cost_splitter.dart
├── data/cost_repository.dart
├── data/local_cost_repository.dart
├── viewmodels/cost_detail_view_model.dart
├── viewmodels/payment_confirmation_view_model.dart
├── widgets/payment_status_badge.dart
└── views/cost_detail_screen.dart, payment_confirmation_screen.dart
lib/routes/payment_confirmation_arguments.dart   (baru)
lib/routes/app_routes.dart                       (diubah)
lib/features/ride_search/views/home_screen.dart  (diubah: tombol Demo Ongkos, debug-only)
test/features/costs/
├── cost_models_test.dart
├── payment_confirmation_view_model_test.dart
└── payment_workflow_test.dart
```

## Perbedaan dari rencana awal

| Rencana awal | Yang akhirnya dibuat | Alasan |
|---|---|---|
| Kolom nominal + validasi angka (`validateAmount`) | **Checkbox** "Aku udah bayar Rp... ke driver" + `validate()` | Nominal selalu sama dengan bagian penumpang, jadi mengetik ulang tidak berguna |
| Dialog "Udah bayar beneran?" (2 tombol) | Dialog info **"Konfirmasi driver"**: "Menunggu konfirmasi pembayaran dari driver", tombol **Ok** | Permintaan pemilik; muncul setelah submit berhasil |
| Saklar "Mode demo: gagal kirim sekali" | **Dihapus** dari UI | Permintaan pemilik. `failNextDeclaration` tetap ada di repository karena tes memakainya |
| Data demo Rp10.000 / 3 penumpang | **Rp15.000 / 2 penumpang** (Rp7.500 per orang) | Pemilik mengubah `demoBreakdown()`. Pembulatan sisa tetap dites di `cost_models_test.dart` |
| Konstruktor ViewModel `required CostRepository repository` + initializer | `required this._repository` | Mengikuti lint `prefer_initializing_formals`; nama parameter di pemanggil tetap `repository:` |
| Widget test lebar 360 dp | Lebar **500 dp** | Font tes (Ahem) lebih lebar dari Roboto sehingga badge "Menunggu konfirmasi" tidak muat di 360 dp. Di aplikasi sungguhan memakai Roboto |
| Checkbox di `Container` berwarna | Dibungkus **`Material`** | Flutter menolak `ListTile` yang bisa disentuh di dalam `DecoratedBox` berwarna (efek tap tertutup) |

## Langkah 1 — Model dan algoritma (logika murni)

### `lib/features/costs/models/payment_status.dart`

```dart
/// Status pembayaran ongkos satu penumpang pada satu perjalanan (FR-10, FR-11).
///
/// Alurnya satu arah dan tidak bisa dilompati:
/// belum bayar → menunggu konfirmasi → lunas.
///
/// - belum bayar → menunggu konfirmasi: penumpang menandai "udah bayar"
///   (deklarasi, uangnya dibayar di luar aplikasi).
/// - menunggu konfirmasi → lunas: keputusan sistem/admin, bukan penumpang.
enum PaymentStatus {
  belumBayar('Belum bayar'),
  menungguKonfirmasi('Menunggu konfirmasi'),
  lunas('Lunas');

  const PaymentStatus(this.label);

  /// Teks yang ditampilkan di badge UI.
  final String label;

  /// Status berikutnya dalam alur, atau `null` kalau sudah di akhir.
  PaymentStatus? get next => switch (this) {
    PaymentStatus.belumBayar => PaymentStatus.menungguKonfirmasi,
    PaymentStatus.menungguKonfirmasi => PaymentStatus.lunas,
    PaymentStatus.lunas => null,
  };

  /// `true` hanya kalau [target] adalah langkah tepat berikutnya.
  /// Mundur atau melompat (belum bayar → lunas) selalu ditolak.
  bool canMoveTo(PaymentStatus target) => next == target;

  /// Penumpang hanya boleh menandai "udah bayar" satu kali, saat belum bayar.
  bool get canDeclarePayment => this == PaymentStatus.belumBayar;
}
```

- `enum` tiga nilai, tiap nilai membawa `label` untuk badge.
- `next` memakai *switch expression* Dart 3; `lunas.next` bernilai `null`.
- `canMoveTo()` adalah aturan **state machine**: hanya boleh maju satu langkah.
- `canDeclarePayment` adalah dasar validasi "tidak boleh menandai bayar dua kali".

### `lib/features/costs/utils/cost_splitter.dart`

```dart
/// Algoritma pembagian ongkos perjalanan (FR-09).
abstract final class CostSplitter {
  /// Membagi [total] rupiah ke [passengerCount] penumpang secara rata.
  ///
  /// Rupiah tidak punya pecahan, jadi dipakai pembagian bilangan bulat:
  /// 1. `base = total ~/ passengerCount` → bagian dasar tiap orang.
  /// 2. `remainder = total % passengerCount` → sisa yang belum terbagi.
  /// 3. Sisa dibagikan Rp1 per orang ke penumpang paling awal.
  ///
  /// Hasilnya selalu berjumlah persis [total], tidak ada rupiah yang hilang.
  /// Contoh: `split(10000, 3)` → `[3334, 3333, 3333]`.
  static List<int> split(int total, int passengerCount) {
    if (total <= 0) {
      throw ArgumentError.value(
        total,
        'total',
        'Total ongkos harus lebih dari 0',
      );
    }
    if (passengerCount <= 0) {
      throw ArgumentError.value(
        passengerCount,
        'passengerCount',
        'Jumlah penumpang minimal 1',
      );
    }

    final base = total ~/ passengerCount;
    final remainder = total % passengerCount;
    return List<int>.generate(
      passengerCount,
      (index) => index < remainder ? base + 1 : base,
    );
  }
}
```

Algoritma (wajib hafal):
1. `~/` pembagian bilangan bulat: `10000 ~/ 3 = 3333`.
2. `%` sisa bagi: `10000 % 3 = 1`.
3. `List.generate`: indeks yang `< remainder` mendapat `base + 1`.
4. Hasil `[3334, 3333, 3333]`, jumlahnya tetap 10000. Rupiah tidak punya pecahan.
5. Input tidak masuk akal (total ≤ 0, penumpang ≤ 0) ditolak dengan `ArgumentError`.

### `lib/features/costs/models/cost_breakdown.dart`

```dart
import 'package:praktikum_mobile/features/costs/models/payment_status.dart';
import 'package:praktikum_mobile/features/costs/utils/cost_splitter.dart';

/// Bagian ongkos satu penumpang (entitas CostShare pada PRD 2.5).
class CostShare {
  const CostShare({
    required this.passengerName,
    required this.amount,
    required this.status,
    this.isCurrentUser = false,
  });

  final String passengerName;

  /// Nominal bagian dalam rupiah.
  final int amount;
  final PaymentStatus status;

  /// `true` untuk akun yang sedang login, ditampilkan sebagai "(Kamu)".
  final bool isCurrentUser;

  CostShare copyWith({PaymentStatus? status}) => CostShare(
    passengerName: passengerName,
    amount: amount,
    status: status ?? this.status,
    isCurrentUser: isCurrentUser,
  );
}

/// Rincian ongkos satu perjalanan: total dan bagian tiap penumpang.
class CostBreakdown {
  const CostBreakdown({
    required this.tripId,
    required this.origin,
    required this.destination,
    required this.departureLabel,
    required this.driverName,
    required this.totalFare,
    required this.shares,
  });

  /// Membuat rincian dengan membagi [totalFare] memakai [CostSplitter].
  ///
  /// [currentUserIndex] menandai penumpang yang sedang login.
  /// [initialStatuses] mengisi status awal per indeks; default belum bayar.
  factory CostBreakdown.split({
    required String tripId,
    required String origin,
    required String destination,
    required String departureLabel,
    required String driverName,
    required int totalFare,
    required List<String> passengerNames,
    required int currentUserIndex,
    Map<int, PaymentStatus> initialStatuses = const {},
  }) {
    if (currentUserIndex < 0 || currentUserIndex >= passengerNames.length) {
      throw RangeError.index(
        currentUserIndex,
        passengerNames,
        'currentUserIndex',
      );
    }
    final amounts = CostSplitter.split(totalFare, passengerNames.length);
    return CostBreakdown(
      tripId: tripId,
      origin: origin,
      destination: destination,
      departureLabel: departureLabel,
      driverName: driverName,
      totalFare: totalFare,
      shares: [
        for (var i = 0; i < passengerNames.length; i++)
          CostShare(
            passengerName: passengerNames[i],
            amount: amounts[i],
            status: initialStatuses[i] ?? PaymentStatus.belumBayar,
            isCurrentUser: i == currentUserIndex,
          ),
      ],
    );
  }

  final String tripId;
  final String origin;
  final String destination;

  /// Misalnya "Kamis, 1 Okt · 07.30".
  final String departureLabel;
  final String driverName;
  final int totalFare;
  final List<CostShare> shares;

  int get passengerCount => shares.length;

  /// Bagian milik penumpang yang sedang login.
  CostShare get myShare => shares.firstWhere((share) => share.isCurrentUser);

  /// Salinan rincian dengan status milik penumpang login diganti.
  /// Status penumpang lain tidak berubah.
  CostBreakdown withMyStatus(PaymentStatus status) => CostBreakdown(
    tripId: tripId,
    origin: origin,
    destination: destination,
    departureLabel: departureLabel,
    driverName: driverName,
    totalFare: totalFare,
    shares: [
      for (final share in shares)
        share.isCurrentUser ? share.copyWith(status: status) : share,
    ],
  );
}
```

- `CostShare` adalah bagian satu orang (entitas CostShare di PRD 2.5).
- `CostBreakdown.split(...)` adalah *factory constructor*: nominal dihitung `CostSplitter`, bukan diketik manual.
- `withMyStatus()` membuat salinan baru (*immutable*), data lama tidak diubah.

### Tes: `test/features/costs/cost_models_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';
import 'package:praktikum_mobile/features/costs/models/payment_status.dart';
import 'package:praktikum_mobile/features/costs/utils/cost_splitter.dart';

void main() {
  group('CostSplitter.split', () {
    test('membagi rata kalau habis dibagi', () {
      expect(CostSplitter.split(15000, 3), [5000, 5000, 5000]);
    });

    test('sisa diberikan Rp1 ke penumpang paling awal', () {
      expect(CostSplitter.split(10000, 3), [3334, 3333, 3333]);
      expect(CostSplitter.split(10001, 3), [3334, 3334, 3333]);
    });

    test('jumlah hasil selalu sama dengan total', () {
      for (final total in [1, 7, 9999, 12000, 15001]) {
        for (var n = 1; n <= 5; n++) {
          final parts = CostSplitter.split(total, n);
          expect(parts.length, n);
          expect(parts.reduce((a, b) => a + b), total);
        }
      }
    });

    test('menolak total atau jumlah penumpang tidak valid', () {
      expect(() => CostSplitter.split(0, 3), throwsArgumentError);
      expect(() => CostSplitter.split(-5000, 3), throwsArgumentError);
      expect(() => CostSplitter.split(15000, 0), throwsArgumentError);
    });
  });

  group('PaymentStatus', () {
    test('alur maju satu langkah: belum bayar → menunggu → lunas', () {
      expect(PaymentStatus.belumBayar.next, PaymentStatus.menungguKonfirmasi);
      expect(PaymentStatus.menungguKonfirmasi.next, PaymentStatus.lunas);
      expect(PaymentStatus.lunas.next, isNull);
    });

    test('tidak bisa melompat atau mundur', () {
      expect(
        PaymentStatus.belumBayar.canMoveTo(PaymentStatus.menungguKonfirmasi),
        isTrue,
      );
      expect(PaymentStatus.belumBayar.canMoveTo(PaymentStatus.lunas), isFalse);
      expect(PaymentStatus.lunas.canMoveTo(PaymentStatus.belumBayar), isFalse);
    });

    test('hanya status belum bayar yang boleh menandai udah bayar', () {
      expect(PaymentStatus.belumBayar.canDeclarePayment, isTrue);
      expect(PaymentStatus.menungguKonfirmasi.canDeclarePayment, isFalse);
      expect(PaymentStatus.lunas.canDeclarePayment, isFalse);
    });
  });

  group('CostBreakdown.split', () {
    CostBreakdown build() => CostBreakdown.split(
      tripId: 'trip-1',
      origin: 'Jl. Khatib Sulaiman',
      destination: 'Kampus Unand Limau Manis',
      departureLabel: 'Kamis, 1 Okt · 07.30',
      driverName: 'Taris Rafivdean',
      totalFare: 10000,
      passengerNames: ['Rafi Pratama', 'Aulia Putri', 'Dimas Saputra'],
      currentUserIndex: 0,
      initialStatuses: {
        1: PaymentStatus.menungguKonfirmasi,
        2: PaymentStatus.lunas,
      },
    );

    test('mengisi nominal dari CostSplitter dan status awal', () {
      final breakdown = build();
      expect(breakdown.passengerCount, 3);
      expect(breakdown.shares.map((s) => s.amount), [3334, 3333, 3333]);
      expect(breakdown.shares.map((s) => s.status), [
        PaymentStatus.belumBayar,
        PaymentStatus.menungguKonfirmasi,
        PaymentStatus.lunas,
      ]);
    });

    test('myShare adalah penumpang yang sedang login', () {
      final mine = build().myShare;
      expect(mine.passengerName, 'Rafi Pratama');
      expect(mine.isCurrentUser, isTrue);
    });

    test('withMyStatus hanya mengubah status milik sendiri', () {
      final updated = build().withMyStatus(PaymentStatus.menungguKonfirmasi);
      expect(updated.myShare.status, PaymentStatus.menungguKonfirmasi);
      expect(updated.shares[2].status, PaymentStatus.lunas);
    });

    test('menolak indeks penumpang login di luar daftar', () {
      expect(
        () => CostBreakdown.split(
          tripId: 'trip-1',
          origin: 'A',
          destination: 'B',
          departureLabel: '-',
          driverName: 'X',
          totalFare: 5000,
          passengerNames: ['Rafi'],
          currentUserIndex: 3,
        ),
        throwsRangeError,
      );
    });
  });
}
```

Jalankan: `flutter test test/features/costs/cost_models_test.dart` (11 tes).

## Langkah 2 — Repository (sumber data palsu)

### `lib/features/costs/data/cost_repository.dart`

```dart
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';

/// Kontrak sumber data ongkos. Versi sekarang palsu ([LocalCostRepository]);
/// nanti bisa diganti versi REST API tanpa mengubah ViewModel/View.
abstract interface class CostRepository {
  /// Mengambil rincian ongkos satu perjalanan.
  Future<CostBreakdown> fetchBreakdown(String tripId);

  /// Mencatat deklarasi "udah bayar" milik penumpang login.
  /// Mengembalikan rincian terbaru (status menjadi menunggu konfirmasi).
  Future<CostBreakdown> declarePayment({
    required String tripId,
    required int amount,
  });
}

/// Error yang pesannya aman ditampilkan ke pengguna.
class CostRepositoryException implements Exception {
  const CostRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'CostRepositoryException: $message';
}
```

`abstract interface class` adalah **kontrak**. ViewModel hanya mengenal kontrak ini; saat backend siap cukup buat `ApiCostRepository implements CostRepository`.

### `lib/features/costs/data/local_cost_repository.dart`

```dart
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';
import 'package:praktikum_mobile/features/costs/models/payment_status.dart';

/// Repository palsu untuk demo: menyimpan data di memori dan meniru
/// jeda jaringan. Bukan integrasi backend sungguhan.
class LocalCostRepository implements CostRepository {
  LocalCostRepository({
    CostBreakdown? initialBreakdown,
    this.delay = const Duration(milliseconds: 800),
  }) : _breakdown = initialBreakdown ?? demoBreakdown();

  static const demoTripId = 'trip-demo-1';

  /// Data uji: Rp15.000 dibagi 2 penumpang (Rp7.500 per orang). Pembulatan
  /// sisa rupiah dites terpisah di `cost_models_test.dart`.
  static CostBreakdown demoBreakdown() => CostBreakdown.split(
    tripId: demoTripId,
    origin: 'Jl. Khatib Sulaiman',
    destination: 'Kampus Unand Limau Manis',
    departureLabel: 'Kamis, 1 Okt · 07.30',
    driverName: 'Taris Rafivdean',
    totalFare: 15000,
    passengerNames: ['Shiddiq', 'Dimas Saputra'],
    currentUserIndex: 0,
    initialStatuses: {1: PaymentStatus.menungguKonfirmasi},
  );

  /// Jeda palsu supaya status "lagi ngirim" sempat terlihat.
  final Duration delay;

  /// Saklar demo: kalau `true`, pengiriman berikutnya gagal satu kali
  /// lalu saklar mati sendiri, jadi "Coba Lagi" bisa berhasil.
  bool failNextDeclaration = false;

  CostBreakdown _breakdown;

  @override
  Future<CostBreakdown> fetchBreakdown(String tripId) async {
    await Future<void>.delayed(delay);
    if (tripId != _breakdown.tripId) {
      throw const CostRepositoryException('Perjalanan tidak ditemukan.');
    }
    return _breakdown;
  }

  @override
  Future<CostBreakdown> declarePayment({
    required String tripId,
    required int amount,
  }) async {
    await Future<void>.delayed(delay);
    if (failNextDeclaration) {
      failNextDeclaration = false;
      throw const CostRepositoryException(
        'Gagal ngirim konfirmasi. Cek koneksi kamu, terus coba lagi.',
      );
    }
    if (tripId != _breakdown.tripId) {
      throw const CostRepositoryException('Perjalanan tidak ditemukan.');
    }

    // Server tetap memeriksa ulang, walaupun aplikasi sudah memvalidasi.
    final myShare = _breakdown.myShare;
    if (!myShare.status.canDeclarePayment) {
      throw const CostRepositoryException(
        'Pembayaran ini udah pernah ditandai.',
      );
    }
    if (amount != myShare.amount) {
      throw const CostRepositoryException(
        'Nominal tidak sama dengan bagianmu.',
      );
    }

    _breakdown = _breakdown.withMyStatus(PaymentStatus.menungguKonfirmasi);
    return _breakdown;
  }
}
```

- `demoBreakdown()` adalah data uji: Shiddiq (Kamu) belum bayar, Dimas menunggu konfirmasi.
- `Future.delayed(delay)` meniru jaringan lambat supaya loading terlihat. Di tes, `delay: Duration.zero`.
- `failNextDeclaration` memaksa gagal satu kali; dipakai tes (tidak ada lagi tombolnya di UI).
- `declarePayment` memeriksa ulang aturan: server tidak boleh percaya penuh pada aplikasi.

## Langkah 3 — ViewModel (State + Validation)

### `lib/features/costs/viewmodels/cost_detail_view_model.dart`

```dart
import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';

enum CostDetailStatus { loading, ready, error }

/// State layar Rincian Ongkos (FR-09).
class CostDetailViewModel extends ViewModel {
  CostDetailViewModel({required this._repository, required this.tripId});

  final CostRepository _repository;
  final String tripId;

  CostDetailStatus status = CostDetailStatus.loading;
  CostBreakdown? breakdown;
  String? errorMessage;

  /// Tombol "Konfirmasi Pembayaran" aktif hanya kalau status masih
  /// belum bayar.
  bool get canOpenConfirmation =>
      breakdown?.myShare.status.canDeclarePayment ?? false;

  Future<void> load() async {
    status = CostDetailStatus.loading;
    errorMessage = null;
    publish();
    try {
      final result = await _repository.fetchBreakdown(tripId);
      if (isDisposed) return;
      breakdown = result;
      status = CostDetailStatus.ready;
    } on CostRepositoryException catch (error) {
      if (isDisposed) return;
      errorMessage = error.message;
      status = CostDetailStatus.error;
    }
    publish();
  }

  /// Menerima RESULT yang dikirim balik dari layar Konfirmasi Pembayaran.
  void applyResult(CostBreakdown updated) {
    if (isDisposed) return;
    breakdown = updated;
    publish();
  }
}
```

- `load()` mengikuti pola **loading → ready/error**; setelah `await` selalu cek `isDisposed`.
- `applyResult()` adalah titik masuk **RESULT** dari layar Konfirmasi.

### `lib/features/costs/viewmodels/payment_confirmation_view_model.dart`

```dart
import 'package:praktikum_mobile/core/view_model.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';

/// State, validasi, dan command layar Konfirmasi Pembayaran (FR-10, FR-11).
class PaymentConfirmationViewModel extends ViewModel {
  PaymentConfirmationViewModel({
    required this._repository,
    required this._breakdown,
  });

  static const unconfirmedMessage = 'Centang dulu ya, kalau udah bayar';

  final CostRepository _repository;
  CostBreakdown _breakdown;

  /// `true` kalau penumpang sudah mencentang "udah bayar".
  bool isPaidChecked = false;

  /// Pesan validasi centang; `null` kalau tidak ada masalah.
  String? validationError;

  /// `true` selama data sedang dikirim (untuk spinner & tombol nonaktif).
  bool isSubmitting = false;

  /// Pesan error dari pengiriman terakhir; `null` kalau tidak ada.
  String? errorMessage;

  CostBreakdown get breakdown => _breakdown;
  CostShare get myShare => _breakdown.myShare;

  /// Tombol kirim aktif hanya kalau belum pernah ditandai dan
  /// tidak sedang mengirim.
  bool get canSubmit => myShare.status.canDeclarePayment && !isSubmitting;

  /// INPUT: penumpang mencentang atau melepas centang "udah bayar".
  void setPaidChecked(bool value) {
    if (isDisposed || !canSubmit) return;
    isPaidChecked = value;
    validationError = null;
    publish();
  }

  /// VALIDATION: penumpang wajib mencentang sebelum mengirim.
  /// Mengembalikan `true` kalau valid; kalau tidak, [validationError] diisi.
  bool validate() {
    validationError = isPaidChecked ? null : unconfirmedMessage;
    publish();
    return isPaidChecked;
  }

  /// Mengirim deklarasi "udah bayar" sebesar bagian milik penumpang.
  /// Mengembalikan rincian terbaru kalau berhasil, `null` kalau gagal
  /// (validasi atau pengiriman).
  Future<CostBreakdown?> submit() async {
    if (isDisposed || !canSubmit) return null;
    // Command memvalidasi input-nya sendiri, tidak hanya mengandalkan View.
    if (!validate()) return null;

    isSubmitting = true;
    errorMessage = null;
    publish();
    try {
      final updated = await _repository.declarePayment(
        tripId: _breakdown.tripId,
        amount: myShare.amount,
      );
      if (isDisposed) return null;
      _breakdown = updated;
      return updated;
    } on CostRepositoryException catch (error) {
      if (isDisposed) return null;
      errorMessage = error.message;
      return null;
    } finally {
      if (!isDisposed) {
        isSubmitting = false;
        publish();
      }
    }
  }
}
```

Inti workflow:
- **Input**: `setPaidChecked(bool)` mengubah `isPaidChecked` dan menghapus pesan validasi.
- **Validation**: `validate()` mengisi `validationError` kalau belum dicentang.
- **State** di `submit()`: `isSubmitting = true` → `await repository` → berhasil simpan data baru / gagal isi `errorMessage` → `finally` `isSubmitting = false`.
- `canSubmit` mencegah kirim dua kali (sedang mengirim, atau status sudah bukan "Belum bayar").
- `submit()` memvalidasi sendiri (*command validates its own inputs*), tidak hanya mengandalkan View.
- `submit()` mengembalikan `null` untuk gagal validasi maupun gagal kirim; View membedakannya lewat `validationError` / `errorMessage`.

### Tes: `test/features/costs/payment_confirmation_view_model_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/payment_status.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/payment_confirmation_view_model.dart';

void main() {
  late LocalCostRepository repository;
  late PaymentConfirmationViewModel viewModel;

  setUp(() {
    repository = LocalCostRepository(delay: Duration.zero);
    viewModel = PaymentConfirmationViewModel(
      repository: repository,
      breakdown: LocalCostRepository.demoBreakdown(),
    );
  });

  tearDown(() => viewModel.dispose());

  group('validasi centang', () {
    test('belum dicentang → tidak valid dan ada pesan', () {
      expect(viewModel.isPaidChecked, isFalse);
      expect(viewModel.validate(), isFalse);
      expect(
        viewModel.validationError,
        PaymentConfirmationViewModel.unconfirmedMessage,
      );
    });

    test('sudah dicentang → valid dan pesan hilang', () {
      viewModel.validate();
      viewModel.setPaidChecked(true);

      expect(viewModel.validationError, isNull);
      expect(viewModel.validate(), isTrue);
      expect(viewModel.validationError, isNull);
    });
  });

  test('submit tanpa centang ditolak tanpa memanggil server', () async {
    expect(await viewModel.submit(), isNull);
    expect(
      viewModel.validationError,
      PaymentConfirmationViewModel.unconfirmedMessage,
    );
    expect(viewModel.myShare.status, PaymentStatus.belumBayar);
    expect(viewModel.isSubmitting, isFalse);
  });

  test(
    'submit berhasil → status menunggu konfirmasi, tidak bisa kirim lagi',
    () async {
      viewModel.setPaidChecked(true);
      expect(viewModel.canSubmit, isTrue);

      final result = await viewModel.submit();

      expect(result, isNotNull);
      expect(result!.myShare.status, PaymentStatus.menungguKonfirmasi);
      expect(viewModel.isSubmitting, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.canSubmit, isFalse);
      expect(await viewModel.submit(), isNull);
    },
  );

  test('submit gagal → pesan error, lalu coba lagi berhasil', () async {
    repository.failNextDeclaration = true;
    viewModel.setPaidChecked(true);

    expect(await viewModel.submit(), isNull);
    expect(viewModel.errorMessage, contains('Gagal ngirim'));
    expect(viewModel.isSubmitting, isFalse);
    expect(viewModel.canSubmit, isTrue);

    final retry = await viewModel.submit();
    expect(retry!.myShare.status, PaymentStatus.menungguKonfirmasi);
    expect(viewModel.errorMessage, isNull);
  });
}
```

Jalankan: `flutter test test/features/costs/payment_confirmation_view_model_test.dart` (5 tes).

## Langkah 4 — Tampilan (Feedback)

### `lib/features/costs/widgets/payment_status_badge.dart`

```dart
import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/costs/models/payment_status.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';

/// Badge status pembayaran dengan warna sesuai tahapnya.
class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final tone = switch (status) {
      PaymentStatus.belumBayar => StatusTone.brand,
      PaymentStatus.menungguKonfirmasi => StatusTone.neutral,
      PaymentStatus.lunas => StatusTone.success,
    };
    return StatusBadge(label: status.label, tone: tone);
  }
}
```

Memakai `StatusBadge` milik tim; hanya memetakan status ke warna: Belum bayar = coral, Menunggu = abu-abu, Lunas = hijau.

### `lib/features/costs/views/cost_detail_screen.dart`

```dart
import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/cost_detail_view_model.dart';
import 'package:praktikum_mobile/features/costs/widgets/payment_status_badge.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/routes/payment_confirmation_arguments.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/info_tile.dart';
import 'package:praktikum_mobile/shared/widgets/section_header.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Layar Rincian Ongkos (FR-09): awal workflow Konfirmasi Pembayaran.
class CostDetailScreen extends StatefulWidget {
  const CostDetailScreen({
    super.key,
    this.repository,
    this.tripId = LocalCostRepository.demoTripId,
  });

  /// `null` → layar membuat [LocalCostRepository] sendiri (mode demo).
  final CostRepository? repository;
  final String tripId;

  @override
  State<CostDetailScreen> createState() => _CostDetailScreenState();
}

class _CostDetailScreenState extends State<CostDetailScreen> {
  late final CostRepository _repository;
  late final CostDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalCostRepository();
    _viewModel = CostDetailViewModel(
      repository: _repository,
      tripId: widget.tripId,
    );
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// NAVIGATION: kirim data ke layar Konfirmasi, lalu tunggu RESULT-nya.
  Future<void> _openConfirmation() async {
    final breakdown = _viewModel.breakdown;
    if (breakdown == null) return;

    final result = await Navigator.pushNamed<CostBreakdown>(
      context,
      AppRoutes.paymentConfirmation,
      arguments: PaymentConfirmationArguments(
        repository: _repository,
        breakdown: breakdown,
      ),
    );
    if (!mounted || result == null) return; // ditutup tanpa mengirim

    _viewModel.applyResult(result);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Sip! Udah dicatat, tinggal nunggu konfirmasi sistem.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Rincian Ongkos')),
        body: switch (_viewModel.status) {
          CostDetailStatus.loading => const LoadingView(
            message: 'Lagi ngitung ongkos...',
          ),
          CostDetailStatus.error => ErrorView(
            message: _viewModel.errorMessage ?? 'Ongkos gagal dimuat.',
            onRetry: _viewModel.load,
          ),
          CostDetailStatus.ready => _CostDetailContent(
            breakdown: _viewModel.breakdown!,
          ),
        },
        bottomNavigationBar: _viewModel.status == CostDetailStatus.ready
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppButton(
                    label: _footerLabel(_viewModel.breakdown!),
                    onPressed: _viewModel.canOpenConfirmation
                        ? _openConfirmation
                        : null,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _footerLabel(CostBreakdown breakdown) => _viewModel.canOpenConfirmation
      ? 'Konfirmasi Pembayaran'
      : breakdown.myShare.status.label;
}

class _CostDetailContent extends StatelessWidget {
  const _CostDetailContent({required this.breakdown});

  final CostBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: AppDecorations.outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perjalanan',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${breakdown.origin} → ${breakdown.destination}',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${breakdown.departureLabel} · Driver ${breakdown.driverName}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: InfoTile(
                label: 'Total ongkos',
                value: formatRupiah(breakdown.totalFare),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: InfoTile(
                label: 'Bagian kamu',
                value: formatRupiah(breakdown.myShare.amount),
                positive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Bagian tiap penumpang'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: AppDecorations.outlined,
          child: Column(
            children: [
              for (final share in breakdown.shares)
                ListTile(
                  leading: UserAvatar(name: share.passengerName),
                  title: Text(
                    share.isCurrentUser
                        ? '${share.passengerName} (Kamu)'
                        : share.passengerName,
                    style: AppTextStyles.labelLarge,
                  ),
                  subtitle: Text('Bagian ${formatRupiah(share.amount)}'),
                  trailing: PaymentStatusBadge(status: share.status),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ongkos dibagi rata. Kalau ada sisa rupiah, sisanya ditanggung '
          'penumpang paling atas. Bayarnya langsung ke driver ya.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
```

- `ListenableBuilder(listenable: _viewModel, ...)` membangun ulang tampilan tiap `publish()`. Pengganti `setState`.
- `switch (_viewModel.status)` memilih **loading** / **error** (dengan Coba Lagi) / **ready**.
- `_openConfirmation()`: `Navigator.pushNamed<CostBreakdown>(..., arguments: ...)` **mengirim data**; `await` menunggu layar Konfirmasi ditutup; `result == null` berarti user menekan back tanpa mengirim.
- Tombol bawah aktif hanya saat `canOpenConfirmation`; sesudah ditandai labelnya jadi status dan tombol mati.
- "Total ongkos" dan "Bagian kamu" hanya **menampilkan** `breakdown.totalFare` dan `breakdown.myShare.amount`; hitungannya terjadi di `CostSplitter` saat data dibuat.

### `lib/features/costs/views/payment_confirmation_screen.dart`

```dart
import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';
import 'package:praktikum_mobile/features/costs/models/payment_status.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/payment_confirmation_view_model.dart';
import 'package:praktikum_mobile/features/costs/widgets/payment_status_badge.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/section_header.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Layar Konfirmasi Pembayaran (FR-10, FR-11): penumpang menandai
/// "udah bayar", lalu hasilnya dikirim balik ke Rincian Ongkos.
class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({
    super.key,
    required this.repository,
    required this.breakdown,
  });

  final CostRepository repository;
  final CostBreakdown breakdown;

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late final PaymentConfirmationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PaymentConfirmationViewModel(
      repository: widget.repository,
      breakdown: widget.breakdown,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// INPUT/EVENT: dipanggil saat tombol "Udah Bayar!" ditekan.
  Future<void> _onSubmitPressed() async {
    // VALIDATION + STATE: ViewModel memeriksa centang, lalu mengubah
    // isSubmitting dan status pembayaran. Gagal → user tetap di layar ini
    // (pesan centang atau banner error tampil).
    final updated = await _viewModel.submit();
    if (!mounted || updated == null) return;

    // FEEDBACK: kabari bahwa konfirmasi tinggal menunggu driver.
    await _showDriverNotice();
    if (!mounted) return;

    // NAVIGATION/RESULT: kembali ke Rincian sambil membawa data terbaru.
    Navigator.pop(context, updated);
  }

  Future<void> _showDriverNotice() => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Konfirmasi driver'),
      content: const Text('Menunggu konfirmasi pembayaran dari driver'),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Ok'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final myShare = _viewModel.myShare;
        return Scaffold(
          appBar: AppBar(title: const Text('Konfirmasi Pembayaran')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                decoration: AppDecorations.outlined,
                child: ListTile(
                  leading: UserAvatar(name: myShare.passengerName),
                  title: Text(
                    '${myShare.passengerName} (Kamu)',
                    style: AppTextStyles.labelLarge,
                  ),
                  subtitle: Text('Bagian ${formatRupiah(myShare.amount)}'),
                  trailing: PaymentStatusBadge(status: myShare.status),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Status pembayaran'),
              const SizedBox(height: AppSpacing.sm),
              _PaymentSteps(current: myShare.status),
              const SizedBox(height: AppSpacing.lg),
              Material(
                color: AppColors.surface,
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                  side: BorderSide(color: AppColors.border),
                ),
                child: CheckboxListTile(
                  value: _viewModel.isPaidChecked,
                  onChanged: _viewModel.canSubmit
                      ? (value) => _viewModel.setPaidChecked(value ?? false)
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'Aku udah bayar ${formatRupiah(myShare.amount)} ke driver',
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
              ),
              if (_viewModel.validationError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _viewModel.validationError!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (_viewModel.errorMessage != null) ...[
                ErrorBanner(message: _viewModel.errorMessage!),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                'Bayarnya langsung ke driver ya. Aplikasi cuma nyatet, '
                'nanti sistem yang konfirmasi jadi Lunas.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_viewModel.isSubmitting) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: _submitLabel(),
                    onPressed: _viewModel.canSubmit ? _onSubmitPressed : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _submitLabel() {
    if (_viewModel.isSubmitting) return 'Lagi ngirim...';
    if (_viewModel.errorMessage != null) return 'Coba Lagi';
    return 'Udah Bayar!';
  }
}

/// Tiga tahap status: yang sudah lewat dicentang, yang aktif ditebalkan.
class _PaymentSteps extends StatelessWidget {
  const _PaymentSteps({required this.current});

  final PaymentStatus current;

  static const _descriptions = {
    PaymentStatus.belumBayar: 'Tandai kalau udah bayar ke driver',
    PaymentStatus.menungguKonfirmasi: 'Admin/sistem yang konfirmasi',
    PaymentStatus.lunas: 'Ongkos tercatat selesai',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.outlined,
      child: Column(
        children: [
          for (final step in PaymentStatus.values)
            ListTile(
              leading: Icon(
                step.index < current.index
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: step == current
                    ? AppColors.brandStrong
                    : step.index < current.index
                    ? AppColors.successText
                    : AppColors.textSecondary,
              ),
              title: Text(
                step.label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: step == current
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
              subtitle: Text(_descriptions[step]!),
            ),
        ],
      ),
    );
  }
}
```

Urutan `_onSubmitPressed()` (hafalkan):
1. `await _viewModel.submit()`: ViewModel memeriksa centang. Belum dicentang → teks merah, user tetap di layar.
2. Selama proses, tombol "Lagi ngirim..." dan progress bar tampil.
3. Gagal kirim → `updated == null`, banner merah muncul dan tombol jadi "Coba Lagi".
4. Berhasil → dialog "Konfirmasi driver" (tidak bisa ditutup tanpa menekan **Ok**).
5. Setelah Ok → `Navigator.pop(context, updated)` mengirim **result** balik ke Rincian.

Pertanyaan yang sering muncul:
- **Kenapa `if (!mounted) return;` setelah `await`?** Selama menunggu, layar bisa saja sudah ditutup; memakai `context` yang mati akan error.
- **Kenapa `barrierDismissible: false`?** Supaya user tidak menutup dialog dengan tap di luar dan tertinggal di layar Konfirmasi padahal status sudah berubah.
- **Kenapa `dispose()`?** Membebaskan ViewModel agar tidak bocor memori.

## Langkah 5 — Navigasi

### `lib/routes/payment_confirmation_arguments.dart`

```dart
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';

/// DATA yang dikirim dari Rincian Ongkos ke Konfirmasi Pembayaran.
class PaymentConfirmationArguments {
  const PaymentConfirmationArguments({
    required this.repository,
    required this.breakdown,
  });

  /// Repository yang sama dengan layar Rincian, supaya datanya satu sumber.
  final CostRepository repository;
  final CostBreakdown breakdown;
}
```

Satu kelas membungkus semua **data yang dikirim**. Repository ikut dikirim agar kedua layar memakai sumber data yang sama.

### Perubahan `lib/routes/app_routes.dart`

```diff
diff --git a/lib/routes/app_routes.dart b/lib/routes/app_routes.dart
index 2c84e61..20705fd 100644
--- a/lib/routes/app_routes.dart
+++ b/lib/routes/app_routes.dart
@@ -2,4 +2,8 @@ import 'package:flutter/material.dart';
 
 import 'package:praktikum_mobile/shared/models/ride.dart';
+import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';
+import 'package:praktikum_mobile/features/costs/views/cost_detail_screen.dart';
+import 'package:praktikum_mobile/features/costs/views/payment_confirmation_screen.dart';
+import 'package:praktikum_mobile/routes/payment_confirmation_arguments.dart';
 import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
 import 'package:praktikum_mobile/features/ride_search/views/ride_filter_screen.dart';
@@ -18,4 +22,6 @@ abstract final class AppRoutes {
   static const String postRoute = '/post-route';
   static const String rideFilter = '/ride-filter';
+  static const String costDetail = '/cost-detail';
+  static const String paymentConfirmation = '/payment-confirmation';
 
   static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
@@ -58,4 +64,20 @@ abstract final class AppRoutes {
         }
         return null;
+      case costDetail:
+        return MaterialPageRoute<void>(
+          builder: (_) => const CostDetailScreen(),
+          settings: settings,
+        );
+      case paymentConfirmation:
+        // Layar ini butuh data dari Rincian; tanpa itu → 404.
+        final args = settings.arguments;
+        if (args is! PaymentConfirmationArguments) return null;
+        return MaterialPageRoute<CostBreakdown>(
+          builder: (_) => PaymentConfirmationScreen(
+            repository: args.repository,
+            breakdown: args.breakdown,
+          ),
+          settings: settings,
+        );
       case catatanForm:
         return MaterialPageRoute<String>(
```

`MaterialPageRoute<CostBreakdown>` harus bertipe sama dengan `pushNamed<CostBreakdown>` di Rincian. Kalau `arguments` bukan tipe yang benar, route mengembalikan `null` dan aplikasi menampilkan halaman 404.

### Perubahan `lib/features/ride_search/views/home_screen.dart` (tombol SEMENTARA)

```diff
diff --git a/lib/features/ride_search/views/home_screen.dart b/lib/features/ride_search/views/home_screen.dart
index d2d98cc..9c95ccf 100644
--- a/lib/features/ride_search/views/home_screen.dart
+++ b/lib/features/ride_search/views/home_screen.dart
@@ -1,2 +1,3 @@
+import 'package:flutter/foundation.dart';
 import 'package:flutter/material.dart';
 
@@ -157,4 +158,14 @@ class _HomeScreenState extends State<HomeScreen> {
       builder: (context, _) => Scaffold(
         body: SafeArea(child: _buildContent()),
+        // Tombol SEMENTARA untuk demo UTS Modul 3; hanya tampil saat debug.
+        floatingActionButton: kDebugMode
+            ? FloatingActionButton.extended(
+                heroTag: 'demo-ongkos',
+                onPressed: () =>
+                    Navigator.pushNamed(context, AppRoutes.costDetail),
+                icon: const Icon(Icons.request_quote_outlined),
+                label: const Text('Demo Ongkos'),
+              )
+            : null,
         bottomNavigationBar: NavigationBar(
           selectedIndex: 0,
```

Tombol hanya muncul saat debug (`kDebugMode`), jadi tidak ikut APK release. `home_screen.dart` milik Mikail dan branch `mikail-uts` juga mengubah file ini, jadi saat digabung bagian ini mungkin perlu disesuaikan atau dipindah ke tab "Ongkos". `kDebugMode` butuh `import 'package:flutter/foundation.dart';`.

## Langkah 6 — Tes workflow, kualitas, dan demo

### `test/features/costs/payment_workflow_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/views/cost_detail_screen.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

Future<void> _openApp(
  WidgetTester tester,
  LocalCostRepository repository,
) async {
  // Lebar 500 dp, bukan 360 dp: font tes (Ahem) jauh lebih lebar daripada
  // Roboto, sehingga badge "Menunggu konfirmasi" tidak muat di 360 dp.
  tester.view.physicalSize = const Size(1500, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
      home: CostDetailScreen(repository: repository),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapCheckbox(WidgetTester tester) async {
  final checkbox = find.byType(CheckboxListTile);
  await tester.ensureVisible(checkbox);
  await tester.tap(checkbox);
  await tester.pump();
}

Future<void> _tapSubmit(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Workflow lengkap: rincian → validasi → konfirmasi → result', (
    tester,
  ) async {
    final repository = LocalCostRepository(delay: Duration.zero);
    await _openApp(tester, repository);

    // Rincian Ongkos tampil dengan bagian tiap penumpang (15.000 : 2).
    expect(find.text('Shiddiq (Kamu)'), findsOneWidget);
    expect(find.text('Bagian Rp7.500'), findsNWidgets(2));

    // EVENT + NAVIGATION: buka Konfirmasi Pembayaran membawa data.
    await tester.tap(find.text('Konfirmasi Pembayaran'));
    await tester.pumpAndSettle();
    expect(find.text('Status pembayaran'), findsOneWidget);

    // VALIDATION: belum dicentang → pesan, user tetap di layar ini.
    await _tapSubmit(tester, 'Udah Bayar!');
    expect(find.text('Centang dulu ya, kalau udah bayar'), findsOneWidget);
    expect(find.text('Konfirmasi driver'), findsNothing);

    // Centang → pesan hilang, kirim → dialog info driver.
    await _tapCheckbox(tester);
    expect(find.text('Centang dulu ya, kalau udah bayar'), findsNothing);
    await _tapSubmit(tester, 'Udah Bayar!');
    expect(find.text('Konfirmasi driver'), findsOneWidget);
    expect(
      find.text('Menunggu konfirmasi pembayaran dari driver'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    // RESULT: kembali ke Rincian, snackbar & status baru tampil.
    expect(find.text('Rincian Ongkos'), findsOneWidget);
    expect(
      find.text('Sip! Udah dicatat, tinggal nunggu konfirmasi sistem.'),
      findsOneWidget,
    );
    // Aulia + Shiddiq badge, ditambah label tombol bawah yang nonaktif.
    expect(find.text('Menunggu konfirmasi'), findsNWidgets(3));
  });

  testWidgets('Gagal kirim menampilkan error, lalu Coba Lagi berhasil', (
    tester,
  ) async {
    final repository = LocalCostRepository(delay: Duration.zero)
      ..failNextDeclaration = true;
    await _openApp(tester, repository);

    await tester.tap(find.text('Konfirmasi Pembayaran'));
    await tester.pumpAndSettle();
    await _tapCheckbox(tester);
    await _tapSubmit(tester, 'Udah Bayar!');

    // FEEDBACK gagal: tetap di layar, banner error, tombol jadi Coba Lagi.
    expect(
      find.text('Gagal ngirim konfirmasi. Cek koneksi kamu, terus coba lagi.'),
      findsOneWidget,
    );
    expect(find.text('Konfirmasi driver'), findsNothing);
    await _tapSubmit(tester, 'Coba Lagi');
    expect(find.text('Konfirmasi driver'), findsOneWidget);
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    expect(find.text('Rincian Ongkos'), findsOneWidget);
  });

  test('Rute konfirmasi tanpa data ditolak (jatuh ke 404)', () {
    final route = AppRoutes.onGenerateRoute(
      const RouteSettings(name: AppRoutes.paymentConfirmation),
    );
    expect(route, isNull);
  });
}
```

*Widget test* ini menekan tombol seperti user sungguhan: alur sukses lengkap, alur gagal lalu "Coba Lagi", dan rute tanpa data yang ditolak (404).

### Pemeriksaan kualitas

```
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Catatan Windows: `flutter pub get` butuh **Developer Mode** menyala (Settings → Privacy & security → For developers). Tanpa itu, plugin tidak bisa di-link dan `flutter test` berhenti sebelum jalan.

### Menjalankan aplikasi

```
flutter run -d chrome      # atau HP/emulator, atau -d windows
```

Skenario demo (urutan untuk dosen):
1. Login (Masuk cepat (Dev)), lalu di Beranda tap **Demo Ongkos**.
2. Rincian Ongkos: tunjukkan total, bagian kamu, dan badge tiap orang.
3. Tap **Konfirmasi Pembayaran**, lalu langsung **Udah Bayar!** → teks merah "Centang dulu ya, kalau udah bayar".
4. Centang kotak, tap **Udah Bayar!** → loading → dialog **Konfirmasi driver** → **Ok**.
5. Kembali ke Rincian: snackbar muncul, badge berubah "Menunggu konfirmasi", tombol mati.
6. Demo gagal-kirim tidak ada lagi di UI. Alur gagal dan "Coba Lagi" didemokan lewat widget test (`flutter test test/features/costs/payment_workflow_test.dart`).

Mengubah data demo: edit `demoBreakdown()` di `local_cost_repository.dart` (`totalFare`, `passengerNames`), lalu **Hot Restart** (bukan hot reload, karena data dibuat sekali saat repository dibuat). Tes yang hardcode nominal (`payment_workflow_test.dart`) perlu disesuaikan.

## Latihan: perubahan kecil yang mungkin diminta dosen

| Permintaan dosen | Ubah di mana | Petunjuk |
|---|---|---|
| "Sisa rupiah ditanggung penumpang **terakhir**" | `cost_splitter.dart` | Ganti `index < remainder` menjadi `index >= passengerCount - remainder`; ubah tes `[3334, 3333, 3333]` menjadi `[3333, 3333, 3334]` |
| "Ganti pesan kalau belum dicentang" | `payment_confirmation_view_model.dart` → `unconfirmedMessage` | Ubah string-nya; tes memakai konstanta yang sama, tapi `payment_workflow_test.dart` menulis teksnya langsung, sesuaikan juga |
| "Ganti teks dialog / tombol Ok" | `payment_confirmation_screen.dart` → `_showDriverNotice` | Ubah string, lalu sesuaikan `payment_workflow_test.dart` |
| "Tambah validasi lain (misal harus centang dua hal)" | `payment_confirmation_view_model.dart` → `validate()` | Tambah state baru + cek di `validate()`; ViewModel yang menahan aturan, View hanya menampilkan |
| "Munculkan dialog konfirmasi sebelum kirim" | `payment_confirmation_screen.dart` → `_onSubmitPressed` | `showDialog<bool>` sebelum `submit()`; berhenti kalau hasilnya bukan `true` |
| "Loading lebih lama supaya kelihatan" | `local_cost_repository.dart` | Ubah default `delay` menjadi `Duration(seconds: 2)` |
| "Kirim juga data X ke layar konfirmasi" | `payment_confirmation_arguments.dart` + `app_routes.dart` + konstruktor layar | Tambah field, teruskan di `case paymentConfirmation`, terima di layar |
| "Kembalikan hasil berupa teks, bukan objek" | `Navigator.pop(context, ...)`, `pushNamed<...>`, `MaterialPageRoute<...>` | Tipe di **tiga** tempat itu harus sama |

Tips memakai AI coding assistant di depan dosen: sebutkan file dan fungsi yang mau diubah ("ubah `validate()` di `payment_confirmation_view_model.dart` agar ..."), lalu jalankan `flutter test` sebagai bukti.

## Pertanyaan yang mungkin ditanya

- **Kenapa butuh ViewModel?** Logika (state dan validasi) terpisah dari tampilan, bisa dites tanpa UI, View cukup menampilkan.
- **Bedanya `push` dan `pop`?** `push` membuka layar baru di atas tumpukan. `pop` menutup layar teratas dan boleh membawa hasil.
- **Kenapa repository palsu?** Backend belum ada. Kontrak `CostRepository` sudah siap, tinggal diganti implementasinya.
- **Siapa yang mengubah status menjadi Lunas?** Sistem/admin di backend, bukan penumpang (PRD 1.1, aplikasi hanya untuk penumpang).
- **Kenapa pakai checkbox, bukan kolom nominal?** Nominal selalu sama dengan bagian penumpang, jadi mengetik ulang tidak menambah fungsi. Validasinya tetap ada: wajib dicentang.
- **Kenapa validasi dua kali (aplikasi dan repository)?** Aplikasi untuk feedback cepat; server tetap wajib memeriksa karena data dari aplikasi bisa dimanipulasi.
- **Total ongkos dihitung di mana?** `CostSplitter.split()` dipanggil `CostBreakdown.split()` saat data dibuat. Layar hanya menampilkan. Nanti total dan bagian kemungkinan datang dari backend.

## Masalah yang pernah muncul

- `flutter test` berhenti dengan "Building with plugins requires symlink support" → nyalakan **Developer Mode** Windows.
- Error import `package:praktikum_mobile/...` tidak ditemukan → cek nama folder dan file, harus persis (huruf kecil, garis bawah).
- `pumpAndSettle timed out` dengan banyak exception → buka exception **pertama**; di proyek ini penyebabnya `ListTile` di dalam `Container` berwarna dan badge yang tidak muat karena font tes.
- Perubahan `demoBreakdown()` tidak kelihatan → pakai **Hot Restart**.
