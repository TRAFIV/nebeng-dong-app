import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:praktikum_mobile/core/network/api_client.dart';
import 'package:praktikum_mobile/core/network/api_exception.dart';
import 'package:praktikum_mobile/core/network/json_reader.dart';
import 'package:praktikum_mobile/core/network/token_store.dart';

ApiClient clientWith(
  Future<http.Response> Function(http.Request request) handler, {
  String? token,
  Duration timeout = const Duration(seconds: 1),
}) {
  final client = ApiClient(
    baseUrl: Uri.parse('https://server.test/api/v1'),
    tokenStore: MemoryTokenStore(token),
    client: MockClient(handler),
    timeout: timeout,
  );
  addTearDown(client.close);
  return client;
}

http.Response jsonResponse(Object? body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Future<ApiException> failureOf(Future<Object?> call) async {
  try {
    await call;
  } on ApiException catch (error) {
    return error;
  }
  fail('ApiException expected');
}

void main() {
  test('Sukses: alamat, header JSON, token dan amplop data dibuka', () async {
    late http.Request seen;
    final api = clientWith((request) async {
      seen = request;
      return jsonResponse({
        'data': [
          {'id': 1},
        ],
      }, 200);
    }, token: 'abc');

    final result = await api.get('rides', query: {'q': 'unand'});

    expect(seen.method, 'GET');
    expect(seen.url.toString(), 'https://server.test/api/v1/rides?q=unand');
    expect(seen.headers['Accept'], 'application/json');
    expect(seen.headers['Authorization'], 'Bearer abc');
    expect(result, [
      {'id': 1},
    ]);
  });

  test(
    'Body dikirim sebagai JSON; tanpa token tidak ada Authorization',
    () async {
      late http.Request seen;
      final api = clientWith((request) async {
        seen = request;
        return http.Response('', 204);
      });

      expect(await api.post('/bookings', body: {'ride_id': 'r1'}), isNull);
      expect(seen.headers.containsKey('Authorization'), isFalse);
      expect(seen.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(seen.body), {'ride_id': 'r1'});
    },
  );

  test(
    '401, 404, 409 dan 500 menjadi jenis error dengan pesan ramah',
    () async {
      for (final (status, kind) in [
        (401, ApiErrorKind.unauthorized),
        (403, ApiErrorKind.forbidden),
        (404, ApiErrorKind.notFound),
        (409, ApiErrorKind.conflict),
        (500, ApiErrorKind.server),
      ]) {
        final api = clientWith((_) async => http.Response('', status));
        final error = await failureOf(api.get('rides'));
        expect(error.kind, kind, reason: '$status');
        expect(error.statusCode, status);
        expect(error.message, ApiException.defaultMessage(kind));
      }
    },
  );

  test('422 membawa pesan server dan pesan per kolom', () async {
    final api = clientWith(
      (_) async => jsonResponse({
        'message': 'Isian belum lengkap.',
        'errors': {
          'pickup_location': ['Titik jemput wajib diisi.'],
          'note': 'Catatan terlalu pendek.',
        },
      }, 422),
    );

    final error = await failureOf(api.post('bookings', body: const {}));

    expect(error.kind, ApiErrorKind.validation);
    expect(error.message, 'Isian belum lengkap.');
    expect(error.fieldErrors, {
      'pickup_location': 'Titik jemput wajib diisi.',
      'note': 'Catatan terlalu pendek.',
    });
  });

  test('Jawaban sukses yang bukan JSON ditolak; halaman error HTML tetap sesuai kodenya', () async {
    final notJson = clientWith((_) async => http.Response('<html>', 200));
    expect(
      (await failureOf(notJson.get('rides'))).kind,
      ApiErrorKind.invalidResponse,
    );

    final htmlError = clientWith((_) async => http.Response('<html>', 502));
    expect((await failureOf(htmlError.get('rides'))).kind, ApiErrorKind.server);
  });

  test('Server tidak terhubung dan server terlalu lama', () async {
    final offline = clientWith(
      (_) async => throw http.ClientException('Connection refused'),
    );
    expect((await failureOf(offline.get('rides'))).kind, ApiErrorKind.network);

    final pending = Completer<http.Response>();
    final slow = clientWith(
      (_) => pending.future,
      timeout: const Duration(milliseconds: 10),
    );
    expect((await failureOf(slow.get('rides'))).kind, ApiErrorKind.timeout);
    pending.complete(http.Response('', 200));
  });

  test('parseResponse mengubah JSON salah bentuk menjadi invalidResponse', () {
    String name(Object? json) => asJsonMap(json).read<String>('name');

    expect(parseResponse({'name': 'Taris'}, name), 'Taris');
    for (final broken in [
      null,
      <String, Object?>{},
      {'name': 5},
      [1],
    ]) {
      expect(
        () => parseResponse(broken, name),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.invalidResponse,
          ),
        ),
        reason: '$broken',
      );
    }
  });
}
