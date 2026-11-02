import 'package:flutter/material.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_filter_view_model.dart';
import 'package:praktikum_mobile/shared/utils/rupiah_format.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

class RideFilterScreen extends StatefulWidget {
  const RideFilterScreen({super.key, this.initialFilter = const RideFilter()});
  final RideFilter initialFilter;
  @override
  State<RideFilterScreen> createState() => _RideFilterScreenState();
}

class _RideFilterScreenState extends State<RideFilterScreen> {
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
      Icon(icon, color: AppColors.brandStrong),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(title, style: AppTextStyles.headingMedium)),
    ],
  );

  /// Ketuk jam yang sedang terpilih sekali lagi untuk membatalkannya.
  Widget _windowChoice(DepartureWindow window) => _choice(
    window.label,
    _viewModel.window == window,
    () => _viewModel.selectWindow(_viewModel.window == window ? null : window),
  );

  Widget _choice(String label, bool selected, VoidCallback onPressed) =>
      Semantics(
        selected: selected,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: selected
                ? AppColors.brandSubtle
                : AppColors.border,
            foregroundColor: selected
                ? AppColors.brandStrong
                : AppColors.textSecondary,
            minimumSize: const Size.fromHeight(AppSizes.touchTarget),
            padding: const EdgeInsets.all(AppSpacing.sm),
            alignment: Alignment.centerLeft,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Filter Pencarian')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Sesuaikan tebengan dengan kebutuhanmu.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _heading(Icons.access_time_rounded, 'Jam cabut'),
            const SizedBox(height: AppSpacing.sm),
            // Dua pilihan per baris, dibuat dari semua nilai DepartureWindow.
            for (var i = 0; i < DepartureWindow.values.length; i += 2) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: _windowChoice(DepartureWindow.values[i])),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: i + 1 < DepartureWindow.values.length
                        ? _windowChoice(DepartureWindow.values[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _heading(Icons.event_seat_rounded, 'Minimal kursi'),
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
                      () => _viewModel.selectSeats(seats),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _heading(Icons.account_balance_wallet_rounded, 'Batas ongkos'),
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
              'Kosongkan untuk semua ongkos. Ongkos yang belum diatur tidak dianggap gratis.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tanpa pilihan jam berarti semua jam, termasuk sebelum 06.00 dan setelah 19.00. Tebengan penuh tidak ditampilkan.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: AppColors.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Atur Ulang',
                    variant: AppButtonVariant.secondary,
                    onPressed: _reset,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(label: 'Terapkan', onPressed: _apply),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
