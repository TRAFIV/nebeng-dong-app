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
/// Pindah tab hanya mengganti isi di atas navbar, tanpa route baru, sehingga
/// navbar tidak ikut beranimasi dan posisi tiap tab terjaga. Halaman lanjutan
/// (Hasil, Detail, form) dibuka di atas shell dan menutupi navbar.
class PassengerShellScreen extends StatefulWidget {
  const PassengerShellScreen({super.key, required this.userName});

  final String userName;

  @override
  State<PassengerShellScreen> createState() => _PassengerShellScreenState();
}

class _PassengerShellScreenState extends State<PassengerShellScreen> {
  late PassengerShellViewModel _viewModel;
  PassengerShellViewModel? _ownedViewModel;
  RatingRepository? _fallbackRatingRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scoped = PassengerShellScope.maybeOf(context);
    _viewModel = scoped ?? (_ownedViewModel ??= PassengerShellViewModel());
  }

  @override
  void dispose() {
    _ownedViewModel?.dispose();
    super.dispose();
  }

  void _onTabSelected(PassengerTab tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    _viewModel.select(tab);
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
    listenable: _viewModel,
    builder: (context, _) {
      final selected = _viewModel.selectedTab;
      return PopScope(
        // Tombol kembali di tab lain membawa ke Cari dulu, baru keluar.
        canPop: selected == PassengerTab.cari,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _onTabSelected(PassengerTab.cari);
        },
        child: Scaffold(
          body: IndexedStack(
            index: selected.index,
            children: [
              for (final tab in PassengerTab.values)
                TickerMode(
                  enabled: tab == selected,
                  child: _viewModel.isBuilt(tab)
                      ? _tabPage(tab)
                      : const SizedBox.shrink(),
                ),
            ],
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
