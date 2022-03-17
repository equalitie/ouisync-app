import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'item_type.dart';

abstract class BaseItem extends Equatable {
  BaseItem(
      String name,
      String path,
      int size,
      ItemType itemType) {
    this.name = name;
    this.path = path;
    this.size = size;
    this.itemType = itemType;
  }

  @override
  List<Object> get props => [
    name,
    path,
    size,
    itemType,
  ];

  String name = '';
  String path = '';
  int size = 0;
  ItemType itemType = ItemType.folder;
  
  void rename(String newName);
  void move(String newPath);
}
