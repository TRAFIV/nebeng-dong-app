import 'package:flutter/foundation.dart';

/// Shared lifecycle for presentation state. No widgets, navigation or context.
abstract class ViewModel extends ChangeNotifier {
  bool _disposed = false;
  bool get isDisposed => _disposed;

  @protected
  void publish() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
