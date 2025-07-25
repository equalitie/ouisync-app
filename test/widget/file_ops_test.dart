import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/models/auth_mode.dart';
import 'package:ouisync_app/app/models/repo_location.dart';
import 'package:ouisync_app/app/widgets/dialogs/modal_entry_actions_bottom_sheet.dart'
    show EntryActions;
import 'package:ouisync_app/app/widgets/dialogs/modal_rename_or_replace_entry_dialog.dart'
    show RenameOrReplaceEntryDialog;
import 'package:ouisync_app/app/widgets/items/entry_action_item.dart'
    show EntryActionItem;
import 'package:ouisync_app/app/widgets/dialogs/entries_actions_bottom_sheet.dart'
    show EntriesActionsDialog;
import 'package:ouisync_app/app/widgets/buttons/dialog_positive_button.dart'
    show PositiveButton;
import 'package:ouisync/ouisync.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:styled_text/styled_text.dart';

import '../utils.dart';
import '../navigation.dart';
import '../fake_file_picker.dart';

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

      await repoPage.addFile(tempFile.path);
      await repoPage.addFolder(dstDir);
      await repoPage.tapBackButton();

      Future<void> copyFile(String file, String dstDir) async {
        await repoPage.tapEntryActions(file);

        final findCopyButton = find.ancestor(
          of: find.byIcon(Icons.copy_outlined),
          matching: find.byType(EntryActionItem),
        );

        final copy = await tester.pumpUntilFound(findCopyButton);
        await tester.anxiousTap(await tester.pumpUntilFound(copy));
        await repoPage.tapFolder(dstDir);

        final copyButton = await tester.pumpUntilFound(
          find.descendant(
            of: find.byType(EntriesActionsDialog),
            matching: find.byType(PositiveButton),
          ),
        );
        await tester.tap(copyButton);
      }

      await copyFile(srcFileName, dstDir);
      await tester.pumpUntilNotFound(find.byType(EntryActions));
      await tester.pumpUntilFound(repoPage.findDirEntry(srcFileName));
      await repoPage.tapBackButton();

      // Wait until we get out of the folder
      await tester.pumpUntilFound(repoPage.findDirEntry(dstDir));

      await copyFile(srcFileName, dstDir);

      final alreadyExistsDialog = await tester.pumpUntilFound(
        find.byType(RenameOrReplaceEntryDialog),
      );
      await tester.anxiousTap(find.byType(PositiveButton));

      await tester.pumpUntilNotFound(find.byType(RenameOrReplaceEntryDialog));
      await tester.pumpUntilNotFound(find.byType(EntryActions));
      await tester.pumpUntilFound(repoPage.findDirEntry(srcFileName));

      await repoPage.tapBackButton();

      // Wait until we get out of the folder
      await tester.pumpUntilFound(repoPage.findDirEntry(dstDir));

      // TODO: Test that the source file is still there.
    }),
  );
}
