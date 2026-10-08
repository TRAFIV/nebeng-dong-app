import 'package:praktikum_mobile/shared/models/ride.dart';

enum DepartureWindow {
  early('06.00–07.00', 360, 420),
  morning('07.00–08.00', 420, 480),
  lateMorning('08.00–09.00', 480, 540),
  afternoon('Sore', 900, 1140);

  const DepartureWindow(this.label, this.startMinute, this.endMinute);
  final String label;
  final int startMinute;
  final int endMinute;
}

/// Filter immutable: layar filter mengubah draft, bukan hasil Home langsung.
class RideFilter {
  const RideFilter({this.window, this.minimumSeats = 1, this.maximumFare});

  final DepartureWindow? window;
  final int minimumSeats;
  final int? maximumFare;

  bool get isActive =>
      window != null || minimumSeats != 1 || maximumFare != null;

  bool matches(Ride ride) {
    if (ride.seatsAvailable < minimumSeats || ride.isFull) return false;
    // Nilai 0 pada demo berarti ongkos belum diatur, bukan tebengan gratis.
    if (maximumFare != null &&
        (ride.farePerPerson == 0 || ride.farePerPerson > maximumFare!)) {
      return false;
    }
    final selected = window;
    if (selected == null) return true;
    final minute = parseDepartureMinute(ride.departureTime);
    return minute != null &&
        minute >= selected.startMinute &&
        minute < selected.endMinute;
  }

  /// Ini pencarian teks dua titik, BUKAN pencocokan jalur geografis FR-03.
  List<Ride> apply(
    Iterable<Ride> rides, {
    String origin = '',
    String destination = '',
  }) {
    final from = origin.trim().toLowerCase();
    final to = destination.trim().toLowerCase();
    return rides
        .where(
          (ride) =>
              ride.origin.toLowerCase().contains(from) &&
              ride.destination.toLowerCase().contains(to) &&
              matches(ride),
        )
        .toList();
  }
}

/// Menerima HH.mm atau HH:mm; tidak menerima waktu di luar 24 jam.
int? parseDepartureMinute(String value) {
  final match = RegExp(r'^(\d{1,2})[.:](\d{2})$').firstMatch(value.trim());
  if (match == null) return null;
  final hour = int.parse(match[1]!);
  final minute = int.parse(match[2]!);
  return hour < 24 && minute < 60 ? hour * 60 + minute : null;
}

/// Rupiah bulat, baik 10000 maupun 10.000. Kosong berarti tanpa batas.
int? parseFare(String value) {
  final text = value.trim();
  if (!RegExp(r'^(\d+|\d{1,3}(\.\d{3})+)$').hasMatch(text)) return null;
  return int.tryParse(text.replaceAll('.', ''));
}
