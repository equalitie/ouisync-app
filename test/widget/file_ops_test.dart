import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/widgets/dialogs/modal_entry_actions_bottom_sheet.dart'
    show EntryActions;
import 'package:ouisync_app/app/widgets/dialogs/modal_rename_or_replace_entry_dialog.dart'
    show RenameOrReplaceEntryDialog;
import 'package:ouisync_app/app/widgets/items/entry_action_item.dart'
    show EntryActionItem;
import 'package:ouisync_app/app/widgets/dialogs/entries_actions_bottom_sheet.dart'
    show EntriesActionsDialog;
import 'package:ouisync_app/app/widgets/buttons/dialog_action_button.dart'
    show PositiveButton;
import 'package:ouisync_app/app/models/repo_entry.dart' show OpenRepoEntry;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils.dart';
import '../navigation.dart';

Future<io.File> _createTempFile(String name) async {
  final path = (await getTemporaryDirectory()).path;
  final file = await io.File(p.join(path, name)).create(recursive: true);
  await file.writeAsString("Lorem ipsum");
  return file;
}

void main() {
  late TestDependencies deps;

  setUp(() async {
    deps = await TestDependencies.create();
  });

  tearDown(() async {
    await deps.dispose();
  });

  // Copy a file to a folder twice, the second time overwriting it.
  testWidgets(
    'copy_file_twice_with_overwrite',
    (tester) => tester.runAsyncDebug(() async {
      await tester.loadFonts();

      final mainPage = MainPage(tester, deps);
      final repoPage = await mainPage.createAndEnterRepository();

      final srcFileName = 'file.txt';
      final dstDir = 'folder';

      final tempFile = await _createTempFile(srcFileName);

      String? currentFolder() {
        final state = deps.reposCubit.state;
        final repoEntry = state.current;
        if (repoEntry is! OpenRepoEntry) return null;
        return repoEntry.cubit.state.currentFolder.path;
      }

      Future<void> enteredFolder(String absoluteDirPath) async {
        await tester.pumpUntil(() {
          return currentFolder() == absoluteDirPath;
        });
      }

      await repoPage.addFile(tempFile.path);
      await repoPage.addFolder(dstDir);
      await enteredFolder("/folder");
      await repoPage.tapBackButton();
      await enteredFolder("/");

      Future<void> copyFile(String file, String dstDir) async {
        await repoPage.tapEntryActions(file);

        final findCopyButton = find.ancestor(
          of: find.byIcon(Icons.copy_outlined),
          matching: find.byType(EntryActionItem),
        );

        final copyAction = await tester.pumpUntilFound(findCopyButton);
        await tester.anxiousTap(copyAction);
        await repoPage.tapFolder(dstDir);

        await enteredFolder("/$dstDir");

        final copyButton = await tester.pumpUntilFound(
          find.descendant(
            of: find.byType(EntriesActionsDialog),
            matching: find.byType(PositiveButton),
          ),
        );

        await tester.anxiousTap(copyButton);
      }

      await copyFile(srcFileName, dstDir);
      await tester.pumpUntilNotFound(find.byType(EntryActions));
      await enteredFolder("/$dstDir");
      await repoPage.tapBackButton();
      await enteredFolder("/");

      // Check we did not move the file
      await tester.pumpUntilFound(repoPage.findDirEntry(srcFileName));

      await copyFile(srcFileName, dstDir);

      final dialogFinder = await tester.pumpUntilFound(
        find.byType(RenameOrReplaceEntryDialog),
      );

      await tester.anxiousTap(
        find.descendant(
          of: dialogFinder,
          matching: find.byKey(Key('replace_entry_radio_tile')),
        ),
      );
      await tester.anxiousTap(
        find.descendant(
          of: dialogFinder,
          matching: find.byType(PositiveButton),
        ),
      );

      await tester.pumpUntilNotFound(find.byType(RenameOrReplaceEntryDialog));
      await tester.pumpUntilNotFound(find.byType(EntryActions));
      await tester.pumpUntilFound(repoPage.findDirEntry(srcFileName));

      await repoPage.tapBackButton();
      await enteredFolder("/");

      // Check we did not move the file
      await tester.pumpUntilFound(repoPage.findDirEntry(srcFileName));
    }),
  );
}
