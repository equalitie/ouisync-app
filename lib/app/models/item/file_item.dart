import 'package:equatable/equatable.dart';

import '../models.dart';

class FileItem extends Equatable implements BaseItem {
  FileItem({
    this.name = '',
    this.path = '',
    this.size = 0,
  });

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
  ItemType get type => ItemType.file;
}
