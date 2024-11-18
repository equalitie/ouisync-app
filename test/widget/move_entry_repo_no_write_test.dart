import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:ouisync_app/app/cubits/repo.dart';
import 'package:ouisync_app/app/models/models.dart';
import 'package:ouisync/ouisync.dart' show AccessMode, File, Repository;

import '../utils.dart'
    show BlocBaseExtension, TestDependencies, WidgetTesterExtension, testApp;

void main() {
  late TestDependencies deps;

  late String originRepoName = 'origin';
  late String destinationName = 'destination';

  setUp(() async {
    deps = await TestDependencies.create();

    final reposDir = await deps.reposCubit.settings.getDefaultRepositoriesDir();

    originRepoName = 'origin';
    final originRepoLocation = RepoLocation.fromParts(
      dir: reposDir,
      name: originRepoName,
    );

    destinationName = 'destination';
    final blindRepoLocation = RepoLocation.fromParts(
      dir: reposDir,
      name: destinationName,
    );

    await deps.reposCubit.createRepository(
      location: originRepoLocation,
      setLocalSecret: LocalSecretKeyAndSalt.random(),
      localSecretMode: LocalSecretMode.randomStored,
    );

    await deps.reposCubit.createRepository(
      location: blindRepoLocation,
      setLocalSecret: LocalSecretKeyAndSalt.random(),
      localSecretMode: LocalSecretMode.randomStored,
    );

    final originRepo = await Repository.open(
      deps.session,
      store: originRepoLocation.path,
    );

    final newFile = await File.create(originRepo, '/file.txt');
    await newFile.write(0, 'Hello world!'.codeUnits);
    await newFile.close();
  });

  tearDown(() async {
    await deps.dispose();
  });

  testWidgets(
    'move file to a repo and confirm that MOVE button is disabled when locked',
    (tester) => tester.runAsync(
      () async {
        await loadAppFonts();

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();

        expect(find.text(originRepoName), findsOne);
        expect(find.text(destinationName), findsOne);

        final originRepo = deps.reposCubit.repos
            .firstWhere((r) => r.name == originRepoName)
            .cubit!;

        await tester.tap(find.text(originRepoName));
        await _waitForNavigationIntoRepoToEnd(deps, tester, originRepo);

        final vert = find.byKey(ValueKey('file_vert'));
        expect(vert, findsOne);

        await tester.tap(vert);
        await tester.pumpAndSettle();

        final move = find.widgetWithText(ListTile, 'Move');
        expect(move, findsOne);

        await tester.tap(move);
        await tester.pumpAndSettle();

        final backButton = find.widgetWithIcon(
          IconButton,
          Icons.arrow_back_rounded,
        );
        expect(backButton, findsOne);

        await tester.tap(backButton);
        await tester.pumpAndSettle();

        final destinationRepo = deps.reposCubit.repos
            .firstWhere((r) => r.name == destinationName)
            .cubit!;

        await tester.tap(find.text(destinationName));
        await _waitForNavigationIntoRepoToEnd(deps, tester, destinationRepo);

        await tester.takeScreenshot('repo_blind0');

        expect(destinationRepo.state.accessMode, equals(AccessMode.write));

        final lockButton = find.byKey(ValueKey('lock_repo_icon'));
        expect(lockButton, findsOne);

        await tester.tap(lockButton);

        await deps.reposCubit.currentRepo?.cubit?.waitUntil((_) =>
            deps.reposCubit.currentRepo?.cubit?.state.accessMode ==
            AccessMode.blind);
        await tester.pumpAndSettle();
        await tester.pump(Duration(seconds: 1));

        await tester.takeScreenshot('repo_blind1');

        expect(destinationRepo.state.accessMode, equals(AccessMode.blind));
        expect(
            deps.reposCubit.currentRepo?.accessMode, equals(AccessMode.blind));

        await tester.pumpAndSettle();

        await tester.tap(backButton);
        await tester.pumpAndSettle();

        await tester.takeScreenshot('repo_blind2');

        await tester.tap(find.text(destinationName));
        await tester.pump(Duration(seconds: 1));

        await _waitForNavigationIntoRepoToEnd(deps, tester, destinationRepo);

        await tester.takeScreenshot('repo_blind3');

        final moveButton = find.descendant(
            of: find.byKey(ValueKey('move_entry')),
            matching: find
                .byWidgetPredicate((widget) => widget is RawMaterialButton));
        expect(moveButton, findsOne);
        expect(tester.widget<RawMaterialButton>(moveButton).enabled, false);
      },
    ),
  );
}

Future<void> _waitForNavigationIntoRepoToEnd(
  TestDependencies deps,
  WidgetTester tester,
  RepoCubit repo,
) async {
  await deps.reposCubit.waitUntil((_) =>
      !deps.reposCubit.isLoading &&
      deps.reposCubit.currentRepo?.name == repo.name);
  await tester.pump();

  await deps.reposCubit.currentRepo?.cubit?.waitUntil(
      (_) => deps.reposCubit.currentRepo?.cubit?.state.isLoading == false);
  await tester.pumpAndSettle();
  await tester.pump(Duration(seconds: 1));
}
