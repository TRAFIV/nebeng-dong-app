import 'package:flutter/material.dart';

import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/maps/viewmodels/location_search_view_model.dart';
import 'package:praktikum_mobile/shared/maps/views/location_picker_screen.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/shared/maps/widgets/route_endpoints.dart';

/// Ketikan berbeda membatalkan koordinat lama; hanya pilihan eksplisit yang valid.
class LocationField extends StatefulWidget {
  const LocationField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.service,
    required this.onSelected,
    this.initialLocation,
    this.validator,
    this.onFieldSubmitted,
    this.showMapButton = true,
  });
  final String label;
  final String hint;
  final TextEditingController controller;
  final MapService service;
  final ValueChanged<MapLocation?> onSelected;
  final MapLocation? initialLocation;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final bool showMapButton;
  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  late final LocationSearchViewModel _viewModel;
  bool _settingText = false;
  late String _lastText;
  @override
  void initState() {
    super.initState();
    _viewModel = LocationSearchViewModel(
      service: widget.service,
      selected: widget.initialLocation,
    );
    _lastText = widget.controller.text;
    widget.controller.addListener(_textChanged);
  }

  @override
  void didUpdateWidget(LocationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_textChanged);
      _lastText = widget.controller.text;
      _viewModel.syncSelection(widget.initialLocation);
      widget.controller.addListener(_textChanged);
    }
    if (oldWidget.service != widget.service) {
      _viewModel.setService(widget.service);
    }
    // A parent echoing onSelected(null) after typing must not cancel the
    // fresh query. Only an externally changed selection (e.g. swap) resets it.
    if (!identical(oldWidget.initialLocation, widget.initialLocation) &&
        !identical(_viewModel.selected, widget.initialLocation)) {
      _viewModel.syncSelection(widget.initialLocation);
      _lastText = widget.controller.text;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    widget.controller.removeListener(_textChanged);
    super.dispose();
  }

  void _textChanged() {
    if (_settingText || !mounted || widget.controller.text == _lastText) return;
    _lastText = widget.controller.text;
    _viewModel.queryChanged(widget.controller.text);
    widget.onSelected(null);
  }

  void _choose(MapLocation place) {
    _settingText = true;
    widget.controller.text = place.label;
    _lastText = place.label;
    _settingText = false;
    _viewModel.choose(place);
    widget.onSelected(place);
    FocusScope.of(context).unfocus();
  }

  Future<void> _pin() async {
    _viewModel.clearSearch();
    FocusScope.of(context).unfocus();
    final result = await Navigator.push<MapLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: 'Pin ${widget.label}',
          initialLocation: _viewModel.selected,
          service: widget.service,
        ),
      ),
    );
    if (!mounted || result == null) return;
    _choose(result);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _viewModel,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LocationPill(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: widget.controller,
                      validator: widget.validator,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintMaxLines: 1,
                        errorMaxLines: 4,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted:
                          widget.onFieldSubmitted ??
                          (_) {
                            _viewModel.searchNow(widget.controller.text);
                          },
                    ),
                  ],
                ),
              ),
              if (widget.showMapButton)
                IconButton(
                  tooltip: _viewModel.selected == null
                      ? 'Pilih pin di peta'
                      : 'Ubah pin di peta',
                  onPressed: _pin,
                  color: AppColors.routeOrigin,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
            ],
          ),
        ),
        if (_viewModel.selected != null)
          const Text(
            'Lokasi dipilih',
            style: TextStyle(color: AppColors.successText),
          ),
        if (_viewModel.selected?.address.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(_viewModel.selected!.address, style: AppTextStyles.bodyMedium),
        ],
        if (_viewModel.loading) const LinearProgressIndicator(),
        if (_viewModel.error != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_viewModel.error!),
              TextButton(
                onPressed: () => _viewModel.searchNow(widget.controller.text),
                child: const Text('Coba cari lagi'),
              ),
            ],
          ),
        if (_viewModel.searched &&
            _viewModel.suggestions.isEmpty &&
            _viewModel.selected == null)
          const Text(
            'Tempat belum ditemukan. Coba nama lain atau pilih pin di peta.',
          ),
        if (_viewModel.suggestions.isNotEmpty)
          Container(
            decoration: AppDecorations.outlined,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  for (final suggestion in _viewModel.suggestions)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(suggestion.label),
                      subtitle: suggestion.address.isEmpty
                          ? null
                          : Text(suggestion.address),
                      onTap: () => _choose(suggestion),
                    ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
