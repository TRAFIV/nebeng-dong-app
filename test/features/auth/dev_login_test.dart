import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/main.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/features/auth/views/login_screen.dart';
import 'package:praktikum_mobile/theme/app_theme.dart';

import '../../support/map_test_support.dart';

void main() {
  testWidgets('Masuk cepat dev tanpa email/password mengganti route Login', (
    tester,
  ) async {
    await pumpTestWidget(tester, const NebengDongApp());
    final shortcut = find.text('Masuk cepat (Dev)');
    expect(shortcut, findsOneWidget);
    await tester.ensureVisible(shortcut);
    await tester.tap(shortcut);
    await tester.pumpAndSettle();
    expect(find.text('Hai, Mikail!'), findsOneWidget);
    expect(find.text('Gas Masuk!'), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('Login dev responsif 320px, teks $scale dengan keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await pumpTestWidget(
        tester,
        MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: const LoginScreen(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        MediaQuery.textScalerOf(tester.element(find.text('Masuk cepat (Dev)')))
            .scale(1),
        scale,
      );
      await tester.ensureVisible(find.text('Masuk cepat (Dev)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masuk cepat (Dev)'));
      await tester.pumpAndSettle();
      expect(find.text('Hai, Mikail!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
