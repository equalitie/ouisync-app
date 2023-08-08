import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../flavors.dart';
import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FileDetail extends StatefulWidget {
  const FileDetail(
      {required this.context,
      required this.cubit,
      required this.data,
      required this.onUpdateBottomSheet,
      required this.onMoveEntry,
      required this.isActionAvailableValidator});

  final BuildContext context;
  final RepoCubit cubit;
  final FileItem data;
  final BottomSheetCallback onUpdateBottomSheet;
  final MoveEntryCallback onMoveEntry;
  final bool Function(AccessMode, EntryAction) isActionAvailableValidator;

  @override
  State<FileDetail> createState() => _FileDetailState();
}

class _FileDetailState extends State<FileDetail> {
  @override
  Widget build(BuildContext context) {
    final sheetTitleStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w400);

    return SingleChildScrollView(
      child: Container(
        padding: Dimensions.paddingBottomSheet,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.bottomSheetHandle(context),
            Fields.bottomSheetTitle(S.current.titleFileDetails,
                style: sheetTitleStyle),
            EntryActionItem(
              iconData: Icons.download,
              title: S.current.iconDownload,
              dense: true,
              onTap: () async {
                Navigator.of(context, rootNavigator: false).pop();

                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return ActionsDialog(
                      title: S.current.titleDownloadToDevice,
                      body:
                          SaveToDevice(data: widget.data, cubit: widget.cubit),
                    );
                  },
                );
              },
              enabledValidation: () => widget.isActionAvailableValidator(
                  widget.cubit.state.accessMode, EntryAction.download),
              disabledMessage: S.current.messageActionNotAvailable,
              disabledMessageDuration:
                  Constants.notAvailableActionMessageDuration,
            ),
            if (io.Platform.isAndroid)
              EntryActionItem(
                iconData: Icons.preview_rounded,
                title: S.current.iconPreview,
                dense: true,
                onTap: () async => await NativeChannels.previewOuiSyncFile(
                  F.authority,
                  widget.data.path,
                  widget.data.size ?? 0,
                ),
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
                  F.authority,
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
              onTap: () async => _showMoveEntryBottomSheet(
                widget.data.path,
                EntryType.file,
                widget.onMoveEntry,
                widget.onUpdateBottomSheet,
              ),
              enabledValidation: () => widget.isActionAvailableValidator(
                  widget.cubit.state.accessMode, EntryAction.move),
              disabledMessage: S.current.messageActionNotAvailable,
              disabledMessageDuration:
                  Constants.notAvailableActionMessageDuration,
            ),
            EntryActionItem(
                iconData: Icons.delete,
                title: S.current.iconDelete,
                textColor: Constants.dangerColor,
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
                icon: Icons.info_rounded, text: S.current.iconInformation),
            Fields.autosizedLabeledText(
                label: S.current.labelName, text: widget.data.name),
            Fields.labeledText(
                label: S.current.labelLocation,
                text: widget.data.path
                    .replaceAll(widget.data.name, '')
                    .trimRight()),
            Fields.labeledText(
                label: S.current.labelSize,
                text: formatSize(widget.data.size ?? 0)),
          ],
        ),
      ),
    );
  }

  _showMoveEntryBottomSheet(
    String path,
    EntryType type,
    MoveEntryCallback moveEntryCallback,
    BottomSheetCallback bottomSheetControllerCallback,
  ) {
    Navigator.of(context).pop();

    final origin = getDirname(path);
    final bottomSheetMoveEntry = MoveEntryDialog(widget.cubit,
        origin: origin,
        path: path,
        type: type,
        onBottomSheetOpen: bottomSheetControllerCallback,
        onMoveEntry: moveEntryCallback);

    widget.onUpdateBottomSheet(bottomSheetMoveEntry, path);
  }

  void _showRenameDialog(FileItem data) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.messageRenameFile,
          body: Rename(
            context: context,
            entryData: data,
            hint: S.current.messageFileName,
            formKey: formKey,
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
