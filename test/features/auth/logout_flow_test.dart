import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/main.dart';

import '../../support/map_test_support.dart';

void main() {
  testWidgets('Keluar dari tab Profil kembali ke Login', (tester) async {
    await pumpTestWidget(tester, const NebengDongApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk cepat (Dev)'));
    await tester.pumpAndSettle();
    expect(find.text('Hai, Mikail!'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profil'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Opsi demo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Keluar dari akun?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Gas Masuk!'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
