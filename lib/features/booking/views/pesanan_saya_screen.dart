import 'package:flutter/material.dart';

import 'package:praktikum_mobile/core/di/booking_repository_scope.dart';
import 'package:praktikum_mobile/features/booking/data/booking_repository.dart';
import 'package:praktikum_mobile/features/booking/data/local_booking_repository.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';
import 'package:praktikum_mobile/features/booking/viewmodels/pesanan_saya_view_model.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';

/// Layar Pesanan Saya: daftar pesanan aktif dan riwayat pesanan (FR-05, FR-07).
///
/// Dapat menerima [ride] sebagai argumen (dikirim dari RideDetailScreen)
/// untuk langsung membuka form Ajukan Tebengan di layar pertama kali.
class PesananSayaScreen extends StatefulWidget {
  const PesananSayaScreen({super.key, this.repository, this.initialRide});

  final BookingRepository? repository;

  /// Tebengan yang ingin diajukan. Jika ada, layar langsung membuka
  /// AjukanTebengan saat pertama kali dimuat.
  final Ride? initialRide;

  @override
  State<PesananSayaScreen> createState() => _PesananSayaScreenState();
}

class _PesananSayaScreenState extends State<PesananSayaScreen> {
  late BookingRepository _repository;
  late PesananSayaViewModel _viewModel;
  bool _initialized = false;
  bool _ownsRepository = false;
  bool _isNavigating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final scoped = BookingRepositoryScope.maybeOf(context);
    final candidate = widget.repository ?? scoped;
    _ownsRepository = candidate == null;
    _repository = candidate ?? LocalBookingRepository();
    _viewModel = PesananSayaViewModel(repository: _repository);
    _initialized = true;
    _viewModel.load();
  }

  @override
  void initState() {
    super.initState();
    // Buka AjukanTebengan setelah frame pertama jika ada ride dari argumen.
    if (widget.initialRide != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ajukanTebengan(widget.initialRide!);
      });
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _viewModel.dispose();
      if (_ownsRepository) _repository.dispose();
    }
    super.dispose();
  }

  /// Buka layar Ajukan Tebengan untuk [ride] tertentu.
  /// Menunggu hasil pop() — jika berhasil, tandai di ViewModel dan tampilkan SnackBar.
  Future<void> _ajukanTebengan(Ride ride) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      final result = await Navigator.pushNamed<Booking>(
        context,
        AppRoutes.ajukanTebengan,
        arguments: ride,
      );

      if (!mounted) return;

      if (result != null) {
        // Tandai di ViewModel — VM publish agar ListenableBuilder rebuild tanpa setState.
        _viewModel.markNewBooking(result.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan terkirim! Tunggu kabar ya.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        _isNavigating = false;
      }
    }
  }

  void _openDetail(Booking booking) {
    Navigator.pushNamed(context, AppRoutes.detailPesanan, arguments: booking);
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: _buildBody()),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onBrand,
          elevation: 3,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          onPressed: () => _ajukanTebengan(_viewModel.sampleRideForSimulation),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            '+ Ajukan Tebengan',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 1,
          onDestinationSelected: _onBottomNavTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Cari',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_rounded),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Pesanan',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments),
              label: 'Ongkos',
              enabled: false,
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const LoadingView(message: 'Memuat pesanan...');
    }

    if (_viewModel.errorMessage != null) {
      return ErrorView(
        message: _viewModel.errorMessage!,
        onRetry: _viewModel.load,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      children: [
        Text('Pesanan Saya', style: AppTextStyles.headingLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Pantau permintaan nebengmu di sini.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Section 1: Pesanan Aktif
        Text('Pesanan Aktif', style: AppTextStyles.headingMedium),
        const SizedBox(height: AppSpacing.md),
        if (!_viewModel.hasActiveBookings)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              'Belum ada pesanan aktif.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          for (final booking in _viewModel.activeBookings) ...[
            _BookingCard(
              booking: booking,
              isNew: _viewModel.isNew(booking.id),
              onTap: () => _openDetail(booking),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

        const SizedBox(height: AppSpacing.lg),

        // Section 2: Riwayat Pesanan
        Text('Riwayat Pesanan', style: AppTextStyles.headingMedium),
        const SizedBox(height: AppSpacing.md),
        if (!_viewModel.hasPastBookings)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              'Belum ada riwayat pesanan.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          for (final booking in _viewModel.pastBookings) ...[
            _BookingCard(
              booking: booking,
              isNew: false,
              onTap: () => _openDetail(booking),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onTap,
    this.isNew = false,
  });

  final Booking booking;
  final VoidCallback onTap;

  /// Jika true, tampilkan penanda "Baru" pada kartu ini.
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(name: booking.driverName, size: 44),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.driverName,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          booking.schedule,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Tampilkan penanda "Baru" jika pesanan baru saja dikirim.
                  if (isNew) ...[
                    StatusBadge(label: 'Baru', tone: StatusTone.brand),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  StatusBadge(
                    label: booking.status.label,
                    tone: booking.status.tone,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.alt_route_rounded,
                    size: 18,
                    color: AppColors.brandStrong,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${booking.origin} → ${booking.destination}',
                      style: AppTextStyles.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
