import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../models/models.dart';
import '../controls.dart';

class RepoDescription extends StatelessWidget {
  const RepoDescription({
    this.folderData,
    this.isEncrypted,
    this.isLocal,
    this.isOwn,
    this.action
});

  final FolderItem folderData;
  final bool isEncrypted;
  final bool isLocal;
  final bool isOwn;
  final Function action;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                new Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10.0, 20.0, 20.0, 10.0),
                    child: Text(
                      folderData.name,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight:  FontWeight.bold,
                        fontSize: 24.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                getActionByType(action),
              ],
            ),


            Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  alignment: AlignmentDirectional.bottomEnd,
                  child: ColumnIcon(
                    labelString: "sync:",
                    icon: _getIconFromStatus(),
                    color: Colors.black,
                    size: 30.0,
                    semanticLabel: "Repo sync status",
                  ),
                ),
              ],
            ),
          ],
        )
    );
  }

  IconData _getIconFromStatus() {
    IconData icon;
    switch(folderData.syncStatus){
      case SyncStatus.syncing:
        icon = Icons.sync;
        break;
      case SyncStatus.idle:
        icon = Icons.sync_alt;
        break;
      case SyncStatus.paused:
        icon = Icons.pause;
        break;
      case SyncStatus.stopped:
        icon = Icons.multiple_stop;
        break;
      case SyncStatus.problem:
        icon = Icons.sync_problem;
        break;
    }

    return icon;
  }

  IconButton getActionByType(Function action) {

    return folderData.itemType == ItemType.folder
        ? IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16.0,), onPressed: action)
        : IconButton(icon: const Icon(Icons.more_vert, size: 24.0,), onPressed: action);
  }
}
