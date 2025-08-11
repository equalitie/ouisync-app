import 'dart:async';

import 'package:ouisync_app/app/utils/flavor.dart';

/// See the "Per directory hierarchy" section in
/// https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html for more info.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Flavor.current = Flavor.itest;
  await testMain();
}
