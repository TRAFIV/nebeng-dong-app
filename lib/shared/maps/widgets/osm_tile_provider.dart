import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';

/// TileLayer mutates headers even when User-Agent already exists.
/// A fresh mutable map is required for every provider; keep built-in caching.
NetworkTileProvider createOsmTileProvider() => NetworkTileProvider(
  headers: <String, String>{if (!kIsWeb) 'User-Agent': MapConfig.userAgent},
);
