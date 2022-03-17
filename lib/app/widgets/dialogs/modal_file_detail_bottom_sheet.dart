import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ouisync_app/generated/l10n.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../bloc/blocs.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class FileDetail extends StatefulWidget {
  const FileDetail({
    required this.context,
    required this.bloc,
    required this.repository,
    required this.name,
    required this.path,
    required this.parent,
    required this.size,
    required this.scaffoldKey,
    required this.onBottomSheetOpen,
    required this.onMoveEntry
  });

  final BuildContext context;
  final DirectoryBloc bloc;
  final Repository repository;
  final String name;
  final String path;
  final String parent;
  final int size;
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
          Fields.actionText(
            S.current.iconPreview,
            onTap: () async => await NativeChannels.previewOuiSyncFile(widget.path, widget.size),
            icon: Icons.preview_rounded,
          ),
          Fields.actionText(
            S.current.iconShare,
            onTap: () async => await NativeChannels.shareOuiSyncFile(widget.path, widget.size),
            icon: Icons.share_rounded,
          ),
          Fields.actionText(
            S.current.iconMove,
            onTap: () => _showMoveEntryBottomSheet(
              widget.parent,
              widget.path,
              EntryType.file,
              widget.onMoveEntry,
              widget.onBottomSheetOpen
            ),
            icon: Icons.drive_file_move_outlined,
          ),
          Fields.actionText(
            S.current.iconDelete,
            onTap: () async => {
              showDialog<String>(
                context: widget.context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  final fileName = getPathFromFileName(widget.path);
                  final parent = extractParentFromPath(widget.path);

                  return Dialogs
                  .buildDeleteFileAlertDialog(
                    widget.repository,
                    widget.bloc,
                    widget.path,
                    context,
                    fileName,
                    parent
                  );
                },
              ).then((fileName) {
                Navigator.of(context).pop();
                Fluttertoast.showToast(msg:
                  S.current
                  .messageFileDeleted.toString()
                  .replaceAll(
                    Strings.replacementName,
                    fileName ?? ''
                  )
                );
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
            text: widget.name,
          ),
          Fields.labeledText(
            label: S.current.labelLocation,
            text: widget.path
            .replaceAll(widget.name, '')
            .trimRight(),
          ),
          Fields.labeledText(
            label: S.current.labelSize,
            text: formattSize(widget.size, units: true),
          ),
        ],
      )
    );
  }

  _showMoveEntryBottomSheet(
    String origin,
    String path,
    EntryType type,
    MoveEntryCallback moveEntryCallback,
    BottomSheetControllerCallback bottomSheetControllerCallback
  ) {
    Navigator.of(context).pop();
    
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
}