import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Setup the test environment and run `callback` inside it.
Future<void> testEnv(FutureOr<void> Function() callback) async {
  Directory? tempDir;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp();
    PathProviderPlatform.instance = _TestPathProviderPlatform(dir);
    SharedPreferences.setMockInitialValues({});

    tempDir = dir;
  });

  tearDown(() async {
    try {
      await tempDir?.delete(recursive: true);
    } on PathAccessException catch (_) {
      // This sometimes happen on the CI on windows. It seems to be caused by another process
      // accessing the temp directory for some reason. It probably doesn't indicate a problem in
      // the code under test so it should be safe to ignore it.
    }
  });

  await callback();
}

class _TestPathProviderPlatform extends PathProviderPlatform {
  final Directory root;

  _TestPathProviderPlatform(this.root);

  @override
  Future<String?> getApplicationSupportPath() async =>
      join(root.path, 'application-support');

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      join(root.path, 'application-documents');
}
