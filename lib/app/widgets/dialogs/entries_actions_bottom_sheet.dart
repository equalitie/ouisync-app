import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../cubits/repos.dart';
import '../../utils/dirs.dart';
import '../../utils/repo_path.dart' as repo_path;
import '../../utils/stage.dart';
import '../../utils/utils.dart'
    show AppLogger, Dimensions, Fields, MoveEntriesActions, MultiEntryActions;
import '../widgets.dart' show NegativeButton, PositiveButton;

class EntriesActionsDialog extends StatefulWidget {
  const EntriesActionsDialog.single(
    this.parentContext, {
    required this.reposCubit,
    required this.originRepoCubit,
    required this.entry,
    required this.sheetType,
    required this.onUpdateBottomSheet,
    required this.dirs,
    required this.stage,
  });

  const EntriesActionsDialog.multiple(
    this.parentContext, {
    required this.reposCubit,
    required this.originRepoCubit,
    required this.sheetType,
    required this.onUpdateBottomSheet,
    required this.dirs,
    required this.stage,
  }) : entry = null;

  final BuildContext parentContext;
  final ReposCubit reposCubit;
  final RepoCubit originRepoCubit;
  final Dirs dirs;
  final Stage stage;

  final FileSystemEntry? entry;

  final BottomSheetType sheetType;
  final void Function(BottomSheetType type, double padding, String entry)
  onUpdateBottomSheet;

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
      BottomSheetType.move,
      widgetSize?.height ?? 0.0,
      '',
    );
  }

  @override
  Widget build(BuildContext ctx) => BlocBuilder<ReposCubit, ReposState>(
    bloc: widget.reposCubit,
    builder: (ctx, reposState) => Container(
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
              widget.reposCubit,
              widget.originRepoCubit,
              reposState,
              widget.reposCubit.navigation,
              widget.originRepoCubit.entrySelectionCubit,
              widget.entry,
              widget.sheetType,
              widget.dirs,
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ];

  Widget _entriesCountLabel(EntrySelectionCubit entrySelectionCubit) =>
      BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
        bloc: entrySelectionCubit,
        builder: (context, state) {
          final totalDirs = state.selectedEntries
              .whereType<DirectoryEntry>()
              .length;
          final totalFiles = state.selectedEntries
              .whereType<FileEntry>()
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
          S.current.messageMoveEntryOrigin(state.selectionOriginPath),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      );

  Widget _selectActions(
    BuildContext context,
    ReposCubit reposCubit,
    RepoCubit originRepoCubit,
    ReposState reposState,
    NavigationCubit navigationCubit,
    EntrySelectionCubit? entrySelectionCubit,
    FileSystemEntry? entry,
    BottomSheetType sheetType,
    Dirs dirs,
  ) => BlocBuilder<NavigationCubit, NavigationState>(
    bloc: navigationCubit,
    builder: (ctx, state) {
      final moveEntriesActions = MoveEntriesActions(
        stage: widget.stage,
        reposCubit: reposCubit,
        originRepoCubit: originRepoCubit,
        sheetType: sheetType,
      );

      return entry == null
          ? _multipleEntriesActions(
              entrySelectionCubit!,
              reposCubit,
              originRepoCubit,
              reposState,
              moveEntriesActions,
              sheetType,
              dirs,
            )
          : _singleEntryActions(
              context,
              state,
              entrySelectionCubit!,
              reposCubit,
              originRepoCubit,
              reposState,
              moveEntriesActions,
              sheetType,
              entry,
            );
    },
  );

  Widget _singleEntryActions(
    BuildContext parentContext,
    NavigationState state,
    EntrySelectionCubit entrySelectionCubit,
    ReposCubit reposCubit,
    RepoCubit originRepoCubit,
    ReposState reposState,
    MoveEntriesActions moveEntriesActions,
    BottomSheetType sheetType,
    FileSystemEntry entry,
  ) {
    final enableAction = moveEntriesActions.enableAction(
      entrySelectionCubit.validateDestination,
      reposState.current,
    );

    negativeAction() => cancelAndDismiss(moveEntriesActions, originRepoCubit);
    final negativeText = S.current.actionCancel;

    Future<void> positiveAction() async {
      cancelAndDismiss(moveEntriesActions, originRepoCubit);

      await moveEntriesActions.copyOrMoveSingleEntry(
        destinationRepoCubit: reposState.current!.cubit!,
        entry: entry,
      );
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
  }

  Widget _multipleEntriesActions(
    EntrySelectionCubit entrySelectionCubit,
    ReposCubit reposCubit,
    RepoCubit originRepoCubit,
    ReposState reposState,
    MoveEntriesActions moveEntriesActions,
    BottomSheetType sheetType,
    Dirs dirs,
  ) => BlocBuilder<EntrySelectionCubit, EntrySelectionState>(
    bloc: entrySelectionCubit,
    builder: (context, state) {
      bool enableAction = false;
      if ([
        BottomSheetType.download,
        BottomSheetType.delete,
      ].contains(sheetType)) {
        enableAction = true;
      } else {
        final validation = entrySelectionCubit.validateDestination;
        enableAction = moveEntriesActions.enableAction(
          validation,
          reposState.current,
        );
      }

      negativeAction() => cancelAndDismiss(moveEntriesActions, originRepoCubit);
      final negativeText = S.current.actionCancel;

      Future<void> positiveAction() async {
        final currentRepoCubit = reposState.current?.cubit;
        if (currentRepoCubit == null) return;

        final multiEntryActions = MultiEntryActions(
          entrySelectionCubit: entrySelectionCubit,
          dirs: dirs,
          stage: widget.stage,
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
    bool enableAction,
    double aspectRatio,
    Future<void> Function()? positiveAction,
    String positiveText,
    void Function() negativeAction,
    String negativeText,
    bool isDangerButton,
  ) => [
    NegativeButton(
      buttonsAspectRatio: aspectRatio,
      buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
      text: negativeText,
      onPressed: () async {
        negativeAction();
      },
    ),
    PositiveButton(
      key: ValueKey('move_entry'),
      buttonsAspectRatio: aspectRatio,
      dangerous: isDangerButton,
      buttonConstrains: Dimensions.sizeConstrainsBottomDialogAction,
      text: positiveText,
      onPressed: enableAction ? positiveAction : null,
    ),

    /// If the entry can't be moved (the user selected the same entry/path, for example)
    /// Then null is used instead of the function, which disable the button.
  ];

  void cancelAndDismiss(
    MoveEntriesActions moveEntriesActions,
    RepoCubit originRepoCubit,
  ) {
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
