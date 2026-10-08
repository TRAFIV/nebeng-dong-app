import 'package:flutter/material.dart';

import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/legacy/driver/viewmodels/post_route_view_model.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_field.dart';
import 'package:praktikum_mobile/shared/maps/widgets/route_endpoints.dart';
import 'package:praktikum_mobile/core/di/map_service_scope.dart';
import 'package:praktikum_mobile/shared/maps/widgets/open_street_map_view.dart';

/// Form FR-01. Hasil bertipe Ride dikembalikan ke Rute Saya setelah validasi.
class PostRouteScreen extends StatefulWidget {
  const PostRouteScreen({
    super.key,
    required this.repository,
    required this.driverName,
    this.initialRide,
  });
  final LegacyDriverRepository repository;
  final String driverName;
  final Ride? initialRide;

  @override
  State<PostRouteScreen> createState() => _PostRouteScreenState();
}

class _PostRouteScreenState extends State<PostRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _origin;
  late final TextEditingController _destination;
  late final TextEditingController _departure;
  late final TextEditingController _seats;
  late PostRouteViewModel _viewModel;
  MapService? _mapService;
  bool _ownsMapService = false;

  @override
  void initState() {
    super.initState();
    final ride = widget.initialRide;
    _origin = TextEditingController(text: ride?.origin);
    _destination = TextEditingController(text: ride?.destination);
    _departure = TextEditingController(text: ride?.departureTime);
    _seats = TextEditingController(text: ride?.seatCapacity.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mapService != null) return;
    _mapService = MapServiceScope.maybeOf(context)?.service;
    _ownsMapService = _mapService == null;
    _mapService ??= OpenMapService();
    _viewModel = PostRouteViewModel(
      repository: widget.repository,
      service: _mapService!,
      driverName: widget.driverName,
      initialRide: widget.initialRide,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    if (_ownsMapService) _mapService?.close();
    _origin.dispose();
    _destination.dispose();
    _departure.dispose();
    _seats.dispose();
    super.dispose();
  }

  void _swapLocations() {
    if (_viewModel.saving) return;
    final originText = _origin.text;
    final destinationText = _destination.text;
    final originPlace = _viewModel.originPlace;
    final destinationPlace = _viewModel.destinationPlace;
    FocusScope.of(context).unfocus();
    _origin.text = destinationText;
    _destination.text = originText;
    _viewModel.setLocations(destinationPlace, originPlace);
  }

  Future<void> _save() async {
    if (_viewModel.saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final result = await _viewModel.save(
      origin: _origin.text,
      destination: _destination.text,
      departure: _departure.text,
      seats: _seats.text,
    );
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    if (result != null) {
      Navigator.pop(context, result);
    } else if (_viewModel.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_viewModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = _viewModel.editing;
    return PopScope<Ride>(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _viewModel.cancelSave();
      },
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: Text(editing ? 'Edit Rute' : 'Posting Rute')),
          body: AbsorbPointer(
            absorbing: _viewModel.saving,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Beri Tebengan • Kamu sebagai pengemudi'),
                    const SizedBox(height: AppSpacing.md),
                    RouteEndpoints(
                      onSwap: _viewModel.saving ? null : _swapLocations,
                      origin: LocationField(
                        label: 'Dari',
                        hint: 'Contoh: Jl. Khatib Sulaiman',
                        controller: _origin,
                        service: _mapService!,
                        initialLocation: _viewModel.originPlace,
                        onSelected: _viewModel.selectOrigin,
                        validator: _viewModel.validateOrigin,
                      ),
                      destination: LocationField(
                        label: 'Ke',
                        hint: 'Contoh: Kampus Unand Limau Manis',
                        controller: _destination,
                        service: _mapService!,
                        initialLocation: _viewModel.destinationPlace,
                        onSelected: _viewModel.selectDestination,
                        validator: (value) =>
                            _viewModel.validateDestination(value, _origin.text),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final fields = [
                          Expanded(
                            child: AppTextField(
                              label: 'Jam cabut',
                              icon: Icons.schedule_rounded,
                              hint: '07.30',
                              controller: _departure,
                              keyboardType: TextInputType.datetime,
                              textInputAction: TextInputAction.next,
                              validator: _viewModel.validateDeparture,
                            ),
                          ),
                          Expanded(
                            child: AppTextField(
                              label: editing ? 'Total kursi' : 'Kursi kosong',
                              icon: Icons.event_seat_outlined,
                              hint: '3',
                              controller: _seats,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _save(),
                              validator: _viewModel.validateSeats,
                            ),
                          ),
                        ];
                        if (constraints.maxWidth < 300 ||
                            MediaQuery.textScalerOf(context).scale(1) > 1.3) {
                          return Column(
                            children: [
                              fields[0].child,
                              const SizedBox(height: AppSpacing.md),
                              fields[1].child,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            fields[0],
                            const SizedBox(width: AppSpacing.md),
                            fields[1],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_viewModel.saving) const LinearProgressIndicator(),
                    if (widget.initialRide?.geography != null &&
                        identical(
                          _viewModel.originPlace,
                          widget.initialRide!.geography!.origin,
                        ) &&
                        identical(
                          _viewModel.destinationPlace,
                          widget.initialRide!.geography!.destination,
                        ))
                      SizedBox(
                        height: 340,
                        child: OpenStreetMapView(
                          geography: widget.initialRide!.geography,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.brandSubtle,
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: const Text(
                        'Jadwal rutin: Senin–Jumat. Atur jam berangkat dan '
                        'jumlah kursi sesuai tebenganmu.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Lokasi asal dan tujuan dikirim ke layanan peta untuk menghitung rute.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                label: _viewModel.saving
                    ? 'Menghitung Jalur...'
                    : editing
                    ? 'Simpan Perubahan'
                    : 'Posting Rutenya!',
                onPressed: _viewModel.saving ? null : _save,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
