import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';
import 'package:ouisync_app/app/widgets/widgets.dart'
    show DisambiguationAction, ReplaceKeepEntry;
import 'package:path/path.dart' as p;

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show RepoCubit;
import 'utils.dart' show AppThemeExtension, Fields, ThemeGetter;

mixin EntryOps {
  Future<DisambiguationAction?> pickEntryDisambiguationAction(
    BuildContext context,
    String entryName,
    EntryType entryType,
  ) async =>
      await showDialog<DisambiguationAction?>(
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
