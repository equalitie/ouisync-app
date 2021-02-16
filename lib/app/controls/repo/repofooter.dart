import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RepoFooter extends StatelessWidget {
  const RepoFooter({
    this.syncStatus
  });

  final SyncStatus syncStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ColumnIcon(
            labelString: "sync:",
            icon: _getIconFromStatus(),
            color: Colors.black,
            size: 30.0,
            semanticLabel: "Sync status",
          ),
        ],
      ),
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

enum SyncStatus {
  syncing,
  idle,
  paused,
  stopped,
  problem
}

class ColumnIcon extends StatelessWidget {
  ColumnIcon({
    this.labelString,
    this.icon,
    this.color,
    this.size,
    this.semanticLabel
  });

  final String labelString;
  final IconData icon;
  final Color color;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelString,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 14.0,
                color: Colors.black26,
                fontWeight: FontWeight.bold
            ),
          ),
          Icon(
            icon,
            color: color,
            size: size,
            semanticLabel: semanticLabel
          ),
        ]
    );
  }
}