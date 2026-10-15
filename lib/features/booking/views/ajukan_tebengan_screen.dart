import 'package:flutter/material.dart';

import 'package:praktikum_mobile/core/di/booking_repository_scope.dart';
import 'package:praktikum_mobile/features/booking/data/booking_repository.dart';
import 'package:praktikum_mobile/features/booking/data/local_booking_repository.dart';
import 'package:praktikum_mobile/features/booking/viewmodels/ajukan_tebengan_view_model.dart';
import 'package:praktikum_mobile/shared/maps/widgets/open_street_map_view.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Layar Ajukan Tebengan: verifikasi titik jemput & kirim permintaan (FR-05, FR-06).
class AjukanTebenganScreen extends StatefulWidget {
  const AjukanTebenganScreen({
    super.key,
    required this.ride,
    this.repository,
    this.initialPickup,
    this.initialNote,
  });

  final Ride ride;
  final BookingRepository? repository;
  final String? initialPickup;
  final String? initialNote;

  @override
  State<AjukanTebenganScreen> createState() => _AjukanTebenganScreenState();
}

class _AjukanTebenganScreenState extends State<AjukanTebenganScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _pickupController;
  late final TextEditingController _noteController;
  late BookingRepository _repository;
  late AjukanTebenganViewModel _viewModel;
  bool _initialized = false;
  bool _ownsRepository = false;

  @override
  void initState() {
    super.initState();
    final defaultPickup =
        widget.initialPickup ??
        widget.ride.geography?.origin.address ??
        'Gerbang Kompleks Veteran, Padang';
    _pickupController = TextEditingController(text: defaultPickup);
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final scoped = BookingRepositoryScope.maybeOf(context);
    final candidate = widget.repository ?? scoped;
    _ownsRepository = candidate == null;
    _repository = candidate ?? LocalBookingRepository();
    _viewModel = AjukanTebenganViewModel(
      ride: widget.ride,
      repository: _repository,
    );
    _initialized = true;
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _noteController.dispose();
    if (_initialized) {
      _viewModel.dispose();
      if (_ownsRepository) _repository.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final booking = await _viewModel.submitBooking(
      pickup: _pickupController.text,
      note: _noteController.text,
    );

    if (!mounted) return;

    if (booking != null) {
      // Tutup layar ini dan kembalikan objek booking ke pemanggil (FR-05).
      // PesananSaya atau RideDetail akan menampilkan SnackBar sukses.
      Navigator.pop(context, booking);
    } else {
      // Tetap di form, tampilkan pesan gagal (FR-06).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Gagal mengirim. Coba lagi ya.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Ajukan Tebengan'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // 1. Driver summary card
                _DriverSummaryCard(ride: ride),
                const SizedBox(height: AppSpacing.md),

                // 2. Map preview
                _MapPreviewBox(ride: ride),
                const SizedBox(height: AppSpacing.md),

                // 3. Field Alamat Lengkap
                AppTextField(
                  label: 'Titik Jemput',
                  controller: _pickupController,
                  hint: 'Masukkan lokasi titik jemput',
                  textInputAction: TextInputAction.next,
                  validator: _viewModel.validatePickup,
                ),
                const SizedBox(height: AppSpacing.md),

                // 4. Field Catatan buat driver
                AppTextField(
                  label: 'Catatan buat ${ride.driverName}',
                  hint: 'Contoh: depan pagar biru',
                  controller: _noteController,
                  textInputAction: TextInputAction.done,
                  validator: _viewModel.validateNote,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.xs),

                // 5. Helper text
                Text(
                  'Pin harus dekat jalur tebengan ${ride.driverName}.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
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
                label: _viewModel.isSubmitting
                    ? 'Mengirim...'
                    : 'Kirim Permintaan!',
                onPressed: _viewModel.isSubmitting ? null : _submit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverSummaryCard extends StatelessWidget {
  const _DriverSummaryCard({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          UserAvatar(name: ride.driverName, size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.driverName,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${ride.schedule} · ${ride.departureTime}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            label: 'Sisa ${ride.seatsAvailable} kursi',
            tone: StatusTone.success,
          ),
        ],
      ),
    );
  }
}

class _MapPreviewBox extends StatelessWidget {
  const _MapPreviewBox({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    final geography = ride.geography;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F1E8),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (geography != null)
            Positioned.fill(
              child: IgnorePointer(
                child: OpenStreetMapView(geography: geography),
              ),
            )
          else
            const Center(
              child: Icon(
                Icons.map_rounded,
                size: 64,
                color: Color(0xFFB4D2B8),
              ),
            ),

          // Stylized Callout Pin Overlay
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.pill,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Gerbang Kompleks Veteran',
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.location_on,
                  color: AppColors.brandStrong,
                  size: 28,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ride.origin,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // OSM Attribution
          Positioned(
            bottom: 4,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
