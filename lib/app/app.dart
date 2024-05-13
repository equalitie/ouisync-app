import 'dart:async';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' show Session;
import 'package:ouisync_plugin/native_channels.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../generated/l10n.dart';
import 'cubits/cubits.dart';
import 'pages/pages.dart';
import 'session.dart';
import 'utils/platform/platform.dart';
import 'utils/utils.dart';

Future<Widget> initOuiSyncApp(List<String> args) async {
  _setupErrorReporting();

  final packageInfo = await PackageInfo.fromPlatform();
  final windowManager = await PlatformWindowManager.create(
    args,
    packageInfo.appName,
  );
  final session = await createSession(
    packageInfo: packageInfo,
    windowManager: windowManager,
    logger: Loggy<AppLogger>('foreground'),
  );

  // TODO: Maybe we don't need to await for this, instead just get the future
  // and let whoever needs seetings to await for it.
  final settings = await loadAndMigrateSettings(session);

  var showOnboarding = settings.getShowOnboarding();
  var eqValuesAccepted = settings.getEqualitieValues();

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
  OuiSyncApp({
    required this.windowManager,
    required this.session,
    required this.settings,
    required this.packageInfo,
    super.key,
  }) : nativeChannels = NativeChannels(session);

  final PlatformWindowManager windowManager;
  final Session session;
  final NativeChannels nativeChannels;
  final Settings settings;
  final PackageInfo packageInfo;

  @override
  State<OuiSyncApp> createState() => _OuiSyncAppState(session, settings);
}

class _OuiSyncAppState extends State<OuiSyncApp> with AppLogger {
  final _mediaReceiver = MediaReceiver();
  final UpgradeExistsCubit _upgradeExists;

  _OuiSyncAppState(Session session, Settings settings)
      : _upgradeExists =
            UpgradeExistsCubit(session.currentProtocolVersion, settings);

  @override
  void initState() {
    super.initState();
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
          loggy.debug(
              'Drop done: ${detail.files.map((file) => file.path).join(', ')}');

          final media = detail.files
              .map((file) => SharedMediaFile(
                  path: file.path,
                  type: SharedMediaType.file,
                  mimeType: file.mimeType))
              .toList();
          _mediaReceiver.controller.add(media);
        },
        onDragEntered: (detail) {
          loggy.debug('Drop entered: ${detail.localPosition}');
        },
        onDragExited: (detail) {
          loggy.debug('Drop exited: ${detail.localPosition}');
        },
        child: MainPage(
          mediaReceiver: _mediaReceiver,
          navigation: navigation,
          packageInfo: widget.packageInfo,
          session: widget.session,
          nativeChannels: widget.nativeChannels,
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
