import 'package:flutter/material.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    required this.itemData,
    required this.mainAction,
    required this.filePopupMenu,
    required this.folderDotsAction,
  });

  final BaseItem itemData;
  final Function mainAction;
  final PopupMenuButton<dynamic>? filePopupMenu;
  final Function? folderDotsAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap:() => mainAction.call(),
        splashColor: Colors.blue,
        child: Container(
          padding: Dimensions.paddingListItem,
          child: _buildItem(),
        )
      ),
      color: Colors.white,
    );
  }

  Widget _buildItem() {
    if (itemData.type == ItemType.file) {
      return _buildFileItem();
    } else {
      return _buildFolderItem();
    }
  }

  Widget _buildFileItem() =>
    Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Icon(Icons.insert_drive_file_outlined, size: Dimensions.sizeIconAverage)),
        Expanded(
          flex: 9,
          child: Padding(
            padding: Dimensions.paddingItem,
            child: FileDescription(fileData: itemData))),
        _getFileAction(),
      ],
    );

  Widget _buildFolderItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Icon(Icons.folder_outlined, size: Dimensions.sizeIconAverage)),
        Expanded(
          flex: 9,
          child: Padding(
            padding: Dimensions.paddingItem,
            child: FolderDescription(folderData: itemData))),
        _getFolderAction(),
      ],
    );
  }

  Widget _getFileAction() {
    return filePopupMenu!;
  }

  Widget _getFolderAction() {
    return IconButton(
      icon: const Icon(Icons.more_vert_rounded, size: Dimensions.sizeIconSmall),
      onPressed: () async => await folderDotsAction!.call());
  }

}
