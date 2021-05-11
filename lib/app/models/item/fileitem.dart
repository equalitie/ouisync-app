import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../controls/repo/repofooter.dart';
import '../user/user.dart';
import 'baseitem.dart';
import 'itemtype.dart';

class FileItem extends Equatable implements BaseItem {
  FileItem(
      id,
      name,
      extension,
      path,
      size,
      syncStatus,
      user,
      {
        description = "file",
        icon = Icons.insert_drive_file
      }) {
    this.id = id;
    this.creationDate = DateTime.now();
    this.lastModificationDate = DateTime.now();
    this.name = name;
    this.extension = extension;
    this.description = description;
    this.path = path;
    this.size = size;
    this.syncStatus = syncStatus;
    this.itemType = ItemType.file;
    this.icon = icon;
    this.user = user;
  }

  @override
  List<Object> get props => [
    id,
    creationDate,
    lastModificationDate,
    name,
    extension,
    description,
    path,
    size,
    syncStatus,
    itemType,
    icon,
    user
  ];
  
  @override
  DateTime creationDate;

  @override
  String description;

  String extension;
  
  @override
  IconData icon;

  @override
  String id;

  @override
  ItemType itemType;

  @override
  DateTime lastModificationDate;

  @override
  String name;

  @override
  String path;

  @override
  double size;

  @override
  SyncStatus syncStatus;

  @override
  User user;

  @override
  void move(String newPath) {
    this.path = newPath;
  }

  @override
  void rename(String newName) {
    this.name = newName;
  }

  @override
  void setIcon(IconData icon) {
    this.icon = icon;
  }

  @override
  void setSyncStatus(SyncStatus newSyncStatus) {
    this.syncStatus = newSyncStatus;
  }

  @override
  void updateDescription(String newDescription) {
    this.description = newDescription;
  }

  @override
  void updateModificationDate(DateTime modificationDate) {
    this.lastModificationDate = modificationDate;
  }
}