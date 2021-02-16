import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/controls/items/filedescription.dart';
import 'package:ouisync_app/app/controls/items/folderdescription.dart';
import 'package:ouisync_app/app/models/item/baseitem.dart';
import 'package:ouisync_app/app/models/item/itemtype.dart';


class ListItem extends StatelessWidget {
  const ListItem({
    this.itemData,
    this.action
  });

  final BaseItem itemData;
  final Function action;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: _getPadding(),
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
    return itemData.itemType == ItemType.folder
        ? Colors.transparent
        : Color.fromARGB(35, 220, 220, 220);
  }

  EdgeInsets _getPadding() {
    return itemData.itemType == ItemType.folder
        ? EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0)
        : EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0);
  }

  Expanded getExpandedDescriptionByType() {
    return Expanded(
              flex: 1,
              child: itemData.itemType == ItemType.folder
                  ? FolderDescription(folderData: itemData)
                  : FileDescription(fileData: itemData)
          );
  }

  IconButton getActionByType(Function action) {

    return itemData.itemType == ItemType.folder
        ? IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16.0,), onPressed: action)
        : IconButton(icon: const Icon(Icons.more_vert, size: 24.0,), onPressed: action);
  }

}