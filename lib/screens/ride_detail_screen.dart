import 'package:flutter/material.dart';

import '../models/ride.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/rupiah_format.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/user_avatar.dart';

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
  bool _requestSent = false;

  @override
  void dispose() {
    _pickupController.dispose();
    super.dispose();
  }

  String? _validatePickup(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Titik jemputnya diisi dulu, ya';
    }
    return null;
  }

  void _requestToJoin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Backend belum tersedia: status permintaan hanya disimpan di layar ini.
    setState(() => _requestSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sip! Permintaanmu udah dikirim, tinggal nunggu di-ACC.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final String buttonLabel;
    if (ride.isFull) {
      buttonLabel = 'Yah, Udah Penuh';
    } else if (_requestSent) {
      buttonLabel = 'Nunggu di-ACC...';
    } else {
      buttonLabel = 'Ikut Nebeng!';
    }
    final canRequest = !ride.isFull && !_requestSent;

    return Scaffold(
      appBar: AppBar(title: const Text('Info Tebengan')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _DriverCard(ride: ride),
              const SizedBox(height: AppSpacing.md),
              _RouteCard(ride: ride),
              const SizedBox(height: AppSpacing.md),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Sisa kursi',
                        value:
                            '${ride.seatsAvailable} dari ${ride.seatCapacity}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _InfoTile(
                        label: 'Patungan per orang',
                        value: formatRupiah(ride.farePerPerson),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Mau dijemput di mana?',
                hint: 'Contoh: depan gerbang Kompleks Veteran',
                controller: _pickupController,
                textInputAction: TextInputAction.done,
                validator: _validatePickup,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: buttonLabel,
              onPressed: canRequest ? _requestToJoin : null,
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
          _RouteRow(label: 'Dari', value: ride.origin),
          const SizedBox(height: AppSpacing.md),
          _RouteRow(label: 'Ke', value: ride.destination),
          const SizedBox(height: AppSpacing.md),
          _RouteRow(
            label: 'Jadwal cabut',
            value: '${ride.schedule}, ${ride.departureTime}',
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.brandSubtle,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.brand),
          ),
        ],
      ),
    );
  }
}
