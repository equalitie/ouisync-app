import 'dart:io' show Directory;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/utils/share_token.dart';
import 'package:ouisync/ouisync.dart' show AccessMode, Session, Server;
import 'package:path/path.dart' show join;

import '../sandbox.dart' show deleteTempDir;
import '../utils.dart';
import '../navigation.dart';

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
    'create_repository_without_password',
    (tester) => tester.runAsyncDebug(() async {
      final mainPage = MainPage(tester, deps);
      await mainPage.createAndEnterRepository();
    }),
  );

  testWidgets(
    'attempt_to_create_repository_with_existing_name',
    (tester) => tester.runAsync(() async {
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

      await tester.anxiousTap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      await tester.anxiousTap(find.text('Create repository'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(ValueKey('name')), name);
      await repoCreationObserver.waitUntil(
        (state) => switch (state.substate) {
          RepoCreationPending(nameError: final nameError)
              when nameError != null && nameError.isNotEmpty =>
            true,
          _ => false,
        },
      );

      await tester.pump();

      expect(
        find.text('There is already a repository with this name'),
        findsOne,
      );
    }),
  );

  testWidgets(
    'import repository with token',
    (tester) => tester.runAsync(() async {
      final name = 'le repo';
      final token = await _createShareToken(
        name: name,
        accessMode: AccessMode.read,
      );

      final repoCreationObserver = StateObserver.install<RepoCreationState>();
      final repoImportObserver = StateObserver.install<ShareTokenResult?>();

      expect(deps.reposCubit.state.repos, isEmpty);

      await tester.pumpWidget(testApp(deps.createMainPage()));
      await tester.pumpAndSettle();

      await tester.anxiousTap(find.text('IMPORT REPOSITORY'));
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

      await tester.anxiousTap(
        find.widgetWithText(ElevatedButton, 'IMPORT A REPOSITORY'),
      );
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
      final suggestedName = find.text(
        'Suggested: $name\n(tap here to use this name)',
      );
      expect(suggestedName, findsOne);

      // Tap on the suggested name and wait until it gets applied.
      await tester.anxiousTap(suggestedName);
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
      await tester.anxiousTap(find.text('IMPORT'));
      await repoCreationObserver.waitUntil(
        (state) => state.substate is RepoCreationSuccess,
      );

      // The repo got created correctly.
      final repoCubit = deps.reposCubit.state.repos.values.first.cubit!;
      final actualMode = repoCubit.state.accessMode;
      final actualToken = await repoCubit.createShareToken(AccessMode.read);

      expect(actualMode, equals(AccessMode.read));
      expect(actualToken.toString(), equals(token));
    }),
  );
}

Future<String> _createShareToken({
  required String name,
  required AccessMode accessMode,
}) async {
  final dir = await Directory.systemTemp.createTemp();
  final configPath = join(dir.path, 'config');

  final server = Server.create(configPath: configPath);

  try {
    await server.start();
    final session = await Session.create(configPath: configPath);

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
      await server.stop();
    }
  } finally {
    await deleteTempDir(dir);
  }
}
