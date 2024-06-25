import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/entry_bottom_sheet.dart';
import 'package:ouisync_app/app/cubits/navigation.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_entry.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/pages/repository_creation_page.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:ouisync_plugin/native_channels.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'utils.dart';

void main() {
  late Session session;
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

    final nativeChannels = NativeChannels(session);
    final settings = await Settings.init(MasterKey.random());

    reposCubit = ReposCubit(
      session: session,
      nativeChannels: nativeChannels,
      settings: settings,
      navigation: NavigationCubit(),
      bottomSheet: EntryBottomSheetCubit(),
      cacheServers: CacheServers.disabled,
    );

    await reposCubit.init();
  });

  tearDown(() async {
    await reposCubit.close();
    await session.close();
  });

  testWidgets('create repository', (tester) async {
    // NOTE: We need to construct the completer inside `runAsync` otherwise its future would never
    // complete.
    final onSuccess =
        (await tester.runAsync(() => Future.value(Completer<RepoLocation>())))!;

    await tester.pumpWidget(MaterialApp(
      home: RepositoryCreation(
        reposCubit: reposCubit,
        onSuccess: onSuccess.complete,
      ),
      localizationsDelegates: const [S.delegate],
    ));
    await tester.pumpAndSettle();

    final nameField = find.byKey(ValueKey('name'));
    final useCacheServersField = find.descendant(
      of: find.byKey(ValueKey('use-cache-servers')),
      matching: find.byType(Switch),
    );

    await tester.enterText(nameField, 'my repo');
    await tester.tap(useCacheServersField);
    await tester.pumpAndSettle();

    // Verify that use cache servers is off:
    expect(tester.widget<Switch>(useCacheServersField).value, isFalse);

    await tester.runAsync(() async {
      await tester.tap(find.text('CREATE'));
      await onSuccess.future.timeout(const Duration(seconds: 10));
    });

    final repoEntry =
        reposCubit.repos.where((entry) => entry.name == 'my repo').firstOrNull;

    expect(
      repoEntry,
      isA<OpenRepoEntry>()
          .having(
            (e) => e.cubit.state.accessMode,
            'cubit.state.accessMode',
            equals(AccessMode.write),
          )
          .having(
            (e) => e.cubit.state.isCacheServersEnabled,
            'cubit.state.isCacheServersEnabled',
            isFalse,
          ),
    );
  });

  testWidgets('attempt to create repository with existing name',
      (tester) async {
    final name = 'le repo';

    await tester.runAsync(() async => await reposCubit.createRepository(
          location: RepoLocation.fromParts(
            dir: await reposCubit.settings.getDefaultRepositoriesDir(),
            name: name,
          ),
          setLocalSecret: LocalSecretKeyAndSalt.random(),
          localSecretMode: LocalSecretMode.randomStored,
        ));

    final onFailure = (await tester.runAsync(() => Future.value(Completer())))!;

    await tester.pumpWidget(MaterialApp(
      home: RepositoryCreation(
        reposCubit: reposCubit,
        onFailure: onFailure.complete,
      ),
      localizationsDelegates: const [S.delegate],
    ));
    await tester.pumpAndSettle();

    final nameField = find.byKey(ValueKey('name'));
    await tester.enterText(nameField, name);

    await tester.runAsync(() async {
      await tester.tap(find.text('CREATE'));
      await onFailure.future.timeout(const Duration(seconds: 10));
    });

    await tester.pumpAndSettle();

    expect(find.text('There is already a repository with this name'), findsOne);
    expect(reposCubit.repos.length, equals(1));
  });
}
