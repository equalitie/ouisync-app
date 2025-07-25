import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show EntryType;

import '../../../generated/l10n.dart';
import '../../utils/utils.dart'
    show AppThemeExtension, Dimensions, Fields, showSnackBar, ThemeGetter;
import '../widgets.dart' show NegativeButton, PositiveButton;

class RenameOrReplaceEntryDialog extends StatelessWidget {
  final String name;
  final EntryType type;

  static const _defaultAction = RenameOrReplaceResult.rename;

  final _fileAction = ValueNotifier<RenameOrReplaceResult>(_defaultAction);

  static Future<RenameOrReplaceResult?> show(
    BuildContext context, {
    required String title,
    required String entryName,
    required EntryType entryType,
  }) async => await showDialog<RenameOrReplaceResult?>(
    context: context,
    builder: (BuildContext _) => AlertDialog(
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
      content: RenameOrReplaceEntryDialog._(name: entryName, type: entryType),
    ),
  );

  RenameOrReplaceEntryDialog._({required this.name, required this.type});

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
                      showSnackBar(S.current.messageOnlyAvailableFiles);
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
        Fields.dialogActions(buttons: _actions(context)),
      ],
    );
  }

  List<Widget> _actions(context) => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () async => await Navigator.of(context).maybePop(null),
    ),
    PositiveButton(
      text: S.current.actionAccept,
      onPressed: () async =>
          await Navigator.of(context).maybePop(_fileAction.value),
    ),
  ];

  void _onFileActionChanged(RenameOrReplaceResult? value) =>
      _fileAction.value = value ?? _defaultAction;
}

enum RenameOrReplaceResult { rename, replace }
