import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/widgets/osm_tile_provider.dart';

void main() {
  test('Each provider owns separate mutable headers', () {
    final first = createOsmTileProvider();
    final second = createOsmTileProvider();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    first.headers['X-Test'] = 'first';
    expect(second.headers.containsKey('X-Test'), isFalse);
    expect(second.headers['User-Agent'], MapConfig.userAgent);
  });
  test('Native tile setup can populate mutable headers and retain custom User-Agent', () {
    final provider = createOsmTileProvider();
    addTearDown(provider.dispose);
    // Exercise the real native TileLayer constructor, even without fetching tiles.
    expect(
      () => TileLayer(urlTemplate: MapConfig.tileUrl, tileProvider: provider),
      returnsNormally,
    );
    expect(provider.headers['User-Agent'], MapConfig.userAgent);
    expect(
      () => TileLayer(urlTemplate: MapConfig.tileUrl, tileProvider: provider),
      returnsNormally,
    );
    expect(
      provider.cachingProvider,
      isNull,
    ); // Built-in HTTP cache remains enabled.
  });
}
