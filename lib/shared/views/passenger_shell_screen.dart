import 'package:flutter/material.dart';
import 'package:praktikum_mobile/core/di/rating_repository_scope.dart';
import 'package:praktikum_mobile/features/booking/views/pesanan_saya_screen.dart';
import 'package:praktikum_mobile/features/costs/views/cost_history_screen.dart';
import 'package:praktikum_mobile/features/reputation/data/local_rating_repository.dart';
import 'package:praktikum_mobile/features/reputation/data/rating_repository.dart';
import 'package:praktikum_mobile/features/reputation/views/rating_history_screen.dart';
import 'package:praktikum_mobile/features/ride_search/views/home_screen.dart';
import 'package:praktikum_mobile/shared/viewmodels/passenger_shell_view_model.dart';
import 'package:praktikum_mobile/shared/widgets/passenger_navigation.dart';
import 'package:praktikum_mobile/shared/widgets/passenger_shell_scope.dart';

/// Kerangka utama penumpang: satu navbar tetap dan empat halaman tab.
///
/// Tab bisa dipilih lewat navbar atau digeser ke kiri/kanan. Pindah tab hanya
/// mengganti isi di atas navbar, tanpa route baru, sehingga navbar tidak ikut
/// beranimasi. Tab dibangun saat pertama terlihat lalu tetap hidup, sehingga
/// isi dan posisi gulirnya terjaga. Halaman lanjutan (Hasil, Detail, form)
/// dibuka di atas shell dan menutupi navbar.
class PassengerShellScreen extends StatefulWidget {
  const PassengerShellScreen({super.key, required this.userName});

  final String userName;

  @override
  State<PassengerShellScreen> createState() => _PassengerShellScreenState();
}

class _PassengerShellScreenState extends State<PassengerShellScreen> {
  PassengerShellViewModel? _viewModel;
  PassengerShellViewModel? _ownedViewModel;
  PageController? _pages;
  RatingRepository? _fallbackRatingRepository;

  /// True saat perubahan tab berasal dari geseran, agar halaman tidak dilompatkan lagi.
  bool _changedBySwipe = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scoped = PassengerShellScope.maybeOf(context);
    final next = scoped ?? (_ownedViewModel ??= PassengerShellViewModel());
    if (!identical(next, _viewModel)) {
      _viewModel?.removeListener(_syncPage);
      _viewModel = next..addListener(_syncPage);
    }
    _pages ??= PageController(initialPage: next.selectedTab.index);
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_syncPage);
    _ownedViewModel?.dispose();
    _pages?.dispose();
    super.dispose();
  }

  /// Tab dipilih dari navbar atau dari layar lain: lompat langsung ke halamannya
  /// tanpa melewati (dan memuat) tab di antaranya.
  void _syncPage() {
    if (_changedBySwipe) {
      _changedBySwipe = false;
      return;
    }
    final pages = _pages;
    final target = _viewModel!.selectedTab.index;
    if (pages != null && pages.hasClients && pages.page?.round() != target) {
      pages.jumpToPage(target);
    }
  }

  void _onTabSelected(PassengerTab tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    _viewModel!.select(tab);
  }

  void _onPageSwiped(int index) {
    final tab = PassengerTab.values[index];
    if (tab == _viewModel!.selectedTab) return;
    _changedBySwipe = true;
    _onTabSelected(tab);
  }

  Widget _tabPage(PassengerTab tab) => switch (tab) {
    PassengerTab.cari => HomeScreen(userName: widget.userName),
    PassengerTab.pesanan => const PesananSayaScreen(),
    PassengerTab.ongkos => const CostHistoryScreen(),
    PassengerTab.profil => RatingHistoryScreen(
      repository:
          RatingRepositoryScope.maybeOf(context) ??
          (_fallbackRatingRepository ??= LocalRatingRepository(
            LocalRatingStorage(),
          )),
    ),
  };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _viewModel!,
    builder: (context, _) {
      final selected = _viewModel!.selectedTab;
      return PopScope(
        // Tombol kembali di tab lain membawa ke Cari dulu, baru keluar.
        canPop: selected == PassengerTab.cari,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _onTabSelected(PassengerTab.cari);
        },
        child: Scaffold(
          // PageView hanya membangun halaman yang terlihat, jadi data tab lain
          // baru dimuat saat tab itu pertama kali dibuka atau digeser.
          body: PageView.builder(
            controller: _pages,
            itemCount: PassengerTab.values.length,
            onPageChanged: _onPageSwiped,
            itemBuilder: (context, index) {
              final tab = PassengerTab.values[index];
              return _KeepAlivePage(
                child: TickerMode(
                  enabled: tab == selected,
                  child: _tabPage(tab),
                ),
              );
            },
          ),
          bottomNavigationBar: PassengerNavigation(
            selectedIndex: selected.index,
            onDestinationSelected: (index) =>
                _onTabSelected(PassengerTab.values[index]),
          ),
        ),
      );
    },
  );
}

/// Menjaga halaman tab tetap hidup setelah digeser keluar layar.
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
