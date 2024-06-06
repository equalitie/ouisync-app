import 'dart:io';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_location.dart';
import '../../utils/path.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class MoveEntryDialog extends StatefulWidget {
  const MoveEntryDialog({
    required this.repo,
    required this.navigation,
    required this.entryPath,
    required this.entryType,
    required this.onUpdateBottomSheet,
    required this.onMoveEntry,
    required this.onCancel,
  });

  final RepoCubit repo;
  final NavigationCubit navigation;
  final String entryPath;
  final EntryType entryType;
  final void Function(
    BottomSheetType type,
    double padding,
    String entry,
  ) onUpdateBottomSheet;
  final Future<bool> Function() onMoveEntry;
  final void Function() onCancel;

  @override
  State<MoveEntryDialog> createState() => _MoveEntryDialogState();
}

class _MoveEntryDialogState extends State<MoveEntryDialog> {
  final bodyKey = GlobalKey();
  Size? widgetSize;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild());
    super.initState();
  }

  void afterBuild() {
    final widgetContext = bodyKey.currentContext;
    if (widgetContext == null) return;

    widgetSize = widgetContext.size;

    widgetContext.size?.let((it) {
          widget.onUpdateBottomSheet(
            BottomSheetType.move,
            it.height,
            widget.entryPath,
          );
        }) ??
        0.0;
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w800);

    final parent = dirname(widget.entryPath);
    final name = basename(widget.entryPath);

    return Container(
      key: bodyKey,
      padding: Dimensions.paddingBottomSheet,
      decoration: Dimensions.decorationBottomSheetAlternative,
      child: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Dimensions.spacingVertical,
            Fields.iconLabel(
              icon: Icons.drive_file_move_outlined,
              text: name,
            ),
            Fields.ellipsedText(
              S.current.messageMoveEntryOrigin(parent),
              ellipsisPosition: TextOverflowPosition.middle,
              style: bodyStyle,
            ),
            _selectActions(context),
          ],
        ),
      ),
    );
  }

  _selectActions(context) {
    final aspectRatio = _getButtonAspectRatio(widgetSize);
    return Fields.dialogActions(
      context,
      buttons: _actions(context, aspectRatio),
      padding: const EdgeInsets.only(top: 20.0),
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }

  List<Widget> _actions(BuildContext context, double aspectRatio) => [
        NegativeButton(
          buttonsAspectRatio: aspectRatio,
          buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
          text: S.current.actionCancel,
          onPressed: () {
            widget.onUpdateBottomSheet(BottomSheetType.gone, 0.0, '');
            widget.onCancel();
          },
        ),
        BlocBuilder<NavigationCubit, NavigationState>(
          bloc: widget.navigation,
          builder: (context, state) {
            final originPath = dirname(state.path);
            final canMove = state.isFolder
                ? _canMove(
                    state.repoLocation,
                    state.path,
                    widget.repo.location,
                    originPath,
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
                        widget.onMoveEntry(),
                      );

                      if (moved) {
                        widget.onUpdateBottomSheet(
                          BottomSheetType.gone,
                          0.0,
                          '',
                        );
                        widget.onCancel();
                      }
                    }
                  : null,
            );
          },
        ),

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

  double _getButtonAspectRatio(Size? size) {
    if (Platform.isWindows || Platform.isLinux) {
      if (size == null) {
        return Dimensions.aspectRatioModalDialogButton;
      }

      final height = size.height * 0.6;
      final width = size.width;
      return width / height;
    }

    return Dimensions.aspectRatioBottomDialogButton;
  }
}
