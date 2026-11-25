import 'package:flutter/material.dart';
import 'package:praktikum_mobile/features/reputation/data/local_rating_repository.dart';
import 'package:praktikum_mobile/features/reputation/data/rating_repository.dart';

/// Satu repository rating per sesi aplikasi, supaya rating yang baru disimpan
/// langsung terlihat setiap kali tab Profil dibuka lagi.
/// Repository tidak memegang resource, jadi tidak ada yang perlu di-dispose.
class RatingRepositoryProvider extends StatefulWidget {
  const RatingRepositoryProvider({
    super.key,
    this.repository,
    required this.child,
  });
  final RatingRepository? repository;
  final Widget child;
  @override
  State<RatingRepositoryProvider> createState() =>
      _RatingRepositoryProviderState();
}

class _RatingRepositoryProviderState extends State<RatingRepositoryProvider> {
  late RatingRepository _repository;
  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? LocalRatingRepository(LocalRatingStorage());
  }

  @override
  void didUpdateWidget(RatingRepositoryProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _repository =
          widget.repository ?? LocalRatingRepository(LocalRatingStorage());
    }
  }

  @override
  Widget build(BuildContext context) =>
      RatingRepositoryScope(repository: _repository, child: widget.child);
}

class RatingRepositoryScope extends InheritedWidget {
  const RatingRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });
  final RatingRepository repository;
  static RatingRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<RatingRepositoryScope>()
      ?.repository;
  @override
  bool updateShouldNotify(RatingRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
