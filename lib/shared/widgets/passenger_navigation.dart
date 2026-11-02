import 'package:flutter/material.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';

/// Navigasi bawah penumpang yang dipakai bersama semua modul.
///
/// Tab tanpa route (`null`) belum terintegrasi sehingga tetap nonaktif.
/// Profil saat ini memuat Riwayat & Rating (Modul 4); rekap profil menyusul.
class PassengerNavigation extends StatelessWidget {
  const PassengerNavigation({super.key, this.selectedIndex = 0});

  final int selectedIndex;

  static const List<String?> _tabRoutes = [
    AppRoutes.home,
    AppRoutes.pesananSaya,
    AppRoutes.costs,
    AppRoutes.profil,
  ];

  void _openTab(BuildContext context, int index) {
    if (index == selectedIndex) return;
    if (index == 0) {
      // Kembali ke Cari tanpa membuat Home baru agar nama pengguna tetap.
      Navigator.popUntil(
        context,
        (route) => route.isFirst || route.settings.name == AppRoutes.home,
      );
      return;
    }
    final routeName = _tabRoutes[index]!;
    if (selectedIndex == 0) {
      Navigator.pushNamed(context, routeName);
    } else {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: NavigationBarTheme(
      data: Theme.of(context).navigationBarTheme
          .copyWith(indicatorColor: Colors.transparent),
      child: NavigationBar(
        height: 72,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _openTab(context, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            label: 'Cari',
            enabled: _tabRoutes[0] != null,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
            enabled: _tabRoutes[1] != null,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_rounded),
            label: 'Ongkos',
            enabled: _tabRoutes[2] != null,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_rounded),
            label: 'Profil',
            enabled: _tabRoutes[3] != null,
          ),
        ],
      ),
    ),
  );
}
