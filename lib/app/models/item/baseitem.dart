import 'package:flutter/widgets.dart';
import 'package:ouisync_app/app/controls/repo/repofooter.dart';
import 'package:ouisync_app/app/models/user/user.dart';

import 'itemtype.dart';

abstract class BaseItem {
  BaseItem(
      String id,
      DateTime creationDate,
      DateTime lastModificationDate,
      String name,
      String description,
      String path,
      double size,
      SyncStatus syncStatus,
      ItemType itemType, //folder, file, safe (?)
      IconData icon,
      User user
      ) {
    this.id = id;
    this.creationDate = creationDate;
    this.lastModificationDate = lastModificationDate;
    this.name = name;
    this.description = description;
    this.path = path;
    this.size = size;
    this.syncStatus = syncStatus;
    this.itemType = itemType; //folder, file, safe (?)
    this.icon = icon;
    this.user =user;
  }

  String id;
  DateTime creationDate;
  DateTime lastModificationDate;
  String name;
  String description;
  String path;
  double size;
  SyncStatus syncStatus;
  ItemType itemType; //folder, file, safe (?)
  IconData icon;
  User user;

  void updateModificationDate(DateTime modificationDate);
  void rename(String newName);
  void updateDescription(String newDescription);
  void move(String newPath);
  void setIcon(IconData icon);
  void setSyncStatus(SyncStatus status);
}