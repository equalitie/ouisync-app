import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ouisync/ouisync.dart' show NetworkDefaults, Server, Session;
import 'package:ouisync_app/app/cubits/store_dirs.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:path/path.dart' show join;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stream_transform/stream_transform.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart'
    show LocaleCubit, LocaleState, MountCubit, ReposCubit, ErrorCubit;
import 'pages/pages.dart';
import 'utils/constants.dart' show Constants;
import 'utils/dirs.dart';
import 'utils/log.dart' as log;
import 'utils/stage.dart';
import 'utils/platform/platform.dart' show PlatformWindowManager;
import 'utils/utils.dart'
    show
        AppLogger,
        AppTextThemeExtension,
        AppTypography,
        CacheServers,
        clearPreviewCache,
        loadAndMigrateSettings,
        Settings;
import 'widgets/flavor_banner.dart';
import 'widgets/media_receiver.dart';

/// The top level widget
class App extends StatefulWidget {
  const App([List<String> args = const []]) : this._(args, null);

  /// Create App for testing. Accepts `AppController` which can be used to explicitly stop the
  /// Ouisync service and await until the stop fully competes. Useful mainly for integration
  /// testing.
  @visibleForTesting
  const App.test({List<String> args = const [], AppController? controller})
    : this._(args, controller);

  const App._(this.args, this.controller);

  final List<String> args;

  @visibleForTesting
  final AppController? controller;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final components = _AppComponents.create(widget.args)
      .then((components) {
        widget.controller?._stopListener = () => components.destroy();
        return components;
      })
      .catchError((Object error, StackTrace stackTrace) {
        log.named('Startup').error('app startup failed:', error, stackTrace);
        throw error;
      });

  @override
  Widget build(BuildContext context) => FutureBuilder<_AppComponents>(
    future: components,
    builder: (context, snapshot) {
      final components = snapshot.data;

      if (snapshot.hasError) {
        return _buildMaterialApp(
          home: StartupErrorScreen(
            error: snapshot.error!,
            stackTrace: snapshot.stackTrace,
          ),
        );
      } else if (components != null) {
        return BlocBuilder<LocaleCubit, LocaleState>(
          bloc: components.localeCubit,
          builder: (context, localeState) => _buildMaterialApp(
            locale: localeState.currentLocale,
            home: _buildHomeWidget(components),
          ),
        );
      } else {
        return _buildMaterialApp(home: LoadingScreen());
      }
    },
  );

  Widget _buildMaterialApp({required Widget home, Locale? locale}) =>
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _setupAppThemeData(),
        locale: locale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: home,
        builder: (context, child) =>
            FlavorBanner(child: child ?? SizedBox.shrink()),
        navigatorObservers: [_AppNavigatorObserver()],
      );

  Widget _buildHomeWidget(_AppComponents components) => HomeWidget(
    dirs: components.dirs,
    server: components.server,
    session: components.session,
    windowManager: components.windowManager,
    settings: components.settings,
    localeCubit: components.localeCubit,
    errorCubit: components.errorCubit,
    storeDirsCubit: components.storeDirsCubit,
  );
}

@visibleForTesting
class AppController {
  Future<void> Function()? _stopListener;

  Future<void> stop() => _stopListener?.call() ?? Future.value();

  void dispose() {
    _stopListener = null;
  }
}

class _AppComponents {
  final PlatformWindowManager windowManager;
  final Dirs dirs;
  final Server server;
  final Session session;
  final Settings settings;
  final ErrorCubit errorCubit;
  final LocaleCubit localeCubit;
  final StoreDirsCubit storeDirsCubit;
  final StreamSubscription<void> _unresponsiveSubscription;

  _AppComponents._(
    this.windowManager,
    this.dirs,
    this.server,
    this.session,
    this.settings,
    this.errorCubit,
    this.localeCubit,
    this.storeDirsCubit,
    this._unresponsiveSubscription,
  );

  static Future<_AppComponents> create(List<String> args) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final windowManager = await PlatformWindowManager.create(
      args,
      packageInfo.appName,
    );

    final dirs = await Dirs.init();
    await log.init(dirs);

    unawaited(clearPreviewCache());

    final (server, session) = await _initServerAndSession(dirs, windowManager);
    final errorCubit = ErrorCubit(session);
    final settings = await loadAndMigrateSettings(session);
    final localeCubit = LocaleCubit(settings);
    final storeDirsCubit = StoreDirsCubit(session, dirs);
    final unresponsiveSubscription = session.serviceUnresponsive.listen(
      (_) => unawaited(_restartUnresponsiveService(server, session)),
    );

    return _AppComponents._(
      windowManager,
      dirs,
      server,
      session,
      settings,
      errorCubit,
      localeCubit,
      storeDirsCubit,
      unresponsiveSubscription,
    );
  }

  Future<void> destroy() async {
    await _unresponsiveSubscription.cancel();
    await localeCubit.close();
    await errorCubit.close();

    await session.close();
    await server.stop();
  }
}

// Several independent subscriptions on the same dead client tend to cross the unresponsive
// threshold within the same tick, each firing their own event - guard against the resulting
// pile-up of concurrent restarts (harmless in practice, since `server.start()` just rejects the
// extra ones with `serviceAlreadyRunning`, but there's no reason to let them race).
bool _restartingUnresponsiveService = false;

/// Restarts the native service when it appears to be gone rather than merely unreachable (see
/// `Session.serviceUnresponsive`). Observed after some iOS background/foreground cycles: the
/// service's local listener socket disappears outright (connection attempts get refused
/// immediately, forever) rather than just erroring once and recovering on its own, which means
/// the native process/thread died and nothing will bring it back except restarting it.
Future<void> _restartUnresponsiveService(Server server, Session session) async {
  if (_restartingUnresponsiveService) {
    return;
  }
  _restartingUnresponsiveService = true;

  final logger = log.named('');
  logger.warning('Native service appears unresponsive, restarting it');

  try {
    // The old handle may belong to a thread that's already dead, in which case this would hang
    // forever waiting for a reply that will never come - time-box it instead. `server.stop()`
    // clears its handle synchronously before awaiting anything, so `server.start()` below is
    // safe to call regardless of whether this completes, times out, or throws.
    await server.stop().timeout(const Duration(seconds: 2));
  } catch (e) {
    logger.debug('Ignoring failure stopping unresponsive server: $e');
  }

  try {
    await server.start();
    await session.resetConnection();
    logger.debug('Native service restarted');
  } catch (e, st) {
    logger.error('Failed to restart native service:', e, st);
  } finally {
    _restartingUnresponsiveService = false;
  }
}

Future<(Server, Session)> _initServerAndSession(
  Dirs dirs,
  PlatformWindowManager windowManager,
) async {
  final logger = log.named('');

  final server = Server.create(configPath: dirs.config);
  // Append the native (Rust) logs to the same file the Dart side logs to (see utils/log.dart),
  // so they show up in the app's Save/Share logs. On iOS/macOS the native side's stdout isn't
  // otherwise captured anywhere once the app is backgrounded, so without this there is no way
  // to see what the service is doing after that point.
  await server.initLog(
    logFilePath: join(dirs.root, 'logs', Constants.logFileName),
  );

  try {
    await server.start();
  } catch (e, st) {
    logger.error('failed to start server:', e, st);
    rethrow;
  }

  try {
    final session = await Session.create(configPath: dirs.config);

    windowManager.onClose(() async {
      await session.close();
      await server.stop();
    });

    await session.initNetwork(
      NetworkDefaults(
        bind: Constants.defaultBindAddrs,
        portForwardingEnabled: true,
        localDiscoveryEnabled: true,
      ),
    );

    return (server, session);
  } catch (e, st) {
    logger.error('failed to initialize session:', e, st);
    await server.stop();
    rethrow;
  }
}

class HomeWidget extends StatefulWidget {
  HomeWidget({
    required this.windowManager,
    required this.dirs,
    required this.server,
    required this.session,
    required this.settings,
    required this.localeCubit,
    required this.errorCubit,
    required this.storeDirsCubit,
    super.key,
  });

  final PlatformWindowManager windowManager;
  final Dirs dirs;
  final Server server;
  final Session session;
  final Settings settings;
  final LocaleCubit localeCubit;
  final ErrorCubit errorCubit;
  final StoreDirsCubit storeDirsCubit;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with AppLogger /*, RouteAware*/ {
  final receivedMediaController = StreamController<List<SharedMediaFile>>();
  late final MountCubit mountCubit;
  late final ReposCubit reposCubit;
  late final StreamSubscription updateServerNotificationSubscription;
  final stage = Stage();

  @override
  void initState() {
    super.initState();

    // Update the server notification for the current locale and also every time the current locale
    // changes. This is so it always shows correctly localized messages.
    updateServerNotificationSubscription = widget.localeCubit.stream
        .startWith(widget.localeCubit.state)
        .listen(
          (_) => widget.server.notify(
            contentTitle: S.current.messageBackgroundNotification,
          ),
        );

    final cacheServers = CacheServers(widget.session);
    cacheServers.addAll(widget.settings.cacheServers);

    mountCubit = MountCubit(widget.session, widget.dirs)..init();
    reposCubit = ReposCubit(
      session: widget.session,
      settings: widget.settings,
      cacheServers: cacheServers,
      mountCubit: mountCubit,
      storeDirsCubit: widget.storeDirsCubit,
      onNotify: (message) => stage.showSnackBar(message),
    );

    unawaited(_init());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    stage.update(context);

    //widget.appRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    unawaited(reposCubit.close());
    unawaited(mountCubit.close());
    unawaited(receivedMediaController.close());
    //widget.appRouteObserver.unsubscribe(this);

    unawaited(updateServerNotificationSubscription.cancel());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MediaReceiver(
    controller: receivedMediaController,
    child: OnboardingPage(
      stage: stage,
      localeCubit: widget.localeCubit,
      settings: widget.settings,
      mainPage: MainPage(
        stage: stage,
        localeCubit: widget.localeCubit,
        mountCubit: mountCubit,
        errorCubit: widget.errorCubit,
        receivedMedia: receivedMediaController.stream,
        reposCubit: reposCubit,
        session: widget.session,
        settings: widget.settings,
        windowManager: widget.windowManager,
        dirs: widget.dirs,
        storeDirsCubit: widget.storeDirsCubit,
      ),
    ),
  );

  Future<void> _init() async {
    await widget.windowManager.setTitle(S.current.messageOuiSyncDesktopTitle);
    await widget.windowManager.initSystemTray();
  }
}

ThemeData _setupAppThemeData() => ThemeData().copyWith(
  appBarTheme: AppBarTheme(),
  focusColor: Colors.black26,
  textTheme: TextTheme().copyWith(
    bodyLarge: AppTypography.bodyBig,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    titleMedium: AppTypography.titleMedium,
  ),
  extensions: <ThemeExtension<dynamic>>[
    AppTextThemeExtension(
      titleLarge: AppTypography.titleBig,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyBig,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      bodyMicro: AppTypography.bodyMicro,
      labelLarge: AppTypography.labelBig,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ),
  ],
);

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: CircularProgressIndicator()));
}

// Shown instead of the loading spinner when app startup fails, so the cause is visible.
class StartupErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const StartupErrorScreen({
    required this.error,
    required this.stackTrace,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          'Ouisync failed to start.\n\n$error\n\n${stackTrace ?? ''}',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    ),
  );
}

// Due to race conditions the app sometimes `pop`s more from the stack than have been pushed
// resulting in black screens. This class should help us find those race conditions.
class _AppNavigatorObserver extends NavigatorObserver with AppLogger {
  final int _maxHistoryLength = 16;
  final List<_RouteHistoryEntry> _stackHistory = [];

  _AppNavigatorObserver();

  @override
  void didPush(Route route, Route? previousRoute) {
    _pushHistory(
      "push next:${route.hashCode} onTopOf:${previousRoute?.hashCode}",
      StackTrace.current,
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _pushHistory(
      "replace new:${newRoute?.hashCode} old:${oldRoute?.hashCode}",
      StackTrace.current,
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _pushHistory(
      "remove route:${route.hashCode} previous:${previousRoute?.hashCode}",
      StackTrace.current,
    );
  }

  @override
  void didPop(Route beingPopped, Route? nextCurrent) {
    _pushHistory(
      "pop beingPopped:${beingPopped.hashCode} nextCurrent:${nextCurrent?.hashCode}",
      StackTrace.current,
    );

    if (nextCurrent == null) {
      // The user will now see the black screen.
      _reportProblem("Popped last route");
    }
  }

  void _pushHistory(String action, StackTrace stackTrace) {
    _stackHistory.add(_RouteHistoryEntry(action, stackTrace.toString()));
    if (_stackHistory.length > _maxHistoryLength) {
      _stackHistory.removeAt(0);
    }
  }

  void _reportProblem(String reason) {
    final buffer = StringBuffer(
      "::::::::AppNavigationObserver error: $reason\n",
    );
    for (final e in _stackHistory) {
      buffer.write(":::: ${e.action}\n");
      buffer.write(e.stackTrace);
    }
    loggy.error(buffer);
    unawaited(Sentry.captureMessage(buffer.toString()));
  }
}

class _RouteHistoryEntry {
  String action;
  String stackTrace;
  _RouteHistoryEntry(this.action, this.stackTrace);
}
