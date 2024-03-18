import 'package:equatable/equatable.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'repo_location.dart';

abstract class BaseItem extends Equatable {
  const BaseItem();

  @override
  List<Object> get props => [name, path, size ?? 0];

  String get name;
  String get path;
  int? get size;
}

class FileItem extends BaseItem {
  @override
  final String name;
  @override
  final String path;
  @override
  final int? size;

  const FileItem({
    required this.name,
    required this.path,
    required this.size,
  });
}

class FolderItem extends BaseItem {
  @override
  final String name;
  @override
  final String path;
  @override
  final int size = 0;

  const FolderItem({required this.name, required this.path});
}

class RepoItem extends BaseItem {
  const RepoItem(this.location,
      {required this.accessMode, required this.isDefault});

  final RepoLocation location;
  final AccessMode accessMode;
  final bool isDefault;

  @override
  String get name => location.name;
  @override
  String get path => location.path;
  @override
  int get size => 0;

  @override
  List<Object> get props => [location, accessMode];
}

class RepoMissingItem extends BaseItem {
  const RepoMissingItem(this.location, {required this.message});

  final RepoLocation location;
  final String message;

  @override
  String get name => location.name;
  @override
  String get path => location.path;
  @override
  int get size => 0;

  @override
  List<Object> get props => [location, message];
}
