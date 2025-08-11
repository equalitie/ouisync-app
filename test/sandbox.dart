import 'dart:io';

import 'package:path/path.dart' show join;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sandboxed environment for the app when running under tests.
abstract class Sandbox {
  static Future<Sandbox> setUp() async {
    SharedPreferences.setMockInitialValues({});

    if (Platform.isAndroid || Platform.isIOS) {
      return _NativeSandbox();
    } else {
      return await _TempDirSandbox.setUp();
    }
  }

  Future<void> tearDown();
}

// Dummy implementation that does nothing. Used on platforms that already natively sanbox their
// apps.
class _NativeSandbox extends Sandbox {
  @override
  Future<void> tearDown() => Future.value();
}

// Implementation that puts all files in a temporary directory wich is removed on teardown.
class _TempDirSandbox extends Sandbox {
  final Directory tempDir;

  _TempDirSandbox._(this.tempDir);

  static Future<_TempDirSandbox> setUp() async {
    final tempDir = await Directory.systemTemp.createTemp();

    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir);

    return _TempDirSandbox._(tempDir);
  }

  @override
  Future<void> tearDown() async {
    await deleteTempDir(tempDir);
  }
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  final Directory root;

  _FakePathProviderPlatform(this.root);

  @override
  Future<String?> getApplicationSupportPath() =>
      Future.value(join(root.path, 'support'));

  @override
  Future<String?> getApplicationDocumentsPath() =>
      Future.value(join(root.path, 'documents'));

  @override
  Future<String?> getDownloadsPath() => Future.value(null);

  @override
  Future<String?> getTemporaryPath() => Future.value(join(root.path, 'temp'));
}

Future<void> deleteTempDir(Directory dir) async {
  try {
    await dir.delete(recursive: true);
  } on PathAccessException {
    // This sometimes happens on the CI on windows. It seems to be caused by another process
    // accessing the temp directory for some reason. It probably doesn't indicate a problem in
    // the code under test so it should be safe to ignore it.
  } on PathNotFoundException {
    // This shouldn't happen but it still sometimes does. Unknown why. It doesn't really affect
    // the tests so we ignore it.
  }
}
