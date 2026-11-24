import 'package:flutter/material.dart';

import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';
import 'package:praktikum_mobile/shared/viewmodels/ride_detail_view_model.dart';
import 'package:praktikum_mobile/shared/viewmodels/passenger_shell_view_model.dart';
import 'package:praktikum_mobile/shared/widgets/passenger_shell_scope.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/road_scene.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/shared/maps/widgets/open_street_map_view.dart';
import 'package:praktikum_mobile/shared/maps/widgets/route_endpoints.dart';

/// Info Tebengan: peta, jam dan rute, kursi/ongkos/kendaraan, pengemudi,
/// lalu tombol untuk membuka Ajukan Tebengan (FR-04, FR-05, FR-09).
class RideDetailScreen extends StatefulWidget {
  const RideDetailScreen({super.key, required this.ride});

  final Ride ride;

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  late final RideDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RideDetailViewModel(ride: widget.ride);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Buka Ajukan Tebengan; titik jemput dan catatan diisi di sana.
  Future<void> _requestToJoin() async {
    if (!_viewModel.startRequest()) return;

    // Hasilnya Booking bila terkirim, null bila pengguna kembali tanpa mengirim.
    final result = await Navigator.pushNamed<Object?>(
      context,
      AppRoutes.ajukanTebengan,
      arguments: _viewModel.ride,
    );

    if (!mounted) return;
    _viewModel.finishRequest(sent: result != null);
    if (result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permintaan terkirim! Tunggu kabar ya.')),
    );
    // Arahkan ke tab Pesanan Saya agar user bisa memantau pesanannya.
    if (!PassengerShellScope.openTab(context, PassengerTab.pesanan)) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.pesananSaya,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = _viewModel.ride;
    final vehicle = ride.vehicle;
    final route = ride.geography?.route;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text('Info Tebengan'),
          shape: const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        body: SafeArea(
          // Halaman pendek: semua bagian dibangun sekaligus.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (ride.geography != null) ...[
                  ClipRRect(
                    borderRadius: AppRadius.mdAll,
                    child: SizedBox(
                      // Ikut membesar bersama teks agar atribusi peta muat.
                      height: 180 + MediaQuery.textScalerOf(context).scale(40),
                      child: OpenStreetMapView(geography: ride.geography),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.ms),
                ],
                _TripCard(
                  ride: ride,
                  vehicle: vehicle,
                  distanceLabel: route == null
                      ? null
                      : '${(route.distanceMeters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km'
                            ' · ±${(route.durationSeconds / 60).ceil()} mnt',
                ),
                const SizedBox(height: AppSpacing.ms),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _Fact(
                          icon: Icons.event_seat_outlined,
                          label: 'Sisa kursi',
                          value: ride.isFull
                              ? 'Penuh'
                              : '${ride.seatsAvailable} dari ${ride.seatCapacity}',
                          tone: ride.seatsAvailable == 1
                              ? AppColors.onAccentWarm
                              : AppColors.successText,
                          background: ride.seatsAvailable == 1
                              ? AppColors.accentWarm
                              : AppColors.successSubtle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _Fact(
                          icon: Icons.payments_outlined,
                          label: 'Patungan',
                          value: ride.farePerPerson == 0
                              ? 'Belum diatur'
                              : formatRupiah(ride.farePerPerson),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _Fact(
                          icon: vehicle == VehicleKind.motor
                              ? Icons.two_wheeler_rounded
                              : Icons.directions_car_rounded,
                          label: 'Kendaraan',
                          value: vehicle.label,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.ms),
                _DriverCard(ride: ride),
                const SizedBox(height: AppSpacing.ms),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.ms),
                  decoration: const BoxDecoration(
                    color: AppColors.subtleFill,
                    borderRadius: AppRadius.controlAll,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.brand,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Titik jemput dan catatan buat pengemudi diisi di '
                          'langkah berikutnya.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                icon: _viewModel.canRequest ? Icons.front_hand_rounded : null,
                onPressed: _viewModel.canRequest ? _requestToJoin : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Jam cabut, jarak/durasi, rute Dari/Ke, dan jalan raya mini.
class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.ride,
    required this.vehicle,
    required this.distanceLabel,
  });

  final Ride ride;
  final VehicleKind vehicle;
  final String? distanceLabel;

  @override
  Widget build(BuildContext context) => DecoratedBox(
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
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: ride.departureTime,
                        style: AppTextStyles.headingMedium.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const TextSpan(
                        text: '  cabut',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              if (distanceLabel != null)
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.subtleFill,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        distanceLabel!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.ms),
          RouteLocationSummary(
            origin: ride.origin,
            destination: ride.destination,
            originAddress: ride.geography?.origin.address,
            destinationAddress: ride.geography?.destination.address,
          ),
          const SizedBox(height: AppSpacing.sm),
          RoadScene(vehicle: vehicle),
        ],
      ),
    ),
  );
}

/// Satu fakta singkat: ikon, label kecil, nilai tebal.
class _Fact extends StatelessWidget {
  const _Fact({
    required this.icon,
    required this.label,
    required this.value,
    this.tone = AppColors.brandStrong,
    this.background = AppColors.brandSubtle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tone;
  final Color background;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: AppDecorations.card,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.ms),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: background,
              borderRadius: AppRadius.controlAll,
            ),
            child: Icon(icon, size: 18, color: tone),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
        ],
      ),
    ),
  );
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: AppDecorations.card,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.ms),
      child: Row(
        children: [
          UserAvatar(name: ride.driverName, size: 44),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pengemudi', style: AppTextStyles.caption),
                Text(ride.driverName, style: AppTextStyles.title),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: Color(0xFFF2A900),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${ride.driverRating.toStringAsFixed(1).replaceAll('.', ',')}'
                        ' · Udah ${ride.driverTripCount}x nebengin',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
