import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models.dart';

class FolderItem extends Equatable implements BaseItem {
  FolderItem({
    this.name = '',
    this.path = '',
    this.size = 0,
  }) {}

  @override
  List<Object> get props => [
    name,
    path,
    size,
  ];

  @override
  String name;

  @override
  String path;

  @override
  int size;

  @override
  ItemType get type => ItemType.folder;
}
