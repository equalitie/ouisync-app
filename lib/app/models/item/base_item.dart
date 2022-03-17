import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'item_type.dart';

abstract class BaseItem extends Equatable {
  BaseItem(
      String name,
      String path,
      int size,
      ItemType itemType, //folder, file, safe (?)
      IconData icon,
      ) {
    this.name = name;
    this.path = path;
    this.size = size;
    this.itemType = itemType; //folder, file, safe (?)
    this.icon = icon;
  }

  @override
  List<Object> get props => [
    name,
    path,
    size,
    itemType, //folder, file, safe (?)
    icon
  ];

  String name = '';
  String path = '';
  int size = 0;
  ItemType itemType = ItemType.folder; //folder, file, safe (?)
  IconData icon = Icons.adb;
  
  void rename(String newName);
  void move(String newPath);
  void setIcon(IconData icon);
}
