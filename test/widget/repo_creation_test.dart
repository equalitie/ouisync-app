import 'dart:io' show Directory;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/local_secret.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/utils/share_token.dart';
import 'package:ouisync/ouisync.dart'
    show AccessMode, LocalSecretKeyAndSalt, Repository, Session, SessionKind;
import 'package:path/path.dart' show join;

import '../utils.dart';

void main() {
  late TestDependencies deps;

  setUp(() async {
    deps = await TestDependencies.create();
  });

  tearDown(() async {
    await deps.dispose();
  });

  testWidgets(
    'create repository without password',
    (tester) => tester.runAsync(
      () async {
        final repoCreationObserver = StateObserver.install<RepoCreationState>();

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('CREATE REPOSITORY'));
        await tester.pumpAndSettle();

        // Filling in the repo name triggers an async operation and so we must explicitly wait until
        // it completes.
        await tester.enterText(find.byKey(ValueKey('name')), 'my repo');
        await repoCreationObserver.waitUntil(
            (state) => !state.loading && state.substate is RepoCreationValid);
        await tester.pump();

        await tester.tap(find.descendant(
          of: find.byKey(ValueKey('use-cache-servers')),
          matching: find.byType(Switch),
        ));
        await tester.pump();

        // Verify that use cache servers is off:
        await repoCreationObserver.waitUntil((state) => !state.useCacheServers);

        await tester.tap(find.text('CREATE'));

        await repoCreationObserver
            .waitUntil((state) => state.substate is RepoCreationSuccess);

        final repoCubit = deps.reposCubit.repos
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

        final repoCreationObserver = StateObserver.install<RepoCreationState>();

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('CREATE REPOSITORY'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(ValueKey('name')), name);
        await repoCreationObserver.waitUntil((state) => !state.loading);
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

        await repoCreationObserver
            .waitUntil((state) => state.substate is RepoCreationSuccess);

        final repoCubit = deps.reposCubit.repos
            .where((entry) => entry.name == name)
            .first
            .cubit!;
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

        final repoCreationObserver = StateObserver.install<RepoCreationState>();

        await deps.reposCubit.createRepository(
          location: RepoLocation.fromParts(
            dir: await deps.reposCubit.settings.getDefaultRepositoriesDir(),
            name: name,
          ),
          setLocalSecret: LocalSecretKeyAndSalt.random(),
          localSecretMode: LocalSecretMode.randomStored,
        );

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create repository'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(ValueKey('name')), name);
        await repoCreationObserver.waitUntil((state) =>
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

        final repoCreationObserver = StateObserver.install<RepoCreationState>();
        final repoImportObserver = StateObserver.install<ShareTokenResult?>();

        expect(deps.reposCubit.repos, isEmpty);

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('IMPORT REPOSITORY'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(ValueKey('token')), token);
        await repoImportObserver.waitUntil((state) => state is ShareTokenValid);
        await tester.pumpAndSettle();

        // The repo token is shown.
        expect(
          find.descendant(
            of: find.widgetWithText(Container, 'Repository link: '),
            matching: find.text(token),
          ),
          findsOne,
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'IMPORT A REPOSITORY'));
        await tester.pump();

        await repoCreationObserver
            .waitUntil((state) => !state.loading && state.token != null);
        await tester.pump();

        expect(find.widgetWithText(TextFormField, token), findsOne);

        // The name field is autofilled with the suggested name.
        expect(
          find.descendant(
            of: find.byKey(ValueKey('name')),
            matching: find.text(name),
          ),
          findsOne,
        );
        await tester.pump();

        // Remove the suggested name before testing the tap function
        await tester.enterText(find.byKey(ValueKey('name')), "");
        await tester.pumpAndSettle();

        await repoCreationObserver.waitUntil((state) => !state.loading);

        // The name field is empty.
        expect(
          find.descendant(
            of: find.byKey(ValueKey('name')),
            matching: find.text(""),
          ),
          findsOne,
        );

        // The suggesten name is shown.
        final suggestedName =
            find.text('Suggested: $name\n(tap here to use this name)');
        expect(suggestedName, findsOne);

        // Tap on the suggested name and wait until it gets applied.
        await tester.tap(suggestedName);
        await repoCreationObserver
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
        await repoCreationObserver
            .waitUntil((state) => state.substate is RepoCreationSuccess);

        // The repo got created correctly.
        final repoCubit = deps.reposCubit.repos.first.cubit!;
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
