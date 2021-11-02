import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../pages/pages.dart';
import '../../utils/utils.dart';

class MoveEntryDialog extends StatelessWidget {
  MoveEntryDialog({
    required this.origin,
    required this.path,
    required this.type,
    required this.onBottomSheetOpen,
    required this.onMoveEntry
  });

  final String origin;
  final String path;
  final EntryType type;
  final RetrieveBottomSheetControllerCallback onBottomSheetOpen;
  final MoveEntryCallback onMoveEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
      height: 200.0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0)
        ),
        border: Border.all(
          color: Colors.black26,
          width: 1.0,
          style: BorderStyle.solid
        ),
        color: Colors.white
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildConstrainedText('Moving $path', size: 24.0, fontWeight: FontWeight.w800),
          SizedBox(width: 10.0,),
          buildConstrainedText('Navigate to the destination folder and tap Move', fontWeight: FontWeight.w400),
          buildActionsSection(context, _actions(context), padding: EdgeInsets.only(top: 0.0))
        ],
      ),
    );
  }

  List<Widget> _actions(context) => [
    ElevatedButton(
      onPressed: () => onMoveEntry.call(origin, path, type),
      child: Text('MOVE')
    ),
    SizedBox(width: 20.0,),
    OutlinedButton(
      onPressed: () {
        onBottomSheetOpen.call(null);
        Navigator.of(context).pop('');
      },
      child: Text('CANCEL')
    ),
  ];
}