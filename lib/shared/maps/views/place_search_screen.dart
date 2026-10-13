import 'package:flutter/material.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/viewmodels/location_search_view_model.dart';
import 'package:praktikum_mobile/shared/maps/views/location_picker_screen.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

class PlaceSearchScreen extends StatefulWidget {
  const PlaceSearchScreen({
    super.key,
    required this.label,
    required this.service,
    this.initialLocation,
  });
  final String label;
  final MapService service;
  final MapLocation? initialLocation;
  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  late final TextEditingController _query;
  late final LocationSearchViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialLocation?.label ?? '');
    _viewModel = LocationSearchViewModel(
      service: widget.service,
      selected: widget.initialLocation,
    );
  }

  @override
  void dispose() {
    _query.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openMap() async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.push<MapLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: 'Pin ${widget.label}',
          service: widget.service,
          initialLocation: _viewModel.selected ?? widget.initialLocation,
        ),
      ),
    );
    if (mounted && result != null) Navigator.pop(context, result);
  }

  Widget _place(MapLocation place) => DecoratedBox(
    decoration: AppDecorations.card,
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () {
          FocusScope.of(context).unfocus();
          _viewModel.choose(place);
          Navigator.pop(context, place);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.brandStrong,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.label, style: AppTextStyles.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      place.address,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.alt_route_rounded, color: AppColors.brandStrong),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _feedback() {
    if (_viewModel.loading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text('Mencari tempat...'),
        ],
      );
    }
    if (_viewModel.error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_viewModel.error!),
          TextButton.icon(
            onPressed: () => _viewModel.searchNow(_query.text),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      );
    }
    if (_viewModel.suggestions.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Hasil pencarian', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.md),
          for (final place in _viewModel.suggestions) ...[
            _place(place),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      );
    }
    if (_viewModel.selected != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Lokasi yang dipilih', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.md),
          _place(_viewModel.selected!),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.search_rounded,
          color: AppColors.brandStrong,
          size: 40,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _viewModel.searched
              ? 'Tempat belum ditemukan'
              : 'Cari dulu tempatnya',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _viewModel.searched ? 'Coba nama lain, atau pilih langsung di peta.' : 'Nama saja belum memilih lokasi. Pilih salah satu hasil, atau gunakan pin peta.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text('Pilih ${widget.label}')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            widget.label == 'Dari' ? 'Mulainya dari mana?' : 'Mau ke mana?',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Cari nama tempat atau alamat. Ketik minimal 3 karakter.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const ValueKey('place-query'),
            controller: _query,
            decoration: const InputDecoration(
              hintText: 'Cari tempat atau alamat',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.brandStrong,
              ),
            ),
            textInputAction: TextInputAction.search,
            onChanged: _viewModel.queryChanged,
            onSubmitted: _viewModel.searchNow,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Pilih langsung di peta',
            variant: AppButtonVariant.secondary,
            onPressed: _openMap,
          ),
          const SizedBox(height: AppSpacing.md),
          _feedback(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ColoredBox(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Pencarian memakai layanan peta pihak ketiga. Tidak mengakses GPS kamu.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
