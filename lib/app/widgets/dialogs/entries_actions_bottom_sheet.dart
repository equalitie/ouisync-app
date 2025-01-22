import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show AccessMode;
import 'package:ouisync_app/app/models/models.dart'
    show DirectoryEntry, FileEntry, FileSystemEntry;

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
    show
        AppLogger,
        Dialogs,
        Dimensions,
        Fields,
        MoveEntriesActions,
        MultiEntryActions;
import '../widgets.dart' show NegativeButton, PositiveButton;

class EntriesActionsDialog extends StatefulWidget {
  const EntriesActionsDialog.single(
    this.parentContext, {
    required this.reposCubit,
    required this.originRepoCubit,
    required this.entry,
    required this.sheetType,
    required this.onUpdateBottomSheet,
  });

  const EntriesActionsDialog.multiple(
    this.parentContext, {
    required this.reposCubit,
    required this.originRepoCubit,
    required this.sheetType,
    required this.onUpdateBottomSheet,
  }) : entry = null;

  final BuildContext parentContext;
  final ReposCubit reposCubit;
  final RepoCubit originRepoCubit;

  final FileSystemEntry? entry;

  final BottomSheetType sheetType;
  final void Function(
    BottomSheetType type,
    double padding,
    String entry,
  ) onUpdateBottomSheet;

  @override
  State<EntriesActionsDialog> createState() => _EntriesActionsDialogState();
}

class _EntriesActionsDialogState extends State<EntriesActionsDialog>
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
                ..._getLayout(widget.originRepoCubit.entrySelectionCubit),
                _selectActions(
                  widget.parentContext,
                  reposCubit,
                  widget.originRepoCubit,
                  widget.reposCubit.navigation,
                  widget.originRepoCubit.entrySelectionCubit,
                  widget.entry,
                  widget.sheetType,
                ),
              ],
            ),
          ),
        ),
      );

  List<Widget> _getLayout(EntrySelectionCubit entrySelectionCubit) =>
      widget.entry == null
          ? [
              _entriesCountLabel(entrySelectionCubit),
              _sourceLabel(entrySelectionCubit),
            ]
          : [
              Fields.iconLabel(
                icon: Icons.drive_file_move_outlined,
                text: repo_path.basename(widget.entry!.path),
              ),
              Text(
                S.current.messageMoveEntryOrigin(
                  repo_path.dirname(widget.entry!.path),
                ),
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
          final totalDirs =
              state.selectedEntries.whereType<DirectoryEntry>().length;
          final totalFiles =
              state.selectedEntries.whereType<FileEntry>().length;

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
          S.current.messageMoveEntryOrigin(
            repo_path.dirname(state.selectedEntries.first.path),
          ),
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
    FileSystemEntry? entry,
    BottomSheetType sheetType,
  ) =>
      BlocBuilder<NavigationCubit, NavigationState>(
        bloc: navigationCubit,
        builder: (context, state) {
          final moveEntriesActions = MoveEntriesActions(
            context,
            reposCubit: reposCubit,
            originRepoCubit: originRepoCubit,
            sheetType: sheetType,
          );

          return entry == null
              ? _multipleEntriesActions(
                  context,
                  entrySelectionCubit!,
                  reposCubit,
                  originRepoCubit,
                  moveEntriesActions,
                  sheetType,
                )
              : _singleEntryActions(
                  context,
                  state,
                  reposCubit,
                  originRepoCubit,
                  moveEntriesActions,
                  sheetType,
                  entry,
                );
        },
      );

  Widget _singleEntryActions(
    BuildContext parentContext,
    NavigationState state,
    ReposCubit reposCubit,
    RepoCubit originRepoCubit,
    MoveEntriesActions moveEntriesActions,
    BottomSheetType sheetType,
    FileSystemEntry entry,
  ) {
    bool canMove = false;

    final currentRepo = reposCubit.currentRepo;
    if (currentRepo != null) {
      final isCurrentRepoWriteMode = currentRepo.accessMode == AccessMode.write;
      canMove = state.isFolder
          ? moveEntriesActions.canMove(
              entry: entry,
              destinationPath: state.path,
              destinationRepoLocation: currentRepo.location,
              isCurrentRepoWriteMode: isCurrentRepoWriteMode,
            )
          : false;
    }

    negativeAction() => cancelAndDismiss(moveEntriesActions, originRepoCubit);
    final negativeText = S.current.actionCancel;

    Future<void> positiveAction() async {
      cancelAndDismiss(moveEntriesActions, originRepoCubit);

      await Dialogs.executeFutureWithLoadingDialog(
        null,
        moveEntriesActions.copyOrMoveSingleEntry(
          destinationRepoCubit: currentRepo!.cubit!,
          entry: entry,
        ),
      );
    }

    final positiveText = moveEntriesActions.getActionText(sheetType);

    final aspectRatio = _getButtonAspectRatio(widgetSize);
    final isDangerButton = sheetType == BottomSheetType.delete;

    final actions = _actions(
      canMove,
      aspectRatio,
      positiveAction,
      positiveText,
      negativeAction,
      negativeText,
      isDangerButton,
    );

    return Fields.dialogActions(
      buttons: actions,
      padding: const EdgeInsetsDirectional.only(top: 20.0),
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }

  Widget _multipleEntriesActions(
    BuildContext parentContext,
    EntrySelectionCubit entrySelectionCubit,
    ReposCubit reposCubit,
    RepoCubit originRepoCubit,
    MoveEntriesActions moveEntriesActions,
    BottomSheetType sheetType,
  ) =>
      BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
        bloc: entrySelectionCubit,
        builder: (context, state) {
          bool enableAction = false;
          if ([BottomSheetType.download, BottomSheetType.delete]
              .contains(sheetType)) {
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

          negativeAction() => cancelAndDismiss(
                moveEntriesActions,
                originRepoCubit,
              );
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

            cancelAndDismiss(moveEntriesActions, originRepoCubit);
          }

          final positiveText = moveEntriesActions.getActionText(sheetType);

          final aspectRatio = _getButtonAspectRatio(widgetSize);
          final isDangerButton = sheetType == BottomSheetType.delete;

          final actions = _actions(
            enableAction,
            aspectRatio,
            positiveAction,
            positiveText,
            negativeAction,
            negativeText,
            isDangerButton,
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
    bool isDangerButton,
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
          isDangerButton: isDangerButton,
          buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
          text: positiveText,
          onPressed: canMove ? positiveAction : null,
        )

        /// If the entry can't be moved (the user selected the same entry/path, for example)
        /// Then null is used instead of the function, which disable the button.
      ];

  void cancelAndDismiss(
    MoveEntriesActions moveEntriesActions,
    RepoCubit originRepoCubit,
  ) {
    // widget.onUpdateBottomSheet(BottomSheetType.gone, 0.0, '');

    moveEntriesActions.cancel();
    originRepoCubit.endEntriesSelection();
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
