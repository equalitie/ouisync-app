import 'dart:io' show Platform;

import 'native.dart';

class Storage {
  const Storage({
    required this.description,
    required this.mountPoint,
    required this.primary,
    required this.removable,
  });

  final String description;
  final String mountPoint;
  final bool primary;
  final bool removable;

  static Future<Storage?> forPath(String path) => Platform.isAndroid
      ? Native.getStorageProperties(path).then(
          (props) => props != null
              ? Storage(
                  description: props.description,
                  mountPoint: props.mountPoint,
                  primary: props.primary,
                  removable: props.removable,
                )
              : null,
        )
      : Future.value(null);

  @override
  bool operator ==(Object other) =>
      other is Storage &&
      description == other.description &&
      mountPoint == other.mountPoint &&
      primary == other.primary &&
      removable == other.removable;

  @override
  int get hashCode => Object.hash(description, mountPoint, primary, removable);

  @override
  String toString() =>
      '$runtimeType(description: $description, mountPoint: $mountPoint, primary: $primary, removable: $removable)';
}
