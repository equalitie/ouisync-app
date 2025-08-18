import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_app/app/cubits/locale.dart';
import 'package:ouisync_app/app/cubits/mount.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/cubits/error.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/dirs.dart';
import 'package:ouisync_app/app/utils/log.dart' as log;
import 'package:ouisync_app/app/utils/platform/platform.dart';
import 'package:ouisync_app/app/utils/random.dart';
import 'package:ouisync_app/app/utils/utils.dart'
    show CacheServers, MasterKey, Settings;
import 'package:ouisync_app/generated/l10n.dart';
import 'package:ouisync/ouisync.dart'
    show Session, SetLocalSecretKeyAndSalt, Server;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:stack_trace/stack_trace.dart';

import 'sandbox.dart';
export 'package:flutter/foundation.dart' show debugPrint;

final _loggy = log.named("TestHelper");
const String artifactsDirName = 'artifacts';

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

  Loggy.initLoggy();

  late Sandbox sandbox;
  late BlocObserver origBlocObserver;

  setUp(() async {
    origBlocObserver = Bloc.observer;
    sandbox = await Sandbox.setUp();

    ConnectivityPlatform.instance = _FakeConnectivityPlatform();

    // TODO: add mock for 'org.equalitie.ouisync/backend' once the tests are updated to use channels
  });

  tearDown(() async {
    await sandbox.tearDown();
    Bloc.observer = origBlocObserver;
  });

  await callback();
}

/// Helper to setup and teardown common widget test dependencies
class TestDependencies {
  TestDependencies._(
    this.server,
    this.session,
    this.settings,
    this.reposCubit,
    this.mountCubit,
    this.localeCubit,
    this.errorCubit,
    this.dirs,
  );

  static Future<TestDependencies> create() async {
    final defaultMountDir = await getTemporaryDirectory().then(
      (dir) => join(dir.path, 'mount'),
    );

    final dirs = await Dirs.init(defaultMount: defaultMountDir);

    final server = Server.create(configPath: dirs.config);
    await server.initLog();
    await server.start();

    final session = await Session.create(configPath: dirs.config);

    await session.setStoreDir(dirs.defaultStore);

    final errorCubit = ErrorCubit(session);
    final settings = await Settings.init(MasterKey.random());
    final mountCubit = MountCubit(session, dirs)..init();
    final reposCubit = ReposCubit(
      cacheServers: CacheServers(session),
      session: session,
      settings: settings,
      mountCubit: mountCubit,
    );

    final localeCubit = LocaleCubit(settings);

    return TestDependencies._(
      server,
      session,
      settings,
      reposCubit,
      mountCubit,
      localeCubit,
      errorCubit,
      dirs,
    );
  }

  Future<void> dispose() async {
    await localeCubit.close();
    await mountCubit.close();
    await reposCubit.close();
    await errorCubit.close();
    await session.close();
    await server.stop();
  }

  MainPage createMainPage({Stream<List<SharedMediaFile>>? receivedMedia}) =>
      MainPage(
        localeCubit: localeCubit,
        mountCubit: mountCubit,
        packageInfo: fakePackageInfo,
        receivedMedia: receivedMedia ?? Stream.empty(),
        reposCubit: reposCubit,
        errorCubit: errorCubit,
        session: session,
        settings: settings,
        windowManager: FakeWindowManager(),
        dirs: dirs,
      );

  final Server server;
  final Session session;
  final Settings settings;
  final ReposCubit reposCubit;
  final MountCubit mountCubit;
  final LocaleCubit localeCubit;
  final ErrorCubit errorCubit;
  final Dirs dirs;
}

class _FakeConnectivityPlatform extends ConnectivityPlatform {
  @override
  final Stream<List<ConnectivityResult>> onConnectivityChanged = Stream.empty();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      Future.value([ConnectivityResult.none]);
}

/// Build `MaterialApp` to host the widget under test.
Widget testApp(
  Widget child, {
  List<NavigatorObserver> navigatorObservers = const [],
}) => MaterialApp(
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
  }) => _completer.future
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

  Future<void> waitForDepth(int expected, {Duration timeout = _timeout}) async {
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
  Future<void> takeScreenshot(String name, {Element? element}) async {
    try {
      if (element == null) {
        // If no element is given, take the screenshot of the topmost widget.
        final finder = find.bySubtype<Widget>().first;
        element = finder.evaluate().single;
      }

      final image = await captureImage(element);
      final bytes = (await image.toByteData(
        format: ImageByteFormat.png,
      ))!.buffer.asUint8List();

      final path = join(_testDirPath, artifactsDirName, '$name.png');

      await Directory(dirname(path)).create(recursive: true);
      await File(path).writeAsBytes(bytes);

      _loggy.info('screenshot saved to $path');
    } catch (e) {
      _loggy.error('Failed to save screenshot: $e');
    }
  }

  // This is useful to observe the screen when things are still moving.
  Future<void> takeScreenshots(String name, int n) async {
    assert(n > 0 && n < 1000); // sanity
    for (int i = 0; i < n; i++) {
      await takeScreenshot("$name-$i");
      await pump(Duration(milliseconds: 100));
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  // Write the whole element tree to a file. Similar to
  // https://api.flutter.dev/flutter/widgets/debugDumpApp.html
  Future<void> dumpTree(String name) async {
    final String tree;
    if (WidgetsBinding.instance.rootElement != null) {
      tree = WidgetsBinding.instance.rootElement!.toStringDeep();
    } else {
      tree = '<no tree currently mounted>';
    }
    final path = join(_testDirPath, artifactsDirName, "$name.dump");
    await File(path).writeAsString(tree);
    _loggy.info('element tree dump saved to $path');
  }

  // Invoke this somewhere at the beginning of a test so that the above
  // `takeScreenshot` renders normal fonts instead of squares.
  Future<void> loadFonts() async {
    // TODO: Path on other platforms.
    final fontFile = File(
      '/usr/lib/ouisync/data/flutter_assets/packages/golden_toolkit/fonts/Roboto-Regular.ttf',
    );

    if (!(await fontFile.exists())) {
      _loggy.error(
        "Failed to load fonts, the file ${fontFile.path} does not exist",
      );
      return;
    }

    final fontData = fontFile.readAsBytes().then(
      (bytes) => ByteData.view(Uint8List.fromList(bytes).buffer),
    );

    final fontLoader = FontLoader('Roboto')..addFont(fontData);
    await fontLoader.load();
  }

  // A workaround for the issue with pumpAndSettle as described here
  // https://stackoverflow.com/questions/67186472/error-pumpandsettle-timed-out-maybe-due-to-riverpod
  Future<Finder> pumpUntilFound(
    Finder finder, {
    Duration? timeout,
    Duration? pumpTime,
  }) async {
    final found = await pumpUntilNonNull(
      () => finder.tryEvaluate() ? finder : null,
      timeout: timeout,
      pumpTime: pumpTime,
    );
    // Too often when the above first finds a widget it's outside of the screen
    // area and tapping on it would generate a warning. After this
    // `pumpAndSettle` the widget finds its place inside the screen.
    try {
      await pumpAndSettle();
    } catch (e) {
      // There may still be some progress indicator moving, ignore it.
    }
    return found;
  }

  Future<void> pumpUntilNotFound(Finder finder) async {
    await pumpUntil(() => !finder.tryEvaluate());
  }

  Future<void> pumpUntil(
    bool Function() predicate, {
    Duration? timeout,
    Duration? pumpTime,
  }) async {
    await pumpUntilNonNull(
      () => predicate() ? true : null,
      timeout: timeout,
      pumpTime: pumpTime,
    );
    return;
  }

  Future<T> pumpUntilNonNull<T>(
    T? Function() f, {
    Duration? timeout,
    Duration? pumpTime,
  }) async {
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

  Future<void> anxiousTap(Finder finder) async {
    await tap(finder);
    await pump(Duration(milliseconds: 10));
    if (wouldHit(finder)) {
      await tap(finder);
    }
  }

  // Check that the element represented by `finder` exists and tapping on it is
  // not obstructed by other element
  bool wouldHit(Finder finder) {
    final Iterable<Element> elements = finder.evaluate();
    if (elements.isEmpty) return false;
    if (elements.length > 1) throw "More than one such element";
    final element = elements.single;
    final RenderBox box = element.renderObject! as RenderBox;
    final viewId = viewOf(finder).viewId;
    final location = getCenter(finder, warnIfMissed: false);
    final result = hitTestOnBinding(location, viewId: viewId);
    return result.path.any((HitTestEntry entry) => entry.target == box);
  }

  Future<void> runAsyncDebug(Future<void> Function() callback) {
    return runAsync(() async {
      WidgetController.hitTestWarningShouldBeFatal = true;

      try {
        await callback();
      } catch (e) {
        try {
          await dumpTree(testDescription);
        } catch (de) {
          _loggy.debug("Failed to write debug dump: $de");
        }
        try {
          await takeScreenshot(testDescription);
        } catch (se) {
          _loggy.debug("Failed to take screenshot: $se");
        }
        rethrow;
      }
    });
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

String randomAsciiString(int length) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final rng = Random();

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rng.nextInt(chars.length)),
    ),
  );
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
