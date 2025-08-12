import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/cubits/repo.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';

import '../utils.dart';

void main() {
  late TestDependencies deps;
  late RepoCubit repoCubit;

  setUp(() async {
    deps = await TestDependencies.create();

    final repoEntry = await deps.reposCubit.createRepository(
      location: RepoLocation(
        dir: (await deps.session.getStoreDir())!,
        name: 'Foo',
      ),
      setLocalSecret: randomSetLocalSecret(),
      localSecretMode: LocalSecretMode.randomStored,
    );
    await deps.reposCubit.setCurrent(repoEntry);

    repoCubit = repoEntry.cubit!;
  });

  tearDown(() async {
    await deps.dispose();
  });

  testWidgets(
    'successful rename',
    (tester) => tester.runAsync(() async {
      await tester.pumpWidget(testApp(deps.createMainPage()));
      await tester.pumpAndSettle();

      final settingButton = await tester.pumpUntilFound(
        find.byKey(ValueKey('settings')),
      );
      await tester.tap(settingButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(ValueKey('new-name')), 'Bar');
      await tester.pumpAndSettle();

      await tester.tap(find.text('RENAME'));
      await tester.pumpUntilFound(find.text('Repository renamed as Bar'));

      expect(repoCubit.location.name, equals('Bar'));
    }),
  );
}
