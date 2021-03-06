import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../controls/controls.dart';
import '../models.dart';


class FolderItem extends Equatable implements BaseItem {
  late List<BaseItem> items;

  FolderItem({
    this.id = '',
    this.name = '',
    this.path = '',
    this.size = 0.0,
    this.syncStatus = SyncStatus.idle,
    this.user = const User(id: '', name: ''),
    this.description = "folder",
    this.itemType = ItemType.folder,
    this.icon = Icons.folder,
    required this.creationDate,
    required this.lastModificationDate,
    required this.items,
  }) {
    this.creationDate = DateTime.now();
    this.lastModificationDate = DateTime.now();

    this.items = <BaseItem>[];
  }

  @override
  List<Object> get props => [
    id,
    creationDate,
    lastModificationDate,
    name,
    description,
    path,
    size,
    syncStatus,
    itemType,
    icon,
    user,
    items
  ];

  void addItem(BaseItem item) {
    items.add(item);
  }

  BaseItem getItem(String id) {
    return items.firstWhere((element) => element.id == id);
  }
  
  void removeItem(BaseItem item) {
    items.remove(item);
  }

  @override
  DateTime creationDate;

  @override
  String description;

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
  void setSyncStatus(SyncStatus status) {
    this.syncStatus = status;
  }

  @override
  void updateDescription(String newDescription) {
    this.description = description;
  }

  @override
  void updateModificationDate(DateTime modificationDate) {
    this.lastModificationDate = modificationDate;
  }

}