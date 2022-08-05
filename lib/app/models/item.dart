import 'package:equatable/equatable.dart';

enum ItemType {
  folder,
  file
}

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

class FileItem extends BaseItem implements Equatable {
  FileItem({
    required String name,
    required String path,
    required this.size,
  }) : super(name, path);

  int size;

  @override
  ItemType get type => ItemType.file;
}

class FolderItem extends BaseItem implements Equatable {
  FolderItem({
    required String name,
    required String path,
  }): super(name, path);

  @override
  ItemType get type => ItemType.folder;
}
