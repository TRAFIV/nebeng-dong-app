import 'package:praktikum_mobile/shared/models/ride.dart';

/// Nama hari sesuai [DateTime.weekday] (1 = Senin … 7 = Minggu).
const _weekdays = [
  'senin',
  'selasa',
  'rabu',
  'kamis',
  'jumat',
  'sabtu',
  'minggu',
];
const _shortDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
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

/// Hari jalan dari teks jadwal rute, mis. "Senin–Jumat", "Senin, Rabu",
/// "Setiap hari". `null` bila tidak terbaca: rute itu tidak disaring.
///
/// Sementara jadwal masih teks bebas dari admin; nanti server mengirim daftar
/// hari dan pencarian per tanggal dihitung di server.
Set<int>? scheduleWeekdays(String schedule) {
  final text = schedule.toLowerCase().replaceAll("jum'at", 'jumat');
  if (text.contains('setiap hari') || text.contains('tiap hari')) {
    return {1, 2, 3, 4, 5, 6, 7};
  }
  final names = _weekdays.join('|');
  final range = RegExp('($names)\\s*(?:[–—-]|s\\.?d\\.?|sampai)\\s*($names)')
      .firstMatch(text);
  if (range != null) {
    final from = _weekdays.indexOf(range.group(1)!) + 1;
    final to = _weekdays.indexOf(range.group(2)!) + 1;
    final days = <int>{};
    for (var day = from; ; day = day % 7 + 1) {
      days.add(day);
      if (day == to) break;
    }
    return days;
  }
  final listed = <int>{
    for (final (index, name) in _weekdays.indexed)
      if (text.contains(name)) index + 1,
  };
  return listed.isEmpty ? null : listed;
}

/// Rute berjalan pada [date] menurut jadwalnya.
bool rideRunsOn(Ride ride, DateTime date) {
  final days = ride.scheduleDays ?? scheduleWeekdays(ride.schedule);
  return days == null || days.contains(date.weekday);
}

/// "Hari ini", "Besok", atau "Kam, 26 Nov".
String formatTripDay(DateTime date, DateTime today) {
  final day = DateTime(date.year, date.month, date.day);
  final difference = day.difference(today).inDays;
  if (difference == 0) return 'Hari ini';
  if (difference == 1) return 'Besok';
  return '${_shortDays[day.weekday - 1]}, ${day.day} ${_months[day.month - 1]}';
}

/// Versi panjang untuk ringkasan Hasil: "Hari ini, Sel 24 Nov".
String formatTripDayLong(DateTime date, DateTime today) {
  final short =
      '${_shortDays[date.weekday - 1]} ${date.day} '
      '${_months[date.month - 1]}';
  final relative = formatTripDay(date, today);
  return relative.contains(',') ? relative : '$relative, $short';
}
