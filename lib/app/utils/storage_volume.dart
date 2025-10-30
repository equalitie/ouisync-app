import 'dart:io' show Platform;

import 'native.dart';

/// Information about a storage volume on the device.
class StorageVolume {
  const StorageVolume({
    required this.description,
    required this.mountPoint,
    required this.primary,
    required this.removable,
  });

  final String description;

  // This property is only supported on Android 30 or later. On older versions it's always `null`.
  final String? mountPoint;

  final bool primary;
  final bool removable;

  /// Retrieve storage volume that contains the given path.
  ///
  /// Note this currently works only on Android (returns `null` on other platforms).
  static Future<StorageVolume?> forPath(String path) => Platform.isAndroid
      ? Native.getStorageProperties(path).then(
          (props) => props != null
              ? StorageVolume(
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
      other is StorageVolume &&
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
