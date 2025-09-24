import 'dart:async';
import 'dart:io';

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
import '../utils/storage.dart';
import 'buttons/dialog_action_button.dart';

/// Widget for selecting the directory to store a repository in.
class StorageSelector extends StatefulWidget {
  StorageSelector({
    required this.session,
    required this.onChanged,
    this.value,
    super.key,
  });

  final Session session;
  final ValueChanged<String> onChanged;
  final String? value;

  @override
  State<StorageSelector> createState() => _StorageSelectorState();
}

class _StorageSelectorState extends State<StorageSelector> with AppLogger {
  late final entries = _getStorages();

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: entries,
    builder: (context, snapshot) {
      final entries = snapshot.data ?? [];

      if (entries.length < 2) {
        return SizedBox.shrink();
      }

      final selectedPath = widget.value;
      final selectedEntry = selectedPath != null
          ? entries.firstWhere(
              (entry) =>
                  equals(entry.path, selectedPath) ||
                  isWithin(entry.path, selectedPath),
            )
          : entries.firstWhere((entry) => entry.storage.primary);

      return Column(
        children: entries
            .map(
              (entry) => RadioListTile(
                title: StorageLabel(entry.storage),
                subtitle: Text(
                  entry.storage.mountPoint,
                  overflow: TextOverflow.ellipsis,
                ),
                value: entry.path,
                groupValue: selectedEntry.path,
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

  Future<List<_StorageEntry>> _getStorages() => widget.session
      .getStoreDirs()
      .then(
        (dirs) => Future.wait(
          dirs.map(
            (dir) => Storage.forPath(dir).then(
              (storage) => storage != null ? _StorageEntry(dir, storage) : null,
            ),
          ),
        ),
      )
      .then((entries) => entries.nonNulls.toList());
}

class _StorageEntry {
  final String path;
  final Storage storage;

  const _StorageEntry(this.path, this.storage);

  @override
  String toString() => '$runtimeType(path: $path, storage: $storage)';
}

/// Returns icon for the given storage.
IconData storageIcon(Storage storage) =>
    storage.removable ? Icons.sd_card : Icons.smartphone;

/// Label for the given storage: consists of the storage description and icon.
class StorageLabel extends StatelessWidget {
  final Storage storage;

  StorageLabel(this.storage, {super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(storageIcon(storage)),
      Dimensions.spacingHorizontalHalf,
      Text(storage.description, overflow: TextOverflow.ellipsis),
    ],
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
  );
}

/// Dialog for changing repository storage
class StorageDialog extends StatelessWidget with AppLogger {
  StorageDialog({required this.session, required this.repoCubit, super.key});

  final Session session;
  final RepoCubit repoCubit;

  @override
  Widget build(BuildContext context) => BlocBuilder<RepoCubit, RepoState>(
    bloc: repoCubit,
    builder: (context, state) => AlertDialog(
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
          Divider(),
          Text(
            S.current.messageStorage,
            style: context.theme.appTextStyle.titleMedium,
          ),
          StorageSelector(
            session: session,
            value: state.location.dir,
            onChanged: (path) => _selectStorage(context, state, path),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(S.current.actionCloseCapital),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  Future<void> _copyToClipboard(BuildContext context, RepoState state) async {
    await Clipboard.setData(ClipboardData(text: state.location.path));
    showSnackBar(S.current.messageCopiedToClipboard, context: context);
  }

  Future<void> _openDirectory(RepoState state) =>
      launchUrl(Uri.file(state.location.dir));

  Future<void> _selectStorage(
    BuildContext context,
    RepoState state,
    String path,
  ) async {
    if (state.location.dir == path) {
      return;
    }

    final storage = await Storage.forPath(path);
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

/// Widget that builds itself based on the `Storage` containing the given path.
class StorageBuilder extends StatefulWidget {
  const StorageBuilder({required this.path, required this.builder, super.key});

  final String path;
  final Widget Function(BuildContext, Storage?) builder;

  @override
  State<StorageBuilder> createState() => _StorageBuilderState();
}

class _StorageBuilderState extends State<StorageBuilder> {
  Future<Storage?> storage = Future.value(null);

  @override
  void initState() {
    super.initState();
    storage = Storage.forPath(widget.path);
  }

  @override
  void didUpdateWidget(StorageBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.path != widget.path) {
      storage = Storage.forPath(widget.path);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Storage?>(
    future: storage,
    builder: (context, snapshot) => widget.builder(context, snapshot.data),
  );
}
