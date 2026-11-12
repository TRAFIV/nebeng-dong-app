import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/cost_history_view_model.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/cost_share_view_model.dart';

/// Repository uji yang deklarasinya bisa ditahan atau digagalkan.
class ControlledCostRepository extends LocalCostRepository {
  ControlledCostRepository() : super(delay: Duration.zero);

  Completer<void>? gate;
  String? failWith;
  int declareCalls = 0;

  @override
  Future<CostShare> declarePayment(String costShareId) async {
    declareCalls++;
    if (gate != null) await gate!.future;
    if (failWith != null) throw CostRepositoryException(failWith!);
    return super.declarePayment(costShareId);
  }
}

void main() {
  group('CostHistoryViewModel', () {
    test('splits history (newest first) from upcoming estimates', () async {
      final viewModel = CostHistoryViewModel(
        repository: LocalCostRepository(delay: Duration.zero),
      );
      expect(viewModel.status, CostViewStatus.loading);

      await viewModel.load();

      expect(viewModel.status, CostViewStatus.success);
      expect(viewModel.history.map((s) => s.id), [
        'cost-1',
        'cost-2',
        'cost-4',
        'cost-3',
      ]);
      expect(viewModel.history.every((s) => s.tripCompleted), isTrue);
      expect(viewModel.upcoming.map((s) => s.id), ['cost-5']);
      expect(viewModel.isSimulation, isTrue);
      viewModel.dispose();
    });

    test('shows an error then recovers on retry', () async {
      final repository = LocalCostRepository(delay: Duration.zero);
      final failing = CostHistoryViewModel(
        repository: repository,
        simulateError: true,
      );
      await failing.load();
      expect(failing.status, CostViewStatus.error);
      expect(failing.errorMessage, contains('Gagal memuat ongkos'));
      failing.dispose();

      final working = CostHistoryViewModel(repository: repository);
      await working.load();
      expect(working.status, CostViewStatus.success);
      working.dispose();
    });

    test('reports empty when there are no trips', () async {
      final viewModel = CostHistoryViewModel(
        repository: LocalCostRepository(costShares: [], delay: Duration.zero),
      );
      await viewModel.load();
      expect(viewModel.isEmpty, isTrue);
      viewModel.dispose();
    });

    test('refreshes after a declaration made elsewhere', () async {
      final repository = LocalCostRepository(delay: Duration.zero);
      final viewModel = CostHistoryViewModel(repository: repository);
      await viewModel.load();

      await repository.declarePayment('cost-1');

      expect(
        viewModel.history.firstWhere((s) => s.id == 'cost-1').paymentStatus,
        PaymentStatus.pendingConfirmation,
      );
      viewModel.dispose();
    });
  });

  group('CostShareViewModel', () {
    test('enables declaring only for a finished, priced, unreported trip', () {
      final repository = LocalCostRepository(delay: Duration.zero);
      bool canDeclare(String id) {
        final viewModel = CostShareViewModel(
          repository: repository,
          costShareId: id,
        );
        final result = viewModel.canDeclare;
        viewModel.dispose();
        return result;
      }

      expect(canDeclare('cost-1'), isTrue); // selesai, belum dilaporkan
      expect(canDeclare('cost-2'), isFalse); // menunggu konfirmasi
      expect(canDeclare('cost-3'), isFalse); // terkonfirmasi
      expect(canDeclare('cost-4'), isFalse); // ongkos belum diatur
      expect(canDeclare('cost-5'), isFalse); // belum berangkat
      expect(canDeclare('missing'), isFalse);
    });

    test('declare succeeds and moves to waiting for confirmation', () async {
      final repository = LocalCostRepository(delay: Duration.zero);
      final viewModel = CostShareViewModel(
        repository: repository,
        costShareId: 'cost-1',
      );

      expect(await viewModel.declarePayment(), isTrue);

      expect(viewModel.share!.paymentStatus, PaymentStatus.pendingConfirmation);
      expect(viewModel.isSubmitting, isFalse);
      expect(viewModel.declareError, isNull);
      expect(viewModel.canDeclare, isFalse);
      viewModel.dispose();
    });

    test('a double tap while submitting sends only one declaration', () async {
      final repository = ControlledCostRepository()..gate = Completer<void>();
      final viewModel = CostShareViewModel(
        repository: repository,
        costShareId: 'cost-1',
      );

      final first = viewModel.declarePayment();
      expect(viewModel.isSubmitting, isTrue);
      expect(viewModel.canDeclare, isFalse);
      expect(await viewModel.declarePayment(), isFalse);

      repository.gate!.complete();
      expect(await first, isTrue);
      expect(repository.declareCalls, 1);
      viewModel.dispose();
    });

    test('keeps the status and shows the error when declaring fails', () async {
      final repository = ControlledCostRepository()
        ..failWith = 'Koneksi putus, coba lagi.';
      final viewModel = CostShareViewModel(
        repository: repository,
        costShareId: 'cost-1',
      );

      expect(await viewModel.declarePayment(), isFalse);

      expect(viewModel.declareError, 'Koneksi putus, coba lagi.');
      expect(viewModel.share!.paymentStatus, PaymentStatus.unreported);
      expect(viewModel.canDeclare, isTrue);
      viewModel.dispose();
    });

    test('blocked declaration never reaches the repository', () async {
      final repository = ControlledCostRepository();
      final viewModel = CostShareViewModel(
        repository: repository,
        costShareId: 'cost-5',
      );

      expect(await viewModel.declarePayment(), isFalse);

      expect(viewModel.declareError, contains('setelah perjalanan selesai'));
      expect(repository.declareCalls, 0);
      viewModel.dispose();
    });
  });
}
