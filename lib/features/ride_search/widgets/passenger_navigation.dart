import 'package:flutter/material.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';

/// M1 Passenger Navigation. Unintegrated team destinations remain disabled.
class PassengerNavigation extends StatelessWidget {
  const PassengerNavigation({super.key});
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
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Cari',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
            enabled: false,
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Ongkos',
            enabled: false,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
            enabled: false,
          ),
        ],
      ),
    ),
  );
}
