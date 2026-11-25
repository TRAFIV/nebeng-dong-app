import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:praktikum_mobile/core/di/auth_repository_scope.dart';
import 'package:praktikum_mobile/core/network/api_client.dart';
import 'package:praktikum_mobile/core/network/token_store.dart';
import 'package:praktikum_mobile/features/auth/data/remote_auth_repository.dart';
import 'package:praktikum_mobile/features/auth/viewmodels/login_view_model.dart';
import 'package:praktikum_mobile/features/auth/views/login_screen.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

import '../../support/map_test_support.dart';

const _user = {
  'id': 7,
  'name': 'Mikail Samyth',
  'email': 'mikail@student.unand.ac.id',
  'role': 'passenger',
};

http.Response _json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Server tiruan: kata sandi "benar123" diterima, token "t-1".
MockClient _server({bool meExpired = false, List<String>? calls}) =>
    MockClient((request) async {
      calls?.add('${request.method} ${request.url.path}');
      final auth = request.headers['Authorization'];
      switch (request.url.path) {
        case '/api/v1/auth/login':
          final body = jsonDecode(request.body) as Map;
          return body['password'] == 'benar123'
              ? _json({
                  'data': {'token': 't-1', 'user': _user},
                }, 200)
              : _json({
                  'message': 'Email atau kata sandi salah.',
                  'errors': {
                    'email': ['Email atau kata sandi salah.'],
                  },
                }, 422);
        case '/api/v1/me':
          return auth == 'Bearer t-1' && !meExpired
              ? _json({'data': _user}, 200)
              : _json({'message': 'Sesi kamu berakhir.'}, 401);
        case '/api/v1/auth/logout':
          return http.Response('', 204);
      }
      return _json({'message': 'Tidak ditemukan.'}, 404);
    });

ApiClient _api(MockClient client, TokenStore tokens) => ApiClient(
  baseUrl: Uri.parse('https://server.test/api/v1'),
  tokenStore: tokens,
  client: client,
);

void main() {
  test('masuk menyimpan token; nama sapaan kata pertama', () async {
    final tokens = MemoryTokenStore();
    final repo = RemoteAuthRepository(_api(_server(), tokens), tokens);
    final user = await repo.login(
      email: ' mikail@student.unand.ac.id ',
      password: 'benar123',
    );
    expect(user.firstName, 'Mikail');
    expect(await tokens.read(), 't-1');
  });

  test('kata sandi salah: pesan server tampil, token tidak disimpan', () async {
    final tokens = MemoryTokenStore();
    final vm = LoginViewModel(
      repository: RemoteAuthRepository(_api(_server(), tokens), tokens),
    );
    addTearDown(vm.dispose);
    final user = await vm.login(
      email: 'mikail@student.unand.ac.id',
      password: 'salah123',
    );
    expect(user, isNull);
    expect(vm.errorMessage, 'Email atau kata sandi salah.');
    expect(await tokens.read(), isNull);
  });

  test('sesi tersimpan dipulihkan; token kedaluwarsa dihapus', () async {
    final tokens = MemoryTokenStore('t-1');
    final repo = RemoteAuthRepository(_api(_server(), tokens), tokens);
    expect((await repo.restore())!.name, 'Mikail Samyth');

    final expired = RemoteAuthRepository(
      _api(_server(meExpired: true), tokens),
      tokens,
    );
    expect(await expired.restore(), isNull);
    expect(await tokens.read(), isNull);
  });

  test('keluar mencabut token di server dan di HP', () async {
    final calls = <String>[];
    final tokens = MemoryTokenStore('t-1');
    await RemoteAuthRepository(
      _api(_server(calls: calls), tokens),
      tokens,
    ).logout();
    expect(calls, contains('POST /api/v1/auth/logout'));
    expect(await tokens.read(), isNull);
  });

  test('401 dengan token memicu sesi habis; tanpa token tidak', () async {
    var expired = 0;
    final withToken = _api(_server(meExpired: true), MemoryTokenStore('t-1'))
      ..onUnauthorized = () => expired++;
    await expectLater(withToken.get('me'), throwsA(anything));
    expect(expired, 1);

    final withoutToken = _api(_server(), MemoryTokenStore())
      ..onUnauthorized = () => expired++;
    await expectLater(withoutToken.get('me'), throwsA(anything));
    expect(expired, 1);
  });

  testWidgets('layar Login menampilkan penolakan server', (tester) async {
    final tokens = MemoryTokenStore();
    await pumpTestWidget(
      tester,
      AuthRepositoryProvider(
        repository: RemoteAuthRepository(_api(_server(), tokens), tokens),
        child: MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'nama@student.unand.ac.id'),
      'mikail@student.unand.ac.id',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ketik password kamu'),
      'salah123',
    );
    await tester.tap(find.text('Gas Masuk!'));
    await tester.pumpAndSettle();
    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
    expect(find.text('Hai, Mikail!'), findsNothing);
  });

  testWidgets('token tersimpan: langsung masuk ke Cari', (tester) async {
    final tokens = MemoryTokenStore('t-1');
    await pumpTestWidget(
      tester,
      AuthRepositoryProvider(
        repository: RemoteAuthRepository(_api(_server(), tokens), tokens),
        child: MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hai, Mikail!'), findsOneWidget);
  });
}
