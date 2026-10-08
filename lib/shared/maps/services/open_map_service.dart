import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:praktikum_mobile/shared/maps/models/map_location.dart';

abstract interface class MapService {
  Future<List<MapLocation>> searchPlaces(String query);
  Future<MapLocation?> reverseGeocode(GeoPoint point);
  Future<RoadRoute> routeBetween(GeoPoint origin, GeoPoint destination);
  void close();
}

class MapServiceException implements Exception {
  const MapServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract final class MapConfig {
  static const photonUrl = String.fromEnvironment(
    'PHOTON_URL',
    defaultValue: 'https://photon.komoot.io',
  );
  static const routingUrl = String.fromEnvironment(
    'OSRM_URL',
    defaultValue: 'https://routing.openstreetmap.de/routed-car',
  );
  static const tileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );
  static const userAgent =
      'NebengDongPraktikum/1.0 (+https://github.com/TRAFIV/nebeng-dong-app)';
  static const padangCenter = GeoPoint(-0.9471, 100.4172);
}

/// Layanan publik untuk demo kecil, bukan backend aplikasi atau SLA produksi.
class OpenMapService implements MapService {
  OpenMapService({
    http.Client? client,
    Uri? photonBase,
    Uri? routingBase,
    this.timeout = const Duration(seconds: 15),
    this.requestInterval = const Duration(milliseconds: 1100),
  }) : _client = client ?? http.Client(),
       _photonBase = photonBase ?? Uri.parse(MapConfig.photonUrl),
       _routingBase = routingBase ?? Uri.parse(MapConfig.routingUrl);

  final http.Client _client;
  final Uri _photonBase;
  final Uri _routingBase;
  final Duration timeout;
  final Duration requestInterval;
  final _searchCache = <String, List<MapLocation>>{};
  final _reverseCache = <String, MapLocation?>{};
  final _routeCache = <String, RoadRoute>{};
  final _pending = <Completer<void>>{};
  Future<void> _searchTail = Future.value();
  Future<void> _routeTail = Future.value();
  DateTime? _lastSearch;
  DateTime? _lastRoute;
  bool _closed = false;

  @override
  Future<List<MapLocation>> searchPlaces(String query) {
    final text = query.trim();
    if (text.length < 3) return Future.value([]);
    final result = _searchTail.then((_) => _search(text));
    // Error tetap diterima caller; antrian berikutnya tetap boleh berjalan.
    _searchTail = result.then<void>((_) {}, onError: (Object error) {});
    return result;
  }

  Future<List<MapLocation>> _search(String query) async {
    if (_closed) throw const MapServiceException('Layanan peta sudah ditutup');
    final key = query.toLowerCase();
    if (_searchCache.containsKey(key)) return _searchCache[key]!;
    await _wait(_lastSearch);
    _lastSearch = DateTime.now();
    final body = await _get(
      _endpoint(_photonBase, '/api/', {
        'q': query,
        'limit': '5',
        'lat': '${MapConfig.padangCenter.latitude}',
        'lon': '${MapConfig.padangCenter.longitude}',
      }),
    );
    final result = List<MapLocation>.unmodifiable(_locations(body).take(5));
    if (_searchCache.length >= 40) _searchCache.remove(_searchCache.keys.first);
    _searchCache[key] = result;
    return result;
  }

  List<MapLocation> _locations(Map<String, dynamic> body) {
    final features = body['features'];
    if (features is! List) {
      throw const MapServiceException('Jawaban pencarian tempat tidak valid');
    }
    final locations = <MapLocation>[];
    for (final feature in features) {
      if (feature is! Map ||
          feature['properties'] is! Map ||
          feature['geometry'] is! Map) {
        continue;
      }
      final properties = feature['properties'] as Map;
      final coordinates = feature['geometry']['coordinates'];
      GeoPoint point;
      try {
        point = GeoPoint.fromGeoJson(coordinates);
      } on FormatException {
        continue;
      }
      final name =
          [properties['name'], properties['street'], properties['city']]
              .whereType<String>()
              .where((value) => value.trim().isNotEmpty)
              .firstOrNull;
      if (name == null) continue;
      final address = <String>{
        for (final field in [
          'street',
          'housenumber',
          'locality',
          'district',
          'city',
          'county',
          'state',
          'postcode',
          'country',
        ])
          if (properties[field] is String &&
              (properties[field] as String).isNotEmpty)
            properties[field] as String,
      }.join(', ');
      locations.add(
        MapLocation(
          label: name,
          address: address,
          point: point,
          sourceId:
              '${properties['osm_type'] ?? ''}:${properties['osm_id'] ?? ''}',
        ),
      );
    }
    return locations;
  }

  @override
  Future<MapLocation?> reverseGeocode(GeoPoint point) {
    // Forward and reverse share one Photon queue/rate limit.
    final result = _searchTail.then((_) => _reverse(point));
    _searchTail = result.then<void>((_) {}, onError: (Object error) {});
    return result;
  }

  Future<MapLocation?> _reverse(GeoPoint point) async {
    if (_closed) throw const MapServiceException('Layanan peta sudah ditutup');
    final key = point.coordinateLabel;
    if (_reverseCache.containsKey(key)) {
      final cached = _reverseCache[key];
      // Retain the exact tapped point even for nearby cache hits.
      return cached == null
          ? null
          : MapLocation(
              label: cached.label,
              address: cached.address,
              point: point,
              sourceId: cached.sourceId,
            );
    }
    await _wait(_lastSearch);
    _lastSearch = DateTime.now();
    final body = await _get(
      _endpoint(_photonBase, '/reverse', {
        'lat': '${point.latitude}',
        'lon': '${point.longitude}',
        'radius': '0.2',
        'limit': '1',
      }),
    );
    final nearby = _locations(body)
        .where((place) => place.point.distanceTo(point) <= 200)
        .firstOrNull;
    MapLocation? result;
    if (nearby != null) {
      final address = <String>{
        nearby.label,
        if (nearby.address.isNotEmpty) ...nearby.address.split(', '),
      }.join(', ');
      result = MapLocation(
        label: address,
        address: address,
        point: point,
        sourceId: nearby.sourceId,
      );
    }
    if (result != null) {
      if (_reverseCache.length >= 40) {
        _reverseCache.remove(_reverseCache.keys.first);
      }
      _reverseCache[key] = result;
    }
    return result;
  }

  @override
  Future<RoadRoute> routeBetween(GeoPoint origin, GeoPoint destination) {
    final result = _routeTail.then((_) => _route(origin, destination));
    _routeTail = result.then<void>((_) {}, onError: (Object error) {});
    return result;
  }

  Future<RoadRoute> _route(GeoPoint origin, GeoPoint destination) async {
    if (_closed) throw const MapServiceException('Layanan peta sudah ditutup');
    if (origin.distanceTo(destination) < 50) {
      throw const MapServiceException(
        'Asal dan tujuan terlalu dekat (minimal 50 meter)',
      );
    }
    final key = '${origin.coordinateLabel};${destination.coordinateLabel}';
    if (_routeCache.containsKey(key)) return _routeCache[key]!;
    await _wait(_lastRoute);
    _lastRoute = DateTime.now();
    final coordinates =
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
    final body = await _get(
      _endpoint(_routingBase, '/route/v1/driving/$coordinates', {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'false',
      }),
    );
    final routes = body['routes'];
    if (body['code'] != 'Ok' ||
        routes is! List ||
        routes.isEmpty ||
        routes.first is! Map) {
      throw const MapServiceException(
        'Jalur jalan tidak ditemukan. Coba geser pin ke dekat jalan.',
      );
    }
    final waypoints = body['waypoints'];
    if (waypoints is List &&
        waypoints.any(
          (waypoint) =>
              waypoint is Map &&
              waypoint['distance'] is num &&
              waypoint['distance'] > 1000,
        )) {
      throw const MapServiceException(
        'Pin terlalu jauh dari jalan. Pilih titik lain.',
      );
    }
    final route = routes.first as Map;
    if (route['geometry'] is! Map ||
        route['geometry']['coordinates'] is! List ||
        route['distance'] is! num ||
        route['duration'] is! num) {
      throw const MapServiceException('Jawaban jalur jalan tidak valid');
    }
    try {
      final result = RoadRoute(
        points: (route['geometry']['coordinates'] as List).map(
          GeoPoint.fromGeoJson,
        ),
        distanceMeters: (route['distance'] as num).toDouble(),
        durationSeconds: (route['duration'] as num).toDouble(),
      );
      if (_routeCache.length >= 20) _routeCache.remove(_routeCache.keys.first);
      _routeCache[key] = result;
      return result;
    } on FormatException {
      throw const MapServiceException('Koordinat jalur jalan tidak valid');
    }
  }

  Future<void> _wait(DateTime? last) async {
    if (_closed) throw const MapServiceException('Layanan peta sudah ditutup');
    if (last != null) {
      final remaining = requestInterval - DateTime.now().difference(last);
      if (remaining > Duration.zero) await Future<void>.delayed(remaining);
    }
    if (_closed) throw const MapServiceException('Layanan peta sudah ditutup');
  }

  Uri _endpoint(Uri base, String path, Map<String, String> parameters) {
    if (base.scheme != 'https' || base.host.isEmpty) {
      throw const MapServiceException('Endpoint peta harus HTTPS');
    }
    return base.replace(
      path: '${base.path.replaceFirst(RegExp(r'/+$'), '')}$path',
      queryParameters: parameters,
    );
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final abort = Completer<void>();
    _pending.add(abort);
    try {
      final request = http.AbortableRequest(
        'GET',
        uri,
        abortTrigger: abort.future,
      );
      if (!kIsWeb) request.headers['User-Agent'] = MapConfig.userAgent;
      final operation = _client.send(request).then((response) async {
        final bytes = await response.stream.toBytes();
        if (response.statusCode == 429) {
          throw const MapServiceException(
            'Layanan sedang membatasi permintaan. Coba lagi nanti.',
          );
        }
        if (response.statusCode != 200) {
          throw const MapServiceException(
            'Layanan peta belum bisa dihubungi. Coba lagi.',
          );
        }
        final body = jsonDecode(utf8.decode(bytes));
        if (body is! Map<String, dynamic>) {
          throw const FormatException('JSON bukan object');
        }
        return body;
      });
      return await operation.timeout(timeout);
    } on TimeoutException {
      if (!abort.isCompleted) abort.complete();
      throw const MapServiceException(
        'Peta terlalu lama merespons. Periksa internet dan coba lagi.',
      );
    } on http.ClientException {
      throw const MapServiceException(
        'Tidak bisa terhubung ke layanan peta. Periksa internet.',
      );
    } on FormatException {
      throw const MapServiceException('Jawaban layanan peta tidak valid');
    } finally {
      _pending.remove(abort);
    }
  }

  @override
  void close() {
    _closed = true;
    for (final abort in _pending) {
      if (!abort.isCompleted) abort.complete();
    }
    _client.close();
  }
}
