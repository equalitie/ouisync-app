import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_app/app/widgets/media_receiver.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart' show Session;
import 'package:ouisync_plugin/native_channels.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../generated/l10n.dart';
import 'pages/pages.dart';
import 'session.dart';
import 'utils/platform/platform.dart';
import 'utils/utils.dart';

Future<Widget> initOuiSyncApp(List<String> args) async {
  final packageInfo = await PackageInfo.fromPlatform();
  print(packageInfo);

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
    home: OuiSyncApp(
      session: session,
      windowManager: windowManager,
      settings: settings,
      packageInfo: packageInfo,
    ),
  );
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
  State<OuiSyncApp> createState() => _OuiSyncAppState();
}

class _OuiSyncAppState extends State<OuiSyncApp> with AppLogger {
  final receivedMediaController = StreamController<List<SharedMediaFile>>();

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  @override
  void dispose() {
    unawaited(receivedMediaController.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// We show the onboarding the first time the app starts.
    /// Then, we show the page for accepting eQ values, until the user taps YES.
    /// After this, just show the regular home page.
    final home = MediaReceiver(
      controller: receivedMediaController,
      child: MainPage(
        packageInfo: widget.packageInfo,
        session: widget.session,
        nativeChannels: widget.nativeChannels,
        settings: widget.settings,
        windowManager: widget.windowManager,
        receivedMedia: receivedMediaController.stream,
      ),
    );

    final afterOnboarding = widget.settings.getEqualitieValues()
        ? home
        : AcceptEqualitieValuesTermsPrivacyPage(
            settings: widget.settings,
            ouisyncAppHome: home,
          );

    return widget.settings.getShowOnboarding()
        ? OnboardingPage(
            settings: widget.settings,
            ouisyncAppHome: afterOnboarding,
          )
        : afterOnboarding;
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
