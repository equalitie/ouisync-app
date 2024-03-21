import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:ouisync_plugin/native_channels.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FileDetail extends StatefulWidget {
  const FileDetail({
    required this.repo,
    required this.navigation,
    required this.entry,
    required this.onUpdateBottomSheet,
    required this.onPreviewFile,
    required this.onMoveEntry,
    required this.isActionAvailableValidator,
    required this.packageInfo,
    required this.nativeChannels,
  });

  final RepoCubit repo;
  final NavigationCubit navigation;
  final FileEntry entry;
  final BottomSheetCallback onUpdateBottomSheet;
  final PreviewFileCallback onPreviewFile;
  final MoveEntryCallback onMoveEntry;
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
              Fields.bottomSheetTitle(S.current.titleFileDetails,
                  style: context.theme.appTextStyle.titleMedium),
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
                    repoCubit: widget.repo,
                  ).save(defaultDirectoryPath);
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.repo.state.accessMode, EntryAction.download),
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

                  await widget.onPreviewFile
                      .call(widget.repo, widget.entry, false);
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.repo.state.accessMode, EntryAction.preview),
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
                      widget.repo.state.accessMode, EntryAction.share),
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
                    widget.repo.state.accessMode, EntryAction.rename),
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

                  _showMoveEntryBottomSheet(
                    widget.entry.path,
                    EntryType.file,
                    widget.onMoveEntry,
                    widget.onUpdateBottomSheet,
                  );
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                  widget.repo.state.accessMode,
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
                    final fileName = getBasename(widget.entry.path);
                    final parent = getDirname(widget.entry.path);

                    final deletedFileName = await Dialogs.deleteFileAlertDialog(
                        widget.repo,
                        widget.entry.path,
                        context,
                        fileName,
                        parent);

                    if (deletedFileName != null && deletedFileName.isNotEmpty) {
                      Navigator.of(context).pop();
                    }
                  },
                  enabledValidation: () => widget.isActionAvailableValidator(
                      widget.repo.state.accessMode, EntryAction.delete),
                  disabledMessage: S.current.messageActionNotAvailable,
                  disabledMessageDuration:
                      Constants.notAvailableActionMessageDuration),
              const Divider(
                  height: 10.0, thickness: 2.0, indent: 20.0, endIndent: 20.0),
              EntryInfoTable(entryInfo: {
                S.current.labelName: widget.entry.name,
                S.current.labelLocation: getDirname(widget.entry.path),
                S.current.labelSize: formatSize(widget.entry.size ?? 0),
              })
            ],
          ),
        ),
      );

  void _showMoveEntryBottomSheet(
    String path,
    EntryType type,
    MoveEntryCallback moveEntryCallback,
    BottomSheetCallback bottomSheetControllerCallback,
  ) {
    final originPath = getDirname(path);
    final bottomSheetMoveEntry = MoveEntryDialog(
      repo: widget.repo,
      navigation: widget.navigation,
      originPath: originPath,
      path: path,
      type: type,
      onBottomSheetOpen: bottomSheetControllerCallback,
      onMoveEntry: moveEntryCallback,
    );

    widget.onUpdateBottomSheet(bottomSheetMoveEntry, path);
  }

  void _showRenameDialog(FileEntry entry) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ScaffoldMessenger(
          child: Builder(
            builder: (context) {
              final oldName = getBasename(entry.path);
              final originalExtension = getFileExtension(entry.path);

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
    ).then((newName) {
      if (newName.isNotEmpty) {
        // The new name provided by the user.
        final parent = getDirname(entry.path);
        final newEntryPath = pathContext.join(parent, newName);

        widget.repo.moveEntry(source: entry.path, destination: newEntryPath);

        Navigator.of(context).pop();
      }
    });
  }
}
