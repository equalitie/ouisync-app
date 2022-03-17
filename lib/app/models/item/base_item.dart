import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'item_type.dart';

abstract class BaseItem extends Equatable {
  BaseItem(
      String name,
      String path,
      int size) {
    this.name = name;
    this.path = path;
    this.size = size;
  }

  @override
  List<Object> get props => [
    name,
    path,
    size,
  ];

  String name = '';
  String path = '';
  int size = 0;

  ItemType get type;
}
