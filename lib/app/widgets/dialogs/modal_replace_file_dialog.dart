import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class ReplaceFile extends StatelessWidget {
  ReplaceFile({required this.context, required this.fileName});

  final BuildContext context;
  final String fileName;

  final _fileAction = ValueNotifier<FileAction>(FileAction.replace);

  @override
  Widget build(BuildContext context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Dimensions.spacingVerticalDouble,
            Text('$fileName already exist in this location.'
                '\n\nWant do you want to do?'),
            Dimensions.spacingVertical,
            ValueListenableBuilder(
              valueListenable: _fileAction,
              builder: (context, value, child) {
                return Column(children: [
                  RadioListTile<FileAction>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Replace existing file'),
                      value: FileAction.replace,
                      groupValue: value,
                      onChanged: _onFileActionChanged),
                  RadioListTile<FileAction>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Keep both files'),
                      value: FileAction.keep,
                      groupValue: value,
                      onChanged: _onFileActionChanged),
                ]);
              },
            ),
            Dimensions.spacingVertical,
            Fields.dialogActions(context, buttons: _actions(context)),
          ]);

  List<Widget> _actions(context) => [
        NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(null)),
        PositiveButton(
            text: S.current.actionAccept,
            onPressed: () => Navigator.of(context).pop(_fileAction.value))
      ];

  void _onFileActionChanged(FileAction? value) =>
      _fileAction.value = value ?? FileAction.replace;
}

enum FileAction { replace, keep }
