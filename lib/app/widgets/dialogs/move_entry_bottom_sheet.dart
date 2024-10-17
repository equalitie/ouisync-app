import 'dart:io';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_location.dart';
import '../../utils/repo_path.dart' as repo_path;
import '../../utils/utils.dart';
import '../widgets.dart';

class MoveEntryDialog extends StatefulWidget {
  const MoveEntryDialog({
    required this.reposCubit,
    required this.originRepoCubit,
    required this.entryPath,
    required this.onUpdateBottomSheet,
    required this.onMoveEntry,
    required this.onCancel,
  });

  final ReposCubit reposCubit;
  final RepoCubit originRepoCubit;
  final String entryPath;
  final void Function(
    BottomSheetType type,
    double padding,
    String entry,
  ) onUpdateBottomSheet;
  final Future<void> Function() onMoveEntry;
  final void Function() onCancel;

  @override
  State<MoveEntryDialog> createState() => _MoveEntryDialogState();
}

class _MoveEntryDialogState extends State<MoveEntryDialog> {
  final bodyKey = GlobalKey();
  Size? widgetSize;

  NavigationCubit get navigationCubit => widget.reposCubit.navigation;
  RepoCubit get originRepoCubit => widget.originRepoCubit;

  String get entryPath => widget.entryPath;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild());
    super.initState();
  }

  void afterBuild() {
    final widgetContext = bodyKey.currentContext;
    if (widgetContext == null) return;

    widgetSize = widgetContext.size;

    widget.onUpdateBottomSheet(
      BottomSheetType.move,
      widgetSize?.height ?? 0.0,
      widget.entryPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w800);

    final parent = repo_path.dirname(widget.entryPath);
    final name = repo_path.basename(widget.entryPath);

    return widget.reposCubit.builder(
      (cubit) => Container(
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
              _selectActions(context, cubit.showList),
            ],
          ),
        ),
      ),
    );
  }

  _selectActions(context, bool isRepoList) =>
      BlocBuilder<NavigationCubit, NavigationState>(
        bloc: navigationCubit,
        builder: (context, state) {
          final aspectRatio = _getButtonAspectRatio(widgetSize);
          return Fields.dialogActions(
            context,
            buttons: _actions(context, isRepoList, aspectRatio),
            padding: const EdgeInsetsDirectional.only(top: 20.0),
            mainAxisAlignment: MainAxisAlignment.end,
          );
        },
      );

  List<Widget> _actions(
    BuildContext context,
    bool isRepoList,
    double aspectRatio,
  ) =>
      [
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
          bloc: navigationCubit,
          builder: (context, state) {
            final canMove = state.isFolder
                ? _canMove(
                    originRepoLocation: originRepoCubit.location,
                    originPath: repo_path.dirname(entryPath),
                    destinationRepoLocation: state.repoLocation,
                    destinationPath: state.path,
                    isRepoList: isRepoList,
                  )
                : false;
            return PositiveButton(
              buttonsAspectRatio: aspectRatio,
              buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
              text: S.current.actionMove,
              onPressed: canMove
                  ? () async {
                      await Dialogs.executeFutureWithLoadingDialog(
                        context,
                        widget.onMoveEntry(),
                      ).then(
                        (_) {
                          widget.onUpdateBottomSheet(
                            BottomSheetType.gone,
                            0.0,
                            '',
                          );
                          widget.onCancel();
                        },
                      );
                    }
                  : null,
            );
          },
        ),

        /// If the entry can't be moved (the user selected the same entry/path, for example)
        /// Then null is used instead of the function, which disable the button.
      ];

  bool _canMove({
    required RepoLocation originRepoLocation,
    required String originPath,
    required RepoLocation? destinationRepoLocation,
    required String destinationPath,
    required bool isRepoList,
  }) {
    if (isRepoList) return false;
    if (destinationRepoLocation == null) return false;

    bool isSameRepo = originRepoLocation.compareTo(destinationRepoLocation) == 0
        ? true
        : false;
    final isSamePath =
        originPath.compareTo(destinationPath) == 0 ? true : false;
    if (isSameRepo && isSamePath) return false;

    return true;
  }

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
