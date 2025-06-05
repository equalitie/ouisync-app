import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_text/styled_text.dart';

import '../utils.dart';

void main() {
  late TestDependencies deps;

  setUp(() async {
    deps = await TestDependencies.create();
  });

  tearDown(() async {
    await deps.dispose();
  });

  Future<RepoLocation> createExportedRepo([
    String name = 'exported-repo',
  ]) async {
    final location = RepoLocation(
      dir: (await getTemporaryDirectory()).path,
      name: name,
    );
    final repo = await deps.session.createRepository(
      path: location.path,
      readSecret: null,
      writeSecret: null,
    );
    await repo.setAccess(write: AccessChangeDisable());
    await repo.close();

    return location;
  }

  testWidgets(
    'import repo when no repos exists',
    (tester) => tester.runAsync(
      () async {
        final location = await createExportedRepo();

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('IMPORT REPOSITORY'));
        await tester.pumpAndSettle();

        // Mock file picker
        FilePicker.platform = _FakeFilePicker(location.path);

        final locateButton = find.text('LOCATE');
        await tester.ensureVisible(locateButton);
        await tester.tap(locateButton);
        await deps.reposCubit.waitUntil((state) => state.repos.isNotEmpty);
        await deps.reposCubit
            .waitUntil((state) => state.current?.location == location);

        // TODO: Test that the bottom sheet is closed and the repo list now contains the imported
        // repo. Problem is that calling `pumpAndSettle` here throws timeout exception and calling
        // just `pump` doesn't refresh the page for some reason, which makes it difficult to test
        // this. Figure it out.

        //expect(find.widgetWithText(InkWell, location.name), findsOne);
      },
    ),
  );

  testWidgets(
    'import repo when some repos exists',
    (tester) => tester.runAsync(
      () async {
        // Create existing repo
        final existingLocation = RepoLocation(
          dir: (await deps.session.getStoreDir())!,
          name: 'some repo',
        );
        await deps.reposCubit.createRepository(
          location: existingLocation,
          setLocalSecret: randomSetLocalSecret(),
          localSecretMode: LocalSecretMode.randomStored,
        );

        // Create repo to be imported
        final exportedLocation = await createExportedRepo();

        expect(deps.reposCubit.state.repos, hasLength(1));

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();

        final importButton =
            find.widgetWithText(GestureDetector, 'Import repository');
        await tester.tap(importButton);
        await tester.pumpAndSettle();

        // Mock file picker
        FilePicker.platform = _FakeFilePicker(exportedLocation.path);

        final locateButton = find.text('LOCATE');
        await tester.ensureVisible(locateButton);
        await tester.tap(locateButton);

        await deps.reposCubit.waitUntil((state) => state.repos.length == 2);
        await deps.reposCubit
            .waitUntil((state) => state.current?.location == exportedLocation);

        // TODO: Test that the bottom sheet is closed and the repo list now contains both repos.
        // Problem is that calling `pumpAndSettle` here throws timeout exception and calling just
        // `pump` doesn't refresh the page for some reason, which makes it difficult to test this.
        // Figure it out.
      },
    ),
  );

  testWidgets(
    'lock and unlock imported repo without password',
    (tester) => tester.runAsync(
      () async {
        final location = await createExportedRepo();

        await deps.reposCubit.waitUntil((state) => !state.isLoading);
        await deps.reposCubit.importRepoFromLocation(location);

        final repoEntry = deps.reposCubit.state.repos[location];
        final repoCubit = repoEntry!.cubit!;

        await tester.pumpWidget(testApp(deps.createMainPage()));
        await tester.pumpAndSettle();
        await deps.reposCubit.waitUntil((state) => !state.isLoading);

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
        await deps.reposCubit.waitUntil((state) => state.current == repoEntry);
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

/// Fake FilePicker instance that simulates picking the given file.
class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this.pickedFile);

  final String pickedFile;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    final name = basename(pickedFile);
    final size = await io.File(pickedFile).length();

    return FilePickerResult([
      PlatformFile(
        path: pickedFile,
        name: name,
        size: size,
      )
    ]);
  }
}
