import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Setup the test environment and run `callback` inside it.
///
/// This can be applied automatically using `flutter_test_config.dart`.
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

extension WidgetTesterExtension on WidgetTester {
  /// Take a screenshot of the widget under test. Useful to debug tests. Note that by default all
  /// text is rendered using a font that shows all letters as rectangles. See the "Including Fonts"
  /// section in https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html for more
  /// details.
  ///
  /// This Code is taken from https://github.com/flutter/flutter/issues/129623.
  Future<void> takeScreenshot([String name = 'screenshot']) async {
    final finder = find.bySubtype<Widget>().first;
    final image = await captureImage(finder.evaluate().single);
    final bytes = (await image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();

    final path = join(_testDirPath, 'screenshots', '$name.png');

    await Directory(dirname(path)).create(recursive: true);

    debugPrint('screenshot saved to $path');

    await File(path).writeAsBytes(bytes);
  }
}

extension CubitExtension<State> on Cubit<State> {
  /// Waits until this cubit transitions to a state for which the given predicate returns true. If
  /// it's already in such state, returns immediately.
  Future<void> waitUntil(
    bool Function(State) f, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (f(state)) {
      return;
    }

    await stream.where(f).timeout(timeout).first;
  }
}

String get _testDirPath =>
    (goldenFileComparator as LocalFileComparator).basedir.path;
