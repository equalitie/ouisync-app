import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import '../../cubits/cubits.dart'
    show EntrySelectionCubit, EntrySelectionState, Job, RepoCubit, RepoState;
import '../../cubits/store_dirs.dart';
import '../../models/models.dart'
    show DirectoryEntry, FileEntry, FileSystemEntry, RepoLocation;
import '../../utils/stage.dart';
import '../../utils/utils.dart' show Constants, Dimensions, Fields, ThemeGetter;
import '../widgets.dart'
    show
        FileDescription,
        FileIconAnimated,
        MissingRepoDescription,
        RepoDescription,
        RepoStatus,
        ScrollableTextWidget,
        SelectionStatus;
import '../store_dir.dart' show StorageVolumeExtension;

class FileListItem extends StatelessWidget {
  FileListItem({
    super.key,
    required this.entry,
    required this.repoCubit,
    required this.mainAction,
    required this.verticalDotsAction,
  });

  final FileEntry entry;
  final RepoCubit repoCubit;
  final void Function() mainAction;
  final void Function() verticalDotsAction;

  final ValueNotifier<bool?> _selected = ValueNotifier<bool?>(false);
  final ValueNotifier<Color?> _backgroundColor = ValueNotifier<Color?>(null);

  @override
  Widget build(BuildContext context) {
    // TODO: should this be inside of a BlockBuilder of fileItem.repoCubit?
    final repoInfoHash = repoCubit.state.infoHash;

    final entrySelectionCubit = repoCubit.entrySelectionCubit;
    final isSelected = entrySelectionCubit.state.isEntrySelected(
      repoInfoHash,
      entry,
    );

    final onSelectEntry = repoCubit.entrySelectionCubit.selectEntry;
    final onClearEntry = repoCubit.entrySelectionCubit.clearEntry;

    _updateSelection(
      context,
      isSelected,
      repoInfoHash: repoInfoHash,
      entry: entry,
      valueNotifier: _selected,
      colorNotifier: _backgroundColor,
      onSelectEntry: onSelectEntry,
      onClearEntry: onClearEntry,
    );

    final uploadJob = repoCubit.state.uploads[entry.path];
    final downloadJob = repoCubit.state.downloads[entry.path];

    return ValueListenableBuilder(
      valueListenable: _backgroundColor,
      builder: (context, stateColor, child) => _ListItemContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FileIconAnimated(downloadJob),
            Expanded(
              child: Container(
                padding: Dimensions.paddingItem,
                child: FileDescription(repoCubit, entry, uploadJob),
              ),
            ),
            TrailAction(
              repoInfoHash,
              entry,
              entrySelectionCubit: entrySelectionCubit,
              selectedNotifier: _selected,
              backgroundColorNotifier: _backgroundColor,
              onSelectEntry: onSelectEntry,
              onClearEntry: onClearEntry,
              uploadJob: uploadJob,
              verticalDotsAction: verticalDotsAction,
            ),
          ],
        ),
        mainAction: mainAction,
        backgroundColor: stateColor,
      ),
    );
  }
}

class DirectoryListItem extends StatelessWidget {
  DirectoryListItem({
    super.key,
    required this.entry,
    required this.repoCubit,
    required this.mainAction,
    required this.verticalDotsAction,
  });

  final DirectoryEntry entry;
  final RepoCubit repoCubit;
  final void Function() mainAction;
  final void Function() verticalDotsAction;

  final ValueNotifier<bool?> _selected = ValueNotifier<bool?>(false);
  final ValueNotifier<Color?> _backgroundColor = ValueNotifier<Color?>(null);

  @override
  Widget build(BuildContext context) {
    final repoInfoHash = repoCubit.state.infoHash;

    final entrySelectionCubit = repoCubit.entrySelectionCubit;
    final isSelected = entrySelectionCubit.state.isEntrySelected(
      repoInfoHash,
      entry,
    );

    final onSelectEntry = repoCubit.entrySelectionCubit.selectEntry;
    final onClearEntry = repoCubit.entrySelectionCubit.clearEntry;

    _updateSelection(
      context,
      isSelected,
      repoInfoHash: repoInfoHash,
      entry: entry,
      valueNotifier: _selected,
      colorNotifier: _backgroundColor,
      onSelectEntry: onSelectEntry,
      onClearEntry: onClearEntry,
    );

    return ValueListenableBuilder(
      valueListenable: _backgroundColor,
      builder: (context, stateColor, child) => _ListItemContainer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_rounded,
              size: Dimensions.sizeIconAverage,
              color: Constants.folderIconColor,
            ),
            Expanded(
              child: Container(
                padding: Dimensions.paddingItem,
                child: ScrollableTextWidget(child: Text(entry.name)),
              ),
            ),
            TrailAction(
              repoInfoHash,
              entry,
              entrySelectionCubit: entrySelectionCubit,
              selectedNotifier: _selected,
              backgroundColorNotifier: _backgroundColor,
              onSelectEntry: onSelectEntry,
              onClearEntry: onClearEntry,
              uploadJob: null,
              verticalDotsAction: verticalDotsAction,
            ),
          ],
        ),
        mainAction: mainAction,
        backgroundColor: stateColor,
      ),
    );
  }
}

class RepoListItem extends StatelessWidget {
  RepoListItem({
    super.key,
    required this.stage,
    required this.repoCubit,
    required this.storeDirsCubit,
    required this.isDefault,
    required this.mainAction,
    required this.verticalDotsAction,
  });

  final Stage stage;
  final RepoCubit repoCubit;
  final StoreDirsCubit storeDirsCubit;
  final bool isDefault;
  final void Function() mainAction;
  final void Function() verticalDotsAction;

  @override
  Widget build(BuildContext context) => _ListItemContainer(
    child: BlocBuilder<RepoCubit, RepoState>(
      bloc: repoCubit,
      builder: (context, state) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            key: Key('access-mode-button'),
            icon: Icon(
              Fields.accessModeIcon(state.accessMode),
              size: Dimensions.sizeIconAverage,
            ),
            color: Constants.folderIconColor,
            padding: EdgeInsets.all(0.0),
            onPressed: () => repoCubit.lock(),
          ),
          Expanded(
            child: Container(
              padding: Dimensions.paddingItem,
              child: RepoDescription(state, isDefault: isDefault),
            ),
          ),
          _RepoStore(storeDirsCubit, state.location),
          RepoStatus(stage, repoCubit),
          _VerticalDotsButton(disable: false, action: verticalDotsAction),
        ],
      ),
    ),
    mainAction: mainAction,
  );
}

class MissingRepoListItem extends StatelessWidget {
  MissingRepoListItem({
    super.key,
    required this.location,
    required this.mainAction,
    required this.verticalDotsAction,
  });

  final RepoLocation location;
  final void Function() mainAction;
  final void Function() verticalDotsAction;

  @override
  Widget build(BuildContext context) => _ListItemContainer(
    mainAction: mainAction,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Icon(
            Icons.error_outline_rounded,
            size: Dimensions.sizeIconAverage,
            color: Constants.folderIconColor,
          ),
        ),
        Expanded(
          flex: 9,
          child: Padding(
            padding: Dimensions.paddingItem,
            child: MissingRepoDescription(location.name),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.delete,
            size: Dimensions.sizeIconMicro,
            color: Constants.dangerColor,
          ),
          onPressed: () => verticalDotsAction(),
        ),
      ],
    ),
  );
}

class _ListItemContainer extends StatelessWidget {
  _ListItemContainer({
    required this.child,
    required this.mainAction,
    this.backgroundColor,
  });

  final Widget child;
  final Function mainAction;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Material(
    color: backgroundColor ?? Colors.white,
    child: InkWell(
      onTap: () => mainAction.call(),
      splashColor: Colors.blue,
      child: Container(padding: Dimensions.paddingListItem, child: child),
    ),
  );
}

class TrailAction extends StatelessWidget {
  const TrailAction(
    this.repoInfoHash,
    this.entry, {
    required this.entrySelectionCubit,
    required ValueNotifier<bool?> selectedNotifier,
    required ValueNotifier<Color?> backgroundColorNotifier,
    required this.onSelectEntry,
    required this.onClearEntry,
    required this.uploadJob,
    required this.verticalDotsAction,
    super.key,
  }) : _selectedNotifier = selectedNotifier,
       _backgroundColorNotifier = backgroundColorNotifier;

  final String repoInfoHash;
  final FileSystemEntry entry;

  final EntrySelectionCubit entrySelectionCubit;

  final ValueNotifier<bool?> _selectedNotifier;
  final ValueNotifier<Color?> _backgroundColorNotifier;

  final void Function(String, FileSystemEntry) onSelectEntry;
  final void Function(String, FileSystemEntry) onClearEntry;

  final Job? uploadJob;
  final void Function() verticalDotsAction;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EntrySelectionCubit, EntrySelectionState>(
      bloc: entrySelectionCubit,
      builder: (context, state) {
        final isSingleEntry = state.singleEntry != DirectoryEntry(path: '');
        if (isSingleEntry) {
          return state.singleEntry.path == entry.path
              ? IconButton(onPressed: () {}, icon: const Icon(Icons.check))
              : _VerticalDotsButton(disable: true, action: verticalDotsAction);
        }

        final parent = p.dirname(entry.path);
        final isSelectable = state.isSelectable(repoInfoHash, parent);
        return isSelectable
            ? ValueListenableBuilder(
                valueListenable: _selectedNotifier,
                builder: (BuildContext context, bool? value, Widget? child) =>
                    Checkbox.adaptive(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      value: value,
                      onChanged: (value) => _updateSelection(
                        context,
                        value ?? false,
                        repoInfoHash: repoInfoHash,
                        entry: entry,
                        valueNotifier: _selectedNotifier,
                        colorNotifier: _backgroundColorNotifier,
                        onSelectEntry: onSelectEntry,
                        onClearEntry: onClearEntry,
                      ),
                    ),
              )
            : _VerticalDotsButton(
                disable: state.status == SelectionStatus.on,
                action: uploadJob == null ? verticalDotsAction : null,
              );
      },
      listener: (context, state) {
        if (repoInfoHash != state.originRepoInfoHash) return;

        if (state.status == SelectionStatus.off) {
          _updateSelection(
            context,
            false,
            repoInfoHash: repoInfoHash,
            entry: entry,
            valueNotifier: _selectedNotifier,
            colorNotifier: _backgroundColorNotifier,
            onSelectEntry: onSelectEntry,
            onClearEntry: onClearEntry,
          );
        }
      },
    );
  }
}

class _RepoStore extends StatelessWidget {
  final StoreDirsCubit storeDirsCubit;
  final RepoLocation location;

  _RepoStore(this.storeDirsCubit, this.location);

  @override
  Widget build(BuildContext context) => BlocBuilder<StoreDirsCubit, StoreDirs>(
    bloc: storeDirsCubit,
    builder: (context, storeDirs) {
      if (storeDirs.length <= 1) {
        return SizedBox.shrink();
      }

      final dir = storeDirs.firstWhereOrNull((dir) => dir.path == location.dir);
      if (dir == null) {
        return SizedBox.shrink();
      }

      if (!dir.volume.isRemovable) {
        return SizedBox.shrink();
      }

      return Tooltip(
        message: dir.volume.description,
        child: Icon(dir.volume.icon, color: Colors.black.withAlpha(128)),
      );
    },
  );
}

void _updateSelection(
  BuildContext context,
  bool value, {
  required String repoInfoHash,
  required FileSystemEntry entry,
  required ValueNotifier<bool?> valueNotifier,
  required ValueNotifier<Color?> colorNotifier,
  required void Function(String, FileSystemEntry) onSelectEntry,
  required void Function(String, FileSystemEntry) onClearEntry,
}) async {
  if (valueNotifier.value == value) return;

  valueNotifier.value = value;

  if (value) {
    onSelectEntry(repoInfoHash, entry);
  } else {
    onClearEntry(repoInfoHash, entry);
  }

  _getBackgroundColor(context, notifier: colorNotifier, value: value);
}

void _getBackgroundColor(
  BuildContext context, {
  required ValueNotifier<Color?> notifier,
  required bool value,
}) => notifier.value = switch (value) {
  true => context.theme.highlightColor,
  false => Colors.white,
};

class _VerticalDotsButton extends StatelessWidget {
  _VerticalDotsButton({required this.disable, required this.action});

  final bool disable;
  final void Function()? action;

  @override
  Widget build(BuildContext context) => IconButton(
    key: ValueKey('file_vert'),
    color: disable ? Colors.grey : null,
    icon: Icon(
      disable ? Icons.more_horiz_rounded : Icons.more_vert_rounded,
      size: Dimensions.sizeIconSmall,
    ),
    onPressed: action,
  );
}
