import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:praktikum_mobile/features/reputation/data/local_rating_repository.dart';
import 'package:praktikum_mobile/features/reputation/data/rating_repository.dart';
import 'package:praktikum_mobile/features/reputation/data/sample_rating_trips.dart';
import 'package:praktikum_mobile/features/reputation/models/trip_rating.dart';
import 'package:praktikum_mobile/features/reputation/viewmodels/rating_view_model.dart';
import 'package:praktikum_mobile/features/reputation/viewmodels/rating_history_view_model.dart';

import 'rating_workflow_test.dart' show TestStorage;

class DelayedStorage extends TestStorage {
  final gate = Completer<void>();
  @override
  Future<void> write(String data) async {
    await gate.future;
    await super.write(data);
  }
}

void main() {
  const unfinished = RatingTrip(
    id: 'pending',
    driverId: 'taris',
    driverName: 'Taris',
    passengerId: 'duha',
    origin: 'A',
    destination: 'B',
    dateLabel: 'Hari ini',
    completed: false,
  );
  test(
    'ownership and canonical completed status cannot be forged by the caller',
    () async {
      final store = TestStorage();
      final repo = LocalRatingRepository(
        store,
        trips: [...sampleRatingTrips, unfinished],
        delay: Duration.zero,
      );
      expect(repo.tripsFor('other'), isEmpty);
      await expectLater(
        repo.save(
          trip: sampleRatingTrips.first,
          userId: 'other',
          score: 5,
          comment: '',
        ),
        throwsA(isA<RatingException>()),
      );
      const forged = RatingTrip(
        id: 'pending',
        driverId: 'taris',
        driverName: 'Taris',
        passengerId: 'duha',
        origin: 'A',
        destination: 'B',
        dateLabel: 'Hari ini',
        completed: true,
      );
      await expectLater(
        repo.save(trip: forged, userId: 'duha', score: 5, comment: ''),
        throwsA(isA<RatingException>()),
      );
      expect(store.writes, 0);
    },
  );
  test('save loads persisted ratings before checking duplicates', () async {
    final store = TestStorage();
    final repo = LocalRatingRepository(store, delay: Duration.zero);
    await repo.save(
      trip: sampleRatingTrips.first,
      userId: 'duha',
      score: 4,
      comment: '',
    );
    final reopened = LocalRatingRepository(store, delay: Duration.zero);
    await expectLater(
      reopened.save(
        trip: sampleRatingTrips.first,
        userId: 'duha',
        score: 2,
        comment: '',
      ),
      throwsA(isA<RatingException>()),
    );
    expect(store.writes, 1);
  });
  test('viewmodel validates comment before writing and keeps selected stars on failure', () async {
    final store = TestStorage()..fail = true;
    final vm = RatingViewModel(
      repository: LocalRatingRepository(store, delay: Duration.zero),
      trip: sampleRatingTrips.first,
      userId: 'duha',
    );
    addTearDown(vm.dispose);
    expect(await vm.submit(''), isNull);
    expect(vm.error, 'Pilih bintang dulu, ya!');
    vm.selectScore(4);
    expect(await vm.submit('a' * 201), isNull);
    expect(store.writes, 0);
    expect(await vm.submit('Ramah'), isNull);
    expect(vm.score, 4);
    expect(vm.saving, isFalse);
    expect(vm.error, contains('Rating belum tersimpan'));
    store.fail = false;
    expect((await vm.submit('Ramah'))?.score, 4);
  });
  test(
    'double submit, concurrent reset and dispose cannot publish stale results',
    () async {
      final store = DelayedStorage();
      final repo = LocalRatingRepository(store, delay: Duration.zero);
      final vm = RatingViewModel(
        repository: repo,
        trip: sampleRatingTrips.first,
        userId: 'duha',
      );
      vm.selectScore(5);
      var notifications = 0;
      vm.addListener(() => notifications++);
      final pending = vm.submit('');
      expect(vm.saving, isTrue);
      expect(await vm.submit('duplicate'), isNull);
      await expectLater(repo.resetDemo(), throwsA(isA<RatingException>()));
      vm.dispose();
      final before = notifications;
      store.gate.complete();
      expect(await pending, isNull);
      expect(notifications, before);
      expect(store.writes, 1);
    },
  );
  test(
    'history only lists own trips and saved result returns to all filter',
    () async {
      final repo = LocalRatingRepository(
        TestStorage(),
        trips: [...sampleRatingTrips, unfinished],
        delay: Duration.zero,
      );
      final vm = RatingHistoryViewModel(repository: repo, userId: 'duha');
      addTearDown(vm.dispose);
      await vm.load();
      vm.filter(true);
      expect(vm.trips.length, 2);
      await repo.save(
        trip: sampleRatingTrips.first,
        userId: 'duha',
        score: 3,
        comment: '',
      );
      expect(vm.trips.length, 1);
      vm.showSavedResult();
      expect(vm.onlyUnrated, isFalse);
      expect(vm.trips.length, 3);
      expect(vm.ratingFor(sampleRatingTrips.first)?.score, 3);
    },
  );
  test(
    'new passenger storage and reset leave legacy two-role data intact',
    () async {
      const oldKey = 'nebeng_dong_duha_rating_demo_v1';
      SharedPreferences.setMockInitialValues({oldKey: 'legacy sentinel'});
      final repo = LocalRatingRepository(
        LocalRatingStorage(),
        delay: Duration.zero,
      );
      await repo.save(
        trip: sampleRatingTrips.first,
        userId: 'duha',
        score: 4,
        comment: '',
      );
      await repo.resetDemo();
      expect(
        (await SharedPreferences.getInstance()).getString(oldKey),
        'legacy sentinel',
      );
    },
  );
}
