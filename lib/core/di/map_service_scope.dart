import 'package:flutter/material.dart';

import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';

/// Satu client/cache/antrian per sesi aplikasi. Test dapat menyuntikkan fake.
class MapServiceProvider extends StatefulWidget {
  const MapServiceProvider({
    super.key,
    this.service,
    this.enableTiles = true,
    required this.child,
  });
  final MapService? service;
  final bool enableTiles;
  final Widget child;
  @override
  State<MapServiceProvider> createState() => _MapServiceProviderState();
}

class _MapServiceProviderState extends State<MapServiceProvider> {
  late MapService _service;
  @override
  void initState() {
    super.initState();
    _service = widget.service ?? OpenMapService();
  }

  @override
  void didUpdateWidget(MapServiceProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      if (oldWidget.service == null) _service.close();
      _service = widget.service ?? OpenMapService();
    }
  }

  @override
  void dispose() {
    if (widget.service == null) _service.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MapServiceScope(
    service: _service,
    enableTiles: widget.enableTiles,
    child: widget.child,
  );
}

class MapServiceScope extends InheritedWidget {
  const MapServiceScope({
    super.key,
    required this.service,
    required this.enableTiles,
    required super.child,
  });
  final MapService service;
  final bool enableTiles;
  static MapServiceScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MapServiceScope>();
  @override
  bool updateShouldNotify(MapServiceScope oldWidget) =>
      service != oldWidget.service || enableTiles != oldWidget.enableTiles;
}
