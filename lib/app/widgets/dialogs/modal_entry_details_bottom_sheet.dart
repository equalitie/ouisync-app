import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync/native_channels.dart' show NativeChannels;
import 'package:ouisync/ouisync.dart' show AccessMode;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show BottomSheetType, RepoCubit;
import '../../models/models.dart'
    show DirectoryEntry, FileEntry, FileSystemEntry;
import '../../pages/pages.dart' show PreviewFileCallback;
import '../../utils/repo_path.dart' as repo_path;
import '../../utils/utils.dart'
    show
        AppThemeExtension,
        Constants,
        Dialogs,
        Dimensions,
        Fields,
        FileIO,
        Native,
        ThemeGetter,
        formatSize,
        showSnackBar;
import '../widgets.dart'
    show
        ActionsDialog,
        EntryAction,
        EntryActionItem,
        EntryInfoTable,
        RenameEntry;

class EntryDetails extends StatefulWidget {
  const EntryDetails.file(
    this.context, {
    required this.repoCubit,
    required this.entry,
    required this.isActionAvailableValidator,
    required this.onPreviewFile,
    required this.packageInfo,
    required this.nativeChannels,
  }) : assert(entry is FileEntry);

  const EntryDetails.folder(
    this.context, {
    required this.repoCubit,
    required this.entry,
    required this.isActionAvailableValidator,
  })  : assert(entry is DirectoryEntry),
        onPreviewFile = null,
        packageInfo = null,
        nativeChannels = null;

  final BuildContext context;
  final RepoCubit repoCubit;
  final FileSystemEntry entry;
  final bool Function(AccessMode, EntryAction) isActionAvailableValidator;
  final PreviewFileCallback? onPreviewFile;
  final PackageInfo? packageInfo;
  final NativeChannels? nativeChannels;

  @override
  State<EntryDetails> createState() => _EntryDetailsState();
}

class _EntryDetailsState extends State<EntryDetails> {
  late final bool isFile = widget.entry is FileEntry;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Container(
          padding: Dimensions.paddingBottomSheet,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Fields.bottomSheetHandle(context),
              Fields.bottomSheetTitle(
                isFile
                    ? S.current.titleFileDetails
                    : S.current.titleFolderDetails,
                style: context.theme.appTextStyle.titleMedium,
              ),
              if (isFile) _buildAction(EntryAction.preview),
              _buildAction(EntryAction.copy),
              _buildAction(EntryAction.move),
              _buildAction(EntryAction.rename),
              if (isFile) _buildAction(EntryAction.download),
              if (isFile && io.Platform.isAndroid)
                _buildAction(EntryAction.share),
              _buildAction(EntryAction.delete),
              const Divider(
                height: 10.0,
                thickness: 2.0,
                indent: 20.0,
                endIndent: 20.0,
              ),
              EntryInfoTable(
                entryInfo: {
                  S.current.labelName: widget.entry.name,
                  S.current.labelLocation: p.dirname(widget.entry.path),
                  if (isFile)
                    S.current.labelSize: formatSize(
                      (widget.entry as FileEntry).size ?? 0,
                    ),
                },
              ),
            ],
          ),
        ),
      );
}

extension on _EntryDetailsState {
  Widget _buildAction(EntryAction type) => EntryActionItem(
        iconData: _getIconForAction(type),
        title: _getTextForType(type),
        onTap: _getActionForType(type),
        enabledValidation: () => widget.isActionAvailableValidator(
          widget.repoCubit.state.accessMode,
          type,
        ),
        dense: true,
        isDanger: type == EntryAction.delete,
        disabledMessage: S.current.messageActionNotAvailable,
        disabledMessageDuration: Constants.notAvailableActionMessageDuration,
      );

  IconData _getIconForAction(EntryAction type) => switch (type) {
        EntryAction.preview => Icons.preview_outlined,
        EntryAction.copy => Icons.copy_outlined,
        EntryAction.move => Icons.drive_file_move_outlined,
        EntryAction.rename => Icons.edit_outlined,
        EntryAction.download => Icons.download_outlined,
        EntryAction.share => Icons.share_outlined,
        EntryAction.delete => Icons.delete_outlined,
      };

  String _getTextForType(EntryAction type) => switch (type) {
        EntryAction.preview => S.current.iconPreview,
        EntryAction.copy => S.current.iconCopy,
        EntryAction.move => S.current.iconMove,
        EntryAction.rename => S.current.iconRename,
        EntryAction.download => S.current.iconDownload,
        EntryAction.share => S.current.iconShare,
        EntryAction.delete => S.current.iconDelete,
      };

  Function() _getActionForType(EntryAction type) => switch (type) {
        EntryAction.preview => _onPreviewFileTap,
        EntryAction.copy => _onCopyTap,
        EntryAction.move => _onMoveTap,
        EntryAction.rename => _onRenameTap,
        EntryAction.download => _onDownloadTap,
        EntryAction.share => _onShareTap,
        EntryAction.delete => _onDeleteTap,
      };

  Future<void> _onPreviewFileTap() async {
    await Navigator.of(context).maybePop();
    await widget.onPreviewFile!.call(
      widget.repoCubit,
      widget.entry as FileEntry,
      false,
    );
  }

  Future<void> _onCopyTap() async {
    await Navigator.of(context).maybePop();
    await _copyOrMoveEntry(
      widget.repoCubit,
      widget.entry,
      BottomSheetType.copy,
    );
  }

  Future<void> _onMoveTap() async {
    await Navigator.of(context).maybePop();
    await _copyOrMoveEntry(
      widget.repoCubit,
      widget.entry,
      BottomSheetType.move,
    );
  }

  Future<void> _copyOrMoveEntry(
    RepoCubit originRepoCubit,
    FileSystemEntry entry,
    BottomSheetType type,
  ) async {
    final isSingleSelection = true;

    await originRepoCubit.startEntriesSelection(isSingleSelection, entry);
    originRepoCubit.showMoveEntryBottomSheet(sheetType: type, entry: entry);
  }

  Future<void> _onRenameTap() async {
    final entry = widget.entry;
    final newName = await _getNewEntryName(entry);

    if (newName.isEmpty) return;

    await Navigator.of(context).maybePop();

    final parent = p.dirname(entry.path);
    final newEntryPath = p.join(parent, newName);

    await widget.repoCubit.moveEntry(
      source: entry.path,
      destination: newEntryPath,
    );

    showSnackBar(widget.entry is FileEntry
        ? S.current.messageFileRenamed(newName)
        : S.current.messageFolderRenamed(newName));
  }

  Future<String> _getNewEntryName(FileSystemEntry entry) async {
    final newName = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            final parent = p.dirname(entry.path);
            final oldName = p.basename(entry.path);
            final originalExtension =
                entry is FileEntry ? p.extension(entry.path) : '';

            return ActionsDialog(
              title: entry is FileEntry
                  ? S.current.messageRenameFile
                  : S.current.messageRenameFolder,
              body: RenameEntry(
                parentContext: context,
                repoCubit: widget.repoCubit,
                parent: parent,
                oldName: oldName,
                originalExtension: originalExtension,
                isFile: entry is FileEntry,
                hint: entry is FileEntry
                    ? S.current.messageFileName
                    : S.current.messageFolderName,
              ),
            );
          },
        ) ??
        '';

    return newName;
  }

  Future<void> _onDownloadTap() async {
    String? defaultDirectoryPath;
    if (io.Platform.isAndroid) {
      defaultDirectoryPath = await Native.getDownloadPathForAndroid();
    } else {
      final defaultDirectory = io.Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getDownloadsDirectory();

      defaultDirectoryPath = defaultDirectory?.path;
    }

    if (defaultDirectoryPath == null) return;

    await Navigator.of(context, rootNavigator: false).maybePop();

    await FileIO(
      context: context,
      repoCubit: widget.repoCubit,
    ).saveFileToDevice(widget.entry as FileEntry, defaultDirectoryPath);
  }

  Future<void> _onShareTap() async => widget.nativeChannels!.shareOuiSyncFile(
        widget.packageInfo!.packageName,
        widget.entry.path,
        (widget.entry as FileEntry).size ?? 0,
      );

  Future<void> _onDeleteTap() async => _deleteEntryWithValidation(
        widget.repoCubit,
        widget.entry,
      );

  Future<void> _deleteEntryWithValidation(
    RepoCubit repo,
    FileSystemEntry entry,
  ) async {
    final path = entry.path;
    final isEmpty = isFile ? true : await repo.isFolderEmpty(path);
    final recursive = !isEmpty;
    final deleteEntry = await Dialogs.deleteEntry(
      context,
      repoCubit: repo,
      entry: entry,
      isDirEmpty: isEmpty,
    );
    if (deleteEntry == false) return;

    final deleteEntryOk = await Dialogs.executeFutureWithLoadingDialog<bool>(
      null,
      isFile ? repo.deleteFile(path) : repo.deleteFolder(path, recursive),
    );

    if (deleteEntryOk) {
      Navigator.of(context).pop(deleteEntryOk);
      showSnackBar(isFile
          ? S.current.messageFileDeleted(repo_path.basename(path))
          : S.current.messageFolderDeleted(entry.name));
    }
  }
}
