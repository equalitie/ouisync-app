import 'package:flutter/material.dart';
import 'package:ouisync_app/app/utils/utils.dart';
import 'package:ouisync/ouisync.dart';

import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../widgets/dialogs/modal_replace_keep_entry_dialog.dart';

mixin EntryOps {
  Future<FileAction?> getFileActionType(
    BuildContext context,
    String entryName,
    String entryPath,
    EntryType entryType,
  ) async =>
      await showDialog<FileAction?>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Flex(
            direction: Axis.horizontal,
            children: [
              Fields.constrainedText(
                S.current.titleMovingEntry,
                style: context.theme.appTextStyle.titleMedium,
                maxLines: 2,
              )
            ],
          ),
          content: ReplaceKeepEntry(name: entryName, type: entryType),
        ),
      );

  Future<String> disambiguateEntryName({
    required RepoCubit repoCubit,
    required String path,
    int versions = 0,
  }) async {
    final parent = p.dirname(path);
    final name = p.basenameWithoutExtension(path);
    final extension = p.extension(path);

    final newFileName = '$name (${versions += 1})$extension';
    final newPath = p.join(parent, newFileName);

    if (await repoCubit.entryExists(newPath)) {
      return await disambiguateEntryName(
        repoCubit: repoCubit,
        path: path,
        versions: versions,
      );
    }
    return newPath;
  }
}
