import '../models/models.dart';

class Descriptions {

  static String getSyncStatusDescription(SyncStatus status){
    String description;
    switch(status){
      case SyncStatus.syncing:
        description = "syncing";
        break;
      case SyncStatus.idle:
        description = "ok";
        break;
      case SyncStatus.paused:
        description = "paused";
        break;
      case SyncStatus.done:
        description = "stopped";
        break;
      case SyncStatus.failed:
        description = "problem";
        break;
    }

    return description;
  }

}