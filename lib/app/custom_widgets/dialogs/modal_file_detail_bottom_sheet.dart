import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../bloc/blocs.dart';
import '../../pages/pages.dart';
import '../../utils/utils.dart';
import '../custom_widgets.dart';

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
  final MoveEntryBottomSheetControllerCallback onBottomSheetOpen;
  final MoveEntryCallback onMoveEntry;

  @override
  _FileDetailState createState() => _FileDetailState();
}

class _FileDetailState extends State<FileDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16.0))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHandle(context),
          _fileDetails(context),
        ],
      ),
    );
  }

  Widget _fileDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTitle('File Details'),
          _buildPreviewButton(),
          _buildShareButton(),
          _buildMoveFolderButton(
            origin: widget.parent,
            path: widget.path,
            type: EntryType.file,
            moveEntryCallback: widget.onMoveEntry,
            bottomSheetControllerCallback: widget.onBottomSheetOpen
          ),
          _buildDeleteButton(),
          Divider(
            height: 50.0,
            thickness: 2.0,
            indent: 20.0,
            endIndent: 20.0,
          ),
          buildIconLabel(
            Icons.info_rounded,
            'Information',
            iconSize: 40.0,
            infoSize: 24.0,
            labelPadding: EdgeInsets.only(bottom: 30.0)
          ),
          buildInfoLabel(
            'Name: ',
            widget.name
          ),
          buildInfoLabel(
            'Location: ', 
            widget.path
            .replaceAll(widget.name, '')
            .trimRight(),
          ),
          buildInfoLabel(
            'Size: ',
            formattSize(widget.size, units: true)
          ),
        ],
      ),
    );
  }

  GestureDetector _buildPreviewButton() {
    return GestureDetector(
          onTap: () async => await NativeChannels.previewOuiSyncFile(widget.path, widget.size),
          child: buildIconLabel(
            Icons.preview_rounded,
            'Preview',
            iconSize: 40.0,
            infoSize: 18.0,
            labelPadding: EdgeInsets.only(bottom: 30.0)
          ),
        );
  }

  GestureDetector _buildShareButton() {
    return GestureDetector(
          onTap: () async => await NativeChannels.shareOuiSyncFile(widget.path, widget.size),
          child: buildIconLabel(
            Icons.share_rounded,
            'Share',
            iconSize: 40.0,
            infoSize: 18.0,
            labelPadding: EdgeInsets.only(bottom: 30.0)
          ),
        );
  }

  GestureDetector _buildMoveFolderButton({
    required String origin,
    required String path,
    required EntryType type,
    required MoveEntryCallback moveEntryCallback,
    required MoveEntryBottomSheetControllerCallback bottomSheetControllerCallback
  }) {
    return GestureDetector(
      onTap: () => _showMoveEntryBottomSheet(
        origin,
        path,
        type,
        moveEntryCallback,
        bottomSheetControllerCallback
      ),
      child: buildIconLabel(
        Icons.drive_file_move_outlined,
        'Move',
        iconSize: 40.0,
        infoSize: 18.0,
        labelPadding: EdgeInsets.only(bottom: 30.0)
      ),
    );
  }

  _showMoveEntryBottomSheet(
    String origin,
    String path,
    EntryType type,
    MoveEntryCallback moveEntryCallback,
    MoveEntryBottomSheetControllerCallback bottomSheetControllerCallback
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
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero
        ),
      ),
    );

    widget.onBottomSheetOpen.call(controller!, path);
  }

  GestureDetector _buildDeleteButton() {
    return GestureDetector(
      onTap: () async => {},
      child: buildIconLabel(
        Icons.delete_outlined,
        'Delete',
        iconSize: 40.0,
        infoSize: 18.0,
        labelPadding: EdgeInsets.only(bottom: 30.0)
      ),
    );
  }
}