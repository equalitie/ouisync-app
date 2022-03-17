import 'package:flutter/material.dart';
import 'package:ouisync_app/app/bloc/blocs.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    required this.repository,
    required this.itemData,
    required this.mainAction,
    required this.secondaryAction,
    required this.filePopupMenu,
    required this.folderDotsAction,
    this.isDestination = false,
    this.isEncrypted = false,
    this.isLocal = true,
    this.isOwn = true,
  });

  final Repository repository;
  final BaseItem itemData;
  final Function mainAction;
  final Function secondaryAction;
  final PopupMenuButton<dynamic>? filePopupMenu;
  final Function? folderDotsAction;
  final bool isDestination;
  final bool isEncrypted;
  final bool isLocal;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap:() => mainAction.call(),
        splashColor: Colors.blue,
        child: Container(
          padding: Dimensions.paddingListItem,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _getIconByType(),
              _getExpandedDescriptionByType(),
              _getActionByType(secondaryAction, filePopupMenu, folderDotsAction, isDestination),
            ],
          ),
        )
      ),
      color: Colors.white,
    );
  }

  Widget _getIconByType() {
    return itemData.type == ItemType.folder
      ? Icon(
        Icons.folder_outlined,
        size: Dimensions.sizeIconBig
      )
      : Icon(
        Icons.insert_drive_file_outlined,
        size: Dimensions.sizeIconAverage
      );
  }

  Expanded _getExpandedDescriptionByType() {
    return Expanded(
      flex: 1,
      child: itemData.type == ItemType.folder
        ? Padding(
          padding: Dimensions.paddingFolderItem,
          child: FolderDescription(folderData: itemData)
        )
        : Padding(
          padding: Dimensions.paddingFileItem,
          child: FileDescription(
            repository: repository,
            fileData: itemData,
          )
        )
    );
  }

  Widget _getActionByType(Function secondaryAction, PopupMenuButton<dynamic>? filePopupMenu, Function? folderDotsAction, bool isDestination) {
    if (isDestination) {
      return itemData.type == ItemType.folder
        ? IconButton(icon: const Icon(Icons.arrow_circle_down, size: Dimensions.sizeIconAverage,), onPressed: () => secondaryAction.call())
        : IconButton(onPressed: null, icon: Container());
    }

    return itemData.type == ItemType.folder
        ? IconButton(icon: const Icon(Icons.more_vert_rounded, size: Dimensions.sizeIconAverage,), onPressed: () async => await folderDotsAction!.call())
        : filePopupMenu!;
  }

}
