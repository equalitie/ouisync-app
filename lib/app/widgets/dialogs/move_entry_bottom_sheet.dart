import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_location.dart';
import '../../pages/pages.dart';
import '../../utils/path.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class MoveEntryDialog extends StatefulWidget {
  const MoveEntryDialog({
    required this.repo,
    required this.navigation,
    required this.originPath,
    required this.path,
    required this.type,
    required this.onBottomSheetOpen,
    required this.onMoveEntry,
  });

  final RepoCubit repo;
  final NavigationCubit navigation;
  final String originPath;
  final String path;
  final EntryType type;
  final BottomSheetCallback onBottomSheetOpen;
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
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w800);

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
              text: basename(widget.path)),
          Fields.constrainedText(
              S.current.messageMoveEntryOrigin(dirname(widget.path)),
              style: bodyStyle),
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

  _selectActions(context) {
    final aspectRatio = _getButtonAspectRatio();
    return Fields.dialogActions(context,
        buttons: _actions(context, aspectRatio),
        padding: const EdgeInsets.only(top: 0.0),
        mainAxisAlignment: MainAxisAlignment.end);
  }

  List<Widget> _actions(BuildContext context, double aspectRatio) => [
        NegativeButton(
            buttonsAspectRatio: aspectRatio,
            buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
            text: S.current.actionCancel,
            onPressed: () => widget.onBottomSheetOpen.call(null, '')),
        BlocBuilder<NavigationCubit, NavigationState>(
            bloc: widget.navigation,
            builder: (context, state) {
              final canMove = state.isFolder
                  ? _canMove(
                      state.repoLocation,
                      state.path,
                      widget.repo.location,
                      widget.originPath,
                    )
                  : false;
              return PositiveButton(
                  buttonsAspectRatio: aspectRatio,
                  buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
                  text: S.current.actionMove,
                  onPressed: canMove
                      ? () async {
                          final moved =
                              await Dialogs.executeFutureWithLoadingDialog(
                            context,
                            widget.onMoveEntry.call(
                              widget.originPath,
                              widget.path,
                              widget.type,
                            ),
                          );

                          if (moved) widget.onBottomSheetOpen.call(null, '');
                        }
                      : null);
            }),

        /// If the entry can't be moved (the user selected the same entry/path, for example)
        /// Then null is used instead of the function, which disable the button.
      ];

  bool _canMove(
    RepoLocation? originRepoLocation,
    String originPath,
    RepoLocation destinationRepoLocation,
    String destinationPath,
  ) =>
      originRepoLocation == destinationRepoLocation &&
      originPath != destinationPath;

  double _getButtonAspectRatio() {
    if (Platform.isWindows || Platform.isLinux) {
      if (widgetSize == null) {
        return Dimensions.aspectRatioModalDialogButton;
      }

      final height = widgetSize!.height * 0.6;
      final width = widgetSize!.width;
      return width / height;
    }

    return Dimensions.aspectRatioBottomDialogButton;
  }
}
