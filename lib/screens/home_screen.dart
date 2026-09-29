import 'package:flutter/material.dart';

import '../data/ride_repository.dart';
import '../models/ride.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/ride_card.dart';
import '../widgets/state_views.dart';
import '../widgets/user_avatar.dart';

/// Beranda: cari tebengan berdasarkan lokasi asal dan tujuan.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userName, this.rides});

  final String userName;

  // Opsional untuk pengujian; biasanya data dari repository.
  final List<Ride>? rides;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  final _repository = RideRepository();
  List<Ride> _rides = [];
  List<Ride> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _selectedTab = 0;

  // Ubah ke true untuk menguji error.
  bool get _simulateError => false;

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadRides() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rides = await _repository.fetchRides(simulateError: _simulateError);

      if (!mounted) return;

      _rides = widget.rides ?? rides;
      _results = _filterRides();
    } catch (error) {
      if (!mounted) return;

      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Ride> _filterRides() {
    final origin = _originController.text.trim().toLowerCase();
    final destination = _destinationController.text.trim().toLowerCase();

    return _rides.where((ride) {
      return ride.origin.toLowerCase().contains(origin) &&
          ride.destination.toLowerCase().contains(destination);
    }).toList();
  }

  void _search() {
    FocusScope.of(context).unfocus();

    if (_isLoading || _errorMessage != null) return;

    setState(() {
      _results = _filterRides();
    });
  }

  void _openDetail(Ride ride) {
    // Diubah: kirim objek Ride menggunakan named route.
    Navigator.pushNamed<void>(context, AppRoutes.detail, arguments: ride);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _selectedTab == 0 ? _buildRideSearch() : const _ComingSoon(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() => _selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Ongkos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildRideSearch() {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      children: [
        _HomeHeader(userName: widget.userName),
        const SizedBox(height: AppSpacing.lg),
        _SearchCard(
          originController: _originController,
          destinationController: _destinationController,
          onSearch: _search,
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('Yang searah sama kamu', style: AppTextStyles.headingMedium),
        const SizedBox(height: AppSpacing.md),
        ..._buildContent(),
      ],
    );
  }

  List<Widget> _buildContent() {
    if (_isLoading) {
      return [const LoadingView()];
    }

    final errorMessage = _errorMessage;
    if (errorMessage != null) {
      return [ErrorView(message: errorMessage, onRetry: _loadRides)];
    }

    if (_rides.isEmpty) {
      return [const EmptyView(message: 'Belum ada data.')];
    }

    if (_results.isEmpty) {
      return [
        Text(
          'Yah, belum ada yang searah. Coba ganti lokasinya, deh!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ];
    }

    return [
      for (final ride in _results) ...[
        RideCard(ride: ride, onTap: () => _openDetail(ride)),
        const SizedBox(height: AppSpacing.md),
      ],
    ];
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, $userName!',
                style: AppTextStyles.headingLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Mau nebeng ke mana nih hari ini?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        UserAvatar(name: userName),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.originController,
    required this.destinationController,
    required this.onSearch,
  });

  final TextEditingController originController;
  final TextEditingController destinationController;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Berangkat dari mana?',
            hint: 'Contoh: Jl. Khatib Sulaiman',
            controller: originController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Mau ke mana?',
            hint: 'Contoh: Kampus Unand Limau Manis',
            controller: destinationController,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: 'Cariin Tebengan!', onPressed: onSearch),
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Sabar, ya! Fitur ini lagi dimasak.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
