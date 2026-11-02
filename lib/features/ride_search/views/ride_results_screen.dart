import 'package:flutter/material.dart';
import 'package:praktikum_mobile/core/di/ride_repository_scope.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_results_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/widgets/passenger_navigation.dart';
import 'package:praktikum_mobile/features/ride_search/widgets/passenger_ride_card.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

class RideResultsScreen extends StatefulWidget {
  const RideResultsScreen({
    super.key,
    required this.request,
    this.repository,
    this.simulateError = false,
  });
  final RideSearchRequest request;
  final RideRepository? repository;
  final bool simulateError;
  @override
  State<RideResultsScreen> createState() => _RideResultsScreenState();
}

class _RideResultsScreenState extends State<RideResultsScreen> {
  RideRepository? _repository;
  bool _ownsRepository = false;
  late RideResultsViewModel _viewModel;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bind();
  }

  @override
  void didUpdateWidget(RideResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.request != widget.request ||
        oldWidget.simulateError != widget.simulateError) {
      _bind(force: true);
    }
  }

  void _bind({bool force = false}) {
    final candidate = widget.repository ?? RideRepositoryScope.maybeOf(context);
    if (!force &&
        _repository != null &&
        (identical(candidate, _repository) ||
            (candidate == null && _ownsRepository))) {
      return;
    }
    if (_repository != null) {
      _viewModel.dispose();
      if (_ownsRepository) _repository!.dispose();
    }
    _ownsRepository = candidate == null;
    _repository = candidate ?? LocalRideRepository();
    _viewModel = RideResultsViewModel(
      repository: _repository!,
      request: widget.request,
      simulateError: widget.simulateError,
    );
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    if (_ownsRepository) _repository!.dispose();
    super.dispose();
  }

  void _leave() => Navigator.pop(context, _viewModel.filter);
  Future<void> _openFilter() async {
    final result = await Navigator.pushNamed<RideFilter>(
      context,
      AppRoutes.rideFilter,
      arguments: _viewModel.filter,
    );
    if (mounted && result != null) _viewModel.applyFilter(result);
  }

  Widget _summary() => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.mdAll,
    ),
    child: Row(
      children: [
        const Icon(Icons.alt_route_rounded, color: AppColors.brandStrong),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.request.origin.label),
              Text(
                widget.request.destination.label,
                style: AppTextStyles.labelLarge,
              ),
              Text(
                '${_viewModel.filter.window?.label ?? 'Semua jam'} · Min. ${_viewModel.filter.minimumSeats} kursi · '
                '${_viewModel.filter.maximumFare == null ? 'Semua ongkos' : 'Maks. ${formatRupiah(_viewModel.filter.maximumFare!)}'}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _feedback({required bool failed}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    child: Column(
      children: [
        const Icon(
          Icons.search_rounded,
          color: AppColors.brandStrong,
          size: 40,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          failed ? 'Belum bisa memuat tebengan' : 'Belum ada yang searah',
          style: AppTextStyles.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          failed ? _viewModel.errorMessage : 'Coba ubah lokasi atau longgarkan filter. Jangan khawatir, kamu bisa cari lagi.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: failed ? 'Coba Lagi' : 'Ubah Pencarian',
          onPressed: failed ? _viewModel.load : _leave,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => PopScope<RideFilter>(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _leave();
    },
    child: ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Hasil Pencarian'),
          leading: BackButton(onPressed: _leave),
        ),
        bottomNavigationBar: const PassengerNavigation(),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _summary(),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(switch (_viewModel.status) {
                      SearchResultsStatus.loading => 'Mencari tebengan...',
                      SearchResultsStatus.error => 'Gagal memuat',
                      SearchResultsStatus.success =>
                        '${_viewModel.results.length} tebengan searah',
                    }, style: AppTextStyles.labelLarge),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandSubtle,
                      foregroundColor: AppColors.brandStrong,
                      minimumSize: const Size(104, AppSizes.touchTarget),
                    ),
                    onPressed: _openFilter,
                    icon: const Icon(Icons.filter_list_rounded),
                    label: Text(
                      _viewModel.filter.isActive ? 'Filter aktif' : 'Filter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_repository!.isSimulation) ...[
                Text(
                  'Data latihan · bukan perjalanan nyata',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (_viewModel.status == SearchResultsStatus.loading)
                const SizedBox(
                  height: 220,
                  child: LoadingView(message: 'Nyari tebengan dulu...'),
                )
              else if (_viewModel.status == SearchResultsStatus.error)
                _feedback(failed: true)
              else if (_viewModel.results.isEmpty)
                _feedback(failed: false)
              else
                for (final ride in _viewModel.results) ...[
                  PassengerRideCard(
                    ride: ride,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.detail,
                      arguments: ride,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
            ],
          ),
        ),
      ),
    ),
  );
}
