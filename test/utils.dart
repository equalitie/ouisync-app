import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/locale.dart';
import 'package:ouisync_app/app/cubits/mount.dart';
import 'package:ouisync_app/app/cubits/power_control.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/mounter.dart';
import 'package:ouisync_app/app/utils/platform/platform_window_manager.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart' show Session, SessionKind;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
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

/// Helper to setup and teardown common widget test dependencies
class TestDependencies {
  TestDependencies._(
    this.session,
    this.settings,
    this.nativeChannels,
    this.powerControl,
    this.reposCubit,
    this.mountCubit,
    this.localeCubit,
  );

  static Future<TestDependencies> create() async {
    final configPath = join(
      (await getApplicationSupportDirectory()).path,
      'config',
    );

    final session = Session.create(
      kind: SessionKind.unique,
      configPath: configPath,
    );

    final settings = await Settings.init(MasterKey.random());
    final nativeChannels = NativeChannels(session);
    final powerControl = PowerControl(
      session,
      settings,
      connectivity: FakeConnectivity(),
    );
    final reposCubit = ReposCubit(
      cacheServers: CacheServers.disabled,
      nativeChannels: nativeChannels,
      session: session,
      settings: settings,
      mounter: Mounter(session),
    );

    final mountCubit = MountCubit(reposCubit.mounter);
    final localeCubit = LocaleCubit(settings);

    return TestDependencies._(
      session,
      settings,
      nativeChannels,
      powerControl,
      reposCubit,
      mountCubit,
      localeCubit,
    );
  }

  Future<void> dispose() async {
    await localeCubit.close();
    await mountCubit.close();
    await reposCubit.close();
    await powerControl.close();
    await session.close();
  }

  MainPage createMainPage({
    Stream<List<SharedMediaFile>>? receivedMedia,
  }) =>
      MainPage(
        localeCubit: localeCubit,
        mountCubit: mountCubit,
        nativeChannels: nativeChannels,
        packageInfo: fakePackageInfo,
        powerControl: powerControl,
        receivedMedia: receivedMedia ?? Stream.empty(),
        reposCubit: reposCubit,
        session: session,
        settings: settings,
        windowManager: FakeWindowManager(),
      );

  final Session session;
  final Settings settings;
  final NativeChannels nativeChannels;
  final PowerControl powerControl;
  final ReposCubit reposCubit;
  final MountCubit mountCubit;
  final LocaleCubit localeCubit;
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
  final Stream<List<ConnectivityResult>> onConnectivityChanged = Stream.empty();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      Future.value([ConnectivityResult.none]);
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
  StateObserver._(this._prev);

  final BlocObserver? _prev;
  final _completer = Completer<BlocBase<State>>();

  /// Waits until the observed bloc transitions to a state for which the given predicate returns
  /// true. If it's already in such state, returns immediately.
  Future<void> waitUntil(
    bool Function(State) f, {
    Duration timeout = _timeout,
  }) =>
      _completer.future
          .timeout(timeout)
          .then((bloc) => bloc.waitUntil(f, timeout: timeout));

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);

    if (bloc is BlocBase<State>) {
      _completer.complete(bloc);
    }

    _prev?.onCreate(bloc);
  }

  static StateObserver<State> install<State>() {
    final prev = Bloc.observer;
    final next = StateObserver<State>._(prev);
    Bloc.observer = next;
    return next;
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

String get _testDirPath {
  var path = (goldenFileComparator as LocalFileComparator).basedir.path;

  if (Platform.isWindows) {
    // For some reason the `path` on windows looks like `/c:/...`
    if (path[0] == '/') {
      path = path.substring(1);
    }
  }

  return path;
}

const _timeout = Duration(seconds: 10);
