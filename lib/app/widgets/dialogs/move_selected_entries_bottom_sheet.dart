import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show AccessMode, EntryType;

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart'
    show
        BottomSheetType,
        EntrySelectionCubit,
        EntrySelectionState,
        NavigationCubit,
        NavigationState,
        RepoCubit,
        ReposCubit;
import '../../utils/repo_path.dart' as repo_path;
import '../../utils/utils.dart'
    show AppLogger, Dialogs, Dimensions, Fields, MoveEntriesActions, MultiEntryActions;
import '../widgets.dart' show NegativeButton, PositiveButton;

class MoveSelectedEntriesDialog extends StatefulWidget {
  const MoveSelectedEntriesDialog.single(
    this.parentContext, {
    required this.reposCubit,
    required this.originRepoCubit,
    required this.navigationCubit,
    required this.entryPath,
    required this.entryType,
    required this.sheetType,
    required this.onUpdateBottomSheet,
  }) : entrySelectionCubit = null;

  const MoveSelectedEntriesDialog.multiple(
    this.parentContext, {
    required this.reposCubit,
    required this.originRepoCubit,
    required this.navigationCubit,
    required this.entrySelectionCubit,
    required this.sheetType,
    required this.onUpdateBottomSheet,
  })  : entryPath = '',
        entryType = null;

  final BuildContext parentContext;
  final ReposCubit reposCubit;
  final RepoCubit originRepoCubit;
  final NavigationCubit navigationCubit;
  final EntrySelectionCubit? entrySelectionCubit;

  final String entryPath;
  final EntryType? entryType;

  final BottomSheetType sheetType;
  final void Function(
    BottomSheetType type,
    double padding,
    String entry,
  ) onUpdateBottomSheet;

  @override
  State<MoveSelectedEntriesDialog> createState() =>
      _MoveSelectedEntriesDialogState();
}

class _MoveSelectedEntriesDialogState extends State<MoveSelectedEntriesDialog>
    with AppLogger {
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

    widget.onUpdateBottomSheet(
        BottomSheetType.move, widgetSize?.height ?? 0.0, '');
  }

  @override
  Widget build(BuildContext context) => widget.reposCubit.builder(
        (reposCubit) => Container(
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
                ..._getLayout(),
                _selectActions(
                  widget.parentContext,
                  reposCubit,
                  widget.originRepoCubit,
                  widget.navigationCubit,
                  widget.entrySelectionCubit,
                  widget.entryPath,
                  widget.entryType,
                  widget.sheetType,
                ),
              ],
            ),
          ),
        ),
      );

  List<Widget> _getLayout() => widget.entryPath.isEmpty
      ? [
          _entriesCountLabel(widget.entrySelectionCubit!),
          _sourceLabel(widget.entrySelectionCubit!),
        ]
      : [
          Fields.iconLabel(
            icon: Icons.drive_file_move_outlined,
            text: repo_path.basename(widget.entryPath),
          ),
          Text(
            S.current
                .messageMoveEntryOrigin(repo_path.dirname(widget.entryPath)),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w800),
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ];

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
    BuildContext context,
    ReposCubit reposCubit,
    RepoCubit originRepoCubit,
    NavigationCubit navigationCubit,
    EntrySelectionCubit? entrySelectionCubit,
    String entryPath,
    EntryType? entryType,
    BottomSheetType sheetType,
  ) {
    final moveEntriesActions = MoveEntriesActions(
      context,
      reposCubit: reposCubit,
      originRepoCubit: originRepoCubit,
      type: sheetType,
    );

    return widget.entryPath.isEmpty
        ? _multipleEntriesActions(
            context,
            entrySelectionCubit!,
            reposCubit,
            moveEntriesActions,
            sheetType,
          )
        : _singleEntryActions(
            context,
            navigationCubit,
            reposCubit,
            moveEntriesActions,
            sheetType,
            entryPath,
            entryType!,
          );
  }

  Widget _singleEntryActions(
    BuildContext parentContext,
    NavigationCubit navigationCubit,
    ReposCubit reposCubit,
    MoveEntriesActions moveEntriesActions,
    BottomSheetType sheetType,
    String entryPath,
    EntryType entryType,
  ) =>
      BlocBuilder<NavigationCubit, NavigationState>(
        bloc: navigationCubit,
        builder: (context, state) {
          bool canMove = false;

          final currentRepo = reposCubit.currentRepo;
          if (currentRepo != null) {
            final originPath = repo_path.dirname(entryPath);
            final destinationRepoLocation = currentRepo.location;

            final accessMode = currentRepo.accessMode;
            final isCurrentRepoWriteMode = accessMode == AccessMode.write;

            canMove = state.isFolder
                ? moveEntriesActions.canMove(
                    originPath: originPath,
                    destinationRepoLocation: destinationRepoLocation,
                    destinationPath: state.path,
                    isCurrentRepoWriteMode: isCurrentRepoWriteMode,
                  )
                : false;
          }

          negativeAction() => cancelAndDismiss(moveEntriesActions);
          final negativeText = S.current.actionCancel;

          Future<void> positiveAction() async {
            cancelAndDismiss(moveEntriesActions);

            await Dialogs.executeFutureWithLoadingDialog(
              null,
              moveEntriesActions.copyOrMoveSingleEntry(
                destinationRepoCubit: currentRepo!.cubit!,
                entryPath: entryPath,
                entryType: entryType,
              ),
            );
          }

          final positiveText = moveEntriesActions.getActionText(sheetType);

          final aspectRatio = _getButtonAspectRatio(widgetSize);
          final actions = _actions(
            canMove,
            aspectRatio,
            positiveAction,
            positiveText,
            negativeAction,
            negativeText,
          );

          return Fields.dialogActions(
            buttons: actions,
            padding: const EdgeInsetsDirectional.only(top: 20.0),
            mainAxisAlignment: MainAxisAlignment.end,
          );
        },
      );

  Widget _multipleEntriesActions(
    BuildContext parentContext,
    EntrySelectionCubit entrySelectionCubit,
    ReposCubit reposCubit,
    MoveEntriesActions moveEntriesActions,
    BottomSheetType type,
  ) =>
      BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
        bloc: entrySelectionCubit,
        builder: (context, state) {
          bool enableAction = false;
          if ([BottomSheetType.download, BottomSheetType.delete]
              .contains(type)) {
            enableAction = true;
          } else {
            final currentRepo = reposCubit.currentRepo;
            final currentRepoCubit = currentRepo?.cubit;
            if (currentRepo != null && currentRepoCubit != null) {
              final currentPath = currentRepoCubit.currentFolder;

              final accessMode = currentRepo.accessMode;
              final isCurrentRepoWriteMode = accessMode == AccessMode.write;

              final validationOk = entrySelectionCubit.validateDestination(
                currentRepoCubit,
                currentPath,
              );

              if (!validationOk.destinationOk) {
                loggy.debug(
                  'Error validating multi entry destination: ${validationOk.errorMessage}',
                );
              }

              enableAction =
                  isCurrentRepoWriteMode && validationOk.destinationOk;
            }
          }

          negativeAction() => cancelAndDismiss(moveEntriesActions);
          final negativeText = S.current.actionCancel;

          Future<void> positiveAction() async {
            final currentRepoCubit = reposCubit.currentRepo?.cubit;
            if (currentRepoCubit == null) return;

            final multiEntryActions = MultiEntryActions(
              parentContext,
              entrySelectionCubit: entrySelectionCubit,
            );

            final action = moveEntriesActions.getAction(
              currentRepoCubit,
              multiEntryActions,
            );
            if (action == null) return;

            final resultOk = await action;
            if (!resultOk) return;

            cancelAndDismiss(moveEntriesActions);
          }

          final positiveText = moveEntriesActions.getActionText(type);

          final aspectRatio = _getButtonAspectRatio(widgetSize);
          final actions = _actions(
            enableAction,
            aspectRatio,
            positiveAction,
            positiveText,
            negativeAction,
            negativeText,
          );

          return Fields.dialogActions(
            buttons: actions,
            padding: const EdgeInsetsDirectional.only(top: 20.0),
            mainAxisAlignment: MainAxisAlignment.end,
          );
        },
      );

  List<Widget> _actions(
    bool canMove,
    double aspectRatio,
    void Function()? positiveAction,
    String positiveText,
    void Function()? negativeAction,
    String negativeText,
  ) =>
      [
        NegativeButton(
          buttonsAspectRatio: aspectRatio,
          buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
          text: negativeText,
          onPressed: negativeAction,
        ),
        PositiveButton(
          key: ValueKey('move_entry'),
          buttonsAspectRatio: aspectRatio,
          buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
          text: positiveText,
          onPressed: canMove ? positiveAction : null,
        )

        /// If the entry can't be moved (the user selected the same entry/path, for example)
        /// Then null is used instead of the function, which disable the button.
      ];

  void cancelAndDismiss(MoveEntriesActions moveEntriesActions) {
    widget.onUpdateBottomSheet(BottomSheetType.gone, 0.0, '');
    moveEntriesActions.cancel();
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
