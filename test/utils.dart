import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_app/app/cubits/locale.dart';
import 'package:ouisync_app/app/cubits/mount.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/dirs.dart';
import 'package:ouisync_app/app/utils/platform/platform_window_manager.dart';
import 'package:ouisync_app/app/utils/random.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart'
    show Session, SetLocalSecretKeyAndSalt, initLog;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';
export 'package:flutter/foundation.dart' show debugPrint;

final _loggy = appLogger("TestHelper");

/// Setup the test environment and run `callback` inside it.
///
/// This can be applied automatically using `flutter_test_config.dart`.
Future<void> testEnv(FutureOr<void> Function() callback) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (Platform.environment.containsKey("DEMANGLE_STACK")) {
    // https://api.flutter.dev/flutter/foundation/FlutterError/demangleStackTrace.html
    FlutterError.demangleStackTrace = (StackTrace stack) {
      if (stack is Trace) {
        return stack.vmTrace;
      }
      if (stack is Chain) {
        return stack.toTrace().vmTrace;
      }
      return stack;
    };
  }

  initLog(
    callback: (level, message) => debugPrint(
        '${DateTime.now()} ${level.name.toUpperCase().padRight(5)} $message'),
  );

  Loggy.initLoggy();

  late Directory tempDir;
  late BlocObserver origBlocObserver;

  setUp(() async {
    origBlocObserver = Bloc.observer;

    tempDir = await Directory.systemTemp.createTemp();

    final platformDir = Directory(join(tempDir.path, 'platform'));
    await platformDir.create();
    PathProviderPlatform.instance = _FakePathProviderPlatform(platformDir);

    final shared = Directory(join(tempDir.path, 'shared')).create();
    final mount = Directory(join(tempDir.path, 'mount')).create();
    final native =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    native.setMockMethodCallHandler(
        MethodChannel('org.equalitie.ouisync/native'), (call) async {
      switch (call.method) {
        case 'getSharedDir':
          return (await shared).path;
        case 'getMountRootDirectory':
          return (await mount).path;
        default:
          throw PlatformException(
              code: 'OS06',
              message: 'Method "${call.method}" not exported by host');
      }
    });

    ConnectivityPlatform.instance = _FakeConnectivityPlatform();

    // TODO: add mock for 'org.equalitie.ouisync/backend' once the tests are updated to use channels

    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    Bloc.observer = origBlocObserver;

    try {
      await tempDir.delete(recursive: true);
    } on PathAccessException {
      // This sometimes happens on the CI on windows. It seems to be caused by another process
      // accessing the temp directory for some reason. It probably doesn't indicate a problem in
      // the code under test so it should be safe to ignore it.
    } on PathNotFoundException {
      // This shouldn't happen but it still sometimes does. Unknown why. It doesn't really affect
      // the tests so we ignore it.
    } catch (exception) {
      _loggy.error("Exception during temporary directory removal: $exception");
      rethrow;
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
    this.reposCubit,
    this.mountCubit,
    this.localeCubit,
    this.dirs,
  );

  static Future<TestDependencies> create() async {
    final appDir = await getApplicationSupportDirectory();
    await appDir.create(recursive: true);

    final dirs = Dirs(root: appDir.path);

    final session = await Session.create(configPath: dirs.config);

    await session.setStoreDir(dirs.defaultStore);

    final settings = await Settings.init(MasterKey.random());
    final nativeChannels = NativeChannels();
    final reposCubit = ReposCubit(
      cacheServers: CacheServers(session),
      nativeChannels: nativeChannels,
      session: session,
      settings: settings,
    );

    final mountCubit = MountCubit(session, dirs);
    final localeCubit = LocaleCubit(settings);

    return TestDependencies._(
      session,
      settings,
      nativeChannels,
      reposCubit,
      mountCubit,
      localeCubit,
      dirs,
    );
  }

  Future<void> dispose() async {
    await localeCubit.close();
    await mountCubit.close();
    await reposCubit.close();
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
        receivedMedia: receivedMedia ?? Stream.empty(),
        reposCubit: reposCubit,
        session: session,
        settings: settings,
        windowManager: FakeWindowManager(),
        dirs: dirs,
      );

  final Session session;
  final Settings settings;
  final NativeChannels nativeChannels;
  final ReposCubit reposCubit;
  final MountCubit mountCubit;
  final LocaleCubit localeCubit;
  final Dirs dirs;
}

class _FakeConnectivityPlatform extends ConnectivityPlatform {
  @override
  final Stream<List<ConnectivityResult>> onConnectivityChanged = Stream.empty();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      Future.value([ConnectivityResult.none]);
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
  Future<void> takeScreenshot(
      {String name = 'screenshot', Element? element}) async {
    try {
      if (element == null) {
        // If no element is given, take the screenshot of the topmost widget.
        final finder = find.bySubtype<Widget>().first;
        element = finder.evaluate().single;
      }

      final image = await captureImage(element);
      final bytes = (await image.toByteData(format: ImageByteFormat.png))!
          .buffer
          .asUint8List();

      final path = join(_testDirPath, 'screenshots', '$name.png');

      await Directory(dirname(path)).create(recursive: true);
      await File(path).writeAsBytes(bytes);

      _loggy.info('screenshot saved to $path');
    } catch (e) {
      _loggy.error('Failed to save screenshot: $e');
    }
  }

  // This is useful to observe the screen when things are still moving.
  Future<void> takeNScreenshots(int n, String name) async {
    assert(n > 0 && n < 1000); // sanity
    for (int i = 0; i < n; i++) {
      await takeScreenshot(name: "$name-$i");
      await pump(Duration(milliseconds: 200));
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  // Invoke this somewhere at the beginning of a test so that the above
  // `takeScreenshot` renders normal fonts instead of squares.
  Future<void> loadFonts() async {
    // TODO: Path on other platforms.
    final fontFile = File(
        '/usr/lib/ouisync/data/flutter_assets/packages/golden_toolkit/fonts/Roboto-Regular.ttf');

    if (!(await fontFile.exists())) {
      _loggy.error(
          "Failed to load fonts, the file ${fontFile.path} does not exist");
      return;
    }

    final fontData = fontFile
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));

    final fontLoader = FontLoader('Roboto')..addFont(fontData);
    await fontLoader.load();
  }

  // A workaround for the issue with pumpAndSettle as described here
  // https://stackoverflow.com/questions/67186472/error-pumpandsettle-timed-out-maybe-due-to-riverpod
  Future<Finder> pumpUntilFound(Finder finder,
      {Duration? timeout, Duration? pumpTime}) async {
    final found = await pumpUntilNonNull(
        () => finder.tryEvaluate() ? finder : null,
        timeout: timeout,
        pumpTime: pumpTime);
    // Too often when the above first finds a widget it's outside of the screen
    // area and tapping on it would generate a warning. After this
    // `pumpAndSettle` the widget finds its place inside the screen.
    await pumpAndSettle();
    return found;
  }

  Future<void> pumpUntil(bool Function() predicate,
      {Duration? timeout, Duration? pumpTime}) async {
    await pumpUntilNonNull(() => predicate() ? true : null,
        timeout: timeout, pumpTime: pumpTime);
    return;
  }

  Future<T> pumpUntilNonNull<T>(T? Function() f,
      {Duration? timeout, Duration? pumpTime}) async {
    timeout ??= Duration(seconds: 5);
    pumpTime ??= Duration(milliseconds: 100);

    final stopwatch = Stopwatch();
    stopwatch.start();

    while (stopwatch.elapsed <= timeout) {
      // Hack: it seems the `pump` function "pumps" only when something is
      // moving on the screen, so this delay is needed when we're waiting for
      // async actions which don't generate any GUI changes.
      await Future.delayed(pumpTime);

      final retval = f();
      if (retval != null) {
        return retval;
      }

      await pump(pumpTime);
    }

    throw "pumpUntilNotNull timeout";
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

SetLocalSecretKeyAndSalt randomSetLocalSecret() =>
    SetLocalSecretKeyAndSalt(key: randomSecretKey(), salt: randomSalt());

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
