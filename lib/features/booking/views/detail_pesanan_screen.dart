import 'package:flutter/material.dart';

import 'package:praktikum_mobile/core/di/booking_repository_scope.dart';
import 'package:praktikum_mobile/features/booking/data/booking_repository.dart';
import 'package:praktikum_mobile/features/booking/data/local_booking_repository.dart';
import 'package:praktikum_mobile/features/booking/models/booking.dart';
import 'package:praktikum_mobile/features/booking/viewmodels/detail_pesanan_view_model.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/status_badge.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';

/// Layar Detail Pesanan: rincian status, driver, titik jemput, linimasa, dan pembatalan (FR-05, FR-08).
class DetailPesananScreen extends StatefulWidget {
  const DetailPesananScreen({
    super.key,
    required this.booking,
    this.repository,
  });

  final Booking booking;
  final BookingRepository? repository;

  @override
  State<DetailPesananScreen> createState() => _DetailPesananScreenState();
}

class _DetailPesananScreenState extends State<DetailPesananScreen> {
  late BookingRepository _repository;
  late DetailPesananViewModel _viewModel;
  bool _initialized = false;
  bool _ownsRepository = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final scoped = BookingRepositoryScope.maybeOf(context);
    final candidate = widget.repository ?? scoped;
    _ownsRepository = candidate == null;
    _repository = candidate ?? LocalBookingRepository();
    _viewModel = DetailPesananViewModel(
      booking: widget.booking,
      repository: _repository,
    );
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _viewModel.dispose();
      if (_ownsRepository) _repository.dispose();
    }
    super.dispose();
  }

  void _showCancelConfirmation() {
    final booking = _viewModel.booking;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Batalin pesanan ini?', style: AppTextStyles.headingMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pesanan ke ${booking.driverName} (${booking.schedule}) bakal dibatalkan dan kursimu dilepas.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Nggak Jadi',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Ya, Batalkan',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _performCancel();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performCancel() async {
    final success = await _viewModel.cancelBooking();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibatalkan.')),
      );
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_viewModel.errorMessage!)));
    }
  }

  void _backToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final booking = _viewModel.booking;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Detail Pesanan'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // 1. Status Banner Card
                _StatusBannerCard(booking: booking),
                const SizedBox(height: AppSpacing.md),

                // 2. Driver & Trip Info Card
                _DriverTripCard(booking: booking),
                const SizedBox(height: AppSpacing.md),

                // 3. Timeline Card
                _TimelineCard(booking: booking),
                const SizedBox(height: AppSpacing.md),

                // 4. Helper Text
                Center(
                  child: Text(
                    booking.canCancel
                        ? 'Pesanan ini masih bisa dibatalkan.'
                        : 'Pesanan ini nggak bisa dibatalkan lagi.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: booking.canCancel
                    ? AppButton(
                        label: _viewModel.isCancelling
                            ? 'Membatalkan...'
                            : 'Batalkan Pesanan',
                        variant: AppButtonVariant.secondary,
                        onPressed: _viewModel.isCancelling
                            ? null
                            : _showCancelConfirmation,
                      )
                    : AppButton(
                        label: 'Cariin Tebengan Lain!',
                        variant: AppButtonVariant.primary,
                        onPressed: _backToHome,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBannerCard extends StatelessWidget {
  const _StatusBannerCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (booking.status) {
      BookingStatus.diterima => (
        'Yey, kamu dapet kursi!',
        'Pesananmu udah diterima. Siap-siap di titik jemput ya.',
      ),
      BookingStatus.menunggu => (
        'Menunggu konfirmasi...',
        'Pengemudi lagi ngecek permintaanmu. Pantau terus di sini ya.',
      ),
      BookingStatus.ditolak => (
        'Yah, belum rezeki',
        'Pesananmu belum bisa diterima kali ini. Coba cari tebengan lain, ya.',
      ),
      BookingStatus.dibatalkan => (
        'Pesanan dibatalkan',
        'Kursimu udah dilepas. Mau cari tebengan lain?',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: booking.status.label,
                tone: booking.status.tone,
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  booking.updatedAtLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.headingMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverTripCard extends StatelessWidget {
  const _DriverTripCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatar(name: booking.driverName, size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.driverName, style: AppTextStyles.labelLarge),
                    Text(
                      'Rating ${booking.driverRating.toStringAsFixed(1)} · Udah ${booking.driverTripCount}x nebengin',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg, color: AppColors.border),
          _InfoRow(
            icon: Icons.alt_route_rounded,
            iconColor: AppColors.brandStrong,
            text: '${booking.origin} → ${booking.destination}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.routeOrigin,
            text: booking.schedule,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.routeOrigin,
            text: 'Jemput: ${booking.pickupLocation}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: AppColors.routeOrigin,
            text: 'Catatan: ${booking.note ?? 'Tidak ada catatan'}',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final timeline = booking.timeline;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // Step 1: Permintaan dikirim
          _TimelineItem(
            title: 'Permintaan dikirim',
            time: timeline.requestSentTime,
            isCompleted: true,
            isLast: booking.status == BookingStatus.menunggu,
          ),

          // Status specific steps
          if (booking.status == BookingStatus.diterima) ...[
            _TimelineItem(
              title: 'Pesanan diterima',
              time: timeline.decisionTime ?? '07.15',
              isCompleted: true,
              isLast: false,
            ),
            _TimelineItem(
              title: 'Dijemput di titik jemput',
              time: timeline.pickupTime ?? '07.30',
              isCompleted: false,
              isLast: true,
            ),
          ] else if (booking.status == BookingStatus.ditolak) ...[
            _TimelineItem(
              title: 'Pesanan ditolak',
              time: timeline.decisionTime ?? '07.20',
              isCompleted: true,
              isNegative: true,
              isLast: true,
            ),
          ] else if (booking.status == BookingStatus.dibatalkan) ...[
            if (timeline.decisionTime != null)
              _TimelineItem(
                title: 'Pesanan diterima',
                time: timeline.decisionTime!,
                isCompleted: true,
                isLast: false,
              ),
            _TimelineItem(
              title: 'Pesanan dibatalkan',
              time: timeline.cancelledTime ?? '08.40',
              isCompleted: true,
              isNegative: true,
              isLast: true,
            ),
          ] else if (booking.status == BookingStatus.menunggu) ...[
            const _TimelineItem(
              title: 'Menunggu keputusan pengemudi',
              time: '-',
              isCompleted: false,
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.time,
    required this.isCompleted,
    this.isNegative = false,
    required this.isLast,
  });

  final String title;
  final String time;
  final bool isCompleted;
  final bool isNegative;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = switch ((isCompleted, isNegative)) {
      (true, true) => AppColors.brandStrong,
      (true, false) => AppColors.accent,
      (false, _) => AppColors.textSecondary.withValues(alpha: 0.5),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Center(
                      child: Icon(Icons.check, size: 10, color: Colors.white),
                    )
                  : null,
            ),
            if (!isLast)
              Container(width: 2, height: 32, color: AppColors.border),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
              color: isCompleted
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          time,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
