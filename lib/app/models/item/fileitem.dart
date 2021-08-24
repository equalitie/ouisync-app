import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../controls/controls.dart';
import '../models.dart';

class FileItem extends Equatable implements BaseItem {
  FileItem({
    this.name = '',
    this.extension = '',
    this.path = '',
    this.size = 0.0,
    this.syncStatus = SyncStatus.idle,
    this.itemType = ItemType.file,
    this.icon = Icons.insert_drive_file
  });

  @override
  List<Object> get props => [
    name,
    path,
    size,
    syncStatus,
    itemType,
    icon
  ];
  
  String extension;
  
  @override
  IconData icon;

  @override
  ItemType itemType;

  @override
  String name;

  @override
  String path;

  @override
  double size;

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
  void setSyncStatus(SyncStatus newSyncStatus) {
    this.syncStatus = newSyncStatus;
  }
}