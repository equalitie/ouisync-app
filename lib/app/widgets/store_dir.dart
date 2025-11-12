import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' show isWithin;
import 'package:styled_text/styled_text.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

import '../../generated/l10n.dart';
import '../cubits/repo.dart';
import '../cubits/store_dirs.dart';
import '../utils/dialogs.dart' show Dialogs;
import '../utils/dimensions.dart';
import '../utils/extensions.dart';
import '../utils/log.dart' show AppLogger;
import '../utils/stage.dart';
import '../utils/storage_volume.dart';
import 'buttons/dialog_action_button.dart';

/// Widget for selecting the directory to store a repository in.
class StoreDirSelector extends StatelessWidget {
  StoreDirSelector({
    required this.storeDirsCubit,
    required this.onChanged,
    this.value,
    super.key,
  });

  final StoreDirsCubit storeDirsCubit;
  final ValueChanged<StoreDir> onChanged;
  final StoreDir? value;

  @override
  Widget build(BuildContext context) => BlocBuilder<StoreDirsCubit, StoreDirs>(
    bloc: storeDirsCubit,
    builder: (context, storeDirs) {
      final selected =
          value ?? storeDirs.firstWhereOrNull((dir) => dir.volume.isPrimary);

      return Column(
        children: storeDirs
            .map(
              (dir) => RadioListTile(
                title: StorageVolumeLabel(dir.volume),
                subtitle: switch (dir.volume.state) {
                  StorageVolumeMounted(mountPoint: final mountPoint)
                      when mountPoint != null =>
                    Text(mountPoint, overflow: TextOverflow.ellipsis),
                  StorageVolumeMounted() || StorageVolumeUnmounted() => null,
                },
                value: dir,
                groupValue: selected,
                onChanged: (dir) {
                  if (dir != null) {
                    onChanged(dir);
                  }
                },
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
              ),
            )
            .toList(),
      );
    },
  );
}

extension StorageVolumeExtension on StorageVolume {
  /// Returns icon for the given storage.
  IconData get icon => isRemovable ? Icons.sd_card : Icons.smartphone;
}

/// Label for the given storage volume: consists of the storage volume description and icon.
class StorageVolumeLabel extends StatelessWidget {
  final StorageVolume volume;

  StorageVolumeLabel(this.volume, {super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(volume.icon),
      Dimensions.spacingHorizontalHalf,
      Expanded(
        child: Text(volume.description, overflow: TextOverflow.ellipsis),
      ),
    ],
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
  );
}

/// Dialog for changing repository store directory
class StoreDirDialog extends StatelessWidget with AppLogger {
  StoreDirDialog({
    required this.storeDirsCubit,
    required this.repoCubit,
    required this.stage,
    super.key,
  });

  final StoreDirsCubit storeDirsCubit;
  final RepoCubit repoCubit;
  final Stage stage;

  @override
  Widget build(BuildContext context) => BlocBuilder<RepoCubit, RepoState>(
    bloc: repoCubit,
    builder: (context, repoState) => BlocBuilder<StoreDirsCubit, StoreDirs>(
      bloc: storeDirsCubit,
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
                      repoState.location.path,
                      overflow: TextOverflow.ellipsis,
                    ),
                    message: repoState.location.path,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(repoState),
                  tooltip: S.current.copyToClipboard,
                ),
                if (Platform.isLinux || Platform.isWindows)
                  IconButton(
                    icon: Icon(Icons.folder_open),
                    onPressed: () => _openDirectory(repoState),
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
                storeDirsCubit: storeDirsCubit,
                value: storeDirs.firstWhereOrNull(
                  (dir) => isWithin(dir.path, repoState.location.path),
                ),
                onChanged: (dir) => _selectStoreDir(context, repoState, dir),
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

  Future<void> _copyToClipboard(RepoState state) async {
    await Clipboard.setData(ClipboardData(text: state.location.path));
    stage.showSnackBar(S.current.messageCopiedToClipboard);
  }

  Future<void> _openDirectory(RepoState state) =>
      launchUrl(Uri.file(state.location.dir));

  Future<void> _selectStoreDir(
    BuildContext context,
    RepoState repoState,
    StoreDir dir,
  ) async {
    if (repoState.location.dir == dir.path) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          S.current.repoStorageMoveTitle,
          style: context.theme.appTextStyle.titleMedium,
        ),
        content: StyledText(
          text: S.current.repoStorageMovePrompt(dir.volume.description),
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
        repoCubit.move(repoState.location.relocate(dir.path).path),
      );
    }
  }

  static final tags = {
    'bold': StyledTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
  };
}
