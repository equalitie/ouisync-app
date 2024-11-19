import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:ouisync_app/app/cubits/cubits.dart' show RepoCubit;
import 'package:ouisync_app/app/models/models.dart'
    show LocalSecretMode, LocalSecretKeyAndSalt, RepoEntry, RepoLocation;
import 'package:ouisync/ouisync.dart' show AccessMode, File, Repository;

import '../utils.dart' show BlocBaseExtension, TestDependencies, testApp;

void main() {
  late TestDependencies deps;

  final String originRepoName = 'origin';
  final String blindRepoName = 'destination';

  late Repository originRepo;
  late RepoEntry blindRepoEntry;

  setUp(() async {
    deps = await TestDependencies.create();

    final reposDir = await deps.reposCubit.settings.getDefaultRepositoriesDir();

    final originRepoLocation = RepoLocation.fromParts(
      dir: reposDir,
      name: originRepoName,
    );

    final blindRepoLocation = RepoLocation.fromParts(
      dir: reposDir,
      name: blindRepoName,
    );

    await deps.reposCubit.createRepository(
      location: originRepoLocation,
      setLocalSecret: LocalSecretKeyAndSalt.random(),
      localSecretMode: LocalSecretMode.randomStored,
    );

    blindRepoEntry = await deps.reposCubit.createRepository(
      location: blindRepoLocation,
      setLocalSecret: LocalSecretKeyAndSalt.random(),
      localSecretMode: LocalSecretMode.randomStored,
    );

    await blindRepoEntry.cubit?.lock();

    originRepo = await Repository.open(
      deps.session,
      store: originRepoLocation.path,
    );

    final newFile = await File.create(originRepo, '/file.txt');
    await newFile.write(0, 'Hello world!'.codeUnits);
    await newFile.close();
  });

  tearDown(() async {
    await blindRepoEntry.close();
    await originRepo.close();
    await deps.dispose();
  });

  testWidgets(
    'move file to a blind/locked repo and confirm that MOVE button is disabled',
    (tester) => tester.runAsync(
      () async {
        await loadAppFonts();

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();

        expect(find.text(originRepoName), findsOne);
        expect(find.text(blindRepoName), findsOne);

        final originRepoCubit = deps.reposCubit.repos
            .firstWhere((r) => r.name == originRepoName)
            .cubit!;

        await tester.tap(find.text(originRepoName));
        await _waitForNavigationIntoRepoToEnd(deps, tester, originRepoCubit);

        final fileVert = find.byKey(ValueKey('file_vert'));
        expect(fileVert, findsOne);

        await tester.tap(fileVert);
        await tester.pumpAndSettle();

        final moveListTile = find.widgetWithText(ListTile, 'Move');
        expect(moveListTile, findsOne);

        await tester.tap(moveListTile);
        await tester.pumpAndSettle();

        final backButton = find.widgetWithIcon(
          IconButton,
          Icons.arrow_back_rounded,
        );
        expect(backButton, findsOne);

        await tester.tap(backButton);
        await tester.pumpAndSettle();

        final destinationRepoCubit = deps.reposCubit.repos
            .firstWhere((r) => r.name == blindRepoName)
            .cubit!;

        await tester.tap(find.text(blindRepoName));
        await _waitForNavigationIntoRepoToEnd(
          deps,
          tester,
          destinationRepoCubit,
        );

        final currentRepoEntry = deps.reposCubit.currentRepo;
        expect(currentRepoEntry?.accessMode, equals(AccessMode.blind));

        final moveButton = find.descendant(
          of: find.byKey(ValueKey('move_entry')),
          matching: find.byWidgetPredicate(
            (widget) => widget is RawMaterialButton,
          ),
        );
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
