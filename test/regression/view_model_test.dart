import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/booking/viewmodels/catatan_form_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/shared/maps/viewmodels/location_picker_view_model.dart';
import 'package:praktikum_mobile/shared/maps/viewmodels/location_search_view_model.dart';
import 'package:praktikum_mobile/features/auth/viewmodels/login_view_model.dart';
import 'package:praktikum_mobile/legacy/driver/viewmodels/my_routes_view_model.dart';
import 'package:praktikum_mobile/legacy/driver/viewmodels/post_route_view_model.dart';
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
Ride seed(LegacyDriverRepository repo, {int capacity = 3}) => repo.post(
  driverName: 'Mikail',
  origin: from.label,
  destination: to.label,
  departureTime: '07.30',
  capacity: capacity,
  geography: RideGeography(origin: from, destination: to, route: road()),
);
PostRouteViewModel postVm(
  LegacyDriverRepository repo,
  FakeMapService service, {
  Ride? initial,
}) {
  final vm = PostRouteViewModel(
    repository: repo,
    service: service,
    driverName: 'Mikail',
    initialRide: initial,
  );
  vm.setLocations(from, to);
  addTearDown(vm.dispose);
  return vm;
}

Future<Ride?> save(PostRouteViewModel vm, {String seats = '3'}) => vm.save(
  origin: from.label,
  destination: to.label,
  departure: '7:30',
  seats: seats,
);

class PendingRepository extends LegacyDriverRepository {
  PendingRepository() : super(rides: []);
  final requests = <Completer<List<Ride>>>[];
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

  group('Home/ViewModel repository state', () {
    test('Load, applied search, location draft and filter', () async {
      final repo = LegacyDriverRepository(rides: [], delay: Duration.zero);
      addTearDown(repo.dispose);
      final ride = seed(repo);
      final vm = HomeViewModel(repository: repo);
      addTearDown(vm.dispose);
      expect(vm.status, RideViewStatus.loading);
      await vm.load();
      expect(vm.status, RideViewStatus.success);
      expect(vm.results.single, ride);
      vm.selectOrigin(from);
      expect(vm.originPlace, same(from));
      expect(vm.search(origin: from.label, destination: ''), isNotNull);
      vm.selectDestination(to);
      expect(vm.search(origin: 'Alias A', destination: 'Alias B'), isNull);
      expect(vm.geographicSearch, isTrue);
      expect(vm.results.single.id, ride.id);
      vm.applyFilter(const RideFilter(minimumSeats: 4));
      expect(vm.results, isEmpty);
      vm.selectTab(2);
      expect(vm.selectedTab, 2);
      expect(() => vm.allRides.clear(), throwsUnsupportedError);
      expect(() => vm.results.clear(), throwsUnsupportedError);
    });
    test('Text search, near endpoints and backwards corridor', () async {
      final repo = LegacyDriverRepository(rides: [], delay: Duration.zero);
      addTearDown(repo.dispose);
      seed(repo);
      final vm = HomeViewModel(repository: repo);
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.search(origin: 'unmatched', destination: ''), isNotNull);
      expect(vm.results, hasLength(1));
      vm.setLocations(from, from);
      expect(
        vm.search(origin: from.label, destination: from.label),
        contains('50 meter'),
      );
      vm.setLocations(to, from);
      expect(vm.search(origin: to.label, destination: from.label), isNull);
      expect(vm.results, isEmpty);
    });
    test(
      'Posting/edit/delete/approval notify both Home and My Routes',
      () async {
        final repo = LegacyDriverRepository(rides: [], delay: Duration.zero);
        addTearDown(repo.dispose);
        final home = HomeViewModel(repository: repo);
        final mine = MyRoutesViewModel(repository: repo);
        addTearDown(home.dispose);
        addTearDown(mine.dispose);
        await home.load();
        final ride = seed(repo, capacity: 1);
        expect(home.results.single.id, ride.id);
        expect(mine.rides.single.id, ride.id);
        repo.updateOwned(ride.copyWith(departureTime: '08.30'));
        expect(home.results.single.departureTime, '08.30');
        expect(mine.rides.single.departureTime, '08.30');
        var notifications = 0;
        home.addListener(() => notifications++);
        repo.acceptBooking(routeId: ride.id, bookingId: 'booking-1');
        expect(home.results, isEmpty);
        expect(mine.rides.single.isFull, isTrue);
        final afterApproval = notifications;
        repo.acceptBooking(routeId: ride.id, bookingId: 'booking-1');
        expect(notifications, afterApproval);
        expect(mine.delete(mine.rides.single), contains('penumpang'));
        final free = seed(repo);
        expect(mine.delete(free), 'Rute berhasil dihapus');
        expect(home.allRides.any((r) => r.id == free.id), isFalse);
        mine.toggleManaging();
        expect(mine.managing, isTrue);
      },
    );
    test('Load error exposes retry state', () async {
      final repo = LegacyDriverRepository(rides: [], delay: Duration.zero);
      addTearDown(repo.dispose);
      final vm = HomeViewModel(repository: repo, simulateError: true);
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.status, RideViewStatus.error);
      expect(vm.errorMessage, contains('Gagal memuat data'));
    });
    test('Newest load wins; retry clears old error', () async {
      final repo = PendingRepository();
      addTearDown(repo.dispose);
      final vm = HomeViewModel(repository: repo);
      addTearDown(vm.dispose);
      final failed = vm.load();
      repo.requests[0].completeError(Exception('offline'));
      await failed;
      expect(vm.status, RideViewStatus.error);
      final older = vm.load();
      final latest = vm.load();
      expect(vm.errorMessage, isEmpty);
      repo.requests[2].complete([]);
      await latest;
      repo.requests[1].completeError(Exception('stale failure'));
      await older;
      expect(vm.status, RideViewStatus.success);
      expect(vm.errorMessage, isEmpty);
    });
    test(
      'Disposed Home detaches repository and ignores pending load',
      () async {
        final repo = PendingRepository();
        addTearDown(repo.dispose);
        final vm = HomeViewModel(repository: repo);
        var notifications = 0;
        vm.addListener(() => notifications++);
        final pending = vm.load();
        vm.dispose();
        final count = notifications;
        seed(repo);
        repo.requests.single.complete(repo.rides);
        await pending;
        expect(notifications, count);
        expect(vm.allRides, isEmpty);
      },
    );
  });

  group('Posting ViewModel', () {
    test('Command validates even without a Form widget', () async {
      final repo = LegacyDriverRepository(rides: []);
      addTearDown(repo.dispose);
      final service = FakeMapService();
      final vm = postVm(repo, service);
      expect(vm.validateDeparture('24.00'), isNotNull);
      expect(vm.validateSeats('0'), isNotNull);
      expect(vm.validateSeats('9'), isNotNull);
      expect(await save(vm, seats: '0'), isNull);
      expect(service.routeCalls, 0);
      expect(repo.rides, isEmpty);
      vm.selectOrigin(null);
      expect(await save(vm), isNull);
      expect(vm.error, contains('pin'));
    });
    test('Same names allowed only with different valid coordinates', () {
      final repo = LegacyDriverRepository(rides: []);
      addTearDown(repo.dispose);
      final vm = postVm(repo, FakeMapService());
      expect(vm.validateDestination('Gerbang', 'Gerbang'), isNull);
      vm.setLocations(from, from);
      expect(vm.validateDestination('Gerbang', 'Gerbang'), contains('berbeda'));
    });
    test(
      'Double-submit blocked; snapshot inputs and notify after commit',
      () async {
        final repo = LegacyDriverRepository(rides: []);
        addTearDown(repo.dispose);
        final pending = Completer<RoadRoute>();
        final service = FakeMapService()
          ..routeHandler = (_, _) => pending.future;
        final vm = postVm(repo, service);
        final first = save(vm);
        expect(vm.saving, isTrue);
        expect(await save(vm), isNull);
        vm.setLocations(to, from);
        expect(vm.originPlace, same(from));
        expect(repo.rides, isEmpty);
        pending.complete(road());
        final result = await first;
        expect(service.routeCalls, 1);
        expect(repo.rides.length, 1);
        expect(result!.departureTime, '07.30');
        expect(result.geography!.origin, same(from));
        expect(vm.saving, isFalse);
        expect(vm.error, isNull);
      },
    );
    test('Routing failure does not commit and can retry', () async {
      final repo = LegacyDriverRepository(rides: []);
      addTearDown(repo.dispose);
      final service = FakeMapService()..routeError = 'Offline';
      final vm = postVm(repo, service);
      expect(await save(vm), isNull);
      expect(vm.error, 'Offline');
      expect(vm.saving, isFalse);
      expect(repo.rides, isEmpty);
      service.routeError = null;
      expect(await save(vm), isNotNull);
      expect(vm.error, isNull);
    });
    test('Cancel invalidates late result before repository commit', () async {
      final repo = LegacyDriverRepository(rides: []);
      addTearDown(repo.dispose);
      final pending = Completer<RoadRoute>();
      final service = FakeMapService()..routeHandler = (_, _) => pending.future;
      final vm = postVm(repo, service);
      final request = save(vm);
      vm.cancelSave();
      pending.complete(road());
      expect(await request, isNull);
      expect(repo.rides, isEmpty);
      expect(vm.saving, isFalse);
    });
    test('Dispose while saving also prevents commit', () async {
      final repo = LegacyDriverRepository(rides: []);
      addTearDown(repo.dispose);
      final pending = Completer<RoadRoute>();
      final service = FakeMapService()..routeHandler = (_, _) => pending.future;
      final vm = PostRouteViewModel(
        repository: repo,
        service: service,
        driverName: 'Mikail',
      );
      vm.setLocations(from, to);
      final request = save(vm);
      vm.dispose();
      pending.complete(road());
      expect(await request, isNull);
      expect(repo.rides, isEmpty);
    });
    test(
      'Edit result uses current occupied seats, not stale initial Ride',
      () async {
        final repo = LegacyDriverRepository(rides: []);
        addTearDown(repo.dispose);
        final initial = seed(repo);
        final pending = Completer<RoadRoute>();
        final vm = postVm(
          repo,
          FakeMapService()..routeHandler = (_, _) => pending.future,
          initial: initial,
        );
        final request = save(vm, seats: '4');
        repo.acceptBooking(routeId: initial.id, bookingId: 'new-passenger');
        pending.complete(road());
        final result = await request;
        expect(result!.seatCapacity, 4);
        expect(result.seatsAvailable, 3);
        expect(repo.rides.single, same(result));
      },
    );
    test(
      'Concurrent approval rejects shrinking capacity below occupied seats',
      () async {
        final repo = LegacyDriverRepository(rides: []);
        addTearDown(repo.dispose);
        final initial = seed(repo);
        final pending = Completer<RoadRoute>();
        final vm = postVm(
          repo,
          FakeMapService()..routeHandler = (_, _) => pending.future,
          initial: initial,
        );
        final request = save(vm, seats: '1');
        repo.acceptBooking(routeId: initial.id, bookingId: 'one');
        repo.acceptBooking(routeId: initial.id, bookingId: 'two');
        pending.complete(road());
        expect(await request, isNull);
        expect(vm.error, contains('terisi'));
        expect(repo.rides.single.seatCapacity, 3);
      },
    );
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
    test(
      'Request validates, guards duplicate; never reduces repository seats',
      () {
        final repo = LegacyDriverRepository(rides: []);
        addTearDown(repo.dispose);
        final ride = seed(repo);
        final vm = RideDetailViewModel(ride: ride);
        addTearDown(vm.dispose);
        expect(vm.requestToJoin(''), isFalse);
        expect(vm.requestSent, isFalse);
        expect(vm.requestToJoin('Gerbang'), isTrue);
        expect(vm.requestToJoin('Gerbang'), isFalse);
        expect(vm.canRequest, isFalse);
        expect(vm.buttonLabel, 'Nunggu di-ACC...');
        expect(repo.rides.single.seatsAvailable, 3);
        vm.saveNote('Gerbang depan');
        expect(vm.note, 'Gerbang depan');
      },
    );
    test('Full route cannot request even if command called directly', () {
      final repo = LegacyDriverRepository(rides: []);
      addTearDown(repo.dispose);
      final vm = RideDetailViewModel(
        ride: seed(repo).copyWith(seatsAvailable: 0),
      );
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
        expect(vm.confirm()!.label, to.address);
        expect(vm.addressError, isNull);
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
