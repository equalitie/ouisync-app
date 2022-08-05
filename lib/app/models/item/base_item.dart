import 'package:equatable/equatable.dart';

import 'item_type.dart';

abstract class BaseItem extends Equatable {
  BaseItem(this.name, this.path);

  @override
  List<Object> get props => [
    name,
    path,
  ];

  String name;
  String path;

  ItemType get type;
}
