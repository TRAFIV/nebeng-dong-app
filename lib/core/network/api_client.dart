import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:praktikum_mobile/core/network/api_config.dart';
import 'package:praktikum_mobile/core/network/api_exception.dart';
import 'package:praktikum_mobile/core/network/token_store.dart';

/// Satu pintu ke REST API kelompok untuk semua modul.
///
/// Mengurus hal yang sama di setiap permintaan, supaya repository modul cukup
/// menulis alamat endpoint dan cara membaca datanya:
/// - header JSON dan `Authorization: Bearer <token>` bila sudah masuk;
/// - batas waktu [ApiConfig.timeout];
/// - membuka amplop `{"data": ...}` dari jawaban sukses;
/// - mengubah kegagalan menjadi [ApiException] dengan pesan ramah.
///
/// Kontrak lengkapnya ada di `docs/api/kontrak-api.md`.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    TokenStore? tokenStore,
    http.Client? client,
    this.timeout = ApiConfig.timeout,
  }) : _tokens = tokenStore ?? MemoryTokenStore(),
       _http = client ?? http.Client();

  final Uri baseUrl;
  final TokenStore _tokens;
  final http.Client _http;
  final Duration timeout;

  Future<Object?> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<Object?> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<Object?> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<Object?> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<Object?> delete(String path) => _send('DELETE', path);

  void close() => _http.close();

  /// `rides` + `https://server/api/v1` → `https://server/api/v1/rides`.
  Uri _uri(String path, Map<String, String>? query) {
    final base = baseUrl.path.endsWith('/') ? baseUrl.path : '${baseUrl.path}/';
    final relative = path.startsWith('/') ? path.substring(1) : path;
    return baseUrl.replace(
      path: '$base$relative',
      queryParameters: query == null || query.isEmpty ? null : query,
    );
  }

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final request = http.Request(method, _uri(path, query))
      ..headers['Accept'] = 'application/json';
    final token = await _tokens.read();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _http.send(request).timeout(timeout),
      ).timeout(timeout);
    } on TimeoutException {
      throw _error(ApiErrorKind.timeout);
    } on http.ClientException catch (error) {
      throw _error(ApiErrorKind.network, debugDetail: error.message);
    }

    final json = _decode(response);
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      // Jawaban sukses dibungkus `{"data": ...}`; tanpa amplop dipakai apa adanya.
      return json is Map && json.containsKey('data') ? json['data'] : json;
    }
    throw _failure(status, json);
  }

  Object? _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    if (text.trim().isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      // Halaman error HTML dari server/proxy tetap diperlakukan sesuai kodenya.
      if (response.statusCode >= 400) return null;
      throw _error(
        ApiErrorKind.invalidResponse,
        statusCode: response.statusCode,
        debugDetail:
            'Bukan JSON: ${text.substring(0, text.length.clamp(0, 120))}',
      );
    }
  }

  /// Error dari server berbentuk `{"message": "...", "errors": {"kolom": ["..."]}}`.
  ApiException _failure(int status, Object? json) {
    final kind = switch (status) {
      401 => ApiErrorKind.unauthorized,
      403 => ApiErrorKind.forbidden,
      404 => ApiErrorKind.notFound,
      409 => ApiErrorKind.conflict,
      422 => ApiErrorKind.validation,
      _ => ApiErrorKind.server,
    };
    final body = json is Map ? json : const {};
    final message = body['message'];
    final errors = body['errors'];
    return _error(
      kind,
      statusCode: status,
      message: message is String && message.trim().isNotEmpty ? message : null,
      fieldErrors: {
        if (errors is Map)
          for (final entry in errors.entries)
            '${entry.key}': ?_firstMessage(entry.value),
      },
    );
  }

  static String? _firstMessage(Object? value) => switch (value) {
    final String text => text,
    [final String text, ...] => text,
    _ => null,
  };

  static ApiException _error(
    ApiErrorKind kind, {
    String? message,
    int? statusCode,
    Map<String, String> fieldErrors = const {},
    String? debugDetail,
  }) => ApiException(
    kind,
    message ?? ApiException.defaultMessage(kind),
    statusCode: statusCode,
    fieldErrors: fieldErrors,
    debugDetail: debugDetail,
  );
}
