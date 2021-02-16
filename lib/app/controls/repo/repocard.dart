import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'repofooter.dart';

class RepoCard extends StatelessWidget {
  const RepoCard({
    this.id,
    this.name,
    this.totalFiles,
    this.totalConflicts,
    this.totalSpace,
    this.totalUsers,
    this.syncStatus,
    this.isEncrypted,
    this.isLocal,
    this.isOwn
});

  final String id;
  final String name;
  final int totalFiles;
  final int totalConflicts;
  final double totalSpace;
  final int totalUsers;
  final SyncStatus syncStatus;
  final bool isEncrypted;
  final bool isLocal;
  final bool isOwn;

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
                      name,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight:  FontWeight.bold,
                        fontSize: 24.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                //   child: ColumnText(
                //       labelString: "space:",
                //       value: "500.87 MB"
                //   ),
                // ),
              ],
            ),


            Row(
              children: [
                // Container(
                //   margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                //   alignment: AlignmentDirectional.bottomStart,
                //   child: ColumnText(
                //       labelString: "files:",
                //       value: "22"
                //   ),
                // ),
                // Container(
                //   margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                //   alignment: AlignmentDirectional.bottomStart,
                //   child: ColumnText(
                //       labelString: "conflicts:",
                //       value: "0"
                //   ),
                // ),

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
    switch(syncStatus){
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
}


// Encryption off: name/folder, total files, total conflicts, total space, sync status, users
// Encryption on: name/folder, has conflicts, sync status
