import 'package:praktikum_mobile/theme/app_theme.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/main_rating.dart';
import 'package:praktikum_mobile/features/reputation/data/local_rating_repository.dart';

import 'rating_workflow_test.dart' show TestStorage, openRating;

ThemeData _reviewTheme() {
  final theme = AppTheme.light;
  final label = WidgetStatePropertyAll(
    AppTextStyles.labelLarge.copyWith(fontFamily: 'Roboto'),
  );
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: theme.appBarTheme.titleTextStyle!.copyWith(
        fontFamily: 'Roboto',
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: theme.filledButtonTheme.style!.copyWith(textStyle: label),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: theme.outlinedButtonTheme.style!.copyWith(textStyle: label),
    ),
    textButtonTheme: TextButtonThemeData(
      style: theme.textButtonTheme.style!.copyWith(textStyle: label),
    ),
    chipTheme: theme.chipTheme.copyWith(
      labelStyle: theme.chipTheme.labelStyle!.copyWith(fontFamily: 'Roboto'),
    ),
  );
}

void main() {
  testWidgets('rating screens at 360 x 800', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fontLoader = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/roboto-medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf'));
    await fontLoader.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('capture'),
        child: RatingDemoApp(
          theme: _reviewTheme(),
          repository: LocalRatingRepository(TestStorage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('capture')),
      matchesGoldenFile('goldens/rating_history.png'),
    );
    await openRating(tester, 'Nilai Pengemudi, Yuk!');
    await tester.tap(find.byKey(const ValueKey('star-5')));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('capture')),
      matchesGoldenFile('goldens/rating_form.png'),
    );
    await tester.tap(find.byKey(const ValueKey('star-4')));
    await tester.tap(find.text('Kirim Rating!'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    final saved = find.byKey(const ValueKey('saved-trip-30sep'));
    expect(
      find.descendant(of: saved, matching: find.byIcon(Icons.star_rounded)),
      findsNWidgets(4),
    );
    expect(
      find.descendant(
        of: saved,
        matching: find.byIcon(Icons.star_outline_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: saved,
        matching: find.byKey(const ValueKey('trip-trip-30sep')),
      ),
      findsOneWidget,
    );
    await expectLater(
      find.byKey(const ValueKey('capture')),
      matchesGoldenFile('goldens/rating_saved.png'),
    );
  });
}
