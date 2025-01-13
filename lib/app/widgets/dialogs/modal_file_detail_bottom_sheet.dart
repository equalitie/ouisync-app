import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync/native_channels.dart';
import 'package:ouisync/ouisync.dart' show AccessMode, EntryType;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart' show BottomSheetType, RepoCubit;
import '../../models/models.dart' show FileEntry;
import '../../pages/pages.dart' show PreviewFileCallback;
import '../../utils/repo_path.dart' as repo_path;
import '../../utils/utils.dart'
    show
        AppThemeExtension,
        Constants,
        Dialogs,
        Dimensions,
        FileIO,
        Fields,
        formatSize,
        Native,
        showSnackBar,
        ThemeGetter;
import '../widgets.dart'
    show
        ActionsDialog,
        EntryAction,
        EntryActionItem,
        EntryInfoTable,
        RenameEntry;

class FileDetail extends StatefulWidget {
  const FileDetail({
    required this.repoCubit,
    required this.entry,
    required this.onPreviewFile,
    required this.isActionAvailableValidator,
    required this.packageInfo,
    required this.nativeChannels,
  });

  final RepoCubit repoCubit;
  final FileEntry entry;
  final PreviewFileCallback onPreviewFile;
  final bool Function(AccessMode, EntryAction) isActionAvailableValidator;
  final PackageInfo packageInfo;
  final NativeChannels nativeChannels;

  @override
  State<FileDetail> createState() => _FileDetailState();
}

class _FileDetailState extends State<FileDetail> {
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
                S.current.titleFileDetails,
                style: context.theme.appTextStyle.titleMedium,
              ),
              EntryActionItem(
                iconData: Icons.download_outlined,
                title: S.current.iconDownload,
                dense: true,
                onTap: () async {
                  String? defaultDirectoryPath;
                  if (io.Platform.isAndroid) {
                    defaultDirectoryPath =
                        await Native.getDownloadPathForAndroid();
                  } else {
                    final defaultDirectory = io.Platform.isIOS
                        ? await getApplicationDocumentsDirectory()
                        : await getDownloadsDirectory();

                    defaultDirectoryPath = defaultDirectory?.path;
                  }

                  if (defaultDirectoryPath == null) return;

                  await FileIO(
                    context: context,
                    repoCubit: widget.repoCubit,
                  ).saveFileToDevice(widget.entry, defaultDirectoryPath);

                  await Navigator.of(context, rootNavigator: false).maybePop();
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                  widget.repoCubit.state.accessMode,
                  EntryAction.download,
                ),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration,
              ),
              EntryActionItem(
                iconData: Icons.preview_outlined,
                title: S.current.iconPreview,
                dense: true,
                onTap: () async {
                  await Navigator.of(context).maybePop();

                  await widget.onPreviewFile.call(
                    widget.repoCubit,
                    widget.entry,
                    false,
                  );
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                  widget.repoCubit.state.accessMode,
                  EntryAction.preview,
                ),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration,
              ),
              if (io.Platform.isAndroid)
                EntryActionItem(
                  iconData: Icons.share_outlined,
                  title: S.current.iconShare,
                  dense: true,
                  onTap: () async =>
                      await widget.nativeChannels.shareOuiSyncFile(
                    widget.packageInfo.packageName,
                    widget.entry.path,
                    widget.entry.size ?? 0,
                  ),
                  enabledValidation: () => widget.isActionAvailableValidator(
                    widget.repoCubit.state.accessMode,
                    EntryAction.share,
                  ),
                  disabledMessage: S.current.messageActionNotAvailable,
                  disabledMessageDuration:
                      Constants.notAvailableActionMessageDuration,
                ),
              EntryActionItem(
                iconData: Icons.edit_outlined,
                title: S.current.iconRename,
                dense: true,
                onTap: () async {
                  final entry = widget.entry;
                  final newName = await _getNewFileName(entry);

                  if (newName.isEmpty) return;

                  // The new name provided by the user.
                  final parent = repo_path.dirname(entry.path);
                  final newEntryPath = repo_path.join(parent, newName);

                  await widget.repoCubit.moveEntry(
                    source: entry.path,
                    destination: newEntryPath,
                  );

                  await Navigator.of(context).maybePop();
                  showSnackBar(S.current.messageFileRenamed(newName));
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                  widget.repoCubit.state.accessMode,
                  EntryAction.rename,
                ),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration,
              ),
              EntryActionItem(
                iconData: Icons.copy_outlined,
                title: S.current.iconCopy,
                dense: true,
                onTap: () async {
                  await Navigator.of(context).maybePop();

                  final entryPath = widget.entry.path;
                  final entryType = EntryType.file;

                  widget.repoCubit.showMoveEntryBottomSheet(
                    sheetType: BottomSheetType.copy,
                    entryPath: entryPath,
                    entryType: entryType,
                  );
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                  widget.repoCubit.state.accessMode,
                  EntryAction.move,
                ),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration,
              ),
              EntryActionItem(
                iconData: Icons.drive_file_move_outlined,
                title: S.current.iconMove,
                dense: true,
                onTap: () async {
                  await Navigator.of(context).maybePop();

                  final entryPath = widget.entry.path;
                  final entryType = EntryType.file;

                  widget.repoCubit.showMoveEntryBottomSheet(
                    sheetType: BottomSheetType.move,
                    entryPath: entryPath,
                    entryType: entryType,
                  );
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                  widget.repoCubit.state.accessMode,
                  EntryAction.move,
                ),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration,
              ),
              EntryActionItem(
                iconData: Icons.delete_outlined,
                title: S.current.iconDelete,
                isDanger: true,
                dense: true,
                onTap: () async {
                  final fileName = repo_path.basename(widget.entry.path);
                  final parent = repo_path.dirname(widget.entry.path);

                  final deletedFileName = await Dialogs.deleteFileAlertDialog(
                      widget.repoCubit,
                      widget.entry.path,
                      context,
                      fileName,
                      parent);

                  if (deletedFileName != null && deletedFileName.isNotEmpty) {
                    await Navigator.of(context).maybePop();
                  }
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                  widget.repoCubit.state.accessMode,
                  EntryAction.delete,
                ),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration,
              ),
              const Divider(
                height: 10.0,
                thickness: 2.0,
                indent: 20.0,
                endIndent: 20.0,
              ),
              EntryInfoTable(
                entryInfo: {
                  S.current.labelName: widget.entry.name,
                  S.current.labelLocation: repo_path.dirname(widget.entry.path),
                  S.current.labelSize: formatSize(widget.entry.size ?? 0),
                },
              )
            ],
          ),
        ),
      );

  Future<String> _getNewFileName(FileEntry entry) async {
    final newName = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            final parent = repo_path.dirname(entry.path);
            final oldName = repo_path.basename(entry.path);
            final originalExtension = repo_path.extension(entry.path);

            return ActionsDialog(
              title: S.current.messageRenameFile,
              body: RenameEntry(
                parentContext: context,
                repoCubit: widget.repoCubit,
                parent: parent,
                oldName: oldName,
                originalExtension: originalExtension,
                isFile: true,
                hint: S.current.messageFileName,
              ),
            );
          },
        ) ??
        '';

    return newName;
  }
}
