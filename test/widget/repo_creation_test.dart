import 'dart:io' show Directory;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/entry_bottom_sheet.dart';
import 'package:ouisync_app/app/cubits/navigation.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/cubits/repos.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/local_secret.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/widgets/repo_creation.dart';
import 'package:ouisync_app/app/utils/cache_servers.dart';
import 'package:ouisync_app/app/utils/master_key.dart';
import 'package:ouisync_app/app/utils/settings/settings.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart'
    show AccessMode, LocalSecretKeyAndSalt, Repository, Session, SessionKind;
import 'package:ouisync_plugin/native_channels.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import '../utils.dart';

void main() {
  late Session session;
  late ReposCubit reposCubit;
  late RepoCreationCubit repoCreationCubit;

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

    repoCreationCubit = RepoCreationCubit(reposCubit: reposCubit);
  });

  tearDown(() async {
    await repoCreationCubit.close();
    await reposCubit.close();
    await session.close();
  });

  testWidgets(
    'create repository without password',
    (tester) => tester.runAsync(
      () async {
        await tester.pumpWidget(testApp(RepoCreation(repoCreationCubit)));
        await tester.pumpAndSettle();

        // Filling in the repo name triggers an async operation and so we must explicitly wait until
        // it completes.
        await tester.enterText(find.byKey(ValueKey('name')), 'my repo');
        await repoCreationCubit.waitUntil(
            (state) => !state.loading && state.substate is RepoCreationValid);
        await tester.pump();

        await tester.tap(find.descendant(
          of: find.byKey(ValueKey('use-cache-servers')),
          matching: find.byType(Switch),
        ));
        await tester.pump();

        // Verify that use cache servers is off:
        expect(repoCreationCubit.state.useCacheServers, isFalse);

        await tester.tap(find.text('CREATE'));

        await repoCreationCubit
            .waitUntil((state) => state.substate is RepoCreationSuccess);

        final repoCubit = reposCubit.repos
            .where((entry) => entry.name == 'my repo')
            .first
            .cubit!;

        expect(repoCubit.state.accessMode, equals(AccessMode.write));
        expect(repoCubit.state.isCacheServersEnabled, isFalse);
      },
    ),
  );

  testWidgets(
    'create repository with password',
    (tester) => tester.runAsync(
      () async {
        final name = 'my repo';
        final password = 'supersecret';

        await tester.pumpWidget(testApp(RepoCreation(repoCreationCubit)));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(ValueKey('name')), name);
        await repoCreationCubit.waitUntil((state) => !state.loading);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(ValueKey('use-local-password')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(ValueKey('password')), password);
        await tester.enterText(
            find.byKey(ValueKey('retype-password')), password);
        await tester.pumpAndSettle();

        final submit = find.text('CREATE');
        await tester.ensureVisible(submit);
        await tester.tap(submit);

        await repoCreationCubit
            .waitUntil((state) => state.substate is RepoCreationSuccess);

        final repoCubit =
            reposCubit.repos.where((entry) => entry.name == name).first.cubit!;
        expect(repoCubit.state.accessMode, equals(AccessMode.write));

        await repoCubit.lock();
        expect(repoCubit.state.accessMode, equals(AccessMode.blind));

        await repoCubit.unlock(LocalPassword(password));
        expect(repoCubit.state.accessMode, equals(AccessMode.write));
      },
    ),
  );

  testWidgets(
    'attempt to create repository with existing name',
    (tester) => tester.runAsync(
      () async {
        final name = 'le repo';

        await reposCubit.createRepository(
          location: RepoLocation.fromParts(
            dir: await reposCubit.settings.getDefaultRepositoriesDir(),
            name: name,
          ),
          setLocalSecret: LocalSecretKeyAndSalt.random(),
          localSecretMode: LocalSecretMode.randomStored,
        );

        await tester.pumpWidget(testApp(RepoCreation(repoCreationCubit)));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(ValueKey('name')), name);
        await repoCreationCubit.waitUntil((state) =>
            !state.loading &&
            switch (state.substate) {
              RepoCreationPending(nameError: final nameError)
                  when nameError != null && nameError.isNotEmpty =>
                true,
              _ => false,
            });

        await tester.pump();

        expect(find.text('There is already a repository with this name'),
            findsOne);
      },
    ),
  );

  testWidgets(
    'import repository with token',
    (tester) => tester.runAsync(
      () async {
        final name = 'le repo';
        final token =
            await _createShareToken(name: name, accessMode: AccessMode.read);
        await repoCreationCubit.setInitialTokenValue(token.toString());

        await tester.pumpWidget(testApp(RepoCreation(repoCreationCubit)));
        await tester.pumpAndSettle();

        // The repo token is shown.
        expect(
          find.descendant(
            of: find.widgetWithText(Container, 'Repository link: '),
            matching: find.text(token.toString()),
          ),
          findsOne,
        );

        // The suggesten name is shown.
        final suggestedName =
            find.text('Suggested: $name\n(tap here to use this name)');
        expect(suggestedName, findsOne);

        // Tap on the suggested name and wait until it gets applied.
        await tester.tap(suggestedName);
        await repoCreationCubit
            .waitUntil((state) => !state.loading && state.name == name);

        await tester.pumpAndSettle();

        // The name field is now filled with the suggested name.
        expect(
          find.descendant(
            of: find.byKey(ValueKey('name')),
            matching: find.text(name),
          ),
          findsOne,
        );

        // Tap the "IMPORT" button and wait until the repo gets created.
        await tester.tap(find.text('IMPORT'));
        await repoCreationCubit
            .waitUntil((state) => state.substate is RepoCreationSuccess);

        // The repo got created correctly.
        final location = repoCreationCubit.state.location!;
        final repoCubit = reposCubit.get(location)!.cubit!;
        final actualMode = repoCubit.state.accessMode;
        final actualToken = await repoCubit.createShareToken(AccessMode.read);

        expect(actualMode, equals(AccessMode.read));
        expect(actualToken.toString(), equals(token));
      },
    ),
  );
}

Future<String> _createShareToken({
  required String name,
  required AccessMode accessMode,
}) async {
  final dir = await Directory.systemTemp.createTemp();
  final session = Session.create(
    kind: SessionKind.unique,
    configPath: join(dir.path, 'config'),
  );

  try {
    final repo = await Repository.create(
      session,
      store: join(dir.path, 'store', 'repo.ouisyncdb'),
      readSecret: null,
      writeSecret: null,
    );

    try {
      final token = await repo.createShareToken(
        name: name,
        accessMode: accessMode,
      );
      return token.toString();
    } finally {
      await repo.close();
    }
  } finally {
    await session.close();
    await dir.delete(recursive: true);
  }
}
