import 'package:flutter/material.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';

/// Tampilan navbar penumpang. Perpindahan tab diatur oleh
/// `PassengerShellScreen`; widget ini hanya menampilkan dan melapor ketukan.
class PassengerNavigation extends StatelessWidget {
  const PassengerNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

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
        onDestinationSelected: onDestinationSelected,
        // Ganti tab langsung, seperti navbar aplikasi pada umumnya.
        animationDuration: Duration.zero,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Cari',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Ongkos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    ),
  );
}
