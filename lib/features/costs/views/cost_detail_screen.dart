import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_breakdown.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/cost_detail_view_model.dart';
import 'package:praktikum_mobile/features/costs/widgets/payment_status_badge.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/routes/payment_confirmation_arguments.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/info_tile.dart';
import 'package:praktikum_mobile/shared/widgets/section_header.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Layar Rincian Ongkos (FR-09): awal workflow Konfirmasi Pembayaran.
class CostDetailScreen extends StatefulWidget {
  const CostDetailScreen({
    super.key,
    this.repository,
    this.tripId = LocalCostRepository.demoTripId,
  });

  /// `null` → layar membuat [LocalCostRepository] sendiri (mode demo).
  final CostRepository? repository;
  final String tripId;

  @override
  State<CostDetailScreen> createState() => _CostDetailScreenState();
}

class _CostDetailScreenState extends State<CostDetailScreen> {
  late final CostRepository _repository;
  late final CostDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalCostRepository();
    _viewModel = CostDetailViewModel(
      repository: _repository,
      tripId: widget.tripId,
    );
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// NAVIGATION: kirim data ke layar Konfirmasi, lalu tunggu RESULT-nya.
  Future<void> _openConfirmation() async {
    final breakdown = _viewModel.breakdown;
    if (breakdown == null) return;

    final result = await Navigator.pushNamed<CostBreakdown>(
      context,
      AppRoutes.paymentConfirmation,
      arguments: PaymentConfirmationArguments(
        repository: _repository,
        breakdown: breakdown,
      ),
    );
    if (!mounted || result == null) return; // ditutup tanpa mengirim

    _viewModel.applyResult(result);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Sip! Udah dicatat, tinggal nunggu konfirmasi sistem.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Rincian Ongkos')),
        body: switch (_viewModel.status) {
          CostDetailStatus.loading => const LoadingView(
            message: 'Lagi ngitung ongkos...',
          ),
          CostDetailStatus.error => ErrorView(
            message: _viewModel.errorMessage ?? 'Ongkos gagal dimuat.',
            onRetry: _viewModel.load,
          ),
          CostDetailStatus.ready => _CostDetailContent(
            breakdown: _viewModel.breakdown!,
          ),
        },
        bottomNavigationBar: _viewModel.status == CostDetailStatus.ready
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppButton(
                    label: _footerLabel(_viewModel.breakdown!),
                    onPressed: _viewModel.canOpenConfirmation
                        ? _openConfirmation
                        : null,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _footerLabel(CostBreakdown breakdown) => _viewModel.canOpenConfirmation
      ? 'Konfirmasi Pembayaran'
      : breakdown.myShare.status.label;
}

class _CostDetailContent extends StatelessWidget {
  const _CostDetailContent({required this.breakdown});

  final CostBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: AppDecorations.outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perjalanan',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${breakdown.origin} → ${breakdown.destination}',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${breakdown.departureLabel} · Driver ${breakdown.driverName}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: InfoTile(
                label: 'Total ongkos',
                value: formatRupiah(breakdown.totalFare),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: InfoTile(
                label: 'Bagian kamu',
                value: formatRupiah(breakdown.myShare.amount),
                positive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Bagian tiap penumpang'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: AppDecorations.outlined,
          child: Column(
            children: [
              for (final share in breakdown.shares)
                ListTile(
                  leading: UserAvatar(name: share.passengerName),
                  title: Text(
                    share.isCurrentUser
                        ? '${share.passengerName} (Kamu)'
                        : share.passengerName,
                    style: AppTextStyles.labelLarge,
                  ),
                  subtitle: Text('Bagian ${formatRupiah(share.amount)}'),
                  trailing: PaymentStatusBadge(status: share.status),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ongkos dibagi rata. Kalau ada sisa rupiah, sisanya ditanggung '
          'penumpang paling atas. Bayarnya langsung ke driver ya.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
