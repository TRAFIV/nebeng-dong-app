import 'package:flutter/material.dart';

import 'features/reputation/data/rating_repository.dart';
import 'features/reputation/data/local_rating_repository.dart';
import 'features/reputation/views/rating_history_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    RatingDemoApp(
      repository: LocalRatingRepository(
        LocalRatingStorage(),
        failNextSave: const bool.fromEnvironment('SIMULATE_RATING_FAILURE'),
      ),
    ),
  );
}

class RatingDemoApp extends StatelessWidget {
  const RatingDemoApp({super.key, required this.repository, this.theme});
  final RatingRepository repository;
  final ThemeData? theme;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Nebeng Dong · Rating',
    debugShowCheckedModeBanner: false,
    theme: theme ?? AppTheme.light,
    home: RatingHistoryScreen(repository: repository),
  );
}
