import 'package:flutter/material.dart';

import '../data/rating_repository.dart';
import '../data/sample_rating_trips.dart';
import '../models/trip_rating.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';

import '../widgets/rating_trip_card.dart';
import 'rating_screen.dart';
import '../viewmodels/rating_history_view_model.dart';

class RatingHistoryScreen extends StatefulWidget {
  const RatingHistoryScreen({
    super.key,
    required this.repository,
    this.userId = ratingDemoUserId,
  });
  final RatingRepository repository;
  final String userId;
  @override
  State<RatingHistoryScreen> createState() => _RatingHistoryScreenState();
}

class _RatingHistoryScreenState extends State<RatingHistoryScreen> {
  late RatingHistoryViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _bind();
  }

  void _bind() {
    _viewModel = RatingHistoryViewModel(
      repository: widget.repository,
      userId: widget.userId,
    )..load();
  }

  @override
  void didUpdateWidget(RatingHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.userId != widget.userId) {
      _viewModel.dispose();
      _bind();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _rate(RatingTrip trip) async {
    final viewModel = _viewModel;
    final result = await Navigator.push<TripRating>(
      context,
      MaterialPageRoute(
        builder: (_) => RatingScreen(
          trip: trip,
          userId: widget.userId,
          repository: widget.repository,
        ),
      ),
    );
    if (!mounted || viewModel != _viewModel || result == null) return;
    _viewModel.showSavedResult();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rating ${result.score}/5 tersimpan. Makasih!')),
    );
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ulangi demo rating?'),
        content: const Text(
          'Hanya rating contoh di perangkat ini yang akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ulangi demo'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await _viewModel.resetDemo();
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating belum bisa dihapus. Coba lagi.')),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Perjalanan'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Opsi demo',
            enabled: !_viewModel.loading,
            onSelected: (_) => _reset(),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Ulangi demo rating'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _viewModel.loading
                ? const Center(child: CircularProgressIndicator())
                : _viewModel.error != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_viewModel.error!),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Coba lagi',
                          onPressed: _viewModel.load,
                        ),
                      ],
                    ),
                  )
                : _history(),
          ),
        ),
      ),
    ),
  );
  Widget _history() {
    final trips = _viewModel.trips;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Jejak nebeng kamu',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Searah, bareng, jadi cerita.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Semua'),
              selected: !_viewModel.onlyUnrated,
              onSelected: (_) => _viewModel.filter(false),
            ),
            ChoiceChip(
              label: const Text('Belum dinilai'),
              selected: _viewModel.onlyUnrated,
              onSelected: (_) => _viewModel.filter(true),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (trips.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Text(
              'Tidak ada perjalanan yang perlu dinilai.',
              textAlign: TextAlign.center,
            ),
          ),
        for (final trip in trips) ...[
          RatingTripCard(
            key: ValueKey('trip-${trip.id}'),
            trip: trip,
            footer: _ratingFooter(trip),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _ratingFooter(RatingTrip trip) {
    final rating = _viewModel.ratingFor(trip);
    if (rating == null) {
      return AppButton(
        key: ValueKey('rate-${trip.id}'),
        label: trip.completed
            ? 'Nilai Pengemudi, Yuk!'
            : 'Perjalanan belum selesai',
        onPressed: trip.completed ? () => _rate(trip) : null,
      );
    }
    return Container(
      key: ValueKey('saved-${trip.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successSubtle.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Penilaian kamu',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successSubtle,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.successText,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Sudah dinilai',
                      style: TextStyle(
                        color: AppColors.successText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            label: 'Rating kamu ${rating.score} dari 5 bintang',
            child: ExcludeSemantics(
              child: Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= rating.score
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.brandStrong,
                      size: 26,
                    ),
                  const SizedBox(width: 10),
                  Text(
                    '${rating.score}/5',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (rating.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Komentarmu',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(rating.comment),
          ],
        ],
      ),
    );
  }
}
