import 'package:flutter/material.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_filter_view_model.dart';
import 'package:praktikum_mobile/shared/models/vehicle_kind.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Membuka Filter sebagai lembar dari bawah di atas Hasil.
/// Mengembalikan filter baru, atau `null` bila ditutup tanpa diterapkan.
Future<RideFilter?> showRideFilterSheet(
  BuildContext context,
  RideFilter initialFilter,
) => showModalBottomSheet<RideFilter>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: AppColors.surface,
  builder: (_) => RideFilterSheet(initialFilter: initialFilter),
);

/// Isi Filter: kendaraan, minimal kursi dan batas ongkos. Jam dipilih di Cari
/// (±15 menit), jadi tidak diulang di sini.
class RideFilterSheet extends StatefulWidget {
  const RideFilterSheet({super.key, this.initialFilter = const RideFilter()});
  final RideFilter initialFilter;
  @override
  State<RideFilterSheet> createState() => _RideFilterSheetState();
}

class _RideFilterSheetState extends State<RideFilterSheet> {
  final _formKey = GlobalKey<FormState>();
  late final RideFilterViewModel _viewModel;
  late final TextEditingController _fare;

  @override
  void initState() {
    super.initState();
    _viewModel = RideFilterViewModel(initialFilter: widget.initialFilter);
    final fare = widget.initialFilter.maximumFare;
    _fare = TextEditingController(
      text: fare == null ? '' : formatThousands(fare),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _fare.dispose();
    super.dispose();
  }

  void _reset() {
    _formKey.currentState!.reset();
    _fare.clear();
    _viewModel.reset();
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) return;
    final result = _viewModel.apply(_fare.text);
    if (result != null) Navigator.pop(context, result);
  }

  Widget _heading(IconData icon, String title) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.brand),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(title, style: AppTextStyles.title)),
    ],
  );

  Widget _choice(String label, bool selected, VoidCallback? onPressed) =>
      Semantics(
        selected: selected,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: selected
                ? AppColors.brandSubtle
                : AppColors.subtleFill,
            foregroundColor: selected
                ? AppColors.brandStrong
                : AppColors.textPrimary,
            side: BorderSide(
              color: selected ? AppColors.brand : AppColors.subtleFill,
            ),
            minimumSize: const Size.fromHeight(AppSizes.touchTarget),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.controlAll,
            ),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _viewModel,
    builder: (context, _) => Padding(
      // Naik bersama keyboard saat mengetik ongkos.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Filter', style: AppTextStyles.headingMedium),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Text(
              'Sesuaikan tebengan dengan kebutuhanmu.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _heading(Icons.directions_car_outlined, 'Kendaraan'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final (index, option) in <VehicleKind?>[
                  null,
                  ...VehicleKind.values,
                ].indexed) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _choice(
                      option?.label ?? 'Semua',
                      _viewModel.vehicle == option,
                      () => _viewModel.selectVehicle(option),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _heading(Icons.event_seat_outlined, 'Minimal kursi'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final seats in RideFilterViewModel.seatOptions) ...[
                  if (seats != RideFilterViewModel.seatOptions.first)
                    const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _choice(
                      '$seats kursi',
                      _viewModel.seats == seats,
                      _viewModel.canSelectSeats(seats)
                          ? () => _viewModel.selectSeats(seats)
                          : null,
                    ),
                  ),
                ],
              ],
            ),
            if (_viewModel.vehicle == VehicleKind.motor) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Motor hanya muat 1 penumpang.',
                style: AppTextStyles.caption,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _heading(Icons.account_balance_wallet_outlined, 'Batas ongkos'),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Ongkos paling mahal',
              hint: 'Contoh: 10.000',
              controller: _fare,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _apply(),
              validator: _viewModel.validateFare,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kosongkan untuk semua ongkos. Ongkos yang belum diatur tidak '
              'dianggap gratis. Tebengan penuh tidak ditampilkan.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Atur Ulang',
                    variant: AppButtonVariant.secondary,
                    onPressed: _reset,
                  ),
                ),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: AppButton(label: 'Terapkan', onPressed: _apply),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
