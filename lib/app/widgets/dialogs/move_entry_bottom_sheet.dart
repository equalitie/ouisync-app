import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show AccessMode;

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

    return BlocBuilder<ReposCubit, ReposState>(
      bloc: widget.reposCubit,
      builder: (context, state) => Container(
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
              Text(
                S.current.messageMoveEntryOrigin(parent),
                style: bodyStyle,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
              _selectActions(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectActions(context, ReposState reposState) =>
      BlocBuilder<NavigationCubit, NavigationState>(
        bloc: navigationCubit,
        builder: (context, state) {
          final aspectRatio = _getButtonAspectRatio(widgetSize);
          return Fields.dialogActions(
            buttons: _actions(context, reposState, state, aspectRatio),
            padding: const EdgeInsetsDirectional.only(top: 20.0),
            mainAxisAlignment: MainAxisAlignment.end,
          );
        },
      );

  List<Widget> _actions(
    BuildContext context,
    ReposState reposState,
    NavigationState navigationState,
    double aspectRatio,
  ) {
    final currentRepoAccessMode = reposState.currentEntry?.accessMode;
    final isCurrentRepoWriteMode = currentRepoAccessMode == AccessMode.write;

    final canMove = navigationState.isFolder
        ? _canMove(
            originRepoLocation: originRepoCubit.location,
            originPath: repo_path.dirname(entryPath),
            destinationRepoLocation: reposState.currentEntry?.cubit?.location ??
                navigationState.repoLocation,
            destinationPath: navigationState.path,
            isRepoList: reposState.current == null,
            isCurrentRepoWriteMode: isCurrentRepoWriteMode,
          )
        : false;

    return [
      NegativeButton(
        buttonsAspectRatio: aspectRatio,
        buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
        text: S.current.actionCancel,
        onPressed: () {
          widget.onUpdateBottomSheet(BottomSheetType.gone, 0.0, '');
          widget.onCancel();
        },
      ),
      PositiveButton(
        key: ValueKey('move_entry'),
        buttonsAspectRatio: aspectRatio,
        buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
        text: S.current.actionMove,
        onPressed: canMove
            ? () async {
                widget.onUpdateBottomSheet(
                  BottomSheetType.gone,
                  0.0,
                  '',
                );
                widget.onCancel();

                await Dialogs.executeFutureWithLoadingDialog(
                  null,
                  widget.onMoveEntry(),
                );
              }
            : null,
      )

      /// If the entry can't be moved (the user selected the same entry/path, for example)
      /// Then null is used instead of the function, which disable the button.
    ];
  }

  bool _canMove({
    required RepoLocation originRepoLocation,
    required String originPath,
    required RepoLocation? destinationRepoLocation,
    required String destinationPath,
    required bool isRepoList,
    required bool isCurrentRepoWriteMode,
  }) {
    if (isRepoList) return false;
    if (destinationRepoLocation == null) return false;
    if (!isCurrentRepoWriteMode) return false;

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
