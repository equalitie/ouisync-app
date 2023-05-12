import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

abstract class BaseItem extends Equatable {
  const BaseItem(this.name, this.path, this.size);

  @override
  List<Object> get props => [name, path, size];

  final String name;
  final String path;
  final int size;
}

class FileItem extends BaseItem {
  const FileItem(
      {required String name, required String path, required int size})
      : super(name, path, size);

  @override
  List<Object> get props => [...super.props];
}

class FolderItem extends BaseItem {
  const FolderItem({required String name, required String path, int size = 0})
      : super(name, path, size);

  @override
  List<Object> get props => [...super.props];
}

class RepoItem extends BaseItem {
  const RepoItem(
      {required String name,
      required String path,
      required this.accessMode,
      required this.isDefault})
      : super(name, path, 0);

  final AccessMode accessMode;
  final bool isDefault;

  @override
  List<Object> get props => [...super.props, accessMode];
}

class RepoMissingItem extends BaseItem {
  const RepoMissingItem(
      {required String name, required String path, required this.message})
      : super(name, path, 0);

  final String message;

  @override
  List<Object> get props => [...super.props, message];
}
