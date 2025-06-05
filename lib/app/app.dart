import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ouisync/ouisync.dart' show NetworkDefaults, Server, Session;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stream_transform/stream_transform.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart'
    show LocaleCubit, LocaleState, MountCubit, ReposCubit;
import 'pages/pages.dart';
import 'utils/dirs.dart';
import 'utils/log.dart';
import 'utils/platform/platform.dart' show PlatformWindowManager;
import 'utils/utils.dart'
    show
        AppLogger,
        AppTextThemeExtension,
        AppTypography,
        CacheServers,
        Constants,
        loadAndMigrateSettings,
        Settings;
import 'widgets/flavor_banner.dart';
import 'widgets/media_receiver.dart';

Future<Widget> initApp([List<String> args = const []]) async =>
    FutureBuilder<HomeWidget>(
      future: _initHomeWidget(args),
      builder: (context, snapshot) {
        final home = snapshot.data;

        if (home != null) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            bloc: home.localeCubit,
            builder:
                (context, localeState) => _buildMaterialApp(
                  locale: localeState.currentLocale,
                  home: home,
                ),
          );
        } else {
          return _buildMaterialApp(home: LoadingScreen());
        }
      },
    );

Widget _buildMaterialApp({required Widget home, Locale? locale}) => MaterialApp(
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
  builder: (context, child) => FlavorBanner(child: child ?? SizedBox.shrink()),
  navigatorObservers: [_AppNavigatorObserver()],
);

Future<HomeWidget> _initHomeWidget(List<String> args) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final windowManager = await PlatformWindowManager.create(
    args,
    packageInfo.appName,
  );

  var dirs = await Dirs.init();
  await LogUtils.init(dirs);

  final (server, session) = await _initServerAndSession(dirs, windowManager);
  final settings = await loadAndMigrateSettings(session);
  final localeCubit = LocaleCubit(settings);

  return HomeWidget(
    dirs: dirs,
    server: server,
    session: session,
    windowManager: windowManager,
    settings: settings,
    packageInfo: packageInfo,
    localeCubit: localeCubit,
  );
}

Future<(Server, Session)> _initServerAndSession(
  Dirs dirs,
  PlatformWindowManager windowManager,
) async {
  final logger = appLogger('');

  final server = Server.create(configPath: dirs.config);
  server.initLog(
    callback: (level, message) => logger.log(level.toLoggy(), message),
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

    if (await session.getStoreDir() == null) {
      await session.setStoreDir(dirs.defaultStore);
    }

    await session.initNetwork(
      NetworkDefaults(
        bind: ['quic/0.0.0.0:0', 'quic/[::]:0'],
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
    required this.packageInfo,
    required this.localeCubit,
    super.key,
  });

  final PlatformWindowManager windowManager;
  final Dirs dirs;
  final Server server;
  final Session session;
  final Settings settings;
  final PackageInfo packageInfo;
  final LocaleCubit localeCubit;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with AppLogger /*, RouteAware*/ {
  final receivedMediaController = StreamController<List<SharedMediaFile>>();
  late final MountCubit mountCubit;
  late final ReposCubit reposCubit;
  late final StreamSubscription updateServerNotificationSubscription;

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
    unawaited(cacheServers.addAll(Constants.cacheServers));

    mountCubit = MountCubit(widget.session, widget.dirs)..init();
    reposCubit = ReposCubit(
      session: widget.session,
      settings: widget.settings,
      cacheServers: cacheServers,
    );

    unawaited(_init());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      widget.localeCubit,
      widget.settings,
      mainPage: MainPage(
        localeCubit: widget.localeCubit,
        mountCubit: mountCubit,
        packageInfo: widget.packageInfo,
        receivedMedia: receivedMediaController.stream,
        reposCubit: reposCubit,
        session: widget.session,
        settings: widget.settings,
        windowManager: widget.windowManager,
        dirs: widget.dirs,
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
