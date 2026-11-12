import 'package:flutter/material.dart';

import 'package:praktikum_mobile/core/di/cost_repository_scope.dart';
import 'package:praktikum_mobile/features/costs/data/cost_repository.dart';
import 'package:praktikum_mobile/features/costs/data/local_cost_repository.dart';
import 'package:praktikum_mobile/features/costs/models/cost_share.dart';
import 'package:praktikum_mobile/features/costs/utils/trip_date_format.dart';
import 'package:praktikum_mobile/features/costs/viewmodels/cost_share_view_model.dart';
import 'package:praktikum_mobile/features/costs/widgets/cost_share_card.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/info_tile.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Status Pembayaran (FR-10, FR-11): deklarasi "Sudah bayar" oleh penumpang
/// dan tampilan konfirmasi dari backend/admin.
class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({
    super.key,
    required this.costShareId,
    this.repository,
  });

  final String costShareId;
  final CostRepository? repository;

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
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

  Future<void> _confirmAndDeclare(CostShare share) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Udah bayar?'),
        content: Text(
          'Kamu udah bayar ${fareText(share)} ke ${share.driverName} di luar '
          'aplikasi? Laporanmu nanti dicek dulu sama penyedia/admin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Belum'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Iya, Udah'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await _viewModel.declarePayment();
    if (!mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sip! Pembayaranmu dilaporin, tunggu konfirmasi ya.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Pembayaran')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final share = _viewModel.share;
            if (share == null) {
              return const EmptyView(
                message: 'Data pembayaran ini nggak ketemu.',
                icon: Icons.search_off,
              );
            }
            return _buildStatus(share);
          },
        ),
      ),
    );
  }

  Widget _buildStatus(CostShare share) {
    final secondary = AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textSecondary,
    );
    final blocker = _viewModel.declareBlocker;
    final error = _viewModel.declareError;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      children: [
        InfoTile(
          label: '${share.origin} → ${share.destination}',
          value: fareText(share),
          positive: share.paymentStatus == PaymentStatus.confirmed,
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${formatTripDate(share.tripDate)} · ${share.driverName}',
          style: secondary,
        ),
        const SizedBox(height: AppSpacing.lg),
        _PaymentTimeline(current: share.paymentStatus),
        const SizedBox(height: AppSpacing.md),
        Text(_statusExplanation(share), style: secondary),
        const SizedBox(height: AppSpacing.lg),
        if (share.paymentStatus == PaymentStatus.unreported) ...[
          if (error != null) ...[
            ErrorBanner(message: error),
            const SizedBox(height: AppSpacing.md),
          ] else if (blocker != null) ...[
            Text(blocker, style: secondary),
            const SizedBox(height: AppSpacing.md),
          ],
          AppButton(
            label: _viewModel.isSubmitting
                ? 'Lagi dilaporin...'
                : 'Sudah Bayar',
            onPressed: _viewModel.canDeclare
                ? () => _confirmAndDeclare(share)
                : null,
          ),
        ],
        if (_viewModel.isSimulation) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Data latihan · konfirmasi di sini contoh, bukan dari server.',
            style: secondary,
          ),
        ],
      ],
    );
  }

  String _statusExplanation(CostShare share) {
    switch (share.paymentStatus) {
      case PaymentStatus.unreported:
        return 'Bayarnya langsung ke pengemudi di luar aplikasi. Setelah '
            'bayar, tekan "Sudah Bayar" biar tercatat.';
      case PaymentStatus.pendingConfirmation:
        final declaredAt = share.declaredAt;
        final when = declaredAt == null
            ? ''
            : ' (dilaporin ${formatTripDate(declaredAt)})';
        return 'Laporanmu udah masuk$when. Tinggal tunggu penyedia/admin '
            'ngonfirmasi, kamu nggak perlu ngapa-ngapain lagi.';
      case PaymentStatus.confirmed:
        return 'Pembayaranmu udah dikonfirmasi penyedia/admin. Lunas!';
    }
  }
}

/// Tiga langkah status pembayaran, langkah yang sudah lewat ditandai.
class _PaymentTimeline extends StatelessWidget {
  const _PaymentTimeline({required this.current});

  final PaymentStatus current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final step in PaymentStatus.values)
          _TimelineStep(
            label: step.label,
            reached: step.index <= current.index,
            isCurrent: step == current,
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.reached,
    required this.isCurrent,
  });

  final String label;
  final bool reached;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = reached ? AppColors.successText : AppColors.textSecondary;
    return Semantics(
      label: '$label${isCurrent ? ', status sekarang' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              reached ? Icons.check_circle : Icons.radio_button_unchecked,
              color: color,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: reached ? AppColors.textPrimary : color,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
