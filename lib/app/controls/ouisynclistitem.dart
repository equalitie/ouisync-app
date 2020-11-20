import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/models/baseitem.dart';
import 'package:ouisync_app/app/models/ouisyncfile.dart';
import 'package:ouisync_app/app/models/ouisyncfolder.dart';

class OuiSyncListItem extends StatelessWidget {
  const OuiSyncListItem({
    this.itemData,
  });

  final BaseItem itemData;

  @override
  Widget build(BuildContext context) {
    final paddedRow = Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            itemData.icon,
            getExpandedDescriptionByType(),
            geActionIconByType(),
          ],
        )
    );

    return itemData.type == OSType.folder
          ? Card(child: paddedRow)
          : paddedRow;
  }

  Expanded getExpandedDescriptionByType() {
    return Expanded(
              flex: 1,
              child: itemData.type == OSType.folder
                  ? _FolderDescription(folderData: itemData)
                  : _FileDescription(fileData: itemData)
          );
  }

  Icon geActionIconByType() {
    return itemData.type == OSType.folder
        ? const Icon(Icons.arrow_forward_ios, size: 16.0,)
        : const Icon(Icons.more_vert, size: 24.0,);
  }

}

class _FolderDescription extends StatelessWidget {
  const _FolderDescription({
    Key key,
    this.folderData,
  }) : super(key: key);

  final OuiSyncFolder folderData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            folderData.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            folderData.status,
            style: const TextStyle(fontSize: 12.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            '${folderData.items.length} objects',
            style: const TextStyle(fontSize: 12.0),
          ),
          Text(
              folderData.location.length == 0
                  ? "-"
                  : folderData.location.join("/"),
              style: const TextStyle(fontSize: 12.0)
          )
        ],
      ),
    );
  }
}

class _FileDescription extends StatelessWidget {
  const _FileDescription({
    Key key,
    this.fileData,
  }) : super(key: key);

  final OuiSyncFile fileData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            this.fileData.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            this.fileData.status,
            style: const TextStyle(fontSize: 12.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
              this.fileData.location.length == 0
                  ? "-"
                  : this.fileData.location.join("/"),
              style: const TextStyle(fontSize: 12.0)
          )
        ],
      ),
    );
  }
}