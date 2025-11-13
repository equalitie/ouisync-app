import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show EntryType;

import '../../../generated/l10n.dart';
import '../../utils/stage.dart';
import '../../utils/utils.dart'
    show AppThemeExtension, Dimensions, Fields, ThemeGetter;
import '../widgets.dart' show NegativeButton, PositiveButton;

class RenameOrReplaceEntryDialog extends StatelessWidget {
  final String name;
  final EntryType type;
  final Stage stage;

  static const _defaultAction = RenameOrReplaceResult.rename;

  final _fileAction = ValueNotifier<RenameOrReplaceResult>(_defaultAction);

  static Future<RenameOrReplaceResult?> show({
    required Stage stage,
    required String title,
    required String entryName,
    required EntryType entryType,
  }) => stage.showDialog<RenameOrReplaceResult?>(
    builder: (context) => AlertDialog(
      title: Flex(
        direction: Axis.horizontal,
        children: [
          Fields.constrainedText(
            title,
            style: context.theme.appTextStyle.titleMedium,
            maxLines: 2,
          ),
        ],
      ),
      content: RenameOrReplaceEntryDialog._(
        name: entryName,
        type: entryType,
        stage: stage,
      ),
    ),
  );

  RenameOrReplaceEntryDialog._({
    required this.name,
    required this.type,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.theme.appTextStyle.bodyMedium;

    final replaceMessage = type == EntryType.file
        ? S.current.messageReplaceExistingFile
        : S.current.messageReplaceExistingFolder;

    final renameMessage = type == EntryType.file
        ? S.current.messageKeepBothFiles
        : S.current.messageKeepBothFolders;

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
            return Column(
              children: [
                RadioListTile<RenameOrReplaceResult>(
                  key: Key('rename_entry_radio_tile'),
                  dense: true,
                  contentPadding: EdgeInsetsDirectional.zero,
                  title: Text(renameMessage, style: bodyStyle),
                  value: RenameOrReplaceResult.rename,
                  groupValue: value,
                  onChanged: _onFileActionChanged,
                ),
                GestureDetector(
                  onTap: () {
                    if (type == EntryType.directory) {
                      stage.showSnackBar(S.current.messageOnlyAvailableFiles);
                    }
                  },
                  child: RadioListTile<RenameOrReplaceResult>(
                    key: Key('replace_entry_radio_tile'),
                    dense: true,
                    contentPadding: EdgeInsetsDirectional.zero,
                    title: Text(replaceMessage, style: bodyStyle),
                    value: RenameOrReplaceResult.replace,
                    groupValue: value,
                    onChanged: type == EntryType.file
                        ? _onFileActionChanged
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
        Dimensions.spacingVertical,
        Fields.dialogActions(buttons: _actions()),
      ],
    );
  }

  List<Widget> _actions() => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () => stage.maybePop(null),
    ),
    PositiveButton(
      text: S.current.actionAccept,
      onPressed: () => stage.maybePop(_fileAction.value),
    ),
  ];

  void _onFileActionChanged(RenameOrReplaceResult? value) =>
      _fileAction.value = value ?? _defaultAction;
}

enum RenameOrReplaceResult { rename, replace }
