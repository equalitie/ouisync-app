import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show Session;
import 'package:path/path.dart' show equals, isWithin;
import 'package:styled_text/styled_text.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../utils/actions.dart' show showSnackBar;
import '../utils/dialogs.dart' show Dialogs;
import '../utils/dimensions.dart';
import '../utils/extensions.dart';
import '../utils/log.dart' show AppLogger;
import '../utils/storage_volume.dart';
import 'buttons/dialog_action_button.dart';

/// Widget for selecting the directory to store a repository in.
class StoreDirSelector extends StatefulWidget {
  StoreDirSelector({
    required this.storeDirs,
    required this.onChanged,
    this.value,
    super.key,
  });

  final List<String> storeDirs;
  final ValueChanged<String> onChanged;
  final String? value;

  @override
  State<StoreDirSelector> createState() => _StoreDirSelectorState();
}

class _StoreDirSelectorState extends State<StoreDirSelector> with AppLogger {
  Future<List<_StoreDirEntry>> entries = Future.value([]);

  @override
  void initState() {
    super.initState();
    entries = _getEntries();
  }

  @override
  void didUpdateWidget(StoreDirSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.storeDirs != widget.storeDirs) {
      entries = _getEntries();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: entries,
    builder: (context, snapshot) {
      final entries = snapshot.data ?? [];

      final selectedPath = widget.value;
      final selectedEntry = selectedPath != null
          ? entries.firstWhereOrNull(
              (entry) =>
                  equals(entry.path, selectedPath) ||
                  isWithin(entry.path, selectedPath),
            )
          : entries.firstWhereOrNull((entry) => entry.storage.primary);

      return Column(
        children: entries
            .map(
              (entry) => RadioListTile(
                title: StorageVolumeLabel(entry.storage),
                subtitle: entry.storage.mountPoint?.let(
                  (mountPoint) =>
                      Text(mountPoint, overflow: TextOverflow.ellipsis),
                ),
                value: entry.path,
                groupValue: selectedEntry?.path,
                onChanged: _change,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
              ),
            )
            .toList(),
      );
    },
  );

  void _change(String? path) {
    if (path != null) {
      widget.onChanged(path);
    }
  }

  Future<List<_StoreDirEntry>> _getEntries() => Future.wait(
    widget.storeDirs.map(
      (dir) => StorageVolume.forPath(dir).then(
        (storage) => storage != null ? _StoreDirEntry(dir, storage) : null,
      ),
    ),
  ).then((entries) => entries.nonNulls.toList());
}

class _StoreDirEntry {
  final String path;
  final StorageVolume storage;

  const _StoreDirEntry(this.path, this.storage);

  @override
  String toString() => '$runtimeType(path: $path, storage: $storage)';
}

extension StorageVolumeExtension on StorageVolume {
  /// Returns icon for the given storage.
  IconData get icon => removable ? Icons.sd_card : Icons.smartphone;
}

/// Label for the given storage volume: consists of the storage volume description and icon.
class StorageVolumeLabel extends StatelessWidget {
  final StorageVolume storage;

  StorageVolumeLabel(this.storage, {super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(storage.icon),
      Dimensions.spacingHorizontalHalf,
      Expanded(
        child: Text(storage.description, overflow: TextOverflow.ellipsis),
      ),
    ],
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
  );
}

/// Dialog for changing repository store directory
class StoreDirDialog extends StatelessWidget with AppLogger {
  StoreDirDialog({required this.session, required this.repoCubit, super.key});

  final Session session;
  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => BlocBuilder<RepoCubit, RepoState>(
    bloc: repoCubit,
    builder: (context, state) => StoreDirsBuilder(
      session: session,
      builder: (context, storeDirs) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.repoStorageLocation,
              style: context.theme.appTextStyle.titleMedium,
            ),
            Row(
              children: [
                Expanded(
                  child: Tooltip(
                    child: Text(
                      state.location.path,
                      overflow: TextOverflow.ellipsis,
                    ),
                    message: state.location.path,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(context, state),
                  tooltip: S.current.copyToClipboard,
                ),
                if (Platform.isLinux || Platform.isWindows)
                  IconButton(
                    icon: Icon(Icons.folder_open),
                    onPressed: () => _openDirectory(state),
                    tooltip: S.current.openFolder,
                  ),
              ],
            ),
            if (storeDirs.length > 1) ...[
              Divider(),
              Text(
                S.current.messageStorage,
                style: context.theme.appTextStyle.titleMedium,
              ),
              StoreDirSelector(
                storeDirs: storeDirs,
                value: state.location.dir,
                onChanged: (path) => _selectStoreDir(context, state, path),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            child: Text(S.current.actionCloseCapital),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );

  Future<void> _copyToClipboard(BuildContext context, RepoState state) async {
    await Clipboard.setData(ClipboardData(text: state.location.path));
    showSnackBar(S.current.messageCopiedToClipboard, context: context);
  }

  Future<void> _openDirectory(RepoState state) =>
      launchUrl(Uri.file(state.location.dir));

  Future<void> _selectStoreDir(
    BuildContext context,
    RepoState state,
    String path,
  ) async {
    if (state.location.dir == path) {
      return;
    }

    final storage = await StorageVolume.forPath(path);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          S.current.repoStorageMoveTitle,
          style: context.theme.appTextStyle.titleMedium,
        ),
        content: StyledText(
          text: S.current.repoStorageMovePrompt(storage?.description ?? path),
          tags: tags,
        ),
        actions: [
          NegativeButton(
            text: S.current.actionCancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          PositiveButton(
            text: S.current.actionMove,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await Dialogs.executeFutureWithLoadingDialog(
        context,
        repoCubit.move(state.location.relocate(path).path),
      );
    }
  }

  static final tags = {
    'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
  };
}

/// Widget that builds itself based on the `StorageVolume` containing the given path.
class StorageVolumeBuilder extends StatefulWidget {
  const StorageVolumeBuilder({
    required this.path,
    required this.builder,
    super.key,
  });

  final String path;
  final Widget Function(BuildContext, StorageVolume?) builder;

  @override
  State<StorageVolumeBuilder> createState() => _StorageVolumeBuilderState();
}

class _StorageVolumeBuilderState extends State<StorageVolumeBuilder> {
  Future<StorageVolume?> storage = Future.value(null);

  @override
  void initState() {
    super.initState();
    storage = StorageVolume.forPath(widget.path);
  }

  @override
  void didUpdateWidget(StorageVolumeBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.path != widget.path) {
      storage = StorageVolume.forPath(widget.path);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<StorageVolume?>(
    future: storage,
    builder: (context, snapshot) => widget.builder(context, snapshot.data),
  );
}

/// Widget that builds itself based on the current list of store directories.
class StoreDirsBuilder extends StatelessWidget {
  const StoreDirsBuilder({
    required this.session,
    required this.builder,
    super.key,
  });

  final Session session;
  final Widget Function(BuildContext, List<String>) builder;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<String>>(
    future: session.getStoreDirs(),
    builder: (context, snapshot) =>
        builder(context, snapshot.data ?? const <String>[]),
  );
}
