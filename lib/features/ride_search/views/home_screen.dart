import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:praktikum_mobile/core/app_clock.dart';
import 'package:praktikum_mobile/core/di/map_service_scope.dart';
import 'package:praktikum_mobile/core/di/ride_repository_scope.dart';
import 'package:praktikum_mobile/features/ride_search/data/fixtures/demo_rides.dart';
import 'package:praktikum_mobile/features/ride_search/data/local_ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/data/saved_places_store.dart';
import 'package:praktikum_mobile/features/ride_search/models/saved_place.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_schedule.dart';
import 'package:praktikum_mobile/features/ride_search/utils/ride_search_matcher.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/home_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/saved_places_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/upcoming_rides_view_model.dart';
import 'package:praktikum_mobile/features/ride_search/widgets/saved_place_shortcuts.dart';
import 'package:praktikum_mobile/features/ride_search/widgets/upcoming_ride_card.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/routes/ride_results_arguments.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/services/device_location.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/viewmodels/current_location_view_model.dart';
import 'package:praktikum_mobile/shared/maps/views/place_search_screen.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_selection_tile.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/viewmodels/passenger_shell_view_model.dart';
import 'package:praktikum_mobile/shared/widgets/mascot_profile_badge.dart';
import 'package:praktikum_mobile/shared/widgets/passenger_shell_scope.dart';
import 'package:praktikum_mobile/shared/widgets/route_loader.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// M1 Cari. Form Cari tidak pernah menunggu data rute; "Berangkat sebentar
/// lagi" dimuat terpisah di latar belakang.
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
    this.showUpcoming = true,
    this.savedPlaces,
    this.now,
    this.deviceLocation,
  });
  final String userName;
  final RideRepository? repository;
  final List<Ride>? rides;
  final bool simulateError;
  final Duration loadDelay;
  final MapLocation? initialOrigin;
  final MapLocation? initialDestination;

  /// Tampilkan "Berangkat sebentar lagi" (memuat data rute di latar belakang).
  final bool showUpcoming;

  /// Penyimpanan "Tempat tujuan"; bawaan: SharedPreferences di HP.
  final SavedPlacesStore? savedPlaces;

  /// Jam sekarang, untuk tes.
  final DateTime Function()? now;

  /// Sumber lokasi perangkat untuk mengisi Dari otomatis; bawaan GPS.
  final DeviceLocation? deviceLocation;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late RideRepository _repository;
  late HomeViewModel _viewModel;
  UpcomingRidesViewModel? _upcoming;
  late final SavedPlacesViewModel _places = SavedPlacesViewModel(
    store: widget.savedPlaces ?? LocalSavedPlacesStore(),
  )..load();
  MapService? _mapService;
  CurrentLocationViewModel? _currentLocation;
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
    _currentLocation?.dispose();
    _currentLocation = CurrentLocationViewModel(
      device: widget.deviceLocation ?? const GeolocatorDeviceLocation(),
      maps: _mapService!,
    );
  }

  @override
  void initState() {
    super.initState();
    // Isi Dari dari lokasi perangkat setelah layar tampil (izin diminta
    // sekali oleh sistem). Pilihan penumpang tidak pernah ditimpa.
    WidgetsBinding.instance.addPostFrameCallback((_) => _locateOrigin());
  }

  Future<void> _locateOrigin() async {
    final locator = _currentLocation;
    if (!mounted || locator == null || _viewModel.originPlace != null) return;
    final place = await locator.locate();
    if (!mounted || place == null) return;
    _viewModel.useCurrentLocation(place);
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
    final date = _initialized ? _viewModel.date : null;
    final time = _initialized ? _viewModel.time : null;
    if (_initialized) {
      _viewModel.dispose();
      if (_ownsRepository) _repository.dispose();
    }
    _ownsRepository = candidate == null;
    _repository =
        candidate ??
        LocalRideRepository(rides: widget.rides, delay: widget.loadDelay);
    _viewModel = HomeViewModel();
    _viewModel.setLocations(origin, destination);
    _viewModel.applyFilter(filter);
    if (date != null) _viewModel.restoreWhen(date, time);
    _upcoming?.dispose();
    _upcoming = widget.showUpcoming
        ? UpcomingRidesViewModel(repository: _repository, now: widget.now)
        : null;
    _initialized = true;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _upcoming?.dispose();
    _places.dispose();
    _currentLocation?.dispose();
    if (_ownsRepository) _repository.dispose();
    if (_ownsMapService) _mapService?.close();
    super.dispose();
  }

  Future<void> _select(String label) async {
    if (_navigating) return;
    _navigating = true;
    final initial = label == 'Dari'
        ? _viewModel.originPlace
        : _viewModel.destinationPlace;
    try {
      final result = await Navigator.push<MapLocation>(
        context,
        MaterialPageRoute(
          // Pin peta tetap ada: "Pilih langsung di peta" di layar ini.
          builder: (_) => PlaceSearchScreen(
            label: label,
            service: _mapService!,
            initialLocation: initial,
            quickPlaces: demoPlaces,
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

  bool _isDestination(SavedPlace place) {
    final destination = _viewModel.destinationPlace;
    return destination != null &&
        destination.point.distanceTo(place.location.point) < 1;
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _addPlace() async {
    if (_navigating) return;
    _navigating = true;
    try {
      final location = await Navigator.push<MapLocation>(
        context,
        MaterialPageRoute(
          builder: (_) => PlaceSearchScreen(
            label: 'Tujuan',
            service: _mapService!,
            quickPlaces: demoPlaces,
          ),
        ),
      );
      if (!mounted || location == null) return;
      final name = await showDialog<String>(
        context: context,
        builder: (_) =>
            _NamePlaceDialog(place: location, validator: _places.validateName),
      );
      if (!mounted || name == null) return;
      final saved = await _places.add(name, location);
      if (!mounted) return;
      _showMessage(
        saved
            ? '${name.trim()} tersimpan di Tempat tujuan'
            : _places.errorMessage ?? 'Tempat belum tersimpan. Coba lagi ya.',
      );
    } finally {
      _navigating = false;
    }
  }

  Future<void> _removePlace(SavedPlace place) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${place.name}?'),
        content: const Text('Tempat ini hilang dari Tempat tujuan di HP ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final removed = await _places.remove(place);
    if (mounted && !removed) {
      _showMessage(_places.errorMessage ?? 'Belum bisa menghapus. Coba lagi.');
    }
  }

  void _openRide(Ride ride) =>
      Navigator.pushNamed(context, AppRoutes.detail, arguments: ride);

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([_viewModel, _places]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          children: [
            _Greeting(userName: widget.userName),
            // Pita oranye 40 px di belakang bagian atas kartu rute.
            Stack(
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: ColoredBox(color: AppColors.brand),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: _routeCard(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _section(
              title: 'Tempat tujuan',
              action: TextButton(
                onPressed: _places.places.isEmpty ? null : _managePlaces,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Atur'),
              ),
              child: SavedPlaceShortcuts(
                places: _places.places,
                tagFor: _places.hintFor,
                isSelected: _isDestination,
                onSelect: (place) =>
                    _viewModel.selectDestination(place.location),
                onRemove: _removePlace,
                onAdd: _places.loaded && _places.canAdd ? _addPlace : null,
              ),
            ),
            if (_upcoming != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _UpcomingSection(viewModel: _upcoming!, onOpen: _openRide),
            ],
          ],
        ),
      ),
    ),
  );

  Future<void> _pickDate() async {
    final today = AppClock.today();
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Kapan berangkat?', style: AppTextStyles.headingMedium),
              const SizedBox(height: AppSpacing.ms),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final day in _viewModel.dateOptions)
                    ChoiceChip(
                      label: Text(formatTripDay(day, today)),
                      selected: day == _viewModel.date,
                      onSelected: (_) => Navigator.pop(context, day),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && picked != null) _viewModel.setDate(picked);
  }

  Future<void> _pickTime() async {
    final current = _viewModel.time ?? AppClock.now().hour * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      helpText: 'Jam berangkat (±15 menit)',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (mounted && picked != null) {
      _viewModel.setTime(picked.hour * 60 + picked.minute);
    }
  }

  Widget _routeCard() => DecoratedBox(
    decoration: AppDecorations.floating,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.ms),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Column(
                children: [
                  ListenableBuilder(
                    listenable: _currentLocation!,
                    builder: (context, _) => LocationSelectionTile(
                      label: 'Dari',
                      location: _viewModel.originPlace,
                      note: _viewModel.originIsCurrent
                          ? 'lokasimu sekarang'
                          : null,
                      placeholder: _currentLocation!.locating
                          ? 'Mencari lokasimu…'
                          : null,
                      onSearch: () => _select('Dari'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  LocationSelectionTile(
                    label: 'Ke',
                    location: _viewModel.destinationPlace,
                    onSearch: () => _select('Ke'),
                  ),
                ],
              ),
              // Tombol tukar di dalam kotak, di antara Dari dan Ke.
              Positioned(
                right: AppSpacing.sm,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedRotation(
                    turns: _viewModel.swapCount * 0.5,
                    duration: AppMotion.reduced(context)
                        ? Duration.zero
                        : AppMotion.slow,
                    curve: Curves.easeOutBack,
                    child: IconButton.outlined(
                      tooltip: 'Tukar asal dan tujuan',
                      onPressed: _viewModel.swapLocations,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.brandStrong,
                      ),
                      icon: const Icon(Icons.swap_vert_rounded),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.ms),
          Row(
            children: [
              Expanded(
                child: _WhenPicker(
                  key: const ValueKey('pick-date'),
                  icon: Icons.calendar_today_rounded,
                  label: formatTripDay(_viewModel.date, AppClock.today()),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _WhenPicker(
                  key: const ValueKey('pick-time'),
                  icon: Icons.schedule_rounded,
                  label: _viewModel.time == null
                      ? 'Semua jam'
                      : formatMinuteOfDay(_viewModel.time!),
                  onTap: _pickTime,
                  onClear: _viewModel.time == null
                      ? null
                      : () => _viewModel.setTime(null),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.ms),
          AppButton(
            label: 'Cariin Tebengan!',
            icon: Icons.search_rounded,
            onPressed: _viewModel.canSearch ? _search : null,
          ),
        ],
      ),
    ),
  );

  Future<void> _managePlaces() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => ListenableBuilder(
        listenable: _places,
        builder: (sheetContext, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Tempat tujuan', style: AppTextStyles.headingMedium),
                Text(
                  'Tersimpan di HP ini saja. Maksimal '
                  '${SavedPlacesViewModel.maxPlaces} tempat.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_places.places.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      'Belum ada tempat tersimpan.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                for (final place in _places.places)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(place.name, style: AppTextStyles.labelLarge),
                    subtitle: Text(
                      place.location.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                    trailing: IconButton(
                      tooltip: 'Hapus ${place.name}',
                      onPressed: () => _removePlace(place),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.brandStrong,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
    Widget? action,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.title)),
            ?action,
          ],
        ),
        const SizedBox(height: AppSpacing.ms),
        child,
      ],
    ),
  );
}

/// Sapaan di pita oranye bersama Si Titik yang sesekali berputar
/// memperlihatkan avatar profil.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.brand,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.ms,
        AppSpacing.sm,
        AppSpacing.ms,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai, $userName!',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.onBrand,
                  ),
                ),
                Text(
                  'Mau nebeng ke mana hari ini?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onBrand.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          MascotProfileBadge(
            name: userName,
            // Di dalam shell penumpang, ketuk untuk membuka tab Profil.
            onTap: PassengerShellScope.maybeOf(context) == null
                ? null
                : () =>
                      PassengerShellScope.openTab(context, PassengerTab.profil),
          ),
        ],
      ),
    ),
  );
}

/// "Berangkat sebentar lagi": dimuat terpisah agar form tidak menunggu.
class _UpcomingSection extends StatefulWidget {
  const _UpcomingSection({required this.viewModel, required this.onOpen});

  final UpcomingRidesViewModel viewModel;
  final ValueChanged<Ride> onOpen;

  @override
  State<_UpcomingSection> createState() => _UpcomingSectionState();
}

class _UpcomingSectionState extends State<_UpcomingSection> {
  UpcomingRidesViewModel get viewModel => widget.viewModel;
  ValueChanged<Ride> get onOpen => widget.onOpen;

  @override
  void initState() {
    super.initState();
    // Baru memuat saat bagian ini tampil (ListView membangunnya malas).
    viewModel.ensureLoaded();
  }

  @override
  void didUpdateWidget(_UpcomingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, viewModel)) viewModel.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final Widget body = switch (viewModel.status) {
        UpcomingStatus.loading => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(child: RouteLoader(width: 120)),
        ),
        UpcomingStatus.error => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Daftar keberangkatan belum bisa dimuat.',
                  style: AppTextStyles.caption,
                ),
              ),
              TextButton(
                onPressed: viewModel.load,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        UpcomingStatus.success when viewModel.rides.isEmpty => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Belum ada tebengan yang cabut lagi hari ini.',
            style: AppTextStyles.caption,
          ),
        ),
        UpcomingStatus.success => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, item) in viewModel.rides.indexed) ...[
                if (index > 0) const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 228,
                  child: UpcomingRideCard(
                    item: item,
                    highlight: index == 0,
                    onTap: () => onOpen(item.ride),
                  ),
                ),
              ],
            ],
          ),
        ),
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Berangkat sebentar lagi', style: AppTextStyles.title),
          ),
          const SizedBox(height: AppSpacing.ms),
          body,
        ],
      );
    },
  );
}

/// Dialog memberi nama tempat tujuan baru (mis. Rumah, Kos).
class _NamePlaceDialog extends StatefulWidget {
  const _NamePlaceDialog({required this.place, required this.validator});

  final MapLocation place;
  final String? Function(String?) validator;

  @override
  State<_NamePlaceDialog> createState() => _NamePlaceDialogState();
}

class _NamePlaceDialogState extends State<_NamePlaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _name.text.trim());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Simpan tempat tujuan'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.place.label, style: AppTextStyles.labelLarge),
          if (widget.place.address.isNotEmpty)
            Text(widget.place.address, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.ms),
          TextFormField(
            key: const ValueKey('saved-place-name'),
            controller: _name,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nama',
              hintText: 'Rumah, Kos, Perpus',
            ),
            validator: widget.validator,
            onFieldSubmitted: (_) => _save(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      FilledButton(onPressed: _save, child: const Text('Simpan')),
    ],
  );
}

/// Tombol pemilih tanggal/jam di kartu rute.
class _WhenPicker extends StatelessWidget {
  const _WhenPicker({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Tampil sebagai tanda silang; `null` berarti tidak bisa dikosongkan.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: AppRadius.controlAll,
      side: BorderSide(color: AppColors.border),
    ),
    child: InkWell(
      borderRadius: AppRadius.controlAll,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.ms),
            Icon(icon, size: 18, color: AppColors.brand),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
              ),
            ),
            if (onClear != null)
              IconButton(
                tooltip: 'Semua jam',
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.textSecondary,
              )
            else ...[
              const Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      ),
    ),
  );
}
