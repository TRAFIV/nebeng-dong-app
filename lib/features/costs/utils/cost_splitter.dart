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
