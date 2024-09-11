import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync_app/app/cubits/mount.dart';
import 'package:ouisync_app/app/cubits/power_control.dart';
import 'package:ouisync_app/app/widgets/media_receiver.dart';
import 'package:ouisync/ouisync.dart' show Session;
import 'package:ouisync/native_channels.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../generated/l10n.dart';
import 'cubits/repos.dart';
import 'pages/pages.dart';
import 'session.dart';
import 'utils/mounter.dart';
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
    home: OuisyncApp(
      session: session,
      windowManager: windowManager,
      settings: settings,
      packageInfo: packageInfo,
    ),
  );
}

class OuisyncApp extends StatefulWidget {
  OuisyncApp({
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
  State<OuisyncApp> createState() => _OuisyncAppState();
}

class _OuisyncAppState extends State<OuisyncApp> with AppLogger {
  final receivedMediaController = StreamController<List<SharedMediaFile>>();
  late final powerControl = PowerControl(widget.session, widget.settings);
  late final MountCubit mountCubit;
  late final ReposCubit reposCubit;

  bool get _onboarded =>
      !widget.settings.getShowOnboarding() &&
      widget.settings.getEqualitieValues();

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
  void dispose() {
    unawaited(reposCubit.close());
    unawaited(mountCubit.close());
    unawaited(powerControl.close());
    unawaited(receivedMediaController.close());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Visibility(
        child: MediaReceiver(
          controller: receivedMediaController,
          child: MainPage(
            mountCubit: mountCubit,
            nativeChannels: widget.nativeChannels,
            packageInfo: widget.packageInfo,
            powerControl: powerControl,
            receivedMedia: receivedMediaController.stream,
            reposCubit: reposCubit,
            session: widget.session,
            settings: widget.settings,
            windowManager: widget.windowManager,
          ),
        ),
        visible: _onboarded,
      );

  Future<void> _init() async {
    await widget.windowManager.setTitle(S.current.messageOuiSyncDesktopTitle);
    await widget.windowManager.initSystemTray();

    // We show the onboarding the first time the app starts.
    // Then, we show the page for accepting eQ values, until the user taps YES.
    // After this, just show the regular home page.

    if (!_onboarded) {
      final onboardingPages = <Widget>[];

      if (widget.settings.getShowOnboarding()) {
        onboardingPages.add(OnboardingPage(settings: widget.settings));
      }

      if (!widget.settings.getEqualitieValues()) {
        // If this is the first time the onboarding page was displayed, even
        // though the setting is already set to true by the time we get to the
        // eQ values page, we can allow the user to navigate back to the
        // onboarding using the back button in Android.
        final canNavigateBack = widget.settings.getShowOnboarding();

        onboardingPages.add(
          AcceptEqualitieValuesTermsPrivacyPage(
            settings: widget.settings,
            canNavigateToOnboarding: canNavigateBack,
          ),
        );
      }

      for (var page in onboardingPages) {
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => page));
      }

      if (_onboarded) {
        // Force rebuild to show the main page.
        setState(() {});
      }
    }
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
