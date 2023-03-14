import 'package:equatable/equatable.dart';

abstract class BaseItem extends Equatable {
  const BaseItem(this.name, this.path);

  @override
  List<Object> get props => [
        name,
        path,
      ];

  final String name;
  final String path;
}

class FileItem extends BaseItem {
  const FileItem({
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
  const FolderItem({
    required String name,
    required String path,
  }) : super(name, path);
}
