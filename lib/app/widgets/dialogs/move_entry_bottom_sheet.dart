import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class MoveEntryDialog extends StatelessWidget {
  const MoveEntryDialog(
    this._repo, {
    required this.origin,
    required this.path,
    required this.type,
    required this.onBottomSheetOpen,
    required this.onMoveEntry,
  });

  final RepoCubit _repo;
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
      decoration: Dimensions.decorationBottomSheetAlternative,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.iconLabel(
            icon: Icons.drive_file_move_outlined,
            text: getBasename(path)
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

  _selectActions(context) => _repo.builder((state) {
    bool canMove = false;
    final folder = _repo.currentFolder;

    if (folder.path != origin && folder.path != path) {
      canMove = true;
    }

    return Fields.dialogActions(context,
      buttons: _actions(context, canMove),
      padding: const EdgeInsets.only(top: 0.0),
      mainAxisAlignment: MainAxisAlignment.end
    );
  });

  //_selectActions(context) {
  //  return BlocBuilder(
  //    bloc: BlocProvider.of<DirectoryCubit>(context),
  //    builder: (context, state) {
  //      bool canMove = false;

  //      if (state is DirectoryReloaded) {
  //        if (state.path != origin && state.path != path) {
  //          canMove = true;
  //        }
  //      }

  //      return Fields.dialogActions(context,
  //        buttons: _actions(context, canMove),
  //        padding: const EdgeInsets.only(top: 0.0),
  //        mainAxisAlignment: MainAxisAlignment.end
  //      );
  //    }
  //  );
  //}

  List<Widget> _actions(context, canMove) => [
    NegativeButton(
      text: S.current.actionCancel,
      onPressed: () => _cancelMoving(context)),
    PositiveButton(
      text: S.current.actionMove,
      onPressed: canMove ? () => onMoveEntry.call(origin, path, type) : null)
      /// If the entry can't be moved (the user selected the same entry/path, for example)
      /// Then null is used instead of the function, which disable the button.
  ];

  void _cancelMoving(context) {
    onBottomSheetOpen.call(null, '');
    Navigator.of(context).pop('');
  }
}
