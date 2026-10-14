import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';
import 'package:praktikum_mobile/features/costs/models/payment_status.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/payment_confirmation_view_model.dart';
import 'package:praktikum_mobile/features/costs/widgets/payment_status_badge.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/section_header.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Layar Konfirmasi Pembayaran (FR-10, FR-11): penumpang menandai
/// "udah bayar", lalu hasilnya dikirim balik ke Rincian Ongkos.
class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({
    super.key,
    required this.repository,
    required this.breakdown,
  });

  final CostRepository repository;
  final CostBreakdown breakdown;

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late final PaymentConfirmationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PaymentConfirmationViewModel(
      repository: widget.repository,
      breakdown: widget.breakdown,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// INPUT/EVENT: dipanggil saat tombol "Udah Bayar!" ditekan.
  Future<void> _onSubmitPressed() async {
    // VALIDATION + STATE: ViewModel memeriksa centang, lalu mengubah
    // isSubmitting dan status pembayaran. Gagal → user tetap di layar ini
    // (pesan centang atau banner error tampil).
    final updated = await _viewModel.submit();
    if (!mounted || updated == null) return;

    // FEEDBACK: kabari bahwa konfirmasi tinggal menunggu driver.
    await _showDriverNotice();
    if (!mounted) return;

    // NAVIGATION/RESULT: kembali ke Rincian sambil membawa data terbaru.
    Navigator.pop(context, updated);
  }

  Future<void> _showDriverNotice() => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Konfirmasi driver'),
      content: const Text('Menunggu konfirmasi pembayaran dari driver'),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Ok'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final myShare = _viewModel.myShare;
        return Scaffold(
          appBar: AppBar(title: const Text('Konfirmasi Pembayaran')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                decoration: AppDecorations.outlined,
                child: ListTile(
                  leading: UserAvatar(name: myShare.passengerName),
                  title: Text(
                    '${myShare.passengerName} (Kamu)',
                    style: AppTextStyles.labelLarge,
                  ),
                  subtitle: Text('Bagian ${formatRupiah(myShare.amount)}'),
                  trailing: PaymentStatusBadge(status: myShare.status),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Status pembayaran'),
              const SizedBox(height: AppSpacing.sm),
              _PaymentSteps(current: myShare.status),
              const SizedBox(height: AppSpacing.lg),
              Material(
                color: AppColors.surface,
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                  side: BorderSide(color: AppColors.border),
                ),
                child: CheckboxListTile(
                  value: _viewModel.isPaidChecked,
                  onChanged: _viewModel.canSubmit
                      ? (value) => _viewModel.setPaidChecked(value ?? false)
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'Aku udah bayar ${formatRupiah(myShare.amount)} ke driver',
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
              ),
              if (_viewModel.validationError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _viewModel.validationError!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (_viewModel.errorMessage != null) ...[
                ErrorBanner(message: _viewModel.errorMessage!),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                'Bayarnya langsung ke driver ya. Aplikasi cuma nyatet, '
                'nanti sistem yang konfirmasi jadi Lunas.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_viewModel.isSubmitting) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: _submitLabel(),
                    onPressed: _viewModel.canSubmit ? _onSubmitPressed : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _submitLabel() {
    if (_viewModel.isSubmitting) return 'Lagi ngirim...';
    if (_viewModel.errorMessage != null) return 'Coba Lagi';
    return 'Udah Bayar!';
  }
}

/// Tiga tahap status: yang sudah lewat dicentang, yang aktif ditebalkan.
class _PaymentSteps extends StatelessWidget {
  const _PaymentSteps({required this.current});

  final PaymentStatus current;

  static const _descriptions = {
    PaymentStatus.belumBayar: 'Tandai kalau udah bayar ke driver',
    PaymentStatus.menungguKonfirmasi: 'Admin/sistem yang konfirmasi',
    PaymentStatus.lunas: 'Ongkos tercatat selesai',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.outlined,
      child: Column(
        children: [
          for (final step in PaymentStatus.values)
            ListTile(
              leading: Icon(
                step.index < current.index
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: step == current
                    ? AppColors.brandStrong
                    : step.index < current.index
                    ? AppColors.successText
                    : AppColors.textSecondary,
              ),
              title: Text(
                step.label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: step == current
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
              subtitle: Text(_descriptions[step]!),
            ),
        ],
      ),
    );
  }
}
