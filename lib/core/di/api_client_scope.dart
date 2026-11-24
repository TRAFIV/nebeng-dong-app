import 'package:flutter/widgets.dart';
import 'package:praktikum_mobile/core/network/api_client.dart';
import 'package:praktikum_mobile/core/network/api_config.dart';
import 'package:praktikum_mobile/core/network/token_store.dart';

/// Menyediakan satu [ApiClient] untuk seluruh aplikasi.
///
/// Bila `API_BASE_URL` tidak diisi dan tidak ada klien yang disuntikkan,
/// scope berisi `null`; provider repository lalu memakai data lokal.
/// Hanya klien yang dibuat di sini yang ditutup di sini.
class ApiClientProvider extends StatefulWidget {
  const ApiClientProvider({
    super.key,
    this.client,
    this.tokenStore,
    this.onSessionExpired,
    required this.child,
  });

  final ApiClient? client;
  final TokenStore? tokenStore;

  /// Server menolak token (401): token sudah dihapus, tinggal arahkan ke Login.
  final VoidCallback? onSessionExpired;
  final Widget child;

  @override
  State<ApiClientProvider> createState() => _ApiClientProviderState();
}

class _ApiClientProviderState extends State<ApiClientProvider> {
  late final TokenStore _tokens =
      widget.tokenStore ?? SharedPreferencesTokenStore();
  ApiClient? _owned;

  ApiClient? get _client => widget.client ?? _owned;

  @override
  void initState() {
    super.initState();
    if (widget.client == null && ApiConfig.isConfigured) {
      _owned = ApiClient(
        baseUrl: Uri.parse(ApiConfig.baseUrl),
        tokenStore: _tokens,
      );
    }
    _client?.onUnauthorized = _expired;
  }

  bool _handlingExpiry = false;

  /// Beberapa permintaan bisa gagal bersamaan; tangani sekali saja.
  Future<void> _expired() async {
    if (_handlingExpiry) return;
    _handlingExpiry = true;
    try {
      await _tokens.clear();
      widget.onSessionExpired?.call();
    } finally {
      _handlingExpiry = false;
    }
  }

  @override
  void dispose() {
    _owned?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ApiClientScope(client: _client, tokenStore: _tokens, child: widget.child);
}

class ApiClientScope extends InheritedWidget {
  const ApiClientScope({
    super.key,
    required this.client,
    required this.tokenStore,
    required super.child,
  });

  /// `null` berarti aplikasi berjalan dengan data lokal.
  final ApiClient? client;

  /// Dipakai alur Login untuk menyimpan dan menghapus token.
  final TokenStore tokenStore;

  static ApiClient? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ApiClientScope>()?.client;

  static TokenStore? tokenStoreOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ApiClientScope>()?.tokenStore;

  @override
  bool updateShouldNotify(ApiClientScope oldWidget) =>
      !identical(client, oldWidget.client) ||
      !identical(tokenStore, oldWidget.tokenStore);
}
