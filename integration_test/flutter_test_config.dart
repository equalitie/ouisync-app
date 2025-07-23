import 'dart:async';

import '../test/sandbox.dart';

/// See the "Per directory hierarchy" section in
/// https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html for more info.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final sandbox = await Sandbox.setUp();

  try {
    await testMain();
  } finally {
    await sandbox.tearDown();
  }
}
