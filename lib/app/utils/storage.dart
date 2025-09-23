import 'dart:io' show Platform;

import 'package:ouisync/ouisync.dart' show Session;

import 'native.dart';

class Storage {
  const Storage({
    required this.path,
    required this.description,
    required this.mountPoint,
    required this.primary,
    required this.removable,
  });

  final String path;
  final String description;
  final String mountPoint;
  final bool primary;
  final bool removable;

  static Future<Storage?> forPath(String path) => Platform.isAndroid
      ? Native.getStorageProperties(path).then(
          (props) => props != null
              ? Storage(
                  path: path,
                  description: props.description,
                  mountPoint: props.mountPoint,
                  primary: props.primary,
                  removable: props.removable,
                )
              : null,
        )
      : Future.value(null);

  static Future<List<Storage>> all(Session session) => session
      .getStoreDirs()
      .then((paths) => Future.wait(paths.map((path) => forPath(path))))
      .then((storages) => storages.nonNulls.toList());

  @override
  bool operator ==(Object other) =>
      other is Storage &&
      path == other.path &&
      description == other.description &&
      mountPoint == other.mountPoint &&
      primary == other.primary &&
      removable == other.removable;

  @override
  int get hashCode =>
      Object.hash(path, description, mountPoint, primary, removable);

  @override
  String toString() =>
      '$runtimeType(path: $path, description: $description, mountPoint: $mountPoint, primary: $primary, removable: $removable)';
}
