import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/utils/platform/platform_window_manager.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Setup the test environment and run `callback` inside it.
///
/// This can be applied automatically using `flutter_test_config.dart`.
Future<void> testEnv(FutureOr<void> Function() callback) async {
  late Directory tempDir;
  late BlocObserver origBlocObserver;

  setUp(() async {
    origBlocObserver = Bloc.observer;

    final dir = await Directory.systemTemp.createTemp();
    PathProviderPlatform.instance = _FakePathProviderPlatform(dir);
    SharedPreferences.setMockInitialValues({});

    tempDir = dir;
  });

  tearDown(() async {
    Bloc.observer = origBlocObserver;

    try {
      await tempDir.delete(recursive: true);
    } on PathAccessException catch (_) {
      // This sometimes happen on the CI on windows. It seems to be caused by another process
      // accessing the temp directory for some reason. It probably doesn't indicate a problem in
      // the code under test so it should be safe to ignore it.
    }
  });

  await callback();
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  final Directory root;

  _FakePathProviderPlatform(this.root);

  @override
  Future<String?> getApplicationSupportPath() =>
      Future.value(join(root.path, 'application-support'));

  @override
  Future<String?> getApplicationDocumentsPath() =>
      Future.value(join(root.path, 'application-documents'));

  @override
  Future<String?> getTemporaryPath() =>
      Future.value(join(root.path, 'temporary'));
}

/// Build `MaterialApp` to host the widget under test.
Widget testApp(
  Widget child, {
  List<NavigatorObserver> navigatorObservers = const [],
}) =>
    MaterialApp(
      home: Scaffold(body: child),
      localizationsDelegates: const [S.delegate],
      navigatorObservers: navigatorObservers,
    );

/// Fake window manager
class FakeWindowManager extends PlatformWindowManager {
  @override
  void onClose(CloseHandler handler) {}

  @override
  Future<void> setTitle(String title) => Future.value();

  @override
  Future<void> initSystemTray() => Future.value();
}

/// Fake Connectivity
class FakeConnectivity implements Connectivity {
  @override
  final Stream<ConnectivityResult> onConnectivityChanged = Stream.empty();

  @override
  Future<ConnectivityResult> checkConnectivity() =>
      Future.value(ConnectivityResult.none);
}

/// Fake PackageInfo
PackageInfo fakePackageInfo = PackageInfo(
  appName: 'ouisync.test',
  packageName: 'org.equalitie.ouisync.test',
  version: '1.0.0',
  buildNumber: '42',
  buildSignature: '',
);

/// Observer for bloc/cubit state. Useful when we don't have direct access to the bloc/cubit we
/// want to observe. If we do have access, prefer to use `BlocBaseExtension.waitUntil`.
class StateObserver<State> extends BlocObserver {
  final _completer = Completer<BlocBase<State>>();

  /// Waits until the observed bloc transitions to a state for which the given predicate returns
  /// true. If it's already in such state, returns immediately.
  Future<void> waitUntil(
    bool Function(State) f, {
    Duration timeout = _timeout,
  }) =>
      _completer.future.then((bloc) => bloc.waitUntil(f, timeout: timeout));

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);

    if (bloc is BlocBase<State>) {
      _completer.complete(bloc);
    }
  }
}

class NavigationObserver extends NavigatorObserver {
  final _controller = StreamController<int>.broadcast();
  int _depth = 0;

  @override
  void didPush(Route route, Route? previousRoute) {
    _depth += 1;
    _controller.add(_depth);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _depth -= 1;
    _controller.add(_depth);
  }

  Future<void> waitForDepth(
    int expected, {
    Duration timeout = _timeout,
  }) async {
    if (_depth == expected) {
      return;
    }

    await _controller.stream
        .where((depth) => depth == expected)
        .timeout(_timeout)
        .first;
  }
}

extension WidgetTesterExtension on WidgetTester {
  /// Take a screenshot of the widget under test. Useful to debug tests. Note that by default all
  /// text is rendered using a font that shows all letters as rectangles. See the "Including Fonts"
  /// section in https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html for more
  /// details.
  ///
  /// This Code is taken from https://github.com/flutter/flutter/issues/129623.
  Future<void> takeScreenshot([String name = 'screenshot']) async {
    try {
      final finder = find.bySubtype<Widget>().first;
      final image = await captureImage(finder.evaluate().single);
      final bytes = (await image.toByteData(format: ImageByteFormat.png))!
          .buffer
          .asUint8List();

      final path = join(_testDirPath, 'screenshots', '$name.png');

      await Directory(dirname(path)).create(recursive: true);

      debugPrint('screenshot saved to $path');

      await File(path).writeAsBytes(bytes);
    } catch (e) {
      debugPrint('Failed to save screenshot: $e');
    }
  }
}

extension BlocBaseExtension<State> on BlocBase<State> {
  /// Waits until this cubit transitions to a state for which the given predicate returns true. If
  /// it's already in such state, returns immediately.
  Future<void> waitUntil(
    bool Function(State) f, {
    Duration timeout = _timeout,
  }) async {
    if (f(state)) {
      return;
    }

    await stream.where(f).timeout(timeout).first;
  }
}

String get _testDirPath =>
    (goldenFileComparator as LocalFileComparator).basedir.path;

const _timeout = Duration(seconds: 10);
