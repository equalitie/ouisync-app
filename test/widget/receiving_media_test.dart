import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/entry_bottom_sheet.dart';
import 'package:ouisync_app/app/cubits/repo.dart';
import 'package:ouisync_app/app/cubits/repo_creation.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/pages/main_page.dart';
import 'package:ouisync_app/app/widgets/buttons/dialog_negative_button.dart';
import 'package:ouisync_app/app/widgets/buttons/dialog_positive_button.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../utils.dart';

void main() {
  late TestDependencies deps;
  late StreamController<List<SharedMediaFile>> mediaReceiverController;

  setUp(() async {
    deps = await TestDependencies.create();
    mediaReceiverController = StreamController();
  });

  tearDown(() async {
    await mediaReceiverController.close();
    await deps.dispose();
  });

  MainPage createMainPage() =>
      deps.createMainPage(receivedMedia: mediaReceiverController.stream);

  Future<io.File> createFile({
    required String name,
    String content = '',
  }) async {
    final file = io.File(join((await getTemporaryDirectory()).path, name));
    await file.create(recursive: true);
    await file.writeAsString(content);

    return file;
  }

  Future<String> readRepoFileAsString(
    RepoCubit repoCubit,
    String path,
  ) async {
    final file = await repoCubit.openFile(path);

    try {
      return utf8.decode(await file.read(0, await file.getLength()));
    } finally {
      await file.close();
    }
  }

  testWidgets(
    'receive file from repo list with no repos',
    (tester) => tester.runAsync(
      () async {
        final file = await createFile(name: 'file.txt');

        await tester.pumpWidget(testApp(createMainPage()));
        await tester.pumpAndSettle();

        mediaReceiverController.add([
          SharedMediaFile(
            path: file.path,
            type: SharedMediaType.file,
          ),
        ]);

        await tester.pumpAndSettle();

        expect(find.text('Add file to Ouisync'), findsOne);

        // Verify the save button is disabled
        final saveButton = find.widgetWithText(PositiveButton, 'SAVE');
        expect(saveButton, findsOne);
        expect(tester.widget<PositiveButton>(saveButton).onPressed, isNull);

        // Cancel adding the file
        final cancelButton = find.widgetWithText(NegativeButton, 'CANCEL');
        expect(cancelButton, findsOne);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(find.text('Add file to Ouisync'), findsNothing);
      },
    ),
  );

  testWidgets(
    'receive file from repo list with some repos',
    (tester) => tester.runAsync(
      () async {
        final fileName = 'file.txt';
        final fileContent = 'Hello world';
        final file = await createFile(name: fileName, content: fileContent);

        final repoName = 'my repo';
        final repoEntry = await deps.reposCubit.createRepository(
          location: RepoLocation(
            dir: (await deps.session.getStoreDir())!,
            name: repoName,
          ),
          setLocalSecret: randomSetLocalSecret(),
          localSecretMode: LocalSecretMode.randomStored,
        );
        final repoCubit = repoEntry.cubit!;

        await tester.pumpWidget(testApp(createMainPage()));
        await tester.pumpAndSettle();

        mediaReceiverController.add([
          SharedMediaFile(
            path: file.path,
            type: SharedMediaType.file,
          ),
        ]);
        await tester.pumpAndSettle();

        await tester.tap(find.text(repoName));
        await deps.reposCubit.waitUntil(
          (state) => !state.isLoading && state.current == repoEntry,
        );
        await tester.pump();

        expect(find.widgetWithText(AppBar, repoName), findsOne);

        final saveButton = find.widgetWithText(PositiveButton, 'SAVE');
        expect(saveButton, findsOne);

        await tester.tap(saveButton);
        await repoCubit.waitUntil((state) => state.uploads.isNotEmpty);
        await repoCubit.waitUntil((state) => state.uploads.isEmpty);

        expect(find.text(fileName), findsOne);

        final actualFileContent =
            await readRepoFileAsString(repoCubit, fileName);
        expect(actualFileContent, equals(fileContent));
      },
    ),
  );

  testWidgets(
    'receive file from repo screen',
    (tester) => tester.runAsync(
      () async {
        final fileName = 'file.txt';
        final fileContent = 'Hello world';
        final file = await createFile(name: fileName, content: fileContent);

        final repoName = 'my repo';
        final repoEntry = await deps.reposCubit.createRepository(
          location: RepoLocation(
            dir: (await deps.session.getStoreDir())!,
            name: repoName,
          ),
          setLocalSecret: randomSetLocalSecret(),
          localSecretMode: LocalSecretMode.randomStored,
          // Set the repo as current so we start on the single repo screen, not on the repo list.
          setCurrent: true,
        );
        final repoCubit = repoEntry.cubit!;

        await tester.pumpWidget(testApp(createMainPage()));
        await deps.reposCubit.waitUntil(
          (state) => !state.isLoading && state.current == repoEntry,
        );
        await tester.pump();

        // Verify we are in the single repo screen
        expect(find.widgetWithText(AppBar, repoName), findsOne);

        mediaReceiverController.add([
          SharedMediaFile(
            path: file.path,
            type: SharedMediaType.file,
          ),
        ]);
        await deps.reposCubit.bottomSheet
            .waitUntil((state) => state is SaveMediaSheetState);
        await tester.pump();

        final saveButton = find.widgetWithText(PositiveButton, 'SAVE');
        await tester.tap(saveButton);
        await repoCubit.waitUntil((state) => state.uploads.isNotEmpty);
        await repoCubit.waitUntil((state) => state.uploads.isEmpty);

        expect(find.text(fileName), findsOne);

        final actualFileContent =
            await readRepoFileAsString(repoCubit, fileName);
        expect(actualFileContent, equals(fileContent));
      },
    ),
  );

  testWidgets(
    'receive repo',
    (tester) => tester.runAsync(
      () async {
        final repoName = 'new repo';
        final repoPath =
            join((await getTemporaryDirectory()).path, '$repoName.ouisyncdb');
        final repo = await deps.session.createRepository(
          path: repoPath,
          readSecret: null,
          writeSecret: null,
        );
        await repo.close();

        await tester.pumpWidget(testApp(createMainPage()));
        await tester.pumpAndSettle();

        expect(find.text(repoName), findsNothing);

        mediaReceiverController.add([
          SharedMediaFile(
            path: repoPath,
            type: SharedMediaType.file,
          ),
        ]);
        await deps.reposCubit.waitUntil((state) => state.repos.isNotEmpty);
        await tester.pumpAndSettle();

        expect(find.text(repoName), findsOne);
      },
    ),
  );

  for (final type in [SharedMediaType.text, SharedMediaType.url]) {
    testWidgets(
      'receive token as ${type.value}',
      (tester) => tester.runAsync(
        () async {
          final repoName = 'new repo';
          final repoPath =
              join((await getTemporaryDirectory()).path, '$repoName.ouisyncdb');
          final repo = await deps.session.createRepository(
            path: repoPath,
            readSecret: null,
            writeSecret: null,
          );
          final token = await repo.share(accessMode: AccessMode.read);
          await repo.close();

          final navigationObserver = NavigationObserver();
          final stateObserver = StateObserver.install<RepoCreationState>();

          await tester.pumpWidget(testApp(
            createMainPage(),
            navigatorObservers: [navigationObserver],
          ));
          await tester.pumpAndSettle();

          mediaReceiverController.add([
            SharedMediaFile(
              path: token.toString(),
              type: type,
            ),
          ]);

          // Wait for navigating to the repo creation page.
          await navigationObserver.waitForDepth(2);
          await tester.pump();

          // We should now be on the repo creation page. Wait until it loads.
          await stateObserver.waitUntil((state) => state.token != null);
          await tester.pumpAndSettle();

          // Apply the suggested name.
          await tester.tap(find.textContaining('Suggested: $repoName'));
          await stateObserver
              .waitUntil((state) => state.substate is RepoCreationValid);
          await tester.pumpAndSettle();

          // Create the repo
          await tester.tap(find.text('IMPORT'));
          await stateObserver
              .waitUntil((state) => state.substate is RepoCreationSuccess);

          expect(
            deps.reposCubit.state.repos.values
                .where((entry) => entry.name == repoName),
            isNotEmpty,
          );
        },
      ),
    );
  }
}
