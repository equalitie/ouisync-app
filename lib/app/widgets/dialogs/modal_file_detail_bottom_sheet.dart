import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../../generated/l10n.dart';
import '../../bloc/blocs.dart';
import '../../models/models.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FileDetail extends StatefulWidget {
  const FileDetail({
    required this.context,
    required this.bloc,
    required this.repository,
    required this.data,
    required this.scaffoldKey,
    required this.onBottomSheetOpen,
    required this.onMoveEntry
  });

  final BuildContext context;
  final DirectoryBloc bloc;
  final Repository repository;
  final FileItem data;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BottomSheetControllerCallback onBottomSheetOpen;
  final MoveEntryCallback onMoveEntry;

  @override
  _FileDetailState createState() => _FileDetailState();
}

class _FileDetailState extends State<FileDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimensions.paddingBottomSheet,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Fields.bottomSheetHandle(context),
          Fields.bottomSheetTitle(S.current.titleFileDetails),
          Fields.paddedActionText(
            S.current.iconPreview,
            onTap: () async => await NativeChannels.previewOuiSyncFile(widget.data.path, widget.data.size),
            icon: Icons.preview_rounded,
          ),
          Fields.actionText(
            S.current.iconShare,
            onTap: () async => await NativeChannels.shareOuiSyncFile(widget.data.path, widget.data.size),
            icon: Icons.share_rounded,
          ),
          Fields.paddedActionText(
            S.current.iconRename,
            onTap: () => _showNewNameDialog(
              widget.data.path,
            ),
            icon: Icons.edit
          ),
          Fields.paddedActionText(
            S.current.iconMove,
            onTap: () => _showMoveEntryBottomSheet(
              widget.data.path,
              EntryType.file,
              widget.onMoveEntry,
              widget.onBottomSheetOpen
            ),
            icon: Icons.drive_file_move_outlined,
          ),
          Fields.paddedActionText(
            S.current.iconDelete,
            onTap: () async => {
              showDialog<String>(
                context: widget.context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  final fileName = getPathFromFileName(widget.data.path);
                  final parent = extractParentFromPath(widget.data.path);

                  return Dialogs
                  .buildDeleteFileAlertDialog(
                    widget.repository,
                    widget.bloc,
                    widget.data.path,
                    context,
                    fileName,
                    parent
                  );
                },
              ).then((fileName) {
                Navigator.of(context).pop();
                Fluttertoast.showToast(msg: S.current.messageFileDeleted(fileName ?? ''));
              })
            },
            icon: Icons.delete_outlined,
          ),
          Divider(
            height: 10.0,
            thickness: 2.0,
            indent: 20.0,
            endIndent: 20.0,
          ),
          Fields.iconLabel(
            icon: Icons.info_rounded,
            text: S.current.iconInformation,
          ),
          Fields.labeledText(
            label: S.current.labelName,
            text: widget.data.name,
          ),
          Fields.labeledText(
            label: S.current.labelLocation,
            text: widget.data.path
            .replaceAll(widget.data.name, '')
            .trimRight(),
          ),
          Fields.labeledText(
            label: S.current.labelSize,
            text: formattSize(widget.data.size, units: true),
          ),
        ],
      )
    );
  }

  _showMoveEntryBottomSheet(
    String path,
    EntryType type,
    MoveEntryCallback moveEntryCallback,
    BottomSheetControllerCallback bottomSheetControllerCallback
  ) {
    Navigator.of(context).pop();

    final origin = extractParentFromPath(path);
    final controller = widget.scaffoldKey.currentState?.showBottomSheet(
      (context) => MoveEntryDialog(
        origin: origin,
        path: path,
        type: type,
        onBottomSheetOpen: bottomSheetControllerCallback,
        onMoveEntry: moveEntryCallback
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusBig),
          topRight: Radius.circular(Dimensions.radiusBig),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero
        ),
      ),
    );

    widget.onBottomSheetOpen.call(controller!, path);
  }

  void _showNewNameDialog(String path) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final name = removeParentFromPath(path);

        return ActionsDialog(
          title: S.current.messageRenameFile,
          body: Rename(
            context: context,
            entryName:  name,
            hint: S.current.messageFileName,
            formKey: formKey,
          ),
        );
      }
    ).then((newName) {
      if (newName.isNotEmpty) { // The new name provided by the user.
        final parent = extractParentFromPath(path);
        final newEntryPath = parent == Strings.rootPath
        ? '/$newName'
        : '$parent/$newName';  

        widget.bloc
        .add(RenameEntry(
          repository: widget.repository,
          path: parent,
          entryPath: path,
          newEntryPath: newEntryPath
        ));

        Navigator.of(context).pop();
      }
    });
  }
}
