import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/core/di/ride_repository_scope.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_field.dart';
import 'package:praktikum_mobile/shared/maps/widgets/route_endpoints.dart';
import 'package:praktikum_mobile/core/di/map_service_scope.dart';
import 'package:praktikum_mobile/shared/widgets/ride_card.dart';
import 'package:praktikum_mobile/shared/widgets/section_header.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';

/// Beranda: cari tebengan berdasarkan lokasi asal dan tujuan (FR-02).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userName,
    this.repository,
    this.rides,
    this.simulateError = false,
    this.loadDelay = const Duration(seconds: 2),
  });

  final String userName;
  final RideRepository? repository;
  final List<Ride>? rides;
  final bool simulateError;
  final Duration loadDelay;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  late RideRepository _repository;
  late HomeViewModel _viewModel;
  MapService? _mapService;
  bool _ownsMapService = false;
  bool _ownsRepository = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindRepository();
    if (_mapService != null) return;
    _mapService = MapServiceScope.maybeOf(context)?.service;
    _ownsMapService = _mapService == null;
    _mapService ??= OpenMapService();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.rides != widget.rides ||
        oldWidget.loadDelay != widget.loadDelay ||
        oldWidget.simulateError != widget.simulateError) {
      _bindRepository(force: true);
    }
  }

  void _bindRepository({bool force = false}) {
    final scoped = RideRepositoryScope.maybeOf(context);
    final standalone =
        widget.rides != null ||
        widget.simulateError ||
        widget.loadDelay != const Duration(seconds: 2);
    final candidate = widget.repository ?? (standalone ? null : scoped);
    if (!force &&
        _initialized &&
        (identical(candidate, _repository) ||
            (candidate == null && _ownsRepository))) {
      return;
    }
    if (_initialized) {
      _viewModel.dispose();
      if (_ownsRepository) _repository.dispose();
    }
    _ownsRepository = candidate == null;
    _repository =
        candidate ??
        LocalRideRepository(rides: widget.rides, delay: widget.loadDelay);
    _viewModel = HomeViewModel(
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
    if (_ownsMapService) _mapService?.close();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    final error = _viewModel.search(
      origin: _originController.text,
      destination: _destinationController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _swapLocations() {
    final originText = _originController.text;
    final destinationText = _destinationController.text;
    final originPlace = _viewModel.originPlace;
    final destinationPlace = _viewModel.destinationPlace;
    FocusScope.of(context).unfocus();
    // Capture selections before controller listeners invalidate either field.
    _originController.text = destinationText;
    _destinationController.text = originText;
    _viewModel.setLocations(destinationPlace, originPlace);
  }

  Future<void> _openFilter() async {
    final result = await Navigator.pushNamed<RideFilter>(
      context,
      AppRoutes.rideFilter,
      arguments: _viewModel.filter,
    );
    if (!mounted || result == null) return;
    _viewModel.applyFilter(result);
  }

  void _openDetail(Ride ride) {
    Navigator.pushNamed(context, AppRoutes.detail, arguments: ride);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        body: SafeArea(child: _buildContent()),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Cari',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Pesanan',
              enabled: false,
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments),
              label: 'Ongkos',
              enabled: false,
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (_viewModel.status) {
      RideViewStatus.loading => const LoadingView(
        message: 'Nyari tebengan dulu...',
      ),
      RideViewStatus.error => ErrorView(
        message: _viewModel.errorMessage,
        onRetry: _viewModel.load,
      ),
      RideViewStatus.success => _buildRideSearch(),
    };
  }

  Widget _buildRideSearch() {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      children: [
        _HomeHeader(userName: widget.userName),
        const SizedBox(height: AppSpacing.lg),
        _SearchCard(
          service: _mapService!,
          onSwap: _swapLocations,
          originPlace: _viewModel.originPlace,
          destinationPlace: _viewModel.destinationPlace,
          onOriginSelected: _viewModel.selectOrigin,
          onDestinationSelected: _viewModel.selectDestination,
          originController: _originController,
          destinationController: _destinationController,
          onSearch: _search,
        ),
        if (_repository.isSimulation) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Data latihan · bukan perjalanan nyata'),
        ],
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'Yang searah sama kamu',
          actionLabel: _viewModel.filter.isActive ? 'Filter aktif' : 'Filter',
          onAction: _openFilter,
        ),
        const SizedBox(height: AppSpacing.md),
        if (_viewModel.allRides.isEmpty)
          const SizedBox(
            height: 220,
            child: EmptyView(message: 'Belum ada tebengan.'),
          )
        else if (_viewModel.results.isEmpty)
          Text(
            'Yah, belum ada yang cocok. Coba ganti lokasi atau filternya, deh!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          for (final ride in _viewModel.results) ...[
            if (_viewModel.geographicSearch)
              const Text(
                'Searah jalur',
                style: TextStyle(color: AppColors.successText),
              ),
            RideCard(ride: ride, onTap: () => _openDetail(ride)),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, $userName!',
                style: AppTextStyles.headingLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Mau nebeng ke mana hari ini?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        UserAvatar(name: userName),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.service,
    required this.onSwap,
    required this.originPlace,
    required this.destinationPlace,
    required this.onOriginSelected,
    required this.onDestinationSelected,
    required this.originController,
    required this.destinationController,
    required this.onSearch,
  });

  final TextEditingController originController;
  final TextEditingController destinationController;
  final VoidCallback onSearch;
  final VoidCallback onSwap;
  final MapService service;
  final MapLocation? originPlace;
  final MapLocation? destinationPlace;
  final ValueChanged<MapLocation?> onOriginSelected;
  final ValueChanged<MapLocation?> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Cari tumpangan searah', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          const Text('Pilih lokasi jemput dan tujuanmu.'),
          const SizedBox(height: AppSpacing.md),
          RouteEndpoints(
            onSwap: onSwap,
            origin: LocationField(
              label: 'Dari',
              hint: 'Contoh: Jl. Khatib Sulaiman',
              controller: originController,
              initialLocation: originPlace,
              service: service,
              onSelected: onOriginSelected,
            ),
            destination: LocationField(
              label: 'Ke',
              hint: 'Contoh: Kampus Unand Limau Manis',
              controller: destinationController,
              initialLocation: destinationPlace,
              service: service,
              onSelected: onDestinationSelected,
              onFieldSubmitted: (_) => onSearch(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: 'Cariin Tebengan!', onPressed: onSearch),
        ],
      ),
    );
  }
}
