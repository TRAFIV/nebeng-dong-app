import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_mobile/shared/widgets/mascot_profile_badge.dart';
import 'package:praktikum_mobile/shared/widgets/user_avatar.dart';
import 'package:praktikum_mobile/theme/app_motion.dart';

Widget _badge() => const MaterialApp(
  home: Scaffold(
    body: Center(child: MascotProfileBadge(name: 'Mikail')),
  ),
);

void main() {
  testWidgets('tanpa gerak berulang: diam di sisi Si Titik', (tester) async {
    await tester.pumpWidget(_badge());
    await tester.pump(const Duration(seconds: 6));
    expect(find.byType(UserAvatar), findsNothing);
  });

  testWidgets('berputar ke avatar lalu kembali ke Si Titik', (tester) async {
    AppMotion.ambientEnabled = true;
    addTearDown(() => AppMotion.ambientEnabled = false);
    await tester.pumpWidget(_badge());
    expect(find.byType(UserAvatar), findsNothing);
    await tester.pump(const Duration(milliseconds: 5800)); // sudah berputar
    expect(find.byType(UserAvatar), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000)); // kembali
    expect(find.byType(UserAvatar), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
