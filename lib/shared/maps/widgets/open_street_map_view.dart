import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/widgets/osm_tile_provider.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/core/di/map_service_scope.dart';

LatLng mapLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);

class OpenStreetMapView extends StatefulWidget {
  const OpenStreetMapView({
    super.key,
    this.controller,
    this.center = MapConfig.padangCenter,
    this.selected,
    this.geography,
    this.onTap,
  });
  final MapController? controller;
  final GeoPoint center;
  final GeoPoint? selected;
  final RideGeography? geography;
  final ValueChanged<GeoPoint>? onTap;
  @override
  State<OpenStreetMapView> createState() => _OpenStreetMapViewState();
}

class _OpenStreetMapViewState extends State<OpenStreetMapView> {
  bool _tileError = false;
  bool _errorScheduled = false;
  int _retry = 0;
  void _failed() {
    if (_tileError || _errorScheduled) return;
    _errorScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _tileError = true;
        _errorScheduled = false;
      });
    });
  }

  Future<void> _link(String url) async {
    bool opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (opened || !mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tautan peta'),
        content: SelectableText(url),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final geography = widget.geography;
    final enableTiles = MapServiceScope.maybeOf(context)?.enableTiles ?? true;
    Marker marker(GeoPoint point, String label, Color color) => Marker(
      point: mapLatLng(point),
      width: 48,
      height: 48,
      alignment: Alignment.topCenter,
      child: Semantics(
        label: label,
        child: Tooltip(
          message: label,
          child: Icon(Icons.location_on, size: 48, color: color),
        ),
      ),
    );
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: widget.controller,
                  options: MapOptions(
                    initialCenter: mapLatLng(widget.center),
                    initialZoom: 13,
                    minZoom: 3,
                    maxZoom: 19,
                    initialCameraFit: geography == null
                        ? null
                        : CameraFit.bounds(
                            bounds: LatLngBounds.fromPoints(
                              geography.route.points.map(mapLatLng).toList(),
                            ),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                          ),
                    onTap: widget.onTap == null
                        ? null
                        : (_, point) => widget.onTap!(
                            GeoPoint(point.latitude, point.longitude),
                          ),
                  ),
                  children: [
                    if (enableTiles)
                      _OsmTiles(key: ValueKey(_retry), onError: _failed),
                    if (geography != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: geography.route.points
                                .map(mapLatLng)
                                .toList(),
                            color: AppColors.brand,
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (geography != null) ...[
                          marker(
                            geography.origin.point,
                            'Asal: ${geography.origin.label}',
                            AppColors.brand,
                          ),
                          marker(
                            geography.destination.point,
                            'Tujuan: ${geography.destination.label}',
                            AppColors.accent,
                          ),
                        ],
                        if (widget.selected != null)
                          marker(
                            widget.selected!,
                            'Pin pilihan',
                            AppColors.brandStrong,
                          ),
                      ],
                    ),
                  ],
                ),
                if (_tileError)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Material(
                      color: AppColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Peta gagal dimuat. Periksa internet.',
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() {
                                _tileError = false;
                                _retry++;
                              }),
                              child: const Text('Ulangi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed: () => _link('https://www.openstreetmap.org/copyright'),
              child: const Text('© OpenStreetMap'),
            ),
            TextButton(
              onPressed: () => _link('https://www.openstreetmap.org/fixthemap'),
              child: const Text('Perbaiki peta'),
            ),
            if (geography != null)
              TextButton(
                onPressed: () =>
                    _link('https://routing.openstreetmap.de/about.html'),
                child: const Text('OSRM / FOSSGIS'),
              ),
          ],
        ),
      ],
    );
  }
}

/// Keep one HTTP/cache provider per tile layer, including when a pin moves.
/// TileLayer disposes the provider; a retry creates a fresh layer/provider.
class _OsmTiles extends StatefulWidget {
  const _OsmTiles({super.key, required this.onError});
  final VoidCallback onError;

  @override
  State<_OsmTiles> createState() => _OsmTilesState();
}

class _OsmTilesState extends State<_OsmTiles> {
  late final _provider = createOsmTileProvider();

  @override
  Widget build(BuildContext context) => TileLayer(
    urlTemplate: MapConfig.tileUrl,
    userAgentPackageName: 'com.example.praktikum_mobile',
    tileProvider: _provider,
    errorTileCallback: (_, _, _) => widget.onError(),
  );
}
