import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/core/di/ride_repository_scope.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/ride_results_screen.dart';
import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';

import '../../support/map_test_support.dart';

class TrackingRepository extends LocalRideRepository {
  TrackingRepository() : super(rides: [], delay: Duration.zero);
  int closeCalls = 0;
  @override
  void dispose() {
    closeCalls++;
    super.dispose();
  }
}

/// Tekan Cari, ambil repository yang diteruskan Home ke Hasil, lalu kembali.
Future<RideRepository?> searchRepository(WidgetTester tester) async {
  await tester.tap(find.text('Cariin Tebengan!'));
  await tester.pumpAndSettle();
  final repository = tester
      .widget<RideResultsScreen>(find.byType(RideResultsScreen))
      .repository;
  await tester.pageBack();
  await tester.pumpAndSettle();
  return repository;
}

const home = HomeScreen(
  userName: 'Mikail',
  initialOrigin: khatibPlace,
  initialDestination: unandPlace,
);

void main() {
  testWidgets(
    'Caller-owned repository survives Home removal and provider disposal',
    (tester) async {
      final repo = TrackingRepository();
      addTearDown(repo.dispose);
      Widget app(Widget screen) => RideRepositoryProvider(
        repository: repo,
        child: MaterialApp(
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: screen,
        ),
      );
      await pumpTestWidget(tester, app(home));
      await tester.pumpAndSettle();
      expect(await searchRepository(tester), same(repo));
      await pumpTestWidget(tester, app(const SizedBox()));
      expect(repo.closeCalls, 0);
      await pumpTestWidget(tester, app(home));
      await tester.pumpAndSettle();
      expect(await searchRepository(tester), same(repo));
      await tester.pumpWidget(const SizedBox());
      expect(repo.closeCalls, 0);
    },
  );
  testWidgets(
    'Changing an injected instance rebinds Home without disposing caller repositories',
    (tester) async {
      final first = TrackingRepository(), second = TrackingRepository();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      Widget app(RideRepository repo) => RideRepositoryProvider(
        repository: repo,
        child: MaterialApp(
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: home,
        ),
      );
      await pumpTestWidget(tester, app(first));
      await tester.pumpAndSettle();
      expect(await searchRepository(tester), same(first));
      await pumpTestWidget(tester, app(second));
      await tester.pumpAndSettle();
      expect(await searchRepository(tester), same(second));
      expect(first.closeCalls, 0);
      expect(second.closeCalls, 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Provider-owned instance is stable across rebuilds and disposed with provider',
    (tester) async {
      RideRepository? captured;
      Widget app() => RideRepositoryProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              captured = RideRepositoryScope.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpWidget(app());
      final initial = captured!;
      await tester.pumpWidget(app());
      expect(captured, same(initial));
      await tester.pumpWidget(const SizedBox());
      expect(() => initial.addListener(() {}), throwsFlutterError);
    },
  );
  testWidgets('App injection reaches Home after debug login', (tester) async {
    final repo = TrackingRepository();
    addTearDown(repo.dispose);
    await pumpTestWidget(tester, NebengDongApp(rideRepository: repo));
    await tester.tap(find.text('Masuk cepat (Dev)'));
    await tester.pumpAndSettle();
    await selectHomeLocation(tester, 'Dari', 'Air Tawar');
    await selectHomeLocation(tester, 'Ke', 'Unand');
    expect(await searchRepository(tester), same(repo));
    expect(repo.closeCalls, 0);
  });
}
