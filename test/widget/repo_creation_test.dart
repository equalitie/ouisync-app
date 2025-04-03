import 'dart:io' show Directory;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/utils/share_token.dart';
import 'package:ouisync/ouisync.dart' show AccessMode, Session;
import 'package:path/path.dart' show join;

import '../utils.dart';

void main() {
  late TestDependencies deps;

  setUp(() async {
    deps = await TestDependencies.create();
    await deps.reposCubit.waitUntil((state) => !state.isLoading);
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
        await repoCreationObserver
            .waitUntil((state) => state.substate is RepoCreationValid);
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

        final repoCubit = deps.reposCubit.state.repos.values
            .where((entry) => entry.name == 'my repo')
            .first
            .cubit!;

        expect(repoCubit.state.accessMode, equals(AccessMode.write));
        expect(repoCubit.state.isCacheServersEnabled, isFalse);
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
          location: RepoLocation(
            dir: (await deps.session.getStoreDir())!,
            name: name,
          ),
          setLocalSecret: randomSetLocalSecret(),
          localSecretMode: LocalSecretMode.randomStored,
        );

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create repository'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(ValueKey('name')), name);
        await repoCreationObserver
            .waitUntil((state) => switch (state.substate) {
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

        expect(deps.reposCubit.state.repos, isEmpty);

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

        await tester
            .tap(find.widgetWithText(ElevatedButton, 'IMPORT A REPOSITORY'));
        await tester.pump();

        await repoCreationObserver.waitUntil((state) => state.token != null);
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
        await repoCreationObserver.waitUntil((state) => state.name == name);

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
        final repoCubit = deps.reposCubit.state.repos.values.first.cubit!;
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
  final session = await Session.create(configPath: join(dir.path, 'config'));

  try {
    final repo = await session.createRepository(
      path: join(dir.path, 'store', name),
      readSecret: null,
      writeSecret: null,
    );

    final token = await repo.share(accessMode: accessMode);
    return token.toString();
  } finally {
    await session.close();
    await dir.delete(recursive: true);
  }
}
