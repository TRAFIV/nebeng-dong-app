import 'package:praktikum_mobile/core/view_model.dart';

/// Tab penumpang yang tampil di navigasi bawah, urut sesuai navbar.
enum PassengerTab { cari, pesanan, ongkos, profil }

/// State shell penumpang: tab yang sedang aktif.
///
/// Dipilih lewat navbar, geser halaman, atau `PassengerShellScope.openTab`.
class PassengerShellViewModel extends ViewModel {
  PassengerShellViewModel({PassengerTab initialTab = PassengerTab.cari})
    : _selectedTab = initialTab;

  PassengerTab _selectedTab;

  PassengerTab get selectedTab => _selectedTab;

  void select(PassengerTab tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    publish();
  }
}
