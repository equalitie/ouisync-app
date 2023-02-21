import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

typedef MoveEntryCallback = void Function(
    String origin, String path, EntryType type);

class MoveEntryDialog extends StatefulWidget {
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
  State<MoveEntryDialog> createState() => _MoveEntryDialogState();
}

class _MoveEntryDialogState extends State<MoveEntryDialog> {
  final bodyKey = GlobalKey();

  Size? widgetSize;
  Size? screenSize;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: bodyKey,
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
              text: getBasename(widget.path)),
          Fields.constrainedText(
              S.current.messageMoveEntryOrigin(getDirname(widget.path)),
              fontWeight: FontWeight.w800),
          _selectActions(context)
        ],
      ),
    );
  }

  void afterBuild(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    final widgetContext = bodyKey.currentContext;
    if (widgetContext == null) return;

    widgetSize = widgetContext.size;
  }

  _selectActions(context) => BlocBuilder<RepoCubit, RepoState>(
        bloc: widget._repo,
        builder: (context, state) {
          bool canMove = false;
          final folder = widget._repo.currentFolder;

          if (folder.path != widget.origin && folder.path != widget.path) {
            canMove = true;
          }

          final aspectRatio = _getButtonAspectRatio();
          return Fields.dialogActions(context,
              buttons: _actions(context, canMove, aspectRatio),
              padding: const EdgeInsets.only(top: 0.0),
              mainAxisAlignment: MainAxisAlignment.end);
        },
      );

  List<Widget> _actions(
          BuildContext context, bool canMove, double aspectRatio) =>
      [
        NegativeButton(
            buttonsAspectRatio: aspectRatio,
            buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
            text: S.current.actionCancel,
            onPressed: () => _cancelMoving(context)),
        PositiveButton(
            buttonsAspectRatio: aspectRatio,
            buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
            text: S.current.actionMove,
            onPressed: canMove
                ? () => widget.onMoveEntry
                    .call(widget.origin, widget.path, widget.type)
                : null)

        /// If the entry can't be moved (the user selected the same entry/path, for example)
        /// Then null is used instead of the function, which disable the button.
      ];

  double _getButtonAspectRatio() {
    if (Platform.isWindows || Platform.isLinux) {
      if (widgetSize == null) {
        return Dimensions.aspectRatioModalDialogButtonDesktop;
      }

      final height = widgetSize!.height * 0.6;
      final width = widgetSize!.width;
      return width / height;
    }

    return Dimensions.aspectRatioBottomDialogButton;
  }

  void _cancelMoving(context) {
    widget.onBottomSheetOpen.call(null, '');
    Navigator.of(context).pop('');
  }
}
