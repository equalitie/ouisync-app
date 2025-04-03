import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart' show PublicRuntimeId, Session;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:result_type/result_type.dart' show Failure, Result, Success;
import 'package:sentry_flutter/sentry_flutter.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart'
    show LocaleCubit, LocaleState, MountCubit, ReposCubit;
import 'pages/pages.dart';
import 'session.dart';
import 'utils/dirs.dart';
import 'utils/platform/platform.dart' show PlatformWindowManager;
import 'utils/utils.dart'
    show
        AppLogger,
        AppTextThemeExtension,
        AppTypography,
        CacheServers,
        Constants,
        InvalidSettingsVersion,
        loadAndMigrateSettings,
        Settings;
import 'widgets/flavor_banner.dart';
import 'widgets/media_receiver.dart';

Future<Widget> initOuiSyncApp({
  required Dirs dirs,
  List<String> args = const [],
}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final windowManager = await PlatformWindowManager.create(
    args,
    packageInfo.appName,
  );

  return AppContainer(
    packageInfo: packageInfo,
    windowManager: windowManager,
    dirs: dirs,
  );
}

class AppContainer extends StatefulWidget {
  @override
  State<AppContainer> createState() => _AppContainerState();

  final PackageInfo packageInfo;
  final PlatformWindowManager windowManager;
  final Dirs dirs;

  AppContainer({
    required this.packageInfo,
    required this.windowManager,
    required this.dirs,
  });
}

class _AppContainerWrappedState {
  final Session session;
  final NativeChannels nativeChannels;
  final Settings settings;
  final PublicRuntimeId sessionId;

  _AppContainerWrappedState({
    required this.session,
    required this.nativeChannels,
    required this.settings,
    required this.sessionId,
  });
}

class _AppContainerState extends State<AppContainer> with AppLogger {
  Result<_AppContainerWrappedState, Exception>? state;

  @override
  void initState() {
    super.initState();
    unawaited(_restart());
  }

  @override
  Widget build(BuildContext context) => switch (state) {
        null => _createInMaterialApp(ErrorScreen(message: "Loading...")),
        Success(value: final state) => BlocProvider<LocaleCubit>(
            create: (context) => LocaleCubit(state.settings),
            child: BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, localeState) => _createInMaterialApp(
                    OuisyncApp(
                        dirs: widget.dirs,
                        session: state.session,
                        windowManager: widget.windowManager,
                        settings: state.settings,
                        packageInfo: widget.packageInfo,
                        localeCubit: context.read(),
                        nativeChannels: state.nativeChannels,
                        // we use a custom key tied to the session to force the child
                        // component to drop state whenever the session disconnects
                        key: ValueKey(state.sessionId)),
                    currentLocale: localeState.currentLocale,
                    navigatorObservers: [_AppNavigatorObserver()]))),
        Failure(value: final error) => _createInMaterialApp(ErrorScreen(
            message: error is InvalidSettingsVersion
                ? S.current.messageSettingsVersionNewerThanCurrent
                : "Internal error\n$error",
          ))
      };

  Future<void> _restart() async {
    try {
      final session = await createSession(
          packageInfo: widget.packageInfo,
          windowManager: widget.windowManager,
          dirs: widget.dirs,
          onConnectionReset: () {
            // the session is now defunct: switch to the loading screen
            setState(() => state = null);
            // and attempt to start a new one after a short delay
            Timer(Duration(seconds: 1), () => unawaited(_restart()));
          });
      final settings = await loadAndMigrateSettings(session);
      final sessionId = await session.getRuntimeId();
      setState(() => state = Success(_AppContainerWrappedState(
            session: session,
            nativeChannels: NativeChannels(),
            settings: settings,
            sessionId: sessionId,
          )));
      // FIXME: convert this into the network error thrown by session on reset
    } on UnimplementedError catch (error) {
      // this error is considered transient, retry after a short delay
      loggy.warning('Unable to acquire session:', error);
      Timer(Duration(seconds: 1), () => unawaited(_restart()));
    } on Exception catch (error) {
      setState(() => state = Failure(error));
    }
  }
}

class OuisyncApp extends StatefulWidget {
  OuisyncApp({
    required this.windowManager,
    required this.dirs,
    required this.session,
    required this.settings,
    required this.packageInfo,
    required this.localeCubit,
    required this.nativeChannels,
    super.key,
  });

  final PlatformWindowManager windowManager;
  final Dirs dirs;
  final Session session;
  final NativeChannels nativeChannels;
  final Settings settings;
  final PackageInfo packageInfo;
  final LocaleCubit localeCubit;

  @override
  State<OuisyncApp> createState() => _OuisyncAppState();
}

class _OuisyncAppState extends State<OuisyncApp>
    with AppLogger /*, RouteAware*/ {
  final receivedMediaController = StreamController<List<SharedMediaFile>>();
  late final MountCubit mountCubit;
  late final ReposCubit reposCubit;

  @override
  void initState() {
    super.initState();

    final cacheServers = CacheServers(widget.session);
    unawaited(cacheServers.addAll(Constants.cacheServers));

    mountCubit = MountCubit(widget.session, widget.dirs)..init();
    reposCubit = ReposCubit(
      session: widget.session,
      nativeChannels: widget.nativeChannels,
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MediaReceiver(
        controller: receivedMediaController,
        child: OnboardingPage(widget.localeCubit, widget.settings,
            mainPage: MainPage(
              localeCubit: widget.localeCubit,
              mountCubit: mountCubit,
              nativeChannels: widget.nativeChannels,
              packageInfo: widget.packageInfo,
              receivedMedia: receivedMediaController.stream,
              reposCubit: reposCubit,
              session: widget.session,
              settings: widget.settings,
              windowManager: widget.windowManager,
              dirs: widget.dirs,
            )),
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
            titleMedium: AppTypography.titleMedium),
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
              labelSmall: AppTypography.labelSmall)
        ]);

MaterialApp _createInMaterialApp(
  Widget topWidget, {
  Locale? currentLocale,
  List<NavigatorObserver> navigatorObservers = const [],
}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _setupAppThemeData(),
      locale: currentLocale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: topWidget,
      builder: (context, child) => FlavorBanner(
        child: child ?? SizedBox.shrink(),
      ),
      navigatorObservers: navigatorObservers,
    );

class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({required this.message, super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(message, textAlign: TextAlign.center)));
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
        StackTrace.current);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _pushHistory("replace new:${newRoute?.hashCode} old:${oldRoute?.hashCode}",
        StackTrace.current);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _pushHistory(
        "remove route:${route.hashCode} previous:${previousRoute?.hashCode}",
        StackTrace.current);
  }

  @override
  void didPop(Route beingPopped, Route? nextCurrent) {
    _pushHistory(
        "pop beingPopped:${beingPopped.hashCode} nextCurrent:${nextCurrent?.hashCode}",
        StackTrace.current);

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
    final buffer =
        StringBuffer("::::::::AppNavigationObserver error: $reason\n");
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
