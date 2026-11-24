import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_schedule.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_results_view_model.dart';

Future<RideResultsViewModel> _results({DateTime? date, int? time}) async {
  final repository = LocalRideRepository(delay: Duration.zero);
  final vm = RideResultsViewModel(
    repository: repository,
    request: RideSearchRequest(
      origin: khatibPlace,
      destination: unandPlace,
      date: date,
      time: time,
    ),
  );
  addTearDown(() {
    vm.dispose();
    repository.dispose();
  });
  await vm.load();
  return vm;
}

void main() {
  group('Jadwal rute', () {
    test('rentang, daftar, setiap hari, melewati Minggu, tak terbaca', () {
      expect(scheduleWeekdays('Senin–Jumat'), {1, 2, 3, 4, 5});
      expect(scheduleWeekdays('Senin - Sabtu'), {1, 2, 3, 4, 5, 6});
      expect(scheduleWeekdays('Senin, Rabu'), {1, 3});
      expect(scheduleWeekdays('Setiap hari'), {1, 2, 3, 4, 5, 6, 7});
      expect(scheduleWeekdays('Sabtu–Senin'), {6, 7, 1});
      expect(scheduleWeekdays("Jum'at"), {5});
      expect(scheduleWeekdays('Kalau sempat'), isNull);
    });

    test('label hari relatif', () {
      final today = DateTime(2026, 11, 24); // Selasa
      expect(formatTripDay(today, today), 'Hari ini');
      expect(formatTripDay(DateTime(2026, 11, 25), today), 'Besok');
      expect(formatTripDay(DateTime(2026, 11, 26), today), 'Kam, 26 Nov');
      expect(formatTripDayLong(today, today), 'Hari ini, Sel 24 Nov');
    });
  });

  group('Cari per tanggal dan jam', () {
    test('Minggu: rute Senin–Jumat tidak muncul', () async {
      final sunday = await _results(date: DateTime(2026, 11, 29));
      expect(sunday.results, isEmpty);
      final tuesday = await _results(date: DateTime(2026, 11, 24));
      expect(tuesday.results, isNotEmpty);
    });

    test('jam disaring ±15 menit dari perkiraan lewat', () async {
      final all = await _results();
      final eta = all.matches.first.pickupEtaMinute!;
      final near = await _results(time: eta + 15);
      expect(near.results, contains(all.results.first));
      final far = await _results(time: eta + 16);
      expect(far.results, isNot(contains(all.results.first)));
    });

    test('HomeViewModel: tanggal dibatasi 7 hari, jam bisa dikosongkan', () {
      final vm = HomeViewModel();
      addTearDown(vm.dispose);
      expect(vm.date, DateTime(2026, 11, 24)); // jam tes dipatok
      expect(vm.dateOptions, hasLength(8));
      vm.setDate(DateTime(2026, 11, 25, 9));
      expect(vm.date, DateTime(2026, 11, 25));
      vm.setDate(DateTime(2026, 12, 31));
      expect(vm.date, DateTime(2026, 11, 25), reason: 'di luar 7 hari');
      vm.setTime(7 * 60 + 30);
      vm.setLocations(khatibPlace, unandPlace);
      expect(vm.search(), isNull);
      expect(vm.searchRequest!.date, DateTime(2026, 11, 25));
      expect(vm.searchRequest!.time, 450);
      vm.setTime(null);
      expect(vm.time, isNull);
    });
  });
}
