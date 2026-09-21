/// Mengubah nominal menjadi teks rupiah, misalnya 5000 → "Rp5.000".
String formatRupiah(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer('Rp');
  for (var i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);
    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write('.');
    }
  }
  return buffer.toString();
}
