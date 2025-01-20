import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync_app/app/app.dart';
import 'package:ouisync_app/app/cubits/locale.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../utils.dart';

void main() {
  late Session session;
  late Settings settings;
  late LocaleCubit localeCubit;

  setUp(() async {
    initLog();

    final appDir = await getApplicationSupportDirectory();
    await appDir.create(recursive: true);

    session = await Session.create(configPath: join(appDir.path, 'config'));
    settings = await Settings.init(MasterKey.random());
    localeCubit = LocaleCubit(settings);
  });

  tearDown(() async {
    await localeCubit.close();
    await session.close();
  });

  testWidgets(
    'onboarding',
    (tester) => tester.runAsync(() async {
      final reposObserver = StateObserver.install<ReposState>();

      await tester.pumpWidget(testApp(OuisyncApp(
        localeCubit: localeCubit,
        packageInfo: fakePackageInfo,
        session: session,
        settings: settings,
        windowManager: FakeWindowManager(),
        nativeChannels: NativeChannels(),
      )));
      await tester.pumpAndSettle();

      final englishItem = find.text('English').first;
      await tester.tap(englishItem);
      await tester.pumpAndSettle();

      // Go to the second onboarding page
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester
          .pumpAndSettle(); // TODO: Do we need to call this after every interaction?

      // Go to the third onboarding page
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      // Go to the accept terms & conditions page
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'Ouisync is built in line with our values',
          findRichText: true,
        ),
        findsOne,
      );

      // Agree with the T&C and go to the main page
      await tester.tap(find.text('I AGREE'));
      await reposObserver.waitUntil((state) => !state.isLoading);
      await tester.pumpAndSettle();

      // Assert we are on the main page
      expect(find.byType(MainPage), findsOne);
    }),
  );
}
