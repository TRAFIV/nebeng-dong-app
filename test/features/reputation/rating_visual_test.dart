import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/main_rating.dart';
import 'package:praktikum_mobile/features/reputation/data/local_rating_repository.dart';

import '../../support/app_fonts.dart';
import 'rating_workflow_test.dart' show TestStorage, openRating;

void main() {
  testWidgets('rating screens at 360 x 800', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await loadAppFonts();
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('capture'),
        child: RatingDemoApp(repository: LocalRatingRepository(TestStorage())),
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
