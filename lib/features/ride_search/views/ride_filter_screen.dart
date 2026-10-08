import 'package:flutter/material.dart';

import 'package:praktikum_mobile/features/ride_search/models/ride_filter.dart';
import 'package:praktikum_mobile/features/ride_search/viewmodels/ride_filter_view_model.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';

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
    _fare = TextEditingController(
      text: widget.initialFilter.maximumFare?.toString() ?? '',
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(title: const Text('Filter Pencarian')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text('Jam cabut', style: AppTextStyles.headingMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final window in DepartureWindow.values)
                    ChoiceChip(
                      avatar: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(window.label),
                      selected: _viewModel.window == window,
                      onSelected: (selected) =>
                          _viewModel.selectWindow(selected ? window : null),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Butuh berapa kursi?', style: AppTextStyles.headingMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final seats in [1, 2, 3])
                    ChoiceChip(
                      avatar: const Icon(Icons.event_seat_outlined, size: 18),
                      label: Text('$seats kursi'),
                      selected: _viewModel.seats == seats,
                      onSelected: (_) => _viewModel.selectSeats(seats),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Ongkos paling mahal',
                icon: Icons.payments_outlined,
                hint: 'Contoh: 10.000',
                controller: _fare,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _apply(),
                validator: _viewModel.validateFare,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Sore: 15.00–19.00. Tanpa pilihan jam berarti semua jam. '
                'Tebengan penuh tidak ditampilkan.',
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
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
    );
  }
}
