import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart' show Session;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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

  final windowManager = await PlatformWindowManager.create(
    args,
    packageInfo.appName,
  );
  final session = await createSession(
    packageInfo: packageInfo,
    windowManager: windowManager,
    logger: Loggy<AppLogger>('foreground'),
  );

  final settings = await loadAndMigrateSettings(session);

  final localeCubit = LocaleCubit(settings);

  return BlocProvider<LocaleCubit>(
    create: (context) => localeCubit,
    child: BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _setupAppThemeData(),
          locale: localeState.currentLocale,
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
            localeCubit: localeCubit,
          ),
        );
      },
    ),
  );
}

class OuisyncApp extends StatefulWidget {
  OuisyncApp({
    required this.windowManager,
    required this.session,
    required this.settings,
    required this.packageInfo,
    required this.localeCubit,
    super.key,
  }) : nativeChannels = NativeChannels(session);

  final PlatformWindowManager windowManager;
  final Session session;
  final NativeChannels nativeChannels;
  final Settings settings;
  final PackageInfo packageInfo;
  final LocaleCubit localeCubit;

  @override
  State<OuisyncApp> createState() => _OuisyncAppState();
}

class _OuisyncAppState extends State<OuisyncApp> with AppLogger {
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
  void dispose() {
    unawaited(reposCubit.close());
    unawaited(mountCubit.close());
    unawaited(powerControl.close());
    unawaited(receivedMediaController.close());

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
