import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/payment_status.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/payment_confirmation_view_model.dart';

void main() {
  late LocalCostRepository repository;
  late PaymentConfirmationViewModel viewModel;

  setUp(() {
    repository = LocalCostRepository(delay: Duration.zero);
    viewModel = PaymentConfirmationViewModel(
      repository: repository,
      breakdown: LocalCostRepository.demoBreakdown(),
    );
  });

  tearDown(() => viewModel.dispose());

  group('validasi centang', () {
    test('belum dicentang → tidak valid dan ada pesan', () {
      expect(viewModel.isPaidChecked, isFalse);
      expect(viewModel.validate(), isFalse);
      expect(
        viewModel.validationError,
        PaymentConfirmationViewModel.unconfirmedMessage,
      );
    });

    test('sudah dicentang → valid dan pesan hilang', () {
      viewModel.validate();
      viewModel.setPaidChecked(true);

      expect(viewModel.validationError, isNull);
      expect(viewModel.validate(), isTrue);
      expect(viewModel.validationError, isNull);
    });
  });

  test('submit tanpa centang ditolak tanpa memanggil server', () async {
    expect(await viewModel.submit(), isNull);
    expect(
      viewModel.validationError,
      PaymentConfirmationViewModel.unconfirmedMessage,
    );
    expect(viewModel.myShare.status, PaymentStatus.belumBayar);
    expect(viewModel.isSubmitting, isFalse);
  });

  test(
    'submit berhasil → status menunggu konfirmasi, tidak bisa kirim lagi',
    () async {
      viewModel.setPaidChecked(true);
      expect(viewModel.canSubmit, isTrue);

      final result = await viewModel.submit();

      expect(result, isNotNull);
      expect(result!.myShare.status, PaymentStatus.menungguKonfirmasi);
      expect(viewModel.isSubmitting, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.canSubmit, isFalse);
      expect(await viewModel.submit(), isNull);
    },
  );

  test('submit gagal → pesan error, lalu coba lagi berhasil', () async {
    repository.failNextDeclaration = true;
    viewModel.setPaidChecked(true);

    expect(await viewModel.submit(), isNull);
    expect(viewModel.errorMessage, contains('Gagal ngirim'));
    expect(viewModel.isSubmitting, isFalse);
    expect(viewModel.canSubmit, isTrue);

    final retry = await viewModel.submit();
    expect(retry!.myShare.status, PaymentStatus.menungguKonfirmasi);
    expect(viewModel.errorMessage, isNull);
  });
}
