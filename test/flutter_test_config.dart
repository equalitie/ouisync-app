import 'dart:async';

import 'utils.dart';

/// Automatically invokes each test inside `testEnv`.
///
/// See the "Per directory hierachy" section in
/// https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html for more info.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await testEnv(testMain);
}
