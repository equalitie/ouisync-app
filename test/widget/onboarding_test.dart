import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ouisync_app/app/app.dart';
import 'package:ouisync_app/app/cubits/locale.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/cubits/error.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/dirs.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync/ouisync.dart';

import '../utils.dart';

void main() {
  late Dirs dirs;
  late Server server;
  late Session session;
  late Settings settings;
  late LocaleCubit localeCubit;
  late ErrorCubit errorCubit;

  setUp(() async {
    dirs = await Dirs.init();

    server = Server.create(configPath: dirs.config);
    await server.start();

    session = await Session.create(configPath: dirs.config);

    errorCubit = ErrorCubit(session);

    settings = await Settings.init(MasterKey.random());
    settings.cacheServers = [];

    localeCubit = LocaleCubit(settings);
  });

  tearDown(() async {
    await localeCubit.close();
    await errorCubit.close();
    await session.close();
    await server.stop();
  });

  testWidgets(
    'onboarding',
    (tester) => tester.runAsync(() async {
      final reposObserver = StateObserver.install<ReposState>();

      await tester.pumpWidget(
        testApp(
          HomeWidget(
            localeCubit: localeCubit,
            errorCubit: errorCubit,
            packageInfo: fakePackageInfo,
            server: server,
            session: session,
            settings: settings,
            windowManager: FakeWindowManager(),
            dirs: dirs,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.anxiousTap(find.text('English'));
      await tester.pumpAndSettle();

      // Go to the second onboarding page
      await tester.anxiousTap(find.byIcon(Icons.arrow_forward));
      await tester
          .pumpAndSettle(); // TODO: Do we need to call this after every interaction?

      // Go to the third onboarding page
      await tester.anxiousTap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      // Go to the accept terms & conditions page
      await tester.anxiousTap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'Ouisync is built in line with our values',
          findRichText: true,
        ),
        findsOne,
      );

      // Agree with the T&C and go to the main page
      await tester.anxiousTap(find.text('I AGREE'));
      await reposObserver.waitUntil((state) => !state.isLoading);
      await tester.pumpAndSettle();

      // Assert we are on the main page
      expect(find.byType(MainPage), findsOne);
    }),
  );
}
