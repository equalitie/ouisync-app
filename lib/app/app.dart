import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ouisync_app/app/cubits/store_dirs.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stream_transform/stream_transform.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart'
    show
        ErrorCubit,
        ErrorLog,
        LocaleCubit,
        LocaleState,
        MountCubit,
        ReposCubit,
        SessionCubit,
        SessionState;
import 'pages/pages.dart';
import 'utils/log.dart' as log;
import 'utils/dirs.dart';
import 'utils/master_key.dart' show MasterKeyUnreadable;
import 'utils/stage.dart';
import 'utils/platform/platform.dart' show PlatformWindowManager;
import 'utils/utils.dart'
    show
        AppLogger,
        AppTextThemeExtension,
        AppTypography,
        CacheServers,
        Settings,
        clearPreviewCache,
        loadAndMigrateSettings;
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

class _AppState extends State<App> with AppLogger {
  late final components = AppComponents.create(widget.args).then(
    (components) {
      widget.controller?._stopListener = () => components.destroy();
      return components;
    },
    onError: (Object e, StackTrace st) {
      loggy.error('failed to start:', e, st);
      Error.throwWithStackTrace(e, st);
    },
  );

  // Created once per state, not per build: MaterialApp is rebuilt on locale changes and the
  // observer keeps the route history, which would otherwise be lost on every rebuild.
  final _navigatorObserver = _AppNavigatorObserver();

  // Created once, not per build, so the theme object stays the same across rebuilds.
  final _theme = _setupAppThemeData();

  @override
  Widget build(BuildContext context) => FutureBuilder<AppComponents>(
    future: components,
    builder: (context, snapshot) {
      final components = snapshot.data;

      if (components == null) {
        if (snapshot.hasError) {
          return _buildMaterialApp(
            home: StartupErrorScreen(
              error: snapshot.error!,
              stackTrace: snapshot.stackTrace,
            ),
          );
        }

        return _buildMaterialApp(home: const LoadingScreen());
      }

      // Rebuilds on every session change, so a disconnect or a failed reconnect shows up right away.
      return BlocBuilder<SessionCubit, SessionState>(
        bloc: components.sessionCubit,
        builder: (context, sessionState) {
          if (sessionState.connecting) {
            return _buildMaterialApp(home: const LoadingScreen());
          }

          final sessionError = sessionState.error;
          if (sessionError != null) {
            return _buildMaterialApp(
              home: StartupErrorScreen(
                error: sessionError,
                sessionCubit: components.sessionCubit,
              ),
            );
          }

          return BlocBuilder<LocaleCubit, LocaleState>(
            bloc: components.localeCubit,
            builder: (context, localeState) => _buildMaterialApp(
              locale: localeState.currentLocale,
              home: _buildHomeWidget(components),
            ),
          );
        },
      );
    },
  );

  Widget _buildMaterialApp({required Widget home, Locale? locale}) =>
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _theme,
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
        navigatorObservers: [_navigatorObserver],
      );

  Widget _buildHomeWidget(AppComponents components) =>
      BlocBuilder<SessionCubit, SessionState>(
        bloc: components.sessionCubit,
        builder: (context, sessionState) => HomeWidget(
          // Keyed by generation: after a reconnect, everything that depends on the session has to
          // be recreated with the new one.
          key: ValueKey(sessionState.generation),
          components: components,
        ),
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

/// The long-lived objects the app is built from. Created once at startup and passed down to the
/// widgets that need them.
class AppComponents {
  final PlatformWindowManager windowManager;
  final Dirs dirs;
  final ErrorLog errorLog;
  final SessionCubit sessionCubit;
  final Settings settings;
  final LocaleCubit localeCubit;

  AppComponents({
    required this.windowManager,
    required this.dirs,
    required this.errorLog,
    required this.sessionCubit,
    required this.settings,
    required this.localeCubit,
  });

  static Future<AppComponents> create(List<String> args) async {
    // Installed first, once per process, so errors from any later startup step are recorded. The
    // error log outlives session reconnects.
    final errorLog = ErrorLog()..installGlobalHandlers();

    final packageInfo = await PackageInfo.fromPlatform();
    final windowManager = await PlatformWindowManager.create(
      args,
      packageInfo.appName,
    );

    final dirs = await Dirs.init();
    await log.init(dirs);

    unawaited(clearPreviewCache());

    final sessionCubit = await SessionCubit.create(dirs);

    final Settings settings;
    final LocaleCubit localeCubit;

    try {
      settings = await loadAndMigrateSettings(sessionCubit.session);
      localeCubit = LocaleCubit(settings);
    } catch (e, st) {
      await sessionCubit.close();
      Error.throwWithStackTrace(e, st);
    }

    final components = AppComponents(
      windowManager: windowManager,
      dirs: dirs,
      errorLog: errorLog,
      sessionCubit: sessionCubit,
      settings: settings,
      localeCubit: localeCubit,
    );

    // `destroy` is the only shutdown path. Closing the window calls it too, so the session is
    // closed gracefully before the process exits.
    windowManager.onClose(components.destroy);

    return components;
  }

  Future<void>? _windowInit;

  // Sets the window title and system tray. Runs once per process, on first use, rather than once
  // per `HomeWidget`, since a reconnect recreates the `HomeWidget`. It runs from the widget tree
  // because it needs localization, which is only available under `MaterialApp`.
  Future<void> initWindow() => _windowInit ??= _initWindow();

  Future<void> _initWindow() async {
    await windowManager.setTitle(S.current.messageOuiSyncDesktopTitle);
    await windowManager.initSystemTray();
  }

  Future<void> destroy() async {
    await localeCubit.close();
    await sessionCubit.close();
    await errorLog.close();
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({required this.components, super.key});

  final AppComponents components;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with AppLogger /*, RouteAware*/ {
  final receivedMediaController = StreamController<List<SharedMediaFile>>();
  late final MountCubit mountCubit;
  late final StoreDirsCubit storeDirsCubit;
  late final ReposCubit reposCubit;
  late final ErrorCubit errorCubit;
  late final StreamSubscription updateServerNotificationSubscription;
  final stage = Stage();

  @override
  void initState() {
    super.initState();

    final components = widget.components;
    final session = components.sessionCubit.session;

    // Update the server notification for the current locale and also every time the current locale
    // changes. This is so it always shows correctly localized messages.
    updateServerNotificationSubscription = components.localeCubit.stream
        .startWith(components.localeCubit.state)
        .listen(
          (_) => components.sessionCubit.server.notify(
            contentTitle: S.current.messageBackgroundNotification,
          ),
        );

    errorCubit = ErrorCubit(components.errorLog, session);

    final cacheServers = CacheServers(session);
    cacheServers.addAll(components.settings.cacheServers);

    mountCubit = MountCubit(session, components.dirs)..init();
    storeDirsCubit = StoreDirsCubit(session, components.dirs);
    reposCubit = ReposCubit(
      session: session,
      settings: components.settings,
      cacheServers: cacheServers,
      mountCubit: mountCubit,
      storeDirsCubit: storeDirsCubit,
      onNotify: (message) => stage.showSnackBar(message),
    );

    unawaited(components.initWindow());
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
    unawaited(storeDirsCubit.close());
    unawaited(mountCubit.close());
    unawaited(errorCubit.close());
    unawaited(receivedMediaController.close());
    //widget.appRouteObserver.unsubscribe(this);

    unawaited(updateServerNotificationSubscription.cancel());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final components = widget.components;

    return MediaReceiver(
      controller: receivedMediaController,
      child: OnboardingPage(
        stage: stage,
        localeCubit: components.localeCubit,
        settings: components.settings,
        mainPage: MainPage(
          stage: stage,
          localeCubit: components.localeCubit,
          mountCubit: mountCubit,
          errorCubit: errorCubit,
          receivedMedia: receivedMediaController.stream,
          reposCubit: reposCubit,
          session: components.sessionCubit.session,
          settings: components.settings,
          windowManager: components.windowManager,
          dirs: components.dirs,
          storeDirsCubit: storeDirsCubit,
        ),
      ),
    );
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

/// Shown instead of the app when it fails to start.
class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    required this.error,
    this.stackTrace,
    this.sessionCubit,
    super.key,
  });

  final Object error;
  final StackTrace? stackTrace;
  final SessionCubit? sessionCubit;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.titleStartupFailed,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              error is MasterKeyUnreadable
                  ? S.current.messageMasterKeyUnreadable
                  : S.current.messageStartupFailed,
            ),
            if (sessionCubit != null) ...[
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => sessionCubit?.reconnect(),
                child: Text(S.current.actionRetry),
              ),
            ],
            const SizedBox(height: 16.0),
            // Details for reporting the problem.
            SelectableText(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (stackTrace != null) ...[
              const SizedBox(height: 16.0),
              SelectableText(
                stackTrace.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
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
