import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart' show Session;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart'
    show LocaleCubit, LocaleState, MountCubit, PowerControl, ReposCubit;
import 'pages/pages.dart';
import 'session.dart';
import 'utils/mounter.dart';
import 'utils/platform/platform.dart';
import 'utils/utils.dart';
import 'widgets/media_receiver.dart';

Future<Widget> initOuiSyncApp(List<String> args) async {
  final packageInfo = await PackageInfo.fromPlatform();
  print(packageInfo);

  final foregroundLogger = Loggy<AppLogger>('foreground');

  final windowManager = await PlatformWindowManager.create(
    args,
    packageInfo.appName,
  );
  final session = await createSession(
    packageInfo: packageInfo,
    windowManager: windowManager,
    logger: foregroundLogger,
  );

  Settings settings;

  try {
    settings = await loadAndMigrateSettings(session);

    final localeCubit = LocaleCubit(settings);
    final nativeChannels = NativeChannels(session);
    final appRouteObserver = NavigatorObserver();

    return BlocProvider<LocaleCubit>(
      create: (context) => localeCubit,
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return _createInMaterialApp(
            OuisyncApp(
              session: session,
              windowManager: windowManager,
              settings: settings,
              packageInfo: packageInfo,
              localeCubit: localeCubit,
              nativeChannels: nativeChannels,
            ),
            currentLocale: localeCubit.currentLocale,
            navigatorObservers: [_AppNavigatorObserver(foregroundLogger)],
          );
        },
      ),
    );
  } on InvalidSettingsVersion catch (e) {
    if (e.statedVersion > Settings.version) {
      return _createInMaterialApp(ErrorSettingsHigherVersion());
    } else {
      assert(
          false,
          "This should not happen because previous settings versions "
          "should have been migrated to the current one.");
      rethrow;
    }
  }
}

class OuisyncApp extends StatefulWidget {
  OuisyncApp({
    required this.windowManager,
    required this.session,
    required this.settings,
    required this.packageInfo,
    required this.localeCubit,
    required this.nativeChannels,
    super.key,
  });

  final PlatformWindowManager windowManager;
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
  late final powerControl = PowerControl(widget.session, widget.settings);
  late final MountCubit mountCubit;
  late final ReposCubit reposCubit;

  @override
  void initState() {
    super.initState();

    final mounter = Mounter(widget.session);
    mountCubit = MountCubit(mounter)..init();
    reposCubit = ReposCubit(
      session: widget.session,
      nativeChannels: widget.nativeChannels,
      settings: widget.settings,
      cacheServers: CacheServers(Constants.cacheServers),
      mounter: mounter,
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
    unawaited(powerControl.close());
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
              powerControl: powerControl,
              receivedMedia: receivedMediaController.stream,
              reposCubit: reposCubit,
              session: widget.session,
              settings: widget.settings,
              windowManager: widget.windowManager,
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

MaterialApp _createInMaterialApp(Widget topWidget,
        {Locale? currentLocale = null,
        List<NavigatorObserver> navigatorObservers = const []}) =>
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
      navigatorObservers: navigatorObservers,
    );

class ErrorSettingsHigherVersion extends StatelessWidget {
  const ErrorSettingsHigherVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text(S.current.messageSettingsVersionNewerThanCurrent,
                textAlign: TextAlign.center)));
  }
}

// Due to race conditions the app sometimes `pop`s more from the stack than have been pushed
// resulting in black screens. This class should help us find those race conditions.
class _AppNavigatorObserver extends NavigatorObserver {
  final int _maxHistoryLength = 16;
  List<_RouteHistoryEntry> _stackHistory = [];
  Loggy<AppLogger> _logger;

  _AppNavigatorObserver(this._logger);

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
    _logger.error(buffer);
    unawaited(Sentry.captureMessage(buffer.toString()));
  }
}

class _RouteHistoryEntry {
  String action;
  String stackTrace;
  _RouteHistoryEntry(this.action, this.stackTrace);
}
