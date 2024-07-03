import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/power_control.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_plugin/native_channels.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_text/styled_text.dart';

import '../utils.dart';

void main() {
  late Session session;
  late Settings settings;
  late NativeChannels nativeChannels;
  late PowerControl powerControl;
  late ReposCubit reposCubit;

  setUp(() async {
    final configPath = join(
      (await getApplicationSupportDirectory()).path,
      'config',
    );

    session = Session.create(
      kind: SessionKind.unique,
      configPath: configPath,
    );

    settings = await Settings.init(MasterKey.random());
    nativeChannels = NativeChannels(session);
    powerControl = PowerControl(
      session,
      settings,
      connectivity: FakeConnectivity(),
    );

    reposCubit = ReposCubit(
      cacheServers: CacheServers.disabled,
      nativeChannels: nativeChannels,
      session: session,
      settings: settings,
    );
  });

  tearDown(() async {
    await reposCubit.close();
    await powerControl.close();
    await session.close();
  });

  testWidgets(
    'lock and unlock imported repo without password',
    (tester) => tester.runAsync(
      () async {
        final location = RepoLocation.fromParts(
          dir: await getTemporaryDirectory(),
          name: 'external-repo',
        );
        final repo = await Repository.create(
          session,
          store: location.path,
          readSecret: null,
          writeSecret: null,
        );
        await repo.setAccess(write: DisableAccess());
        await repo.close();

        await reposCubit.waitUntil((_) => !reposCubit.isLoading);
        await reposCubit.importRepoFromLocation(location);

        final repoEntry = reposCubit.get(location);
        final repoCubit = repoEntry!.cubit!;

        await tester.pumpWidget(testApp(MainPage(
          nativeChannels: nativeChannels,
          packageInfo: fakePackageInfo,
          powerControl: powerControl,
          receivedMedia: Stream.empty(),
          reposCubit: reposCubit,
          session: session,
          settings: settings,
          windowManager: FakeWindowManager(),
        )));
        await tester.pumpAndSettle();
        await reposCubit.waitUntil((_) => !reposCubit.isLoading);

        final repoItem = find.widgetWithText(InkWell, location.name);
        final readIcon = find.descendant(
          of: repoItem,
          matching: find.byIcon(Icons.visibility_outlined),
        );
        final blindIcon = find.descendant(
          of: repoItem,
          matching: find.byIcon(Icons.visibility_off_outlined),
        );

        expect(readIcon, findsOne);

        // Tap the access mode icon to lock the repo.
        await tester.tap(readIcon);
        await repoCubit
            .waitUntil((state) => state.accessMode == AccessMode.blind);
        await tester.pump();

        expect(readIcon, findsNothing);
        expect(blindIcon, findsOne);

        // Tap the repo to go to the unlock page.
        await tester.tap(repoItem);
        await reposCubit.waitUntil((_) => reposCubit.currentRepo == repoEntry);
        await repoCubit.waitUntil((state) => !state.isLoading);
        await tester.pumpAndSettle();

        // NOTE: This uses `StyledText` and so can't be found using `find.text` or
        // `find.textContaining`
        expect(
          tester
              .widgetList<StyledText>(find.bySubtype<StyledText>())
              .map((widget) => widget.text),
          contains('<font>This <bold>repository</bold> is locked.</font>'),
        );

        // Tap the Unlock button to unlock the repo. This should not ask for a password because the
        // repo doesn't have one.
        await tester.tap(find.text('UNLOCK'));
        await repoCubit
            .waitUntil((state) => state.accessMode == AccessMode.read);
        await tester.pump();

        expect(find.widgetWithText(AppBar, location.name), findsOne);
      },
    ),
  );
}
