import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/data/fixtures/demo_cost_shares.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/features/costs/utils/payment_rules.dart';
import 'package:praktikum_mobile/features/costs/utils/trip_date_format.dart';

CostShare share({
  String id = 'c',
  bool tripCompleted = true,
  int? fare = 5000,
  PaymentStatus status = PaymentStatus.unreported,
}) => CostShare(
  id: id,
  bookingId: 'b-$id',
  rideId: 'ride-1',
  driverName: 'Taris',
  origin: 'Khatib',
  destination: 'Unand',
  tripDate: DateTime(2026, 10, 16, 7, 30),
  tripCompleted: tripCompleted,
  farePerPerson: fare,
  paymentStatus: status,
);

void main() {
  group('FareStage', () {
    test('estimate before the trip, final after it', () {
      expect(share(tripCompleted: false).fareStage, FareStage.estimate);
      expect(share().fareStage, FareStage.finalized);
    });
    test('missing or zero fare is unset, never free', () {
      expect(share(fare: null).fareStage, FareStage.unset);
      expect(share(fare: 0).fareStage, FareStage.unset);
      expect(share(fare: null, tripCompleted: false).isFareSet, isFalse);
    });
  });

  group('PaymentRules.declareBlocker', () {
    test('allows a completed, priced, unreported trip', () {
      expect(PaymentRules.declareBlocker(share()), isNull);
    });
    test('blocks trips that have not finished', () {
      expect(
        PaymentRules.declareBlocker(share(tripCompleted: false)),
        contains('setelah perjalanan selesai'),
      );
    });
    test('blocks unset fares', () {
      expect(
        PaymentRules.declareBlocker(share(fare: null)),
        contains('belum diatur'),
      );
    });
    test('blocks already reported or confirmed payments', () {
      expect(
        PaymentRules.declareBlocker(
          share(status: PaymentStatus.pendingConfirmation),
        ),
        contains('tunggu konfirmasi'),
      );
      expect(
        PaymentRules.declareBlocker(share(status: PaymentStatus.confirmed)),
        contains('terkonfirmasi'),
      );
    });
  });

  group('LocalCostRepository', () {
    LocalCostRepository repo(List<CostShare> shares) => LocalCostRepository(
      costShares: shares,
      delay: Duration.zero,
      clock: () => DateTime(2026, 10, 18, 11, 0),
    );

    test('declare moves unreported to pending and notifies once', () async {
      final repository = repo([share(id: 'a')]);
      var notifications = 0;
      repository.addListener(() => notifications++);

      final updated = await repository.declarePayment('a');

      expect(updated.paymentStatus, PaymentStatus.pendingConfirmation);
      expect(updated.declaredAt, DateTime(2026, 10, 18, 11, 0));
      expect(
        repository.costShares.single.paymentStatus,
        PaymentStatus.pendingConfirmation,
      );
      expect(notifications, 1);
    });

    test('repeated declare is idempotent and never confirms', () async {
      final repository = repo([share(id: 'a')]);
      await repository.declarePayment('a');
      var notifications = 0;
      repository.addListener(() => notifications++);

      final again = await repository.declarePayment('a');

      expect(again.paymentStatus, PaymentStatus.pendingConfirmation);
      expect(again.declaredAt, DateTime(2026, 10, 18, 11, 0));
      expect(notifications, 0);
    });

    test('rejects unfinished, unset, confirmed and unknown shares', () async {
      final repository = repo([
        share(id: 'upcoming', tripCompleted: false),
        share(id: 'unset', fare: null),
        share(id: 'done', status: PaymentStatus.confirmed),
      ]);
      for (final id in ['upcoming', 'unset', 'done', 'missing']) {
        await expectLater(
          repository.declarePayment(id),
          throwsA(isA<CostRepositoryException>()),
          reason: id,
        );
      }
      expect(
        repository.costShares.map((s) => s.paymentStatus),
        isNot(contains(PaymentStatus.pendingConfirmation)),
      );
    });

    test('fetch can simulate an error for the practical', () async {
      await expectLater(
        repo([]).fetchCostShares(simulateError: true),
        throwsA(isA<CostRepositoryException>()),
      );
    });

    test('exposes an unmodifiable list and does not mutate fixtures', () async {
      final repository = LocalCostRepository(delay: Duration.zero);
      expect(() => repository.costShares.clear(), throwsUnsupportedError);
      await repository.declarePayment('cost-1');
      expect(
        demoCostShares.firstWhere((s) => s.id == 'cost-1').paymentStatus,
        PaymentStatus.unreported,
      );
    });
  });

  test('demo fixtures cover every state the screens show', () {
    final ids = {for (final s in demoCostShares) s.id};
    expect(ids.length, demoCostShares.length);
    expect(
      demoCostShares.map((s) => s.paymentStatus).toSet(),
      PaymentStatus.values.toSet(),
    );
    expect(
      demoCostShares.map((s) => s.fareStage).toSet(),
      FareStage.values.toSet(),
    );
  });

  test('formatTripDate uses Indonesian day and month names', () {
    expect(
      formatTripDate(DateTime(2026, 10, 13, 7, 30)),
      'Sel, 13 Okt 2026 · 07.30',
    );
    expect(
      formatTripDate(DateTime(2026, 10, 18, 16, 5)),
      'Min, 18 Okt 2026 · 16.05',
    );
  });
}
