import 'package:flutter/material.dart';

import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/viewmodels/ride_detail_view_model.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';
import 'package:praktikum_mobile/shared/widgets/info_tile.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/shared/maps/widgets/open_street_map_view.dart';
import 'package:praktikum_mobile/shared/maps/widgets/route_endpoints.dart';

/// Detail tebengan: kursi, ongkos, titik jemput, dan ajukan gabung
/// (FR-04, FR-05, FR-06, FR-09).
class RideDetailScreen extends StatefulWidget {
  const RideDetailScreen({super.key, required this.ride});

  final Ride ride;

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  late final RideDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RideDetailViewModel(ride: widget.ride);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  void _requestToJoin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_viewModel.requestToJoin(_pickupController.text)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sip! Permintaanmu udah dikirim, tinggal nunggu di-ACC.'),
      ),
    );
  }

  Future<void> _openNoteForm() async {
    final result = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    if (!mounted || result == null) return;

    _viewModel.saveNote(result);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    final ride = _viewModel.ride;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Info Tebengan')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            // Keep every field mounted: the sticky submit button must validate
            // pickup even before it has been scrolled into view.
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DriverCard(ride: ride),
                  const SizedBox(height: AppSpacing.md),
                  _RouteCard(ride: ride),
                  if (ride.geography != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 340,
                      child: OpenStreetMapView(geography: ride.geography),
                    ),
                    Text(
                      '${(ride.geography!.route.distanceMeters / 1000).toStringAsFixed(1)} km · '
                      'sekitar ${(ride.geography!.route.durationSeconds / 60).ceil()} menit (profil mobil)',
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: InfoTile(
                            icon: Icons.event_seat_outlined,
                            positive: true,
                            label: 'Sisa kursi',
                            value:
                                '${ride.seatsAvailable} dari ${ride.seatCapacity}',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: InfoTile(
                            icon: Icons.payments_outlined,
                            label: 'Patungan per orang',
                            value: ride.farePerPerson == 0
                                ? 'Belum diatur'
                                : formatRupiah(ride.farePerPerson),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Mau dijemput di mana?',
                    icon: Icons.person_pin_circle_outlined,
                    hint: 'Contoh: depan gerbang Kompleks Veteran',
                    controller: _pickupController,
                    textInputAction: TextInputAction.done,
                    validator: _viewModel.validatePickup,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: AppDecorations.outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Catatan', style: AppTextStyles.labelLarge),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _viewModel.note ?? 'Belum ada catatan.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _viewModel.note == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: 'Tulis Catatan',
                          onPressed: _openNoteForm,
                          variant: AppButtonVariant.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                label: _viewModel.buttonLabel,
                onPressed: _viewModel.canRequest ? _requestToJoin : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.outlined,
      child: Row(
        children: [
          UserAvatar(name: ride.driverName, size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ride.driverName, style: AppTextStyles.labelLarge),
                Text(
                  'Rating ${ride.driverRating.toStringAsFixed(1)} · '
                  'Udah ${ride.driverTripCount}x nebengin',
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
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RouteLocationSummary(
            origin: ride.origin,
            destination: ride.destination,
            originAddress: ride.geography?.origin.address,
            destinationAddress: ride.geography?.destination.address,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppColors.routeOrigin),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _RouteRow(
                  label: 'Jadwal cabut',
                  value: '${ride.schedule}, ${ride.departureTime}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(value, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}
