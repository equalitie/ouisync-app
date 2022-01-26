import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

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
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      height: 160.0,
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
          _movingActionTitle(),
          SizedBox(width: 10.0,),
          Fields.constrainedText(
            Strings.messageMoveEntryOrigin
            .replaceAll(
              Strings.replacementPath,
              extractParentFromPath(path)
            ),
            fontWeight: FontWeight.w800
          ),
          _selectActions(context)
        ],
      ),
    );
  }

  Row _movingActionTitle() {
    return Row(
          children: [
            const Icon(
              Icons.drive_file_move_outlined,
              size: 40.0,
            ),
            SizedBox(width: 10.0,),
            Fields.constrainedText(
              '${removeParentFromPath(path)}',
              fontSize: Dimensions.fontBig,
              fontWeight: FontWeight.w800
            ),
          ],
        );
  }

  _selectActions(context) {
    return BlocBuilder(
      bloc: BlocProvider.of<DirectoryBloc>(context),
      builder: (context, state) {
        bool allowAction = false;
        if (state is NavigationLoadSuccess) {
          if (state.destination != origin &&
          state.destination != path) {
            allowAction = true;
          }
        }

        return Fields.actionsSection(context,
          buttons: _actions(context, allowAction),
          padding: EdgeInsets.only(top: 0.0)
        );
      }
    );
  }

  List<Widget> _actions(context, allowAction) {
    List<Widget> actions = <Widget>[];

    if (allowAction) {
      actions.addAll([ElevatedButton(
        onPressed: () => onMoveEntry.call(origin, path, type),
        child: Text(Strings.actionMove)
      ),
      SizedBox(width: 20.0,),]);
    }

    actions.add(OutlinedButton(
      onPressed: () {
        onBottomSheetOpen.call(null, '');
        Navigator.of(context).pop('');
      },
      child: Text(Strings.actionCancel)
    ));

    return actions;
  }
}