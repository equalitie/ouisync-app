import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class ReplaceKeepEntry extends StatelessWidget {
  ReplaceKeepEntry({required this.name, required this.type});

  final String name;
  final EntryType type;

  final _fileAction = ValueNotifier<FileAction>(FileAction.replace);

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.theme.appTextStyle.bodyMedium;

    final replaceMessage = type == EntryType.file
        ? S.current.messageReplaceExistingFile
        : S.current.messageReplaceExistingFolder;

    final keepMessage = type == EntryType.file
        ? S.current.messageKeepBothFiles
        : S.current.messageKeepBothFolders;

    _fileAction.value =
        type == EntryType.file ? FileAction.replace : FileAction.keep;

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Dimensions.spacingVerticalDouble,
          Text(S.current.messageFileAlreadyExist(name), style: bodyStyle),
          Dimensions.spacingVertical,
          ValueListenableBuilder(
            valueListenable: _fileAction,
            builder: (context, value, child) {
              return Column(children: [
                GestureDetector(
                  onTap: () {
                    if (type == EntryType.directory) {
                      showSnackBar(S.current.messageOnlyAvailableFiles);
                    }
                  },
                  child: RadioListTile<FileAction>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(replaceMessage, style: bodyStyle),
                    value: FileAction.replace,
                    groupValue: value,
                    onChanged:
                        type == EntryType.file ? _onFileActionChanged : null,
                  ),
                ),
                RadioListTile<FileAction>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(keepMessage, style: bodyStyle),
                  value: FileAction.keep,
                  groupValue: value,
                  onChanged: _onFileActionChanged,
                ),
              ]);
            },
          ),
          Dimensions.spacingVertical,
          Fields.dialogActions(context, buttons: _actions(context)),
        ]);
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(null),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
        PositiveButton(
            text: S.current.actionAccept,
            onPressed: () => Navigator.of(context).pop(_fileAction.value),
            buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton),
      ];

  void _onFileActionChanged(FileAction? value) =>
      _fileAction.value = value ?? FileAction.replace;
}

enum FileAction { replace, keep }
