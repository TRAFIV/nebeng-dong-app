import 'package:praktikum_mobile/features/reputation/data/local_rating_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:praktikum_mobile/features/reputation/data/rating_repository.dart';
import 'package:praktikum_mobile/features/reputation/data/sample_rating_trips.dart';
import 'package:praktikum_mobile/main_rating.dart';
import 'package:praktikum_mobile/features/reputation/models/trip_rating.dart';
import 'package:praktikum_mobile/features/reputation/views/rating_history_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

class TestStorage implements RatingStorage {
  String? value;
  bool fail = false;
  int writes = 0;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String data) async {
    writes++;
    if (fail) throw StateError('disk unavailable');
    value = data;
  }
}

Future<void> scroll(WidgetTester tester, Finder target, double delta) async {
  await tester.scrollUntilVisible(
    target,
    delta,
    scrollable: find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> openRating(WidgetTester tester, String label) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
  await scroll(tester, find.text(label).first, 150);
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tap outside comment dismisses keyboard and preserves draft', (
    tester,
  ) async {
    final store = TestStorage();
    await tester.pumpWidget(
      RatingDemoApp(repository: LocalRatingRepository(store)),
    );
    await tester.pumpAndSettle();
    await openRating(tester, 'Nilai Pengemudi, Yuk!');
    final field = find.byKey(const ValueKey('rating-comment'));
    await scroll(tester, field, 120);
    await tester.tap(field);
    await tester.enterText(field, 'Pengemudinya ramah');
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isTrue);
    // Touch the empty padding beside the comment, without pressing Back.
    await tester.tapAt(Offset(2, tester.getCenter(field).dy));
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isFalse);
    expect(find.text('Pengemudinya ramah'), findsOneWidget);
    expect(find.text('Nilai Pengemudi'), findsOneWidget);
    expect(store.writes, 0);
    await tester.tap(field);
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isTrue);
  });

  test(
    'local ratings survive a new repository and reject duplicates',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repo = LocalRatingRepository(
        LocalRatingStorage(),
        delay: Duration.zero,
      );
      await repo.load();
      final trip = sampleRatingTrips.first;
      await repo.save(
        trip: trip,
        userId: 'duha',
        score: 4,
        comment: '  Ramah  ',
      );
      final reopened = LocalRatingRepository(
        LocalRatingStorage(),
        delay: Duration.zero,
      );
      await reopened.load();
      expect(reopened.forTrip(trip, 'duha')?.comment, 'Ramah');
      expect(reopened.forTrip(trip, 'duha')?.score, 4);
      await expectLater(
        reopened.save(trip: trip, userId: 'duha', score: 5, comment: ''),
        throwsA(isA<RatingException>()),
      );
      expect(reopened.forTrip(trip, 'other-user'), isNull);
    },
  );

  test('invalid and unfinished ratings are rejected without writing', () async {
    final store = TestStorage();
    final repo = LocalRatingRepository(store, delay: Duration.zero);
    for (final score in [0, 6]) {
      await expectLater(
        repo.save(
          trip: sampleRatingTrips.first,
          userId: 'duha',
          score: score,
          comment: '',
        ),
        throwsA(isA<RatingException>()),
      );
    }
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
    await expectLater(
      repo.save(trip: unfinished, userId: 'duha', score: 5, comment: ''),
      throwsA(isA<RatingException>()),
    );
    expect(store.writes, 0);
  });

  testWidgets(
    'validation, loading lock, result, persistence and second driver',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = TestStorage();
      final repo = LocalRatingRepository(store);
      await tester.pumpWidget(RatingDemoApp(repository: repo));
      await tester.pumpAndSettle();
      await openRating(tester, 'Nilai Pengemudi, Yuk!');
      await tester.tap(find.text('Kirim Rating!'));
      await tester.pumpAndSettle();
      await scroll(tester, find.byKey(const ValueKey('rating-error')), 120);
      expect(find.text('Pilih bintang dulu, ya!'), findsOneWidget);
      expect(store.writes, 0);
      await scroll(tester, find.byKey(const ValueKey('star-4')), -120);
      await tester.tap(find.byKey(const ValueKey('star-4')));
      await scroll(tester, find.byKey(const ValueKey('rating-comment')), 120);
      await tester.enterText(
        find.byKey(const ValueKey('rating-comment')),
        'Nyaman dan ramah',
      );
      await tester.tap(find.text('Kirim Rating!'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Menyimpan rating…'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.pumpAndSettle();
      expect(find.text('4/5'), findsOneWidget);
      expect(find.text('Rating 4/5 tersimpan. Makasih!'), findsOneWidget);
      expect(store.writes, 1);
      expect(repo.forTrip(sampleRatingTrips.first, 'duha')?.targetId, 'taris');
      await openRating(tester, 'Nilai Pengemudi, Yuk!');
      expect(find.text('Nilai Pengemudi'), findsOneWidget);
      expect(find.text('Mikail Samyth'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('star-5')));
      await tester.tap(find.text('Kirim Rating!'));
      await tester.pumpAndSettle();
      expect(repo.forTrip(sampleRatingTrips.last, 'duha')?.targetId, 'mikail');
      await scroll(tester, find.text('Belum dinilai'), -150);
      await tester.tap(find.text('Belum dinilai'));
      await tester.pumpAndSettle();
      expect(
        find.text('Tidak ada perjalanan yang perlu dinilai.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed save retains draft and retry succeeds', (tester) async {
    final store = TestStorage()..fail = true;
    final repo = LocalRatingRepository(store, delay: Duration.zero);
    await tester.pumpWidget(RatingDemoApp(repository: repo));
    await tester.pumpAndSettle();
    await openRating(tester, 'Nilai Pengemudi, Yuk!');
    await tester.tap(find.byKey(const ValueKey('star-3')));
    await scroll(tester, find.byKey(const ValueKey('rating-comment')), 120);
    await tester.enterText(
      find.byKey(const ValueKey('rating-comment')),
      'Tetap tersimpan di form',
    );
    await tester.tap(find.text('Kirim Rating!'));
    await tester.pumpAndSettle();
    await scroll(tester, find.byKey(const ValueKey('rating-error')), 120);
    expect(find.textContaining('Rating belum tersimpan.'), findsOneWidget);
    expect(repo.forTrip(sampleRatingTrips.first, 'duha'), isNull);
    expect(find.text('Tetap tersimpan di form'), findsOneWidget);
    store.fail = false;
    await tester.tap(find.text('Kirim Rating!'));
    await tester.pumpAndSettle();
    expect(find.text('3/5'), findsOneWidget);
  });

  testWidgets(
    'back cancels draft; corrupt storage shows retry; reset recovers',
    (tester) async {
      final store = TestStorage();
      await tester.pumpWidget(
        RatingDemoApp(repository: LocalRatingRepository(store)),
      );
      await tester.pumpAndSettle();
      await openRating(tester, 'Nilai Pengemudi, Yuk!');
      await tester.tap(find.byKey(const ValueKey('star-2')));
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(store.writes, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      store.value = '{broken';
      await tester.pumpWidget(
        RatingDemoApp(repository: LocalRatingRepository(store)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Coba lagi'), findsOneWidget);
      await tester.tap(find.byTooltip('Opsi demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ulangi demo rating'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ulangi demo'));
      await tester.pumpAndSettle();
      expect(find.text('Nilai Pengemudi, Yuk!'), findsWidgets);
    },
  );

  testWidgets('empty history and small screen with large text remain usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: RatingHistoryScreen(
            repository: LocalRatingRepository(TestStorage(), trips: const []),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak ada perjalanan yang perlu dinilai.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
