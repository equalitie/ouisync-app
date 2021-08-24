import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../controls/repo/repofooter.dart';
import 'itemtype.dart';

abstract class BaseItem extends Equatable {
  BaseItem(
      String name,
      String path,
      double size,
      SyncStatus syncStatus,
      ItemType itemType, //folder, file, safe (?)
      IconData icon,
      ) {
    this.name = name;
    this.path = path;
    this.size = size;
    this.syncStatus = syncStatus;
    this.itemType = itemType; //folder, file, safe (?)
    this.icon = icon;
  }

  @override
  List<Object> get props => [
    name,
    path,
    size,
    syncStatus,
    itemType, //folder, file, safe (?)
    icon
  ];

  String name = '';
  String path = '';
  double size = 0.0;
  SyncStatus syncStatus = SyncStatus.idle;
  ItemType itemType = ItemType.folder; //folder, file, safe (?)
  IconData icon = Icons.adb;
  
  void rename(String newName);
  void move(String newPath);
  void setIcon(IconData icon);
  void setSyncStatus(SyncStatus status);
}