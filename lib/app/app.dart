import 'dart:async';
import 'dart:io' as io;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart';
import 'pages/pages.dart';
import 'utils/platform/platform.dart';
import 'utils/utils.dart';

Future<Widget> initOuiSyncApp(List<String> args) async {
  final appDir = await getApplicationSupportDirectory();
  final configPath = p.join(appDir.path, Constants.configDirName);
  final logPath = await LogUtils.path;

  final packageInfo = await PackageInfo.fromPlatform();
  final windowManager = await PlatformWindowManager.create(
    args,
    packageInfo.appName,
  );

  final session = Session.create(
    configPath: configPath,
    logPath: logPath,
  );

  windowManager.session = session;

  // Make sure to only output logs after Session is created (which sets up the log subscriber),
  // otherwise the logs will go nowhere.
  Loggy.initLoggy(logPrinter: AppLogPrinter());

  // When dumping log from logcat, we get logs from past ouisync runs as well,
  // so add a line on each start of the app to know which part of the log
  // belongs to the last app instance.
  logInfo(
      "-------------------- ${packageInfo.appName} Start --------------------");

  _setupErrorReporting();

  logDebug('app dir: ${appDir.path}');
  logDebug('log dir: ${io.File(logPath).parent.path}');

  await session.initNetwork(
    defaultPortForwardingEnabled: true,
    defaultLocalDiscoveryEnabled: true,
  );

  for (final host in Constants.storageServers) {
    try {
      await session.addStorageServer(host);
    } catch (e) {
      logError('failed to add storage server $host:', e);
    }
  }

  // TODO: Maybe we don't need to await for this, instead just get the future
  // and let whoever needs seetings to await for it.
  final settings = await loadAndMigrateSettings();

  var launchAtStartup = settings.getLaunchAtStartup();
  if (launchAtStartup == null) {
    launchAtStartup = true;
    await settings.setLaunchAtStartup(launchAtStartup);
  }
  await windowManager.launchAtStartup(launchAtStartup);

  var showOnboarding = settings.getShowOnboarding();
  if (showOnboarding == null) {
    showOnboarding = true;
    await settings.setShowOnboarding(showOnboarding);
  }

  var eqValuesAccepted = settings.getEqualitieValues();
  if (eqValuesAccepted == null) {
    eqValuesAccepted = false;
    await settings.setEqualitieValues(eqValuesAccepted);
  }

  /// We show the onboarding the first time the app starts.
  /// Then, we show the page for accepting eQ values, until the user taps YES.
  /// After this, just show the regular home page.

  final ouisyncAppHome = OuiSyncApp(
    session: session,
    windowManager: windowManager,
    settings: settings,
    packageInfo: packageInfo,
  );

  var root = eqValuesAccepted
      ? ouisyncAppHome
      : AcceptEqualitieValuesTermsPrivacyPage(
          settings: settings, ouisyncAppHome: ouisyncAppHome);

  var homePage = showOnboarding
      ? OnboardingPage(settings: settings, ouisyncAppHome: root)
      : root;

  return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _setupAppThemeData(),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: homePage);
}

class OuiSyncApp extends StatefulWidget {
  const OuiSyncApp({
    required this.windowManager,
    required this.session,
    required this.settings,
    required this.packageInfo,
    Key? key,
  }) : super(key: key);

  final PlatformWindowManager windowManager;
  final Session session;
  final Settings settings;
  final PackageInfo packageInfo;

  @override
  State<OuiSyncApp> createState() => _OuiSyncAppState(session, settings);
}

class _OuiSyncAppState extends State<OuiSyncApp> with AppLogger {
  final _mediaReceiver = MediaReceiver();
  final _backgroundServiceManager = BackgroundServiceManager();
  final UpgradeExistsCubit _upgradeExists;

  _OuiSyncAppState(Session session, Settings settings)
      : _upgradeExists =
            UpgradeExistsCubit(session.currentProtocolVersion, settings);

  @override
  void initState() {
    super.initState();

    NativeChannels.init();

    unawaited(_init());
  }

  @override
  void dispose() {
    _mediaReceiver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigation = NavigationCubit();

    return Scaffold(
      body: DropTarget(
        onDragDone: (detail) {
          loggy.app('Drop done: ${detail.files.first.path}');

          final xFile = detail.files.firstOrNull;
          if (xFile != null) {
            final file = io.File(xFile.path);
            _mediaReceiver.controller.add(file);
          }
        },
        onDragEntered: (detail) {
          loggy.app('Drop entered: ${detail.localPosition}');
        },
        onDragExited: (detail) {
          loggy.app('Drop exited: ${detail.localPosition}');
        },
        child: MainPage(
          backgroundServiceManager: _backgroundServiceManager,
          mediaReceiver: _mediaReceiver,
          navigation: navigation,
          packageInfo: widget.packageInfo,
          session: widget.session,
          settings: widget.settings,
          upgradeExists: _upgradeExists,
          windowManager: widget.windowManager,
        ),
      ),
    );
  }

  Future<void> _init() async {
    await widget.windowManager.setTitle(S.current.messageOuiSyncDesktopTitle);
    await widget.windowManager.initSystemTray();
    await _backgroundServiceManager
        .maybeRequestPermissionsAndStartService(context);
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

void _setupErrorReporting() {
  // Errors from flutter
  FlutterError.onError = (details) {
    // Invoke the default handler
    FlutterError.presentError(details);

    _onError(details);
  };

  // Errors from outside of flutter
  PlatformDispatcher.instance.onError = (exception, stack) {
    _onError(FlutterErrorDetails(exception: exception, stack: stack));

    // Invoke the default handler
    return false;
  };
}

void _onError(FlutterErrorDetails details) {
  logError("Unhandled Exception:", details.exception, details.stack);

  unawaited(
      Sentry.captureException(details.exception, stackTrace: details.stack));
}
