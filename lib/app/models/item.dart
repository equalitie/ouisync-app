import 'package:equatable/equatable.dart';

abstract class BaseItem extends Equatable {
  BaseItem(this.name, this.path);

  @override
  List<Object> get props => [
        name,
        path,
      ];

  final String name;
  final String path;
}

class FileItem extends BaseItem {
  FileItem({
    required String name,
    required String path,
    required this.size,
  }) : super(name, path);

  final int size;

  @override
  List<Object> get props => [
        ...super.props,
        size,
      ];
}

class FolderItem extends BaseItem {
  FolderItem({
    required String name,
    required String path,
  }) : super(name, path);
}
