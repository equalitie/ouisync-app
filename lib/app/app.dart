import 'dart:async';
import 'dart:io' as io;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart';
import 'pages/pages.dart';
import 'utils/platform/platform.dart';
import 'utils/utils.dart';

Future<Widget> initOuiSyncApp(List<String> args, String appSuffix) async {
  final windowManager = PlatformWindowManager(args);

  final appDir = await getApplicationSupportDirectory();
  final configPath = p.join(appDir.path, Constants.configDirName);
  final logPath = await LogUtils.path;

  final session = Session.create(
    configPath: configPath,
    logPath: logPath,
  );

  // NOTE: When the app exits, the `State.dispose()` methods are not guaranteed to be called for
  // some reason. To ensure resources are properly disposed of, we need to do it via this lifecycle
  // listener.
  // NOTE: The lifecycle listener itself is never `dispose`d but that's OK because it's supposed to
  // live as long as the app itself.
  // NOTE: That the `onExitRequested` function is known to be called only on
  // Linux and Windows, it is known to not get called on Android and iOS has
  // not been tested yet.
  AppLifecycleListener(
    onExitRequested: () async {
      await session.close();
      windowManager.dispose();

      return AppExitResponse.exit;
    },
  );

  // Make sure to only output logs after Session is created (which sets up the log subscriber),
  // otherwise the logs will go nowhere.
  Loggy.initLoggy(logPrinter: AppLogPrinter());

  // When dumping log from logcat, we get logs from past ouisync runs as well,
  // so add a line on each start of the app to know which part of the log
  // belongs to the last app instance.
  logInfo("-------------------- OuiSync$appSuffix Start --------------------");

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
  final settings = await Settings.init();

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
  );

  var root = eqValuesAccepted
      ? ouisyncAppHome
      : AcceptEqualitieValuesTermsPrivacyPage(
          settings: settings, ouisyncAppHome: ouisyncAppHome);

  var homePage = showOnboarding
      ? OnboardingPage(settings: settings, ouisyncAppHome: root)
      : root;

  final suffixColor = appSuffix.isNotEmpty ? Constants.devColor : null;

  return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _setupAppThemeData(suffixColor),
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
    required this.session,
    required this.windowManager,
    required this.settings,
    Key? key,
  }) : super(key: key);

  final Session session;
  final Settings settings;
  final PlatformWindowManager windowManager;

  @override
  State<OuiSyncApp> createState() => _OuiSyncAppState();
}

class _OuiSyncAppState extends State<OuiSyncApp> with AppLogger {
  final _mediaReceiver = MediaReceiver();
  final _backgroundServiceManager = BackgroundServiceManager();

  @override
  void initState() {
    super.initState();

    NativeChannels.init();

    initWindowManager().then((_) async => await _backgroundServiceManager
        .maybeRequestPermissionsAndStartService(context));
  }

  Future<void> initWindowManager() async {
    await widget.windowManager.setTitle(S.current.messageOuiSyncDesktopTitle);
    await widget.windowManager.initSystemTray();
  }

  @override
  void dispose() {
    _mediaReceiver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: We are recreating this on every rebuild. Is that what we want?
    final upgradeExists = UpgradeExistsCubit(
        widget.session.currentProtocolVersion, widget.settings);

    return Scaffold(
      body: MultiBlocProvider(
          providers: [
            // TODO: We have the Cubits class which we thread to widgets that
            // need it, consider getting rid of this BlocProvider pattern.
            BlocProvider<UpgradeExistsCubit>(
                create: (BuildContext context) => upgradeExists),
          ],
          child: DropTarget(
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
                session: widget.session,
                upgradeExists: upgradeExists,
                backgroundServiceManager: _backgroundServiceManager,
                mediaReceiver: _mediaReceiver,
                settings: widget.settings,
                windowManager: widget.windowManager,
              ))),
    );
  }
}

ThemeData _setupAppThemeData(Color? suffixColor) => ThemeData().copyWith(
        appBarTheme: AppBarTheme(backgroundColor: suffixColor),
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
