import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/utils/locale.dart';
import 'dart:ui' show Locale;

void main() {
  setUp(() async {});

  tearDown(() async {});

  test('locale_serialization', () async {
    testCase('en');
    testCase('en_US');
    testCase('en_US_ABC');
    testCase('en__ABC');
  });
}

void testCase(String orig) {
  final locale = deserializeLocale(orig);
  expect(locale, isNotNull);
  if (locale != null) {
    final serialized = serializeLocale(locale);
    expect(orig, serialized);
  }
}
