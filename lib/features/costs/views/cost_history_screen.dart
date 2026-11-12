import 'package:flutter/material.dart';

import 'package:praktikum_mobile/core/di/cost_repository_scope.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/cost_history_view_model.dart';
import 'package:praktikum_mobile/features/costs/widgets/cost_share_card.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/shared/widgets/section_header.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';

/// Layar Ongkos: Riwayat Ongkos pribadi (FR-12) dan estimasi perjalanan
/// yang akan datang.
class CostHistoryScreen extends StatefulWidget {
  const CostHistoryScreen({
    super.key,
    this.repository,
    this.simulateError = false,
  });

  final CostRepository? repository;
  final bool simulateError;

  @override
  State<CostHistoryScreen> createState() => _CostHistoryScreenState();
}

class _CostHistoryScreenState extends State<CostHistoryScreen> {
  late CostRepository _repository;
  late CostHistoryViewModel _viewModel;
  bool _ownsRepository = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final borrowed = widget.repository ?? CostRepositoryScope.maybeOf(context);
    _ownsRepository = borrowed == null;
    _repository = borrowed ?? LocalCostRepository();
    _viewModel = CostHistoryViewModel(
      repository: _repository,
      simulateError: widget.simulateError,
    );
    _initialized = true;
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  void _openDetail(CostShare share) {
    Navigator.pushNamed(context, AppRoutes.costDetail, arguments: share.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ongkos')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => switch (_viewModel.status) {
            CostViewStatus.loading => const LoadingView(
              message: 'Ngitung ongkosmu dulu...',
            ),
            CostViewStatus.error => ErrorView(
              message: _viewModel.errorMessage,
              onRetry: _viewModel.load,
            ),
            CostViewStatus.success => _buildContent(),
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_viewModel.isEmpty) {
      return const EmptyView(
        message: 'Belum ada ongkos. Nebeng dulu, yuk!',
        icon: Icons.payments_outlined,
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      children: [
        if (_viewModel.isSimulation) ...[
          Text(
            'Data latihan · bukan pembayaran nyata',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (_viewModel.upcoming.isNotEmpty) ...[
          const SectionHeader(title: 'Perjalanan berikutnya'),
          const SizedBox(height: AppSpacing.sm),
          for (final share in _viewModel.upcoming) ...[
            CostShareCard(share: share, onTap: () => _openDetail(share)),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
        const SectionHeader(title: 'Riwayat Ongkos'),
        const SizedBox(height: AppSpacing.sm),
        if (_viewModel.history.isEmpty)
          Text(
            'Belum ada perjalanan yang selesai.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          for (final share in _viewModel.history) ...[
            CostShareCard(share: share, onTap: () => _openDetail(share)),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}
