import 'package:praktikum_mobile/core/view_model.dart';

/// Tab penumpang yang tampil di navigasi bawah, urut sesuai navbar.
enum PassengerTab { cari, pesanan, ongkos, profil }

/// State shell penumpang: tab aktif dan tab yang sudah pernah dibuka.
///
/// Tab dibangun saat pertama dibuka agar data modul lain tidak dimuat sebelum
/// dibutuhkan; setelah itu tab tetap hidup sehingga posisi dan isinya terjaga.
class PassengerShellViewModel extends ViewModel {
  PassengerShellViewModel({PassengerTab initialTab = PassengerTab.cari})
    : _selectedTab = initialTab,
      _builtTabs = {initialTab};

  PassengerTab _selectedTab;
  final Set<PassengerTab> _builtTabs;

  PassengerTab get selectedTab => _selectedTab;

  bool isBuilt(PassengerTab tab) => _builtTabs.contains(tab);

  void select(PassengerTab tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    _builtTabs.add(tab);
    publish();
  }
}
