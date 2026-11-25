import '../viewmodels/rating_view_model.dart';

import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';

import 'package:flutter/material.dart';

import '../data/rating_repository.dart';
import '../models/trip_rating.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';

import '../widgets/rating_trip_card.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({
    super.key,
    required this.trip,
    required this.userId,
    required this.repository,
  });
  final RatingTrip trip;
  final String userId;
  final RatingRepository repository;
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _comment = TextEditingController();
  late RatingViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _bind();
  }

  void _bind() {
    _viewModel = RatingViewModel(
      repository: widget.repository,
      trip: widget.trip,
      userId: widget.userId,
    );
  }

  @override
  void didUpdateWidget(RatingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.trip != widget.trip ||
        oldWidget.userId != widget.userId) {
      _viewModel.dispose();
      _comment.clear();
      _bind();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final viewModel = _viewModel;
    final result = await viewModel.submit(_comment.text);
    if (!mounted || viewModel != _viewModel || result == null) return;
    // Rebuild PopScope after the save lock is released before returning a result.
    await WidgetsBinding.instance.endOfFrame;
    if (mounted && viewModel == _viewModel) {
      Navigator.of(context).pop<TripRating>(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => PopScope(
        canPop: !_viewModel.saving,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text('Nilai Pengemudi'),
                  leading: IconButton(
                    tooltip: 'Kembali',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _viewModel.saving
                        ? null
                        : () => Navigator.pop(context),
                  ),
                ),
                body: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            'Gimana nebengnya?',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kamu sebagai penumpang · Nilai pengemudimu.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          RatingTripCard(trip: trip, showFare: false),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.brandSubtle,
                              borderRadius: AppRadius.mdAll,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kasih bintang buat ${trip.driverName.split(' ').first}',
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (var i = 1; i <= 5; i++)
                                      Semantics(
                                        selected: i <= _viewModel.score,
                                        child: IconButton(
                                          key: ValueKey('star-$i'),
                                          tooltip: '$i bintang',
                                          onPressed: _viewModel.saving
                                              ? null
                                              : () => _viewModel.selectScore(i),
                                          iconSize: 32,
                                          color: AppColors.brandStrong,
                                          icon: Icon(
                                            i <= _viewModel.score
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  _viewModel.score == 0
                                      ? 'Pilih 1–5 bintang'
                                      : '${_viewModel.score} dari 5 · ${['', 'Kurang nyaman', 'Perlu ditingkatkan', 'Cukup oke', 'Nyaman!', 'Asyik banget!'][_viewModel.score]}',
                                  style: const TextStyle(
                                    color: AppColors.brandStrong,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            label: 'Cerita sedikit (opsional)',
                            fieldKey: const ValueKey('rating-comment'),
                            controller: _comment,
                            enabled: !_viewModel.saving,
                            maxLength: 200,
                            minLines: 2,
                            maxLines: 4,
                            hint: 'Tepat waktu dan ramah. Makasih!',
                          ),
                          if (_viewModel.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  _viewModel.error!,
                                  key: const ValueKey('rating-error'),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                          const Text(
                            'Nilai pengemudi setelah perjalananmu selesai. Satu penilaian per perjalanan.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButton(
                          label: _viewModel.saving
                              ? 'Menyimpan rating…'
                              : 'Kirim Rating!',
                          onPressed: _viewModel.saving ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_viewModel.saving) ...[
                Positioned.fill(
                  child: ModalBarrier(
                    dismissible: false,
                    color: AppColors.background.withValues(alpha: 0.75),
                  ),
                ),
                const Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Menyimpan rating',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
