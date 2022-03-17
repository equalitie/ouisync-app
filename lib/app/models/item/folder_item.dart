import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models.dart';


class FolderItem extends Equatable implements BaseItem {
  FolderItem({
    this.name = '',
    this.path = '',
    this.size = 0,
    this.syncStatus = SyncStatus.idle,
    this.itemType = ItemType.folder,
    this.icon = Icons.folder_outlined,
  }) {}

  @override
  List<Object> get props => [
    name,
    path,
    size,
    syncStatus,
    itemType,
    icon,
  ];

  @override
  IconData icon;

  @override
  ItemType itemType;

  @override
  String name;

  @override
  String path;

  @override
  int size;

  @override
  SyncStatus syncStatus;

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
  void setSyncStatus(SyncStatus status) {
    this.syncStatus = status;
  }

}
