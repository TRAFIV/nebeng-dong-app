import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/viewmodels/location_picker_view_model.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';
import 'package:praktikum_mobile/shared/maps/widgets/location_field.dart';
import 'package:praktikum_mobile/shared/maps/widgets/open_street_map_view.dart';

/// Pin hanya dikembalikan setelah konfirmasi, bukan ketika peta digeser.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.title,
    required this.service,
    this.initialLocation,
  });
  final String title;
  final MapService service;
  final MapLocation? initialLocation;
  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _controller = MapController();
  final _search = TextEditingController();
  final _address = TextEditingController();
  final _addressFocus = FocusNode();
  late final TextEditingController _label;
  late final LocationPickerViewModel _viewModel;
  bool _syncingFields = false;
  @override
  void initState() {
    super.initState();
    _viewModel = LocationPickerViewModel(
      service: widget.service,
      initialLocation: widget.initialLocation,
    );
    _label = TextEditingController(text: _viewModel.label);
    _address.text = _viewModel.address;
    _label.addListener(_labelChanged);
    _viewModel.addListener(_syncFields);
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.removeListener(_syncFields);
    _viewModel.dispose();
    _label.removeListener(_labelChanged);
    _address.dispose();
    _addressFocus.dispose();
    _search.dispose();
    _label.dispose();
    super.dispose();
  }

  void _labelChanged() {
    if (!_syncingFields) _viewModel.setLabel(_label.text);
  }

  void _syncFields() {
    _syncingFields = true;
    try {
      if (_address.text != _viewModel.address) {
        _address.text = _viewModel.address;
      }
      if (_label.text != _viewModel.label) _label.text = _viewModel.label;
    } finally {
      _syncingFields = false;
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ketuk peta untuk membuat atau memindahkan pin. Geser/zoom untuk mencari posisi.',
            ),
            const SizedBox(height: AppSpacing.sm),
            LocationField(
              label: 'Cari tempat',
              hint: 'Cari tempat atau alamat',
              controller: _search,
              service: widget.service,
              showMapButton: false,
              onSelected: (place) {
                if (place == null) return;
                _viewModel.selectPlace(place);
                _controller.move(mapLatLng(place.point), 16);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: (MediaQuery.sizeOf(context).height * 0.32).clamp(
                220,
                380,
              ),
              child: OpenStreetMapView(
                controller: _controller,
                center: widget.initialLocation?.point ?? MapConfig.padangCenter,
                selected: _viewModel.selected?.point,
                onTap: _viewModel.placePin,
              ),
            ),
            if (_viewModel.selected != null) const Text('Pin sudah dipilih'),
            const SizedBox(height: AppSpacing.sm),
            const Text('Alamat lokasi'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _address,
              focusNode: _addressFocus,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Alamat dari titik di peta',
              ),
              onChanged: _viewModel.setAddress,
            ),
            if (_viewModel.resolving) ...[
              const LinearProgressIndicator(),
              const Text('Mencari alamat pin...'),
            ],
            if (_viewModel.addressError != null) ...[
              Text(_viewModel.addressError!),
              TextButton.icon(
                onPressed: _viewModel.retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Cari alamat lagi'),
              ),
              TextButton.icon(
                onPressed: () => _addressFocus.requestFocus(),
                icon: const Icon(Icons.edit_location_alt_rounded),
                label: const Text('Isi alamat manual'),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Nama pin (opsional)',
              hint: 'Contoh: Gerbang utama kampus',
              controller: _label,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Pencarian tempat memakai layanan peta pihak ketiga. Tidak mengakses GPS kamu.',
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
            child: AppButton(
              label: 'Gunakan Pin Ini',
              onPressed: !_viewModel.canConfirm
                  ? null
                  : () {
                      final result = _viewModel.confirm();
                      if (result != null) Navigator.pop(context, result);
                    },
            ),
          ),
        ),
      ),
    ),
  );
}
