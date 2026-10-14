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
