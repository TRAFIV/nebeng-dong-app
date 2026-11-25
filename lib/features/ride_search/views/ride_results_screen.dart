import 'package:flutter/material.dart';
import 'package:praktikum_mobile/core/app_clock.dart';
import 'package:praktikum_mobile/core/di/ride_repository_scope.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_schedule.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_search_matcher.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_results_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/views/ride_filter_sheet.dart';
import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';
import 'package:praktikum_mobile/features/ride_search/widgets/passenger_ride_card.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/si_titik.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';
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
    final result = await showRideFilterSheet(context, _viewModel.filter);
    if (mounted && result != null) _viewModel.applyFilter(result);
  }

  Widget _summary() {
    final filter = _viewModel.filter;
    return DecoratedBox(
      decoration: AppDecorations.card,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.ms),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _SummaryStop(
                        label: 'Dari',
                        color: AppColors.brand,
                        labelColor: AppColors.brandStrong,
                        place: widget.request.origin.label,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 2,
                          height: 10,
                          margin: const EdgeInsets.only(left: 8),
                          color: AppColors.border,
                        ),
                      ),
                      _SummaryStop(
                        label: 'Ke',
                        color: AppColors.successText,
                        labelColor: AppColors.successText,
                        place: widget.request.destination.label,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.tonalIcon(
                  onPressed: _leave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandSubtle,
                    foregroundColor: AppColors.brandStrong,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: const StadiumBorder(),
                    textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 12),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Ubah'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.ms),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.ms),
            Wrap(
              spacing: AppSpacing.ms,
              runSpacing: AppSpacing.xs,
              children: [
                if (widget.request.date != null)
                  _Meta(
                    icon: Icons.calendar_today_rounded,
                    text: formatTripDayLong(
                      widget.request.date!,
                      AppClock.today(),
                    ),
                  ),
                _Meta(
                  icon: Icons.schedule_rounded,
                  text: widget.request.time != null
                      ? 'Sekitar ${formatMinuteOfDay(widget.request.time!)}'
                      : filter.window?.label ?? 'Semua jam',
                ),
                _Meta(
                  icon: Icons.event_seat_outlined,
                  text: 'Min. ${filter.minimumSeats} kursi',
                ),
                if (filter.vehicle != null)
                  _Meta(
                    icon: filter.vehicle == VehicleKind.motor
                        ? Icons.two_wheeler_rounded
                        : Icons.directions_car_rounded,
                    text: '${filter.vehicle!.label} saja',
                  ),
                if (filter.maximumFare != null)
                  _Meta(
                    icon: Icons.account_balance_wallet_outlined,
                    text: 'Maks. ${formatRupiah(filter.maximumFare!)}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedback({required bool failed}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    child: Column(
      children: [
        SiTitik(
          mood: failed ? SiTitikMood.sad : SiTitikMood.search,
          motion: SiTitikMotion.sway,
          size: 104,
        ),
        const SizedBox(height: AppSpacing.md),
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

  Widget _listHead() => Row(
    children: [
      Expanded(
        child: AnimatedSwitcher(
          duration: AppMotion.reduced(context)
              ? Duration.zero
              : AppMotion.medium,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.centerLeft,
            children: [...previous, ?current],
          ),
          child: Text(
            switch (_viewModel.status) {
              SearchResultsStatus.loading => 'Mencari tebengan...',
              SearchResultsStatus.error => 'Gagal memuat',
              SearchResultsStatus.success =>
                '${_viewModel.results.length} tebengan searah',
            },
            key: ValueKey(_viewModel.status),
            style: AppTextStyles.title,
          ),
        ),
      ),
      if (_viewModel.status == SearchResultsStatus.success &&
          _viewModel.results.length > 1)
        PopupMenuButton<RideSort>(
          tooltip: 'Urutkan',
          initialValue: _viewModel.sort,
          onSelected: _viewModel.setSort,
          itemBuilder: (context) => [
            for (final sort in RideSort.values)
              PopupMenuItem(value: sort, child: Text(sort.label)),
          ],
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.pill,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sort_rounded,
                  size: 16,
                  color: AppColors.brand,
                ),
                const SizedBox(width: 4),
                Text(
                  _viewModel.sort.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.brandStrong,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const Icon(
                  Icons.expand_more_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
    ],
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
          backgroundColor: AppColors.surface,
          title: const Text('Hasil Pencarian'),
          leading: BackButton(onPressed: _leave),
          shape: const Border(bottom: BorderSide(color: AppColors.border)),
          actions: [
            IconButton.filledTonal(
              tooltip: _viewModel.filter.isActive ? 'Filter aktif' : 'Filter',
              onPressed: _openFilter,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.brandSubtle,
                foregroundColor: AppColors.brandStrong,
              ),
              icon: Badge(
                isLabelVisible: _viewModel.filter.isActive,
                smallSize: 8,
                backgroundColor: AppColors.brand,
                child: const Icon(Icons.tune_rounded),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _summary(),
              const SizedBox(height: AppSpacing.md),
              _listHead(),
              const SizedBox(height: AppSpacing.ms),
              if (_repository!.isSimulation) ...[
                Text(
                  'Data latihan · bukan perjalanan nyata',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.ms),
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
                _StaggeredCards(
                  // Kunci baru tiap urutan/isi berubah: kartu muncul ulang.
                  key: ValueKey(
                    '${_viewModel.sort}-${_viewModel.results.map((r) => r.id).join()}',
                  ),
                  children: [
                    for (final (index, item) in _viewModel.matches.indexed)
                      PassengerRideCard(
                        ride: item.ride,
                        match: item,
                        phase: index * 5.3,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.detail,
                          arguments: item.ride,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SummaryStop extends StatelessWidget {
  const _SummaryStop({
    required this.label,
    required this.color,
    required this.labelColor,
    required this.place,
  });

  final String label;
  final Color color;
  final Color labelColor;
  final String place;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.location_on_rounded, size: 18, color: color),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              semanticsLabel: label,
              style: AppTextStyles.overline.copyWith(color: labelColor),
            ),
            Text(
              place,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.brand),
      const SizedBox(width: 4),
      Flexible(child: Text(text, style: AppTextStyles.caption)),
    ],
  );
}

/// Kartu muncul satu per satu dari bawah (sekali jalan).
class _StaggeredCards extends StatefulWidget {
  const _StaggeredCards({super.key, required this.children});

  final List<Widget> children;

  @override
  State<_StaggeredCards> createState() => _StaggeredCardsState();
}

class _StaggeredCardsState extends State<_StaggeredCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 420 + 90 * widget.children.length),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    } else if (_controller.value == 0 && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _controller.duration!.inMilliseconds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, child) in widget.children.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.ms),
          _rise(index, total, child),
        ],
      ],
    );
  }

  Widget _rise(int index, int total, Widget child) {
    final start = (90 * index / total).clamp(0.0, 1.0);
    final end = ((90 * index + 420) / total).clamp(start, 1.0);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
