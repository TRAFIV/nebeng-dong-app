import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_results_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/booking/viewmodels/catatan_form_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/shared/maps/viewmodels/location_picker_view_model.dart';
import 'package:praktikum_mobile/shared/maps/viewmodels/location_search_view_model.dart';
import 'package:praktikum_mobile/features/auth/viewmodels/login_view_model.dart';
import 'package:praktikum_mobile/shared/viewmodels/ride_detail_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_filter_view_model.dart';

import '../support/map_test_support.dart';

final from = FakeMapService.place('Air Tawar');
final to = FakeMapService.place('Unand');
RoadRoute road() => RoadRoute(
  points: [from.point, to.point],
  distanceMeters: 5000,
  durationSeconds: 600,
);

/// Tebengan uji di jalur Air Tawar → Unand.
Ride testRide({String id = 'r1', int seats = 3, String departure = '07.30'}) =>
    Ride(
      id: id,
      driverName: 'Mikail',
      driverRating: 0,
      driverTripCount: 0,
      origin: from.label,
      destination: to.label,
      schedule: 'Senin–Jumat',
      departureTime: departure,
      seatCapacity: 3,
      seatsAvailable: seats,
      farePerPerson: 0,
      geography: RideGeography(origin: from, destination: to, route: road()),
    );

/// Repository uji: datanya bisa diganti dan setiap fetch bisa ditahan, untuk
/// menguji urutan muat dan pembaruan data dari repository.
class ControlledRepository extends RideRepository {
  List<Ride> _rides = [];
  final requests = <Completer<List<Ride>>>[];
  @override
  bool get isSimulation => true;
  @override
  List<Ride> get rides => List.unmodifiable(_rides);
  void replaceRides(List<Ride> rides) {
    _rides = List.of(rides);
    notifyListeners();
  }

  @override
  Future<List<Ride>> fetchRides({bool simulateError = false}) {
    final request = Completer<List<Ride>>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  group('Login/Note ViewModels without widgets', () {
    test('Campus domain, password and trimmed display name', () {
      final vm = LoginViewModel();
      addTearDown(vm.dispose);
      expect(vm.validateEmail(''), 'Email wajib diisi');
      expect(vm.validateEmail('x@gmail.com'), contains(campusEmailDomain));
      expect(vm.validateEmail('x@evilunand.ac.id'), isNotNull);
      expect(vm.validateEmail('x@student.unand.ac.id'), isNull);
      expect(vm.validateEmail('x@UNAND.AC.ID'), isNull);
      expect(vm.login(email: 'x@gmail.com', password: '12345678'), isNull);
      expect(vm.login(email: 'x@unand.ac.id', password: 'short'), isNull);
      expect(
        vm.login(
          email: ' mikail.samyth@student.unand.ac.id ',
          password: '12345678',
        ),
        'Mikail',
      );
      expect(vm.devLogin(), kDebugMode ? 'Mikail' : null);
    });
    test('Note validation and result stay outside Navigator', () {
      final vm = CatatanFormViewModel();
      addTearDown(vm.dispose);
      expect(vm.save(' '), isNull);
      expect(vm.save('abcd'), isNull);
      expect(vm.save('  Gerbang depan  '), 'Gerbang depan');
    });
  });

  group('Search form and results models', () {
    final request = RideSearchRequest(origin: from, destination: to);
    test('Form coordinates, filter and immutable request snapshot', () {
      final vm = HomeViewModel();
      addTearDown(vm.dispose);
      expect(vm.canSearch, isFalse);
      vm.selectOrigin(from);
      expect(vm.search(), isNotNull);
      vm.selectDestination(to);
      expect(vm.canSearch, isTrue);
      expect(vm.search(), isNull);
      final snapshot = vm.searchRequest!;
      vm.setLocations(to, from);
      vm.applyFilter(const RideFilter(minimumSeats: 3));
      expect(snapshot.origin, same(from));
      expect(snapshot.destination, same(to));
      expect(snapshot.filter.minimumSeats, 1);
      expect(vm.search(), isNull);
      expect(vm.searchRequest!.filter.minimumSeats, 3);
    });
    test('Invalid near endpoints preserve the applied request', () {
      final vm = HomeViewModel();
      addTearDown(vm.dispose);
      vm.setLocations(from, to);
      vm.search();
      final previous = vm.searchRequest;
      vm.setLocations(from, from);
      expect(vm.search(), contains('50 meter'));
      expect(vm.searchRequest, same(previous));
    });
    test('Load, readonly results and filter', () async {
      final repo = LocalRideRepository(
        rides: [testRide()],
        delay: Duration.zero,
      );
      addTearDown(repo.dispose);
      final vm = RideResultsViewModel(repository: repo, request: request);
      addTearDown(vm.dispose);
      expect(vm.status, SearchResultsStatus.loading);
      await vm.load();
      expect(vm.status, SearchResultsStatus.success);
      expect(vm.results.single.id, 'r1');
      vm.applyFilter(const RideFilter(minimumSeats: 4));
      expect(vm.results, isEmpty);
      expect(() => vm.results.clear(), throwsUnsupportedError);
    });
    test('Reversed corridor excludes forward travel', () async {
      final repo = LocalRideRepository(
        rides: [testRide()],
        delay: Duration.zero,
      );
      addTearDown(repo.dispose);
      final vm = RideResultsViewModel(
        repository: repo,
        request: RideSearchRequest(origin: to, destination: from),
      );
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.results, isEmpty);
    });
    test('Repository updates refresh results without reloading', () async {
      final repo = ControlledRepository();
      addTearDown(repo.dispose);
      final vm = RideResultsViewModel(repository: repo, request: request);
      addTearDown(vm.dispose);
      final loading = vm.load();
      repo.requests.single.complete([]);
      await loading;
      expect(vm.results, isEmpty);
      repo.replaceRides([testRide(seats: 1)]);
      expect(vm.results.single.id, 'r1');
      repo.replaceRides([testRide(seats: 0)]);
      expect(vm.results, isEmpty);
    });
    test('Error shows useful retry feedback', () async {
      final repo = LocalRideRepository(rides: [], delay: Duration.zero);
      addTearDown(repo.dispose);
      final vm = RideResultsViewModel(
        repository: repo,
        request: request,
        simulateError: true,
      );
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.status, SearchResultsStatus.error);
      expect(vm.errorMessage, contains('Periksa koneksi'));
    });
    test('Latest load wins and retry clears old error', () async {
      final repo = ControlledRepository();
      addTearDown(repo.dispose);
      final vm = RideResultsViewModel(repository: repo, request: request);
      addTearDown(vm.dispose);
      final failed = vm.load();
      repo.requests[0].completeError(Exception('offline'));
      await failed;
      expect(vm.status, SearchResultsStatus.error);
      final older = vm.load();
      final latest = vm.load();
      expect(vm.errorMessage, isEmpty);
      repo.requests[2].complete([]);
      await latest;
      repo.requests[1].completeError(Exception('stale'));
      await older;
      expect(vm.status, SearchResultsStatus.success);
      expect(vm.errorMessage, isEmpty);
    });
    test('Disposed results detach and ignore pending load', () async {
      final repo = ControlledRepository();
      addTearDown(repo.dispose);
      final vm = RideResultsViewModel(repository: repo, request: request);
      var notifications = 0;
      vm.addListener(() => notifications++);
      final pending = vm.load();
      vm.dispose();
      final count = notifications;
      repo.replaceRides([testRide()]);
      repo.requests.single.complete(repo.rides);
      await pending;
      expect(notifications, count);
      expect(vm.results, isEmpty);
    });
  });

  group('Filter and Detail ViewModels', () {
    test('Draft apply/reset does not change immutable initial filter', () {
      const initial = RideFilter(
        window: DepartureWindow.morning,
        minimumSeats: 2,
        maximumFare: 15000,
      );
      final vm = RideFilterViewModel(initialFilter: initial);
      addTearDown(vm.dispose);
      vm.selectWindow(DepartureWindow.afternoon);
      vm.selectSeats(3);
      expect(vm.apply('10.000')!.maximumFare, 10000);
      expect(vm.apply('-1'), isNull);
      expect(initial.window, DepartureWindow.morning);
      expect(initial.minimumSeats, 2);
      vm.reset();
      final result = vm.apply('')!;
      expect(result.isActive, isFalse);
    });
    test('Zero fare limit is rejected; empty still means no limit', () {
      final vm = RideFilterViewModel();
      addTearDown(vm.dispose);
      for (final zero in ['0', '000', ' 0 ', '0.000']) {
        expect(
          vm.validateFare(zero),
          'Batas ongkos harus lebih dari Rp0',
          reason: zero,
        );
        expect(vm.apply(zero), isNull, reason: zero);
      }
      expect(vm.validateFare(''), isNull);
      expect(vm.apply('')!.maximumFare, isNull);
      expect(vm.apply('1')!.maximumFare, 1);
      expect(vm.validateFare('1.5'), 'Isi rupiah bulat, contoh 10.000');
    });
    test('Departure windows are continuous; midday covers noon', () {
      const midday = RideFilter(window: DepartureWindow.midday);
      const afternoon = RideFilter(window: DepartureWindow.afternoon);
      expect(midday.matches(testRide(departure: '12.00')), isTrue);
      expect(midday.matches(testRide(departure: '15.00')), isFalse);
      expect(afternoon.matches(testRide(departure: '15.00')), isTrue);
      for (var i = 1; i < DepartureWindow.values.length; i++) {
        expect(
          DepartureWindow.values[i].startMinute,
          DepartureWindow.values[i - 1].endMinute,
          reason: DepartureWindow.values[i].label,
        );
      }
    });
    test(
      'Request validates, guards duplicate; never reduces repository seats',
      () {
        final ride = testRide();
        final vm = RideDetailViewModel(ride: ride);
        addTearDown(vm.dispose);
        expect(vm.requestToJoin(''), isFalse);
        expect(vm.requestSent, isFalse);
        expect(vm.requestToJoin('Gerbang'), isTrue);
        expect(vm.requestToJoin('Gerbang'), isFalse);
        expect(vm.canRequest, isFalse);
        expect(vm.buttonLabel, 'Nunggu di-ACC...');
        expect(vm.ride.seatsAvailable, 3);
        vm.saveNote('Gerbang depan');
        expect(vm.note, 'Gerbang depan');
      },
    );
    test('Full route cannot request even if command called directly', () {
      final vm = RideDetailViewModel(ride: testRide(seats: 0));
      addTearDown(vm.dispose);
      expect(vm.requestToJoin('Gerbang'), isFalse);
      expect(vm.buttonLabel, 'Yah, Udah Penuh');
    });
  });

  group('Location ViewModels (fake clock, no rendered widgets)', () {
    testWidgets('Autocomplete debounce invalidation and stale result', (
      tester,
    ) async {
      final pending = Completer<List<MapLocation>>();
      final service = FakeMapService()..searchHandler = (_) => pending.future;
      final vm = LocationSearchViewModel(service: service);
      addTearDown(vm.dispose);
      vm.queryChanged('ab');
      await tester.pump(const Duration(milliseconds: 750));
      expect(service.searchCalls, 0);
      vm.queryChanged('Air');
      await tester.pump(const Duration(milliseconds: 300));
      vm.queryChanged('Air Tawar');
      await tester.pump(const Duration(milliseconds: 701));
      expect(service.searchCalls, 1);
      expect(vm.loading, isTrue);
      vm.choose(to);
      pending.complete([from]);
      await tester.pump();
      expect(vm.selected, same(to));
      expect(vm.suggestions, isEmpty);
      expect(vm.loading, isFalse);
      vm.queryChanged('Baru');
      expect(vm.selected, isNull);
      vm.clearSearch();
    });
    test('Quick places match instantly by name or address', () {
      final quick = [
        const MapLocation(
          label: 'Jl. Khatib Sulaiman',
          address: 'Ulak Karang, Padang',
          point: GeoPoint(-0.91, 100.35),
        ),
        const MapLocation(
          label: 'Kampus Unand Limau Manis',
          address: 'Universitas Andalas, Padang',
          point: GeoPoint(-0.91, 100.46),
        ),
      ];
      final vm = LocationSearchViewModel(
        service: FakeMapService(),
        quickPlaces: quick,
      );
      addTearDown(vm.dispose);
      expect(vm.quickMatches, quick);
      vm.queryChanged('KHATIB');
      expect(vm.quickMatches.single.label, 'Jl. Khatib Sulaiman');
      vm.queryChanged('universitas');
      expect(vm.quickMatches.single.label, 'Kampus Unand Limau Manis');
      vm.queryChanged('Bandara');
      expect(vm.quickMatches, isEmpty);
      vm.clearSearch();
    });
    test('Autocomplete failure/retry and immutable suggestions', () async {
      final service = FakeMapService()..searchError = 'Offline';
      final vm = LocationSearchViewModel(service: service);
      addTearDown(vm.dispose);
      await vm.searchNow('Air Tawar');
      expect(vm.error, 'Offline');
      service.searchError = null;
      await vm.searchNow('Air Tawar');
      expect(vm.error, isNull);
      expect(vm.suggestions.single.label, 'Air Tawar');
      expect(() => vm.suggestions.clear(), throwsUnsupportedError);
    });
    test('Disposed autocomplete ignores pending response', () async {
      final pending = Completer<List<MapLocation>>();
      final vm = LocationSearchViewModel(
        service: FakeMapService()..searchHandler = (_) => pending.future,
      );
      final request = vm.searchNow('Air');
      vm.dispose();
      pending.complete([from]);
      await request;
      expect(vm.suggestions, isEmpty);
    });
    testWidgets(
      'Reverse response cannot override manual address or exact pin',
      (tester) async {
        final pending = Completer<MapLocation?>();
        final service = FakeMapService()
          ..reverseHandler = (_) => pending.future;
        final vm = LocationPickerViewModel(service: service);
        addTearDown(vm.dispose);
        vm.placePin(from.point);
        expect(vm.confirm(), isNull);
        await tester.pump(const Duration(milliseconds: 651));
        expect(service.reverseCalls, 1);
        vm.setAddress('  Alamat manual  ');
        vm.setLabel('  Gerbang  ');
        pending.complete(to);
        await tester.pump();
        final result = vm.confirm()!;
        expect(result.address, 'Alamat manual');
        expect(result.label, 'Gerbang');
        expect(result.point, same(from.point));
      },
    );
    testWidgets(
      'Reverse empty/error/retry; successful address retains tapped point',
      (tester) async {
        final service = FakeMapService()..reverseHandler = (_) async => null;
        final vm = LocationPickerViewModel(service: service);
        addTearDown(vm.dispose);
        vm.placePin(from.point);
        await tester.pump(const Duration(milliseconds: 651));
        expect(vm.addressError, contains('belum ditemukan'));
        expect(vm.canConfirm, isFalse);
        service.reverseHandler = (_) async =>
            throw const MapServiceException('Offline');
        vm.retry();
        await tester.pump(const Duration(milliseconds: 651));
        expect(vm.addressError, 'Offline');
        service.reverseHandler = (_) async => to;
        vm.retry();
        await tester.pump(const Duration(milliseconds: 651));
        expect(vm.confirm()!.point, same(from.point));
        expect(vm.confirm()!.label, to.label);
        expect(vm.confirm()!.address, to.address);
        expect(vm.addressError, isNull);
      },
    );
    testWidgets(
      'Moving pin refreshes place name but preserves an edited alias',
      (tester) async {
        final service = FakeMapService()..reverseHandler = (_) async => to;
        final vm = LocationPickerViewModel(
          service: service,
          initialLocation: from,
        );
        addTearDown(vm.dispose);
        vm.placePin(to.point);
        expect(vm.label, isEmpty);
        await tester.pump(const Duration(milliseconds: 651));
        expect(vm.confirm()!.label, to.label);
        vm.setLabel('Gerbang khusus');
        vm.placePin(from.point);
        await tester.pump(const Duration(milliseconds: 651));
        expect(vm.confirm()!.label, 'Gerbang khusus');
        expect(vm.confirm()!.address, to.address);
        expect(vm.confirm()!.point, same(from.point));
      },
    );
    testWidgets('New pin invalidates older reverse request', (tester) async {
      final pending = Completer<MapLocation?>();
      final service = FakeMapService()
        ..reverseHandler = (point) async =>
            identical(point, from.point) ? pending.future : to;
      final vm = LocationPickerViewModel(service: service);
      addTearDown(vm.dispose);
      vm.placePin(from.point);
      await tester.pump(const Duration(milliseconds: 651));
      vm.placePin(to.point);
      await tester.pump(const Duration(milliseconds: 651));
      pending.complete(from);
      await tester.pump();
      expect(vm.confirm()!.point, same(to.point));
    });
    testWidgets(
      'Disposed picker cancels debounce without closing borrowed service',
      (tester) async {
        final service = FakeMapService();
        final vm = LocationPickerViewModel(service: service);
        vm.placePin(from.point);
        vm.dispose();
        await tester.pump(const Duration(seconds: 1));
        expect(service.reverseCalls, 0);
        expect(service.closeCalls, 0);
        expect(await service.searchPlaces('Air'), isNotEmpty);
      },
    );
  });
}
