import 'package:flutter/material.dart';
import 'package:ouisync/ouisync.dart' show EntryType;

import '../../../generated/l10n.dart';
import '../../utils/utils.dart'
    show AppThemeExtension, Dimensions, Fields, showSnackBar, ThemeGetter;
import '../widgets.dart' show NegativeButton, PositiveButton;

class ReplaceKeepEntry extends StatelessWidget {
  ReplaceKeepEntry({required this.name, required this.type});

  final String name;
  final EntryType type;

  final _fileAction =
      ValueNotifier<DisambiguationAction>(DisambiguationAction.replace);

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.theme.appTextStyle.bodyMedium;

    final replaceMessage = type == EntryType.file
        ? S.current.messageReplaceExistingFile
        : S.current.messageReplaceExistingFolder;

    final keepMessage = type == EntryType.file
        ? S.current.messageKeepBothFiles
        : S.current.messageKeepBothFolders;

    _fileAction.value = type == EntryType.file
        ? DisambiguationAction.replace
        : DisambiguationAction.keep;

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
                  child: RadioListTile<DisambiguationAction>(
                    dense: true,
                    contentPadding: EdgeInsetsDirectional.zero,
                    title: Text(replaceMessage, style: bodyStyle),
                    value: DisambiguationAction.replace,
                    groupValue: value,
                    onChanged:
                        type == EntryType.file ? _onFileActionChanged : null,
                  ),
                ),
                RadioListTile<DisambiguationAction>(
                  dense: true,
                  contentPadding: EdgeInsetsDirectional.zero,
                  title: Text(keepMessage, style: bodyStyle),
                  value: DisambiguationAction.keep,
                  groupValue: value,
                  onChanged: _onFileActionChanged,
                ),
              ]);
            },
          ),
          Dimensions.spacingVertical,
          Fields.dialogActions(buttons: _actions(context)),
        ]);
  }

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () async => await Navigator.of(context).maybePop(null)),
        PositiveButton(
            text: S.current.actionAccept,
            onPressed: () async =>
                await Navigator.of(context).maybePop(_fileAction.value)),
      ];

  void _onFileActionChanged(DisambiguationAction? value) =>
      _fileAction.value = value ?? DisambiguationAction.replace;
}

enum DisambiguationAction { replace, keep }
