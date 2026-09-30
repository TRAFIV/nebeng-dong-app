import 'package:flutter/material.dart';

import '../models/ride.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/rupiah_format.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/info_tile.dart';
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
  String? _catatan;

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

  Future<void> _openNoteForm() async {
    final result = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    if (!mounted || result == null) return;

    setState(() => _catatan = result);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan berhasil disimpan')));
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
                      child: InfoTile(
                        positive: true,
                        label: 'Sisa kursi',
                        value:
                            '${ride.seatsAvailable} dari ${ride.seatCapacity}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: InfoTile(
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
                      _catatan ?? 'Belum ada catatan.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _catatan == null
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
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
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
