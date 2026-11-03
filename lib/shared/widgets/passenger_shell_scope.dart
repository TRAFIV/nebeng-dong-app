import 'package:flutter/widgets.dart';
import 'package:praktikum_mobile/shared/viewmodels/passenger_shell_view_model.dart';

/// Satu state tab penumpang per sesi aplikasi, dipasang di atas MaterialApp
/// supaya halaman yang terbuka di atas shell (mis. Detail) bisa pindah tab.
class PassengerShellProvider extends StatefulWidget {
  const PassengerShellProvider({super.key, required this.child});
  final Widget child;
  @override
  State<PassengerShellProvider> createState() => _PassengerShellProviderState();
}

class _PassengerShellProviderState extends State<PassengerShellProvider> {
  final PassengerShellViewModel _viewModel = PassengerShellViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      PassengerShellScope(viewModel: _viewModel, child: widget.child);
}

class PassengerShellScope extends InheritedWidget {
  const PassengerShellScope({
    super.key,
    required this.viewModel,
    required super.child,
  });
  final PassengerShellViewModel viewModel;

  static PassengerShellViewModel? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PassengerShellScope>()?.viewModel;

  /// Tutup halaman di atas shell lalu tampilkan [tab].
  ///
  /// Mengembalikan `false` bila tidak ada shell (mis. layar dibuka langsung di
  /// test); pemanggil kemudian memakai named route seperti sebelumnya.
  static bool openTab(BuildContext context, PassengerTab tab) {
    final viewModel = maybeOf(context);
    if (viewModel == null) return false;
    Navigator.of(context).popUntil((route) => route.isFirst);
    viewModel.select(tab);
    return true;
  }

  @override
  bool updateShouldNotify(PassengerShellScope oldWidget) =>
      !identical(viewModel, oldWidget.viewModel);
}
