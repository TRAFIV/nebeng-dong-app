import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:praktikum_mobile/shared/maps/services/open_map_service.dart';
import 'package:praktikum_mobile/shared/maps/models/map_location.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/maps/widgets/open_street_map_view.dart';

import '../../support/map_test_support.dart';
import 'maps_widget_test.dart' as picker;

const point = GeoPoint(-0.90, 100.35);

Map<String, Object> response() => {
  'features': [
    {
      'properties': {
        'name': 'Jalan Khatib Sulaiman',
        'street': 'Jalan Khatib Sulaiman',
        'housenumber': '10',
        'district': 'Padang Utara',
        'city': 'Padang',
        'state': 'Sumatera Barat',
        'postcode': '25137',
        'country': 'Indonesia',
      },
      'geometry': {
        'coordinates': [100.3501, -0.90],
      },
    },
  ],
};

void main() {
  test('Reverse tanpa hasil bisa retry jaringan', () async {
    var calls = 0;
    final service = OpenMapService(
      requestInterval: Duration.zero,
      client: MockClient((_) async {
        calls++;
        return http.Response(
          jsonEncode(calls == 1 ? {'features': []} : response()),
          200,
        );
      }),
    );
    addTearDown(service.close);
    expect(await service.reverseGeocode(point), isNull);
    expect(await service.reverseGeocode(point), isNotNull);
    expect(calls, 2);
  });
  test('Reverse alamat lengkap/cache tanpa memindahkan titik pin', () async {
    var calls = 0;
    final service = OpenMapService(
      requestInterval: Duration.zero,
      client: MockClient((request) async {
        calls++;
        expect(request.url.path, '/reverse');
        expect(request.url.queryParameters['lat'], '-0.9');
        expect(request.url.queryParameters['lon'], '100.35');
        expect(request.url.queryParameters['limit'], '1');
        expect(request.url.queryParameters['radius'], '0.2');
        return http.Response(jsonEncode(response()), 200);
      }),
    );
    addTearDown(service.close);
    final place = await service.reverseGeocode(point);
    expect(place!.point, same(point));
    expect(
      place.address,
      'Jalan Khatib Sulaiman, 10, Padang Utara, Padang, Sumatera Barat, 25137, Indonesia',
    );
    const nearby = GeoPoint(-0.900001, 100.350001);
    expect((await service.reverseGeocode(nearby))!.point, same(nearby));
    expect(calls, 1);
  });

  test('Reverse kosong/titik jauh tidak menciptakan alamat palsu', () async {
    for (final body in [
      {'features': []},
      {
        'features': [
          {
            'properties': {'name': 'Jauh'},
            'geometry': {
              'coordinates': [101.0, -0.9],
            },
          },
        ],
      },
    ]) {
      final service = OpenMapService(
        requestInterval: Duration.zero,
        client: MockClient((_) async => http.Response(jsonEncode(body), 200)),
      );
      addTearDown(service.close);
      expect(await service.reverseGeocode(point), isNull);
    }
  });

  test(
    'Forward/reverse memakai satu antrean Photon dan error tidak memblokir',
    () async {
      final pending = Completer<http.Response>();
      final paths = <String>[];
      final service = OpenMapService(
        requestInterval: Duration.zero,
        client: MockClient((request) async {
          paths.add(request.url.path);
          if (paths.length == 1) return pending.future;
          return http.Response(jsonEncode(response()), 200);
        }),
      );
      addTearDown(service.close);
      final search = service.searchPlaces('Padang');
      final failed = expectLater(search, throwsA(isA<MapServiceException>()));
      final reverse = service.reverseGeocode(point);
      await Future<void>.delayed(Duration.zero);
      expect(paths, ['/api/']);
      pending.complete(http.Response('{}', 503));
      await failed;
      expect(await reverse, isNotNull);
      expect(paths, ['/api/', '/reverse']);
    },
  );

  testWidgets('Alamat pin otomatis terisi sebelum dikonfirmasi', (
    tester,
  ) async {
    MapLocation? result;
    await picker.openPicker(
      tester,
      FakeMapService(),
      (place) => result = place,
    );
    tester.widget<OpenStreetMapView>(find.byType(OpenStreetMapView)).onTap!(
      point,
    );
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();
    final address = find.widgetWithText(
      TextFormField,
      'Alamat dari titik di peta',
    );
    expect(
      tester.widget<TextFormField>(address).controller!.text,
      contains('Sumatera Barat'),
    );
    await tester.tap(find.text('Gunakan Pin Ini'));
    await tester.pumpAndSettle();
    expect(result!.address, contains('Sumatera Barat'));
    expect(result!.label, result!.address);
    expect(result!.point, same(point));
  });

  testWidgets('Respons alamat lama diabaikan setelah pin dipindahkan', (
    tester,
  ) async {
    final first = Completer<MapLocation?>();
    final second = Completer<MapLocation?>();
    final service = FakeMapService()
      ..reverseHandler = (p) =>
          identical(p, point) ? first.future : second.future;
    await picker.openPicker(tester, service, (_) {});
    void tap(GeoPoint p) => tester
        .widget<OpenStreetMapView>(find.byType(OpenStreetMapView))
        .onTap!(p);
    tap(point);
    await tester.pump(const Duration(milliseconds: 750));
    const newPoint = GeoPoint(-0.94, 100.35);
    tap(newPoint);
    await tester.pump(const Duration(milliseconds: 750));
    first.complete(
      const MapLocation(label: 'Lama', address: 'Alamat lama', point: point),
    );
    await tester.pump();
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'Gunakan Pin Ini'))
          .onPressed,
      isNull,
    );
    second.complete(
      const MapLocation(
        label: 'Baru',
        address: 'Alamat baru, Padang',
        point: newPoint,
      ),
    );
    await tester.pumpAndSettle();
    final address = find.widgetWithText(
      TextFormField,
      'Alamat dari titik di peta',
    );
    expect(
      tester.widget<TextFormField>(address).controller!.text,
      'Alamat baru, Padang',
    );
  });

  testWidgets('Alamat gagal bisa diisi manual dan koordinat tetap tersimpan', (
    tester,
  ) async {
    final service = FakeMapService()..reverseHandler = (_) async => null;
    MapLocation? result;
    await picker.openPicker(tester, service, (place) => result = place);
    tester.widget<OpenStreetMapView>(find.byType(OpenStreetMapView)).onTap!(
      point,
    );
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();
    final address = find.widgetWithText(
      TextFormField,
      'Alamat dari titik di peta',
    );
    await tester.ensureVisible(address);
    await tester.enterText(address, 'Jalan Veteran 20, Padang');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gunakan Pin Ini'));
    await tester.pumpAndSettle();
    expect(result!.address, 'Jalan Veteran 20, Padang');
    expect(result!.point, same(point));
  });
}
