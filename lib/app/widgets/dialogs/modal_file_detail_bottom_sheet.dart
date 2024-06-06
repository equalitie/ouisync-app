import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/native_channels.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/path.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

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
                iconData: Icons.download,
                title: S.current.iconDownload,
                dense: true,
                onTap: () async {
                  Navigator.of(context, rootNavigator: false).pop();

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

                  await SaveFileToDevice(
                    entry: widget.entry,
                    repoCubit: widget.repoCubit,
                  ).save(defaultDirectoryPath);
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
                iconData: Icons.preview_rounded,
                title: S.current.iconPreview,
                dense: true,
                onTap: () async {
                  Navigator.of(context).pop();

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
                  iconData: Icons.share_rounded,
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
                iconData: Icons.edit,
                title: S.current.iconRename,
                dense: true,
                onTap: () async => _showRenameDialog(widget.entry),
                enabledValidation: () => widget.isActionAvailableValidator(
                  widget.repoCubit.state.accessMode,
                  EntryAction.rename,
                ),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration,
              ),
              EntryActionItem(
                iconData: Icons.drive_file_move_outlined,
                title: S.current.iconMove,
                dense: true,
                onTap: () {
                  Navigator.of(context).pop();

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
                iconData: Icons.delete,
                title: S.current.iconDelete,
                isDanger: true,
                dense: true,
                onTap: () async {
                  final fileName = basename(widget.entry.path);
                  final parent = dirname(widget.entry.path);

                  final deletedFileName = await Dialogs.deleteFileAlertDialog(
                      widget.repoCubit,
                      widget.entry.path,
                      context,
                      fileName,
                      parent);

                  if (deletedFileName != null && deletedFileName.isNotEmpty) {
                    Navigator.of(context).pop();
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
                  S.current.labelLocation: dirname(widget.entry.path),
                  S.current.labelSize: formatSize(widget.entry.size ?? 0),
                },
              )
            ],
          ),
        ),
      );

  void _showRenameDialog(FileEntry entry) async => await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ScaffoldMessenger(
            child: Builder(
              builder: (context) {
                final oldName = basename(entry.path);
                final originalExtension = extension(entry.path);

                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: ActionsDialog(
                    title: S.current.messageRenameFile,
                    body: RenameEntry(
                      parentContext: context,
                      oldName: oldName,
                      originalExtension: originalExtension,
                      isFile: true,
                      hint: S.current.messageFileName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ).then(
        (newName) {
          if (newName.isNotEmpty) {
            // The new name provided by the user.
            final parent = dirname(entry.path);
            final newEntryPath = join(parent, newName);

            widget.repoCubit.moveEntry(
              source: entry.path,
              destination: newEntryPath,
            );

            Navigator.of(context).pop();
          }
        },
      );
}
