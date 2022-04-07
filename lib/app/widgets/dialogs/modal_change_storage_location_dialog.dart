import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../pages/pages.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';

class ChangeStorageLocation extends StatelessWidget with OuiSyncAppLogger {
  ChangeStorageLocation({
    required this.context,
    required this.originPath,
    required this.destinationPath,
    required this.moveFilesCallback
  });

  final BuildContext context;
  final String originPath;
  final String destinationPath;
  final MoveFilesCallback moveFilesCallback;

  ValueNotifier<Icon> _copyFilesNotifier = ValueNotifier<Icon>(const Icon(Icons.check_box_outline_blank));
  ValueNotifier<Icon> _closingReposNotifier = ValueNotifier<Icon>(const Icon(Icons.check_box_outline_blank));
  ValueNotifier<Icon> _updatingSettingsNotifier = ValueNotifier<Icon>(const Icon(Icons.check_box_outline_blank));
  ValueNotifier<Icon> _deletingOldfilesNotifier = ValueNotifier<Icon>(const Icon(Icons.check_box_outline_blank));

  ValueNotifier<bool> _actionEnableNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Dimensions.spacingVerticalDouble,
          Row(
            children: [
              Fields.constrainedText(
                '${this.destinationPath}',
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          Dimensions.spacingVerticalDouble,
          Row(
            children: [
              Fields.constrainedText('Closing open repositories'),
              ValueListenableBuilder(
                valueListenable: _closingReposNotifier,
                builder: (context, value, child) => value as Icon
              )
            ],
          ),
          Dimensions.spacingVertical,
          Row(
            children: [
              Fields.constrainedText('Moving files'),
              ValueListenableBuilder(
                valueListenable: _copyFilesNotifier,
                builder: (context, value, child) => value as Icon
              )
            ],
          ),
          Dimensions.spacingVertical,
          Row(
            children: [
              Fields.constrainedText('Updating app settings'),
              ValueListenableBuilder(
                valueListenable: _updatingSettingsNotifier,
                builder: (context, value, child) => value as Icon
              )
            ],
          ),
          Dimensions.spacingVertical,
          Row(
            children: [
              Fields.constrainedText('Deleting old files'),
              ValueListenableBuilder(
                valueListenable: _deletingOldfilesNotifier,
                builder: (context, value, child) => value as Icon
              )
            ],
          ),
          Dimensions.spacingVertical,
          Row(
            children: [
              Fields.constrainedText('Initializing repositories'),
              ValueListenableBuilder(
                valueListenable: _deletingOldfilesNotifier,
                builder: (context, value, child) => value as Icon
              )
            ],
          ),
          Dimensions.spacingVerticalDouble,
          Row(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 20),
                height: 30.0,
                width: 30.0,
                child: CircularProgressIndicator(
                )
              ),
              Expanded(child:Fields.actionsSection(
                context,
                buttons: _actions(context)
              )),
            ],
          )
        ],
      )
    );
  }

  List<Widget> _actions(context) => [
    OutlinedButton(
      onPressed: _actionEnableNotifier.value ? () => Navigator.of(context).pop('') : null,
      child: Text(S.current.actionCloseCapital)
    ),
  ];

}