import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart' show Session;

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../utils/actions.dart' show showSnackBar;
import '../utils/dialogs.dart' show Dialogs;
import '../utils/dimensions.dart';
import '../utils/entry_ops.dart' show viewFile;
import '../utils/extensions.dart';
import '../utils/log.dart' show AppLogger;
import '../utils/storage.dart';
import 'buttons/dialog_action_button.dart';

class StorageSelector extends StatefulWidget {
  StorageSelector({
    required this.session,
    required this.onChanged,
    this.value,
    super.key,
  });

  final Session session;
  final ValueChanged<Storage> onChanged;
  final Storage? value;

  @override
  State<StorageSelector> createState() => _StorageSelectorState();
}

class _StorageSelectorState extends State<StorageSelector> with AppLogger {
  late final storages = Storage.all(widget.session);

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: storages,
    builder: (context, snapshot) {
      final storages = snapshot.data ?? [];

      if (storages.length < 2) {
        return SizedBox.shrink();
      }

      final value =
          widget.value ?? storages.firstWhere((storage) => storage.primary);

      return Column(
        children: storages
            .map(
              (storage) => RadioListTile(
                title: StorageLabel(storage),
                subtitle: Text(
                  storage.mountPoint,
                  overflow: TextOverflow.ellipsis,
                ),
                value: storage,
                groupValue: value,
                onChanged: _change,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
              ),
            )
            .toList(),
      );
    },
  );

  void _change(Storage? value) {
    if (value != null) {
      widget.onChanged(value);
    }
  }
}

IconData storageIcon(Storage storage) =>
    storage.removable ? Icons.sd_card : Icons.smartphone;

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
              ),
              if (Platform.isLinux || Platform.isWindows)
                IconButton(
                  icon: Icon(Icons.folder_open),
                  onPressed: () => _openDirectory(state),
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
            value: state.storage,
            onChanged: (newStorage) =>
                _selectStorage(context, state, newStorage),
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
      viewFile(repo: repoCubit, path: state.location.path, loggy: loggy);

  Future<void> _selectStorage(
    BuildContext context,
    RepoState state,
    Storage newStorage,
  ) async {
    if (newStorage == state.storage) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          S.current.repoStorageMoveTitle,
          style: context.theme.appTextStyle.titleMedium,
        ),
        content: _formatPrompt(newStorage.description),
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
      final newPath = state.location.relocate(newStorage.path).path;
      await Dialogs.executeFutureWithLoadingDialog(
        context,
        repoCubit.move(newPath),
      );
    }
  }

  // Apply rich formatting to the prompt text.
  Widget _formatPrompt(String storageName) {
    final separator = '\u0000';
    final template = S.current.repoStorageMovePrompt(separator);
    final spans = <TextSpan>[];

    for (final part in template.split(separator)) {
      if (spans.isNotEmpty) {
        spans.add(
          TextSpan(
            text: storageName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }

      spans.add(TextSpan(text: part));
    }

    return Text.rich(TextSpan(children: spans));
  }
}
