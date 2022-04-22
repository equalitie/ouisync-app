import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../bloc/blocs.dart';
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
  final BottomSheetControllerCallback onBottomSheetOpen;
  final MoveEntryCallback onMoveEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimensions.paddingBottomSheet,
      height: 160.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black26,
          width: 1.0,
          style: BorderStyle.solid
        ),
        color: Colors.white
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.iconLabel(
            icon: Icons.drive_file_move_outlined,
            text: '${getBasename(path)}'
          ),
          Fields.constrainedText(
            S.current.messageMoveEntryOrigin(getParentSection(path)),
            fontWeight: FontWeight.w800
          ),
          _selectActions(context)
        ],
      ),
    );
  }

  _selectActions(context) {
    return BlocBuilder(
      bloc: BlocProvider.of<DirectoryBloc>(context),
      builder: (context, state) {
        bool canMove = false;

        if (state is DirectoryReloaded) {
          if (state.path != origin && state.path != path) {
            canMove = true;
          }
        }

        return Fields.actionsSection(context,
          buttons: _actions(context, canMove),
          padding: EdgeInsets.only(top: 0.0)
        );
      }
    );
  }

  List<Widget> _actions(context, canMove) {
    List<Widget> actions = <Widget>[];

    if (canMove) {
      actions.addAll([ElevatedButton(
        onPressed: () => onMoveEntry.call(origin, path, type),
        child: Text(S.current.actionMove)
      ),
      SizedBox(width: 20.0,),]);
    }

    actions.add(OutlinedButton(
      onPressed: () {
        onBottomSheetOpen.call(null, '');
        Navigator.of(context).pop('');
      },
      child: Text(S.current.actionCancel)
    ));

    return actions;
  }
}
