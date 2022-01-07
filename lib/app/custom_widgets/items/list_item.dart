import 'package:flutter/material.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../models/models.dart';
import '../custom_widgets.dart';

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
          padding: EdgeInsets.fromLTRB(8.0, 10.0, 2.0, 15.0),
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
    return itemData.itemType == ItemType.folder
      ? Icon(
        itemData.icon,
        size: 40.0
      )
      : Icon(
        itemData.icon,
        size: 38.0,
      );
  }

  Expanded _getExpandedDescriptionByType() {
    return Expanded(
      flex: 1,
      child: itemData.itemType == ItemType.folder
        ? Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: FolderDescription(folderData: itemData)
        )
        : Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: FileDescription(repository: repository, fileData: itemData)
        )
    );
  }

  Widget _getActionByType(Function secondaryAction, PopupMenuButton<dynamic>? filePopupMenu, Function? folderDotsAction, bool isDestination) {
    if (isDestination) {
      return itemData.itemType == ItemType.folder
        ? IconButton(icon: const Icon(Icons.arrow_circle_down, size: 30.0,), onPressed: () => secondaryAction.call())
        : IconButton(onPressed: null, icon: Container());
    }

    return itemData.itemType == ItemType.folder
        ? IconButton(icon: const Icon(Icons.more_vert_rounded, size: 30.0,), onPressed: () async => await folderDotsAction!.call())
        : filePopupMenu!;
  }

}