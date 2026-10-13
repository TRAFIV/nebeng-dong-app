import 'package:flutter/material.dart';
import 'package:praktikum_mobile/core/di/map_service_scope.dart';
import 'package:praktikum_mobile/core/di/ride_repository_scope.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/widgets/passenger_navigation.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/routes/ride_results_arguments.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/views/location_picker_screen.dart';
import 'package:praktikum_mobile/shared/maps/views/place_search_screen.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_selection_tile.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// M1 Cari. The form remains usable without fetching ride data.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userName,
    this.repository,
    this.rides,
    this.simulateError = false,
    this.loadDelay = const Duration(seconds: 2),
    this.initialOrigin,
    this.initialDestination,
  });
  final String userName;
  final RideRepository? repository;
  final List<Ride>? rides;
  final bool simulateError;
  final Duration loadDelay;
  final MapLocation? initialOrigin;
  final MapLocation? initialDestination;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late RideRepository _repository;
  late HomeViewModel _viewModel;
  MapService? _mapService;
  bool _ownsRepository = false;
  bool _ownsMapService = false;
  bool _initialized = false;
  bool _navigating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindRepository();
    final candidate = MapServiceScope.maybeOf(context)?.service;
    if (_mapService != null &&
        (identical(candidate, _mapService) ||
            (candidate == null && _ownsMapService))) {
      return;
    }
    if (_ownsMapService) _mapService?.close();
    _ownsMapService = candidate == null;
    _mapService = candidate ?? OpenMapService();
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
    final origin = _initialized ? _viewModel.originPlace : widget.initialOrigin;
    final destination = _initialized
        ? _viewModel.destinationPlace
        : widget.initialDestination;
    final filter = _initialized ? _viewModel.filter : const RideFilter();
    if (_initialized) {
      _viewModel.dispose();
      if (_ownsRepository) _repository.dispose();
    }
    _ownsRepository = candidate == null;
    _repository =
        candidate ??
        LocalRideRepository(rides: widget.rides, delay: widget.loadDelay);
    _viewModel = HomeViewModel(repository: _repository);
    _viewModel.setLocations(origin, destination);
    _viewModel.applyFilter(filter);
    _initialized = true;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    if (_ownsRepository) _repository.dispose();
    if (_ownsMapService) _mapService?.close();
    super.dispose();
  }

  Future<void> _select(String label, {bool map = false}) async {
    if (_navigating) return;
    _navigating = true;
    final initial = label == 'Dari'
        ? _viewModel.originPlace
        : _viewModel.destinationPlace;
    try {
      final result = await Navigator.push<MapLocation>(
        context,
        MaterialPageRoute(
          builder: (_) => map
              ? LocationPickerScreen(
                  title: 'Pin $label',
                  service: _mapService!,
                  initialLocation: initial,
                )
              : PlaceSearchScreen(
                  label: label,
                  service: _mapService!,
                  initialLocation: initial,
                ),
        ),
      );
      if (!mounted || result == null) return;
      if (label == 'Dari') {
        _viewModel.selectOrigin(result);
      } else {
        _viewModel.selectDestination(result);
      }
    } finally {
      _navigating = false;
    }
  }

  Future<void> _search() async {
    if (_navigating) return;
    final error = _viewModel.search();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final request = _viewModel.searchRequest!;
    _navigating = true;
    try {
      final result = await Navigator.pushNamed<RideFilter>(
        context,
        AppRoutes.rideResults,
        arguments: RideResultsArguments(
          request: request,
          repository: _repository,
          simulateError: widget.simulateError,
        ),
      );
      if (mounted && result != null) _viewModel.applyFilter(result);
    } finally {
      _navigating = false;
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _viewModel,
    builder: (context, _) => Scaffold(
      bottomNavigationBar: const PassengerNavigation(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hai, ${widget.userName}!',
                        style: AppTextStyles.headingLarge,
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
                UserAvatar(name: widget.userName),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppDecorations.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rute perjalananmu',
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tukar asal dan tujuan',
                        onPressed: () => _viewModel.setLocations(
                          _viewModel.destinationPlace,
                          _viewModel.originPlace,
                        ),
                        icon: const Icon(
                          Icons.swap_vert_rounded,
                          color: AppColors.brandStrong,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LocationSelectionTile(
                    label: 'Dari',
                    location: _viewModel.originPlace,
                    onSearch: () => _select('Dari'),
                    onMap: () => _select('Dari', map: true),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LocationSelectionTile(
                    label: 'Ke',
                    location: _viewModel.destinationPlace,
                    onSearch: () => _select('Ke'),
                    onMap: () => _select('Ke', map: true),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Cariin Tebengan!',
                    onPressed: _viewModel.canSearch ? _search : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.brandStrong,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bisa pilih pin langsung di peta',
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(
                        'Ketuk panah kanan. Alamat pin langsung terisi, lalu cari tebengan yang searah.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
