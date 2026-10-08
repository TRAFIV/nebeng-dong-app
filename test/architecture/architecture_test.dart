import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> dartFiles() =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
String normalized(File file) => file.path.replaceAll('\\', '/');

void main() {
  test('ViewModels have no UI, navigation or ViewModel dependencies', () {
    final files = dartFiles()
        .where((f) => normalized(f).contains('/viewmodels/'))
        .toList();
    expect(files.length, greaterThanOrEqualTo(9));
    final forbidden = RegExp(
      r"""(?:import|export)\s+['"][^'"]*(?:views/|widgets/|theme/|routes/|viewmodels/|flutter/material|flutter/widgets)|\b(?:BuildContext|Navigator|ScaffoldMessenger|TextEditingController|GlobalKey)\b""",
    );
    for (final file in files) {
      final source = file.readAsStringSync().replaceAll(
        RegExp(r'//[^\r\n]*'),
        '',
      );
      expect(forbidden.hasMatch(source), isFalse, reason: file.path);
    }
  });
  test('All nested Views delegate data commands to ViewModels', () {
    final files = dartFiles()
        .where((f) => normalized(f).contains('/views/'))
        .toList();
    expect(files.length, greaterThanOrEqualTo(9));
    final forbidden = RegExp(
      r'\.(?:fetchRides|post|updateOwned|deleteOwned|acceptBooking|routeBetween|searchPlaces|reverseGeocode)\s*\(|\bsetState\s*\(',
    );
    for (final file in files) {
      expect(
        forbidden.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
  test('Active source cannot import archived driver implementation', () {
    for (final file in dartFiles().where(
      (f) => !normalized(f).contains('/legacy/'),
    )) {
      expect(
        RegExp(r"""(?:import|export)\s+['"][^'"]*legacy/""")
            .hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
  test('Passenger repository exposes no driver command', () {
    final contract = File('lib/features/ride_search/data/ride_repository.dart')
        .readAsStringSync();
    expect(
      RegExp(r'\b(?:post|updateOwned|deleteOwned|acceptBooking)\s*\(')
          .hasMatch(contract),
      isFalse,
    );
  });
  test('Core and feature boundaries exist; obsolete DI export removed', () {
    for (final path in [
      'lib/core/view_model.dart',
      'lib/core/di/map_service_scope.dart',
      'lib/core/di/ride_repository_scope.dart',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    for (final module in [
      'auth',
      'ride_search',
      'booking',
      'costs',
      'reputation',
    ]) {
      expect(Directory('lib/features/$module').existsSync(), isTrue);
    }
    expect(File('lib/widgets/map_service_scope.dart').existsSync(), isFalse);
  });
}
