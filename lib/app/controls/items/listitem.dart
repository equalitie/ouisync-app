import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../models/models.dart';
import '../controls.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    this.itemData,
    this.action,
    this.isEncrypted,
    this.isLocal,
    this.isOwn,
  });

  final BaseItem itemData;
  final Function action;
  final bool isEncrypted;
  final bool isLocal;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
      color: _getColor(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(itemData.icon),
          getExpandedDescriptionByType(),
          getActionByType(action),
        ],
      ),
    );

    return itemData.itemType == ItemType.folder
        ? Card(child: container)
        : container;
  }

  Color _getColor() {
    return itemData.itemType == ItemType.file
        ? Colors.transparent
        : Color.fromARGB(35, 220, 220, 220);
  }

  Expanded getExpandedDescriptionByType() {
    return Expanded(
      flex: 1,
      child: itemData.itemType == ItemType.repo
        ? RepoDescription(folderData: itemData, isEncrypted: isEncrypted, isLocal: isLocal, isOwn:  isOwn)
        : itemData.itemType == ItemType.folder
        ? FolderDescription(folderData: itemData)
        : FileDescription(fileData: itemData)
    );
  }

  IconButton getActionByType(Function action) {
    return itemData.itemType == ItemType.repo
        ? IconButton(icon: const Icon(Icons.storage, size: 16.0,), onPressed: action)
        : itemData.itemType == ItemType.folder
        ? IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16.0,), onPressed: action)
        : IconButton(icon: const Icon(Icons.more_vert, size: 24.0,), onPressed: action);
  }

}