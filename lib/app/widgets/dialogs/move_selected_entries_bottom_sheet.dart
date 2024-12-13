import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/repo_location.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class MoveSelectedEntriesDialog extends StatefulWidget {
  const MoveSelectedEntriesDialog(
    this.parentContext, {
    required this.reposCubit,
    required this.repoCubit,
    required this.type,
    required this.onUpdateBottomSheet,
    required this.onCancel,
  });

  final BuildContext parentContext;
  final ReposCubit reposCubit;
  final RepoCubit repoCubit;
  final BottomSheetType type;
  final void Function(
    BottomSheetType type,
    double padding,
    String entry,
  ) onUpdateBottomSheet;
  final void Function() onCancel;

  @override
  State<MoveSelectedEntriesDialog> createState() =>
      _MoveSelectedEntriesDialogState();
}

class _MoveSelectedEntriesDialogState extends State<MoveSelectedEntriesDialog> {
  final bodyKey = GlobalKey();
  Size? widgetSize;

  NavigationCubit get navigationCubit => widget.reposCubit.navigation;

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
        BottomSheetType.move, widgetSize?.height ?? 0.0, '');
  }

  @override
  Widget build(BuildContext context) => widget.reposCubit.builder(
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
                _entriesCountLabel(widget.repoCubit.entrySelectionCubit),
                _sourceLabel(widget.repoCubit.entrySelectionCubit),
                _selectActions(
                  widget.parentContext,
                  cubit,
                  widget.repoCubit,
                  widget.type,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _entriesCountLabel(EntrySelectionCubit entrySelectionCubit) =>
      BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
        bloc: entrySelectionCubit,
        builder: (context, state) {
          final totalDirs = state.selectedEntriesPath.entries
              .where((e) => e.value.isDir && e.value.selected)
              .length;
          final totalFiles = state.selectedEntriesPath.entries
              .where((e) => !e.value.isDir)
              .length;
          return Fields.iconLabel(
            icon: Icons.folder_copy,
            text: 'Folders: $totalDirs, Files: $totalFiles',
          );
        },
      );

  Widget _sourceLabel(EntrySelectionCubit entrySelectionCubit) =>
      BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
        bloc: entrySelectionCubit,
        builder: (context, state) => Text(
          S.current.messageMoveEntryOrigin(state.originPath ?? ''),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w800),
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      );

  Widget _selectActions(
    BuildContext parentContext,
    ReposCubit reposCubit,
    RepoCubit repoCubit,
    BottomSheetType type,
  ) =>
      //BlocBuilder<NavigationCubit, NavigationState>(
      BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
        bloc: repoCubit.entrySelectionCubit, //navigationCubit,
        builder: (context, state) {
          final multiEntryActions = MultiEntryActions(
            parentContext,
            entrySelectionCubit: repoCubit.entrySelectionCubit,
          );
          final aspectRatio = _getButtonAspectRatio(widgetSize);
          return Fields.dialogActions(
            buttons: _actions(
              reposCubit,
              repoCubit,
              state,
              multiEntryActions,
              type,
              aspectRatio,
            ),
            padding: const EdgeInsetsDirectional.only(top: 20.0),
            mainAxisAlignment: MainAxisAlignment.end,
          );
        },
      );

  List<Widget> _actions(
    ReposCubit reposCubit,
    RepoCubit repoCubit,
    EntrySelectionState state,
    MultiEntryActions multiEntryActions,
    BottomSheetType type,
    // NavigationState state,
    double aspectRatio,
  ) {
    final isRepoList = reposCubit.showList;
    // final currentRepoAccessMode = widget.reposCubit.currentRepo?.accessMode;
    // final isCurrentRepoWriteMode = currentRepoAccessMode == AccessMode.write;

    // final canMove = state.isFolder
    //     ? _canMove(
    //         originRepoLocation: originRepoCubit.location,
    //         originPath: repo_path.dirname(entryPath),
    //         destinationRepoLocation:
    //             widget.reposCubit.currentRepo?.cubit?.location ??
    //                 state.repoLocation,
    //         destinationPath: state.path,
    //         isRepoList: isRepoList,
    //         isCurrentRepoWriteMode: isCurrentRepoWriteMode,
    //       )
    //     : false;

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
        text: _getActionText(type),
        onPressed: () async {
          final action = switch (type) {
            BottomSheetType.copy => multiEntryActions.copyEntriesTo(
                reposCubit,
                repoCubit,
              ),
            BottomSheetType.delete => multiEntryActions.deleteSelectedEntries(),
            BottomSheetType.download => multiEntryActions.saveEntriesToDevice(),
            BottomSheetType.move => multiEntryActions.moveEntriesTo(
                reposCubit,
                repoCubit,
              ),
            BottomSheetType.upload => null,
            BottomSheetType.gone => null,
          };

          if (action == null) return;

          final resultOk = await action;
          if (!resultOk) return;

          widget.onUpdateBottomSheet(
            BottomSheetType.gone,
            0.0,
            '',
          );
          widget.onCancel();

          // await Dialogs.executeFutureWithLoadingDialog(
          //   null,
          //   widget.onMoveEntry(),
          // );
        },
        // canMove
        //     ? () async {
        //         widget.onUpdateBottomSheet(
        //           BottomSheetType.gone,
        //           0.0,
        //           '',
        //         );
        //         widget.onCancel();

        //         await Dialogs.executeFutureWithLoadingDialog(
        //           null,
        //           widget.onMoveEntry(),
        //         );
        //       }
        //     : null,
      )

      /// If the entry can't be moved (the user selected the same entry/path, for example)
      /// Then null is used instead of the function, which disable the button.
    ];
  }

  String _getActionText(BottomSheetType type) => switch (type) {
        BottomSheetType.copy => S.current.actionCopy,
        BottomSheetType.delete => S.current.actionDelete,
        BottomSheetType.download => S.current.actionDownload,
        BottomSheetType.move => S.current.actionMove,
        BottomSheetType.upload => '',
        BottomSheetType.gone => '',
      };

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
