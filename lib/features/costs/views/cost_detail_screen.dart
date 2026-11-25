import 'package:flutter/material.dart';

import 'package:praktikum_mobile/core/di/cost_repository_scope.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/features/costs/utils/trip_date_format.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/cost_share_view_model.dart';
import 'package:praktikum_mobile/features/costs/widgets/cost_badges.dart';
import 'package:praktikum_mobile/features/costs/widgets/cost_share_card.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/info_tile.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Rincian Ongkos (FR-09): perjalanan, dasar pembagian dan bagian penumpang.
class CostDetailScreen extends StatefulWidget {
  const CostDetailScreen({
    super.key,
    required this.costShareId,
    this.repository,
  });

  final String costShareId;
  final CostRepository? repository;

  @override
  State<CostDetailScreen> createState() => _CostDetailScreenState();
}

class _CostDetailScreenState extends State<CostDetailScreen> {
  late CostRepository _repository;
  late CostShareViewModel _viewModel;
  bool _ownsRepository = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final borrowed = widget.repository ?? CostRepositoryScope.maybeOf(context);
    _ownsRepository = borrowed == null;
    _repository = borrowed ?? LocalCostRepository();
    _viewModel = CostShareViewModel(
      repository: _repository,
      costShareId: widget.costShareId,
    );
    _initialized = true;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  void _openPaymentStatus() {
    Navigator.pushNamed(
      context,
      AppRoutes.paymentStatus,
      arguments: widget.costShareId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rincian Ongkos')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final share = _viewModel.share;
            if (share == null) {
              return const EmptyView(
                message: 'Rincian ongkos ini nggak ketemu.',
                icon: Icons.search_off,
              );
            }
            return _buildDetail(share);
          },
        ),
      ),
    );
  }

  Widget _buildDetail(CostShare share) {
    final secondary = AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textSecondary,
    );
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: AppDecorations.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Perjalanan', style: secondary),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${share.origin} → ${share.destination}',
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(formatTripDate(share.tripDate), style: secondary),
              Text('Pengemudi: ${share.driverName}', style: secondary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        InfoTile(
          label: 'Bagian ongkosmu',
          value: fareText(share),
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            FareStageBadge(stage: share.fareStage),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(_stageExplanation(share.fareStage), style: secondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Dasar pembagian', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tarif tetap per penumpang dari rute ini. Tiap penumpang bayar '
          'jumlah yang sama.',
          style: secondary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text('Status pembayaran', style: AppTextStyles.labelLarge),
            ),
            PaymentStatusBadge(status: share.paymentStatus),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Lihat Status Pembayaran',
          variant: AppButtonVariant.secondary,
          onPressed: _openPaymentStatus,
        ),
      ],
    );
  }

  String _stageExplanation(FareStage stage) => switch (stage) {
    FareStage.estimate =>
      'Perjalanan belum selesai, angka ini bisa berubah sampai final.',
    FareStage.finalized => 'Perjalanan selesai, ongkos udah final.',
    FareStage.unset =>
      'Penyedia belum ngatur ongkosnya. Ini bukan berarti gratis, ya.',
  };
}
