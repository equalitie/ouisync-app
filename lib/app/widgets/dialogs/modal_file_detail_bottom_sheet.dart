import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:path_provider/path_provider.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FileDetail extends StatefulWidget {
  const FileDetail({
    required this.context,
    required this.cubit,
    required this.navigation,
    required this.data,
    required this.onUpdateBottomSheet,
    required this.onPreviewFile,
    required this.onMoveEntry,
    required this.isActionAvailableValidator,
  });

  final BuildContext context;
  final RepoCubit cubit;
  final NavigationCubit navigation;
  final FileItem data;
  final BottomSheetCallback onUpdateBottomSheet;
  final PreviewFileCallback onPreviewFile;
  final MoveEntryCallback onMoveEntry;
  final bool Function(AccessMode, EntryAction) isActionAvailableValidator;

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

                  final deafultDirectory = io.Platform.isIOS
                      ? await getApplicationDocumentsDirectory()
                      : await getDownloadsDirectory();

                  if (deafultDirectory == null) return;

                  await SaveFileToDevice(data: widget.data, cubit: widget.cubit)
                      .save(widget.context, deafultDirectory.path);
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.cubit.state.accessMode, EntryAction.download),
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
                      .call(widget.cubit, widget.data, false);
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.cubit.state.accessMode, EntryAction.preview),
                disabledMessage: S.current.messageActionNotAvailable,
                disabledMessageDuration:
                    Constants.notAvailableActionMessageDuration,
              ),
              if (io.Platform.isAndroid)
                EntryActionItem(
                  iconData: Icons.share_rounded,
                  title: S.current.iconShare,
                  dense: true,
                  onTap: () async => await NativeChannels.shareOuiSyncFile(
                    Constants.androidAppAuthority,
                    widget.data.path,
                    widget.data.size ?? 0,
                  ),
                  enabledValidation: () => widget.isActionAvailableValidator(
                      widget.cubit.state.accessMode, EntryAction.share),
                  disabledMessage: S.current.messageActionNotAvailable,
                  disabledMessageDuration:
                      Constants.notAvailableActionMessageDuration,
                ),
              EntryActionItem(
                iconData: Icons.edit,
                title: S.current.iconRename,
                dense: true,
                onTap: () async => _showRenameDialog(widget.data),
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.cubit.state.accessMode, EntryAction.rename),
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
                    widget.data.path,
                    EntryType.file,
                    widget.onMoveEntry,
                    widget.onUpdateBottomSheet,
                  );
                },
                enabledValidation: () => widget.isActionAvailableValidator(
                    widget.cubit.state.accessMode, EntryAction.move),
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
                    final fileName = getBasename(widget.data.path);
                    final parent = getDirname(widget.data.path);

                    final deletedFileName = await Dialogs.deleteFileAlertDialog(
                        widget.cubit,
                        widget.data.path,
                        context,
                        fileName,
                        parent);

                    if (deletedFileName != null && deletedFileName.isNotEmpty) {
                      Navigator.of(context).pop();
                    }
                  },
                  enabledValidation: () => widget.isActionAvailableValidator(
                      widget.cubit.state.accessMode, EntryAction.delete),
                  disabledMessage: S.current.messageActionNotAvailable,
                  disabledMessageDuration:
                      Constants.notAvailableActionMessageDuration),
              const Divider(
                  height: 10.0, thickness: 2.0, indent: 20.0, endIndent: 20.0),
              Fields.iconLabel(
                  icon: Icons.info_rounded,
                  text: S.current.iconInformation,
                  style: context.theme.appTextStyle.titleMedium),
              Fields.autosizedLabeledText(
                  label: S.current.labelName, text: widget.data.name),
              Fields.labeledText(
                  label: S.current.labelLocation,
                  text: getDirname(widget.data.path),
                  textAlign: TextAlign.start),
              Fields.labeledText(
                  label: S.current.labelSize,
                  text: formatSize(widget.data.size ?? 0)),
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
      widget.cubit,
      navigation: widget.navigation,
      originPath: originPath,
      path: path,
      type: type,
      onBottomSheetOpen: bottomSheetControllerCallback,
      onMoveEntry: moveEntryCallback,
    );

    widget.onUpdateBottomSheet(bottomSheetMoveEntry, path);
  }

  void _showRenameDialog(FileItem data) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ScaffoldMessenger(
          child: Builder(
            builder: (context) {
              final oldName = getBasename(data.path);
              final originalExtension = getFileExtension(data.path);

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
        final parent = getDirname(data.path);
        final newEntryPath = buildDestinationPath(parent, newName);

        widget.cubit.moveEntry(source: data.path, destination: newEntryPath);

        Navigator.of(context).pop();
      }
    });
  }
}
