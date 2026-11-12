const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// Contoh: `DateTime(2026, 10, 13, 7, 30)` → "Sel, 13 Okt 2026 · 07.30".
String formatTripDate(DateTime date) {
  final day = _days[date.weekday - 1];
  final month = _months[date.month - 1];
  final time = '${_twoDigits(date.hour)}.${_twoDigits(date.minute)}';
  return '$day, ${date.day} $month ${date.year} · $time';
}
