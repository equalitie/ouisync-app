import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models.dart';

class FileItem extends Equatable implements BaseItem {
  FileItem({
    this.name = '',
    this.extension = '',
    this.path = '',
    this.size = 0,
    this.itemType = ItemType.file,
  });

  @override
  List<Object> get props => [
    name,
    path,
    size,
    itemType,
  ];
  
  String extension;
  
  @override
  ItemType itemType;

  @override
  String name;

  @override
  String path;

  @override
  int size;

  @override
  void move(String newPath) {
    this.path = newPath;
  }

  @override
  void rename(String newName) {
    this.name = newName;
  }
}
