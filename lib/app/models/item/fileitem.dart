import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../controls/controls.dart';
import '../models.dart';

class FileItem extends Equatable implements BaseItem {
  FileItem({
    this.id = '',
    this.name = '',
    this.extension = '',
    this.path = '',
    this.size = 0.0,
    this.syncStatus = SyncStatus.idle,
    this.itemType = ItemType.file,
    this.user = const User(id: '', name: ''),
    this.description = "file",
    this.icon = Icons.insert_drive_file,
    required this.creationDate,
    required this.lastModificationDate
  }) {
    this.creationDate = DateTime.now();
    this.lastModificationDate = DateTime.now();
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